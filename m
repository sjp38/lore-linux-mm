Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D15A56B0038
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:39:07 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r144so38749143wme.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 06:39:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v203si22604129wmb.51.2017.01.25.06.39.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 06:39:06 -0800 (PST)
Subject: Re: [ATTEND] many topics
References: <20170118054945.GD18349@bombadil.infradead.org>
 <20170118133243.GB7021@dhcp22.suse.cz>
 <20170119110513.GA22816@bombadil.infradead.org>
 <20170119113317.GO30786@dhcp22.suse.cz>
 <20170119115243.GB22816@bombadil.infradead.org>
 <20170119121135.GR30786@dhcp22.suse.cz>
 <878tq5ff0i.fsf@notabene.neil.brown.name>
 <20170121131644.zupuk44p5jyzu5c5@thunk.org>
 <87ziijem9e.fsf@notabene.neil.brown.name>
 <20170123060544.GA12833@bombadil.infradead.org>
 <20170123170924.ubx2honzxe7g34on@thunk.org>
 <87mvehd0ze.fsf@notabene.neil.brown.name>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <58357cf1-65fc-b637-de8e-6cf9c9d91882@suse.cz>
Date: Wed, 25 Jan 2017 15:36:15 +0100
MIME-Version: 1.0
In-Reply-To: <87mvehd0ze.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>, Theodore Ts'o <tytso@mit.edu>, Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 01/23/2017 08:34 PM, NeilBrown wrote:
> On Tue, Jan 24 2017, Theodore Ts'o wrote:
>
>> On Sun, Jan 22, 2017 at 10:05:44PM -0800, Matthew Wilcox wrote:
>>>
>>> I don't have a clear picture in my mind of when Java promotes objects
>>> from nursery to tenure
>>
>> It's typically on the order of minutes.   :-)
>>
>>> ... which is not too different from my lack of
>>> understanding of what the MM layer considers "temporary" :-)  Is it
>>> acceptable usage to allocate a SCSI command (guaranteed to be freed
>>> within 30 seconds) from the temporary area?  Or should it only be used
>>> for allocations where the thread of control is not going to sleep between
>>> allocation and freeing?
>>
>> What the mm folks have said is that it's to prevent fragmentation.  If
>> that's the optimization, whether or not you the process is allocating
>> the memory sleeps for a few hundred milliseconds, or even seconds, is
>> really in the noise compared with the average lifetime of an inode in
>> the inode cache, or a page in the page cache....
>>
>> Why do you think it matters whether or not we sleep?  I've not heard
>> any explanation for the assumption for why this might be important.
>
> Because "TEMPORARY" implies a limit to the amount of time, and sleeping
> is the thing that causes a process to take a large amount of time.  It
> seems like an obvious connection to me.

There's no simple connection to time, it depends on the larger picture - what's 
the state of the allocator and what other allocations/free's are happening 
around this one. Perhaps let me try to explain what the flag does and what 
benefits are expected.

GFP_TEMPORARY, compared to GFP_KERNEL, adds __GFP_RECLAIMABLE, which tries to 
place the allocation within MIGRATE_RECLAIMABLE pageblocks - GFP_KERNEL implies 
MIGRATE_UNMOVABLE pageblocks, and userspace allocations are typically 
MIGRATE_MOVABLE. The main goal of this "mobility grouping" is to prevent the 
unmovable pages spreading all over the memory, making it impossible to get 
larger blocks by defragmentation (compaction). Ideally we would have all these 
problematic pages fit neatly into the smallest possible number of pageblocks 
that can accomodate them. But we can't know in advance how many, and we don't 
know their lifetimes, so there are various heuristics for relabeling pageblocks 
between the 3 types as we exceed the existing ones.

Now GFP_TEMPORARY means we tell the allocator about the relatively shorter 
lifetime, so it places the allocation within the RECLAIMABLE pageblocks, which 
are also used for slab caches that have shrinkers. The expected benefit of this 
is that we potentially prevent growing the number of UNMOVABLE pageblocks 
(either directly by this allocation, or a subsequent GFP_KERNEL one, that would 
otherwise fit within the existing pageblocks). While the RECLAIMABLE pages also 
cannot be defragmented (at least currently, there are some proposals for the 
slab caches...), we can at least shrink them, so the negative impact on 
compaction is considered less severe in the longer term.

> Imagine I want to allocate a large contiguous region in the
> ZONE_MOVEABLE region.  I find a mostly free region, so I just need to
> move those last few pages.  If there is a limit on how long a process
> can sleep while holding an allocation from ZONE_MOVEABLE, then I know
> how long, at most, I need to wait before those pages become either free
> or movable.  If those processes can wait indefinitely, then I might have
> to wait indefinitely to get this large region.

Yeah so this is not relevant, because GFP_TEMPORARY does not make the allocation 
__GFP_MOVABLE, so it still is not allowed to end up within a ZONE_MOVABLE zone. 
Unfortunately the issue similar to that you mention does still exist due to 
uncontrolled pinning of the movable pages, which affects both ZONE_MOVABLE and 
CMA, but that's another story...

> "temporary" doesn't mean anything without a well defined time limit.
>
> But maybe I completely misunderstand.

HTH,
Vlastimil

> NeilBrown
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
