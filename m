Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0391F6B0038
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 13:19:14 -0400 (EDT)
Received: by obbop1 with SMTP id op1so129204739obb.2
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 10:19:13 -0700 (PDT)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id ds2si14761111oeb.55.2015.08.10.10.19.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 10:19:12 -0700 (PDT)
Message-ID: <55C8DD0A.2010307@roeck-us.net>
Date: Mon, 10 Aug 2015 10:19:06 -0700
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] percpu: Prevent endless loop if there is no unallocated
 region (unicore32 bug)
References: <1439122659-31442-1-git-send-email-linux@roeck-us.net> <20150810163638.GC23408@mtj.duckdns.org>
In-Reply-To: <20150810163638.GC23408@mtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>

On 08/10/2015 09:36 AM, Tejun Heo wrote:
> Hello,
>
> On Sun, Aug 09, 2015 at 05:17:39AM -0700, Guenter Roeck wrote:
>> Qemu tests with unicore32 show memory management code entering an endless
>> loop in pcpu_alloc(). Bisect points to commit a93ace487a33 ("percpu: move
>> region iterations out of pcpu_[de]populate_chunk()"). Code analysis
>> identifies the following relevant changes.
>>
>> -       rs = page_start;
>> -       pcpu_next_pop(chunk, &rs, &re, page_end);
>> -
>> -       if (rs != page_start || re != page_end) {
>> +       pcpu_for_each_unpop_region(chunk, rs, re, page_start, page_end) {
>>
>> For unicore32, values were page_start==0, page_end==1, rs==0, re==1.
>> This worked fine with the old code. With the new code, however, the loop
>> is always entered. Debugging information added into the loop shows
>> an endless repetition of
>>
>> in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
>> in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
>> in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
>> in loop chunk c5c53100 populated 0xff rs 1 re 2 page start 0 page end 1
>
> That's a bug in the find bit functions in unicore32.  If @offset >=
> @end, it should return @end, not @offset.
>

Yes, your are right, the find next functions in unicore32 are wrong.

Sorry for the noise - I should have checked more closely. Copying the maintainer.

Thanks,
Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
