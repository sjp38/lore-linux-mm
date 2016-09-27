Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A5BA528026B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 04:44:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w84so60865wmg.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 01:44:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fk9si1271452wjc.41.2016.09.27.01.44.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 01:44:06 -0700 (PDT)
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
References: <20160922152831.24165-1-vbabka@suse.cz>
 <006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
 <20160923172434.7ad8f2e0@roar.ozlabs.ibm.com> <57E55CBB.5060309@akamai.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
Date: Tue, 27 Sep 2016 10:44:04 +0200
MIME-Version: 1.0
In-Reply-To: <57E55CBB.5060309@akamai.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@akamai.com>, Nicholas Piggin <npiggin@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'Alexander Viro' <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, 'Michal Hocko' <mhocko@kernel.org>, netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>

On 09/23/2016 06:47 PM, Jason Baron wrote:
> Hi,
>
> On 09/23/2016 03:24 AM, Nicholas Piggin wrote:
>> On Fri, 23 Sep 2016 14:42:53 +0800
>> "Hillf Danton" <hillf.zj@alibaba-inc.com> wrote:
>>
>>>>
>>>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
>>>> with the number of fds passed. We had a customer report page allocation
>>>> failures of order-4 for this allocation. This is a costly order, so it might
>>>> easily fail, as the VM expects such allocation to have a lower-order fallback.
>>>>
>>>> Such trivial fallback is vmalloc(), as the memory doesn't have to be
>>>> physically contiguous. Also the allocation is temporary for the duration of the
>>>> syscall, so it's unlikely to stress vmalloc too much.
>>>>
>>>> Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
>>>> it doesn't need this kind of fallback.
>>
>> How about something like this? (untested)

This pushes the limit further, but might just delay the problem. Could be an 
optimization on top if there's enough interest, though.

[...]

>> +
>> +		if (!(fds.in && fds.out && fds.ex &&
>> +				fds.res_in && fds.res_out && fds.res_ex))
>> +			goto out;
>> +	} else {
>> +		if (nr_bytes > sizeof(stack_fds)) {
>> +			/* Not enough space in on-stack array */
>> +			if (nr_bytes > PAGE_SIZE * 2)
>
> The 'if' looks extraneous?
>
> Also, I wonder if we can just avoid some allocations altogether by
> checking by if the user fd_set pointers are NULL? That can avoid failures :)

That would be a more major rewrite, as the core algorithm doesn't expect NULLs.

> Thanks,
>
> -Jason
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
