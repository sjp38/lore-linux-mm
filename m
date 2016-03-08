Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 304276B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 19:33:06 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id y89so111284812qge.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 16:33:06 -0800 (PST)
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com. [209.85.220.171])
        by mx.google.com with ESMTPS id o34si278653qge.94.2016.03.07.16.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 16:33:05 -0800 (PST)
Received: by mail-qk0-f171.google.com with SMTP id o6so54032323qkc.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 16:33:05 -0800 (PST)
Subject: Re: [PATCHv4 2/2] mm/page_poisoning.c: Allow for zero poisoning
References: <1457135448-15541-1-git-send-email-labbott@fedoraproject.org>
 <1457135448-15541-3-git-send-email-labbott@fedoraproject.org>
 <20160304160751.05931d89f451626b58073489@linux-foundation.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56DE1DBC.5050403@redhat.com>
Date: Mon, 7 Mar 2016 16:33:00 -0800
MIME-Version: 1.0
In-Reply-To: <20160304160751.05931d89f451626b58073489@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <labbott@fedoraproject.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 03/04/2016 04:07 PM, Andrew Morton wrote:
> On Fri,  4 Mar 2016 15:50:48 -0800 Laura Abbott <labbott@fedoraproject.org> wrote:
>
>>
>> By default, page poisoning uses a poison value (0xaa) on free. If this
>> is changed to 0, the page is not only sanitized but zeroing on alloc
>> with __GFP_ZERO can be skipped as well. The tradeoff is that detecting
>> corruption from the poisoning is harder to detect. This feature also
>> cannot be used with hibernation since pages are not guaranteed to be
>> zeroed after hibernation.
>>
>> Credit to Grsecurity/PaX team for inspiring this work
>>
>> --- a/kernel/power/hibernate.c
>> +++ b/kernel/power/hibernate.c
>> @@ -1158,6 +1158,22 @@ static int __init kaslr_nohibernate_setup(char *str)
>>   	return nohibernate_setup(str);
>>   }
>>
>> +static int __init page_poison_nohibernate_setup(char *str)
>> +{
>> +#ifdef CONFIG_PAGE_POISONING_ZERO
>> +	/*
>> +	 * The zeroing option for page poison skips the checks on alloc.
>> +	 * since hibernation doesn't save free pages there's no way to
>> +	 * guarantee the pages will still be zeroed.
>> +	 */
>> +	if (!strcmp(str, "on")) {
>> +		pr_info("Disabling hibernation due to page poisoning\n");
>> +		return nohibernate_setup(str);
>> +	}
>> +#endif
>> +	return 1;
>> +}
>
> It seems a bit unfriendly to silently accept the boot option but not
> actually do anything with it.  Perhaps a `#else pr_info("sorry")' is
> needed.
>
> But I bet we made the same mistake in 1000 other places.
>
> What happens if page_poison_nohibernate_setup() simply doesn't exist
> when CONFIG_PAGE_POISONING_ZERO=n?  It looks like
> kernel/params.c:parse_args() says "Unknown parameter".
>
>

I didn't see that behavior when I tested, even with nonsense parameters.
It looks like it might fall back to some other behavior before giving
-ENOENT?

It's also worth noting the page_poison= option is also parsed in
mm/page_poison.c to do other on/off of the poisoning feature. The
option code supported it and it seemed to match better with what the
existing hibernate code was doing with turning off options.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
