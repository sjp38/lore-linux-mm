Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0CC6B0038
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 11:00:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z25so11698634pgu.18
        for <linux-mm@kvack.org>; Mon, 04 Dec 2017 08:00:36 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0088.outbound.protection.outlook.com. [104.47.42.88])
        by mx.google.com with ESMTPS id u66si10450798pfa.237.2017.12.04.08.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Dec 2017 08:00:35 -0800 (PST)
Subject: Re: [PATCH] x86/mm: Rewrite sme_populate_pgd() in a more sensible way
References: <20171204112323.47019-1-kirill.shutemov@linux.intel.com>
 <d177df77-cdc7-1507-08f8-fcdb3b443709@amd.com>
 <20171204145755.6xu2w6a6og56rq5v@node.shutemov.name>
From: Tom Lendacky <thomas.lendacky@amd.com>
Message-ID: <d9701b1c-1abf-5fc1-80b0-47ab4e517681@amd.com>
Date: Mon, 4 Dec 2017 10:00:26 -0600
MIME-Version: 1.0
In-Reply-To: <20171204145755.6xu2w6a6og56rq5v@node.shutemov.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Borislav Petkov <bp@suse.de>, Brijesh Singh <brijesh.singh@amd.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/4/2017 8:57 AM, Kirill A. Shutemov wrote:
> On Mon, Dec 04, 2017 at 08:19:11AM -0600, Tom Lendacky wrote:
>> On 12/4/2017 5:23 AM, Kirill A. Shutemov wrote:
>>> sme_populate_pgd() open-codes a lot of things that are not needed to be
>>> open-coded.
>>>
>>> Let's rewrite it in a more stream-lined way.
>>>
>>> This would also buy us boot-time switching between support between
>>> paging modes, when rest of the pieces will be upstream.
>>
>> Hi Kirill,
>>
>> Unfortunately, some of these can't be changed.  The use of p4d_offset(),
>> pud_offset(), etc., use non-identity mapped virtual addresses which cause
>> failures at this point of the boot process.
> 
> Wat? Virtual address is virtual address. p?d_offset() doesn't care about
> what mapping you're using.

Yes it does.  For example, pmd_offset() issues a pud_page_addr() call,
which does a __va() returning a non-identity mapped address (0xffff88...). 
  Only identity mapped virtual addresses have been setup at this point, so
the use of that virtual address panics the kernel.

Thanks,
Tom

> 
>> Also, calls such as __p4d(), __pud(), etc., are part of the paravirt
>> support and can't be used yet, either.
> 
> Yeah, I missed this. native_make_p?d() has to be used instead.
> 
>> I can take a closer look at some of the others (p*d_none() and
>> p*d_large()) which make use of the native_ macros, but my worry would be
>> that these get changed in the future to the non-native calls and then
>> boot failures occur.
> 
> If you want to avoid paravirt altogher for whole compilation unit, one
> more option would be to put #undef CONFIG_PARAVIRT before all includes.
> That's hack, but it works. We already use this in arch/x86/boot/compressed
> code.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
