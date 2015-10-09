Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 5F32E6B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 04:03:34 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so55974382wic.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 01:03:33 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id r8si16964335wiw.74.2015.10.09.01.03.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 01:03:33 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so59294690wic.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 01:03:33 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] ext4: Fix possible deadlock with local interrupts
 disabled and page-draining IPI
References: <062501d10262$d40d0a50$7c271ef0$@alibaba-inc.com>
 <56176C10.8040709@kyup.com> <062801d10265$5a749fc0$0f5ddf40$@alibaba-inc.com>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <561774D2.3050002@kyup.com>
Date: Fri, 9 Oct 2015 11:03:30 +0300
MIME-Version: 1.0
In-Reply-To: <062801d10265$5a749fc0$0f5ddf40$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, linux-fsdevel@vger.kernel.org, SiteGround Operations <operations@siteground.com>, vbabka@suse.cz, gilad@benyossef.com, mgorman@suse.de, linux-mm@kvack.org, Marian Marinov <mm@1h.com>

On 10/09/2015 10:37 AM, Hillf Danton wrote:
>>>> @@ -109,8 +109,8 @@ static void ext4_finish_bio(struct bio *bio)
>>>>  			if (bio->bi_error)
>>>>  				buffer_io_error(bh);
>>>>  		} while ((bh = bh->b_this_page) != head);
>>>> -		bit_spin_unlock(BH_Uptodate_Lock, &head->b_state);
>>>>  		local_irq_restore(flags);
>>>
>>> What if it takes 100ms to unlock after IRQ restored?
>>
>> I'm not sure I understand in what direction you are going? Care to
>> elaborate?
>>
> Your change introduces extra time cost the lock waiter has to pay in
> the case that irq happens before the lock is released.

[CC filesystem and mm people. For reference the thread starts here:
 http://thread.gmane.org/gmane.linux.kernel/2056996 ]

Right, I see what you mean and it's a good point but when doing the
patches I was striving for correctness and starting a discussion, hence
the RFC. In any case I'd personally choose correctness over performance
always ;).

As I'm not an fs/ext4 expert and have added the relevant parties (please
use reply-all from now on so that the thread is not being cut in the
middle) who will be able to say whether it impact is going to be that
big. I guess in this particular code path worrying about this is prudent
as writeback sounds like a heavily used path.

Maybe the problem should be approached from a different angle e.g.
drain_all_pages and its reliance on the fact that the IPI will always be
delivered in some finite amount of time? But what if a cpu with disabled
interrupts is waiting on the task issuing the IPI?

> 
>>>> +		bit_spin_unlock(BH_Uptodate_Lock, &head->b_state);
>>>>  		if (!under_io) {
>>>>  #ifdef CONFIG_EXT4_FS_ENCRYPTION
>>>>  			if (ctx)
>>>> --
>>>> 2.5.0
>>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
