Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDBC6B0253
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 05:06:24 -0400 (EDT)
Received: by wijq8 with SMTP id q8so71164836wij.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 02:06:23 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id a2si9246688wjb.203.2015.10.14.02.06.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 02:06:23 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so221500898wic.1
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 02:06:22 -0700 (PDT)
Subject: Re: Making per-cpu lists draining dependant on a flag
References: <56179E4F.5010507@kyup.com>
 <20151014083710.GF28333@dhcp22.suse.cz>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <561E1B0D.9050809@kyup.com>
Date: Wed, 14 Oct 2015 12:06:21 +0300
MIME-Version: 1.0
In-Reply-To: <20151014083710.GF28333@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de, Andrew Morton <akpm@linux-foundation.org>, Marian Marinov <mm@1h.com>, SiteGround Operations <operations@siteground.com>, Jan Kara <jack@suse.cz>



On 10/14/2015 11:37 AM, Michal Hocko wrote:
> On Fri 09-10-15 14:00:31, Nikolay Borisov wrote:
>> Hello mm people,
>>
>>
>> I want to ask you the following question which stemmed from analysing
>> and chasing this particular deadlock:
>> http://permalink.gmane.org/gmane.linux.kernel/2056730
> 
> This link doesn't seem to work properly for me. Could you post a
> http://lkml.kernel.org/r/$msg_id link please?
> 
>> To summarise it:
>>
>> For simplicity I will use the following nomenclature:
>> t1 - kworker/u96:0
>> t2 - kworker/u98:39
>> t3 - kworker/u98:7
>>
>> t1 issues drain_all_pages which generates IPI's, at the same time
>> however,
> 
> OK, as per
> http://lkml.kernel.org/r/1444318308-27560-1-git-send-email-kernel%40kyup.com
> drain_all_pages is called from the __alloc_pages_nodemask called from
> slab allocator. There is no stack leading to the allocation but then you
> are saying
> 
>> t2 has already started doing async write of pages
>> as part of its normal operation but is blocked upon t1 completion of
>> its IPI (generated from drain_all_pages) since they both work on the
>> same dm-thin volume.
> 
> which I read as the allocator is holding the same dm_bufio_lock, right?
> 
>> At the same time again, t3 is executing
>> ext4_finish_bio, which disables interrupts, yet is dependent on t2
>> completing its writes.
> 
> That would be a bug on its own because ext4_finish_bio seems to be
> called from SoftIRQ context so it cannot wait for a regular scheduling
> context. Whoever is holding that lock BH_Uptodate_Lock has to be in
> (soft)IRQ context.
> 
> <found the original thread on linux-mm finally - the threading got
> broken on the way>
> http://lkml.kernel.org/r/20151013131453.GA1332%40quack.suse.cz
> 
> So Jack (CCed) thinks this is a non-atomic update of flags and that
> indeed sounds plausible.
> 
>> But since it has disabled interrupts, it wont
>> respond to t1's IPI and at this point a hard lock up occurs. This
>> happens, since drain_all_pages calls on_each_cpu_mask with the last
>> argument equal to  "true" meaning "wait until the ipi handler has
>> finished", which of course will never happen in the described situation.
>>
>> Based on that I was wondering whether avoiding such situation might
>> merit making drain_all_pages invocation from
>> __alloc_pages_direct_reclaim dependent on a particular GFP being passed
>> e.g. GFP_NOPCPDRAIN or something along those lines?
> 
> I do not think so. Even if the dependency was real it would be a clear
> deadlock even without drain_all_pages AFAICS.
> 
>> Alternatively would it be possible to make the IPI asycnrhonous e.g.
>> calling on_each_cpu_mask with the last argument equal to false?
> 
> Strictly speaking the allocation path doesn't really depend on the sync
> behavior. We are just trying to release pages on pcp lists and retry the
> allocation. Even if the allocation context was faster than other CPUs
> and fail the request then we would try again without triggering the OOM
> because the reclaim has apparently made some progress.
> 
> Other callers might be more sensitive. Anyway this is called only if the
> allocator issues a sleeping allocation request so I think that waiting
> here is perfectly acceptable.

Thanks for taking the time to look over the issue. Indeed, I guess I
have been misled as to who the real culprit is, though the call traces
seemed to make the issue apparent. But kernel land seems to be a lot
more subtle :)

In any case I will test with Jack's patch and hopefully report that
everything is okay.

Nikolay

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
