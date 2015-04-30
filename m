Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 37D496B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 02:07:52 -0400 (EDT)
Received: by iejt8 with SMTP id t8so59746585iej.2
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 23:07:52 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id aq7si1341093icc.21.2015.04.29.23.07.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 23:07:51 -0700 (PDT)
Message-ID: <5541C6AD.8080906@codeaurora.org>
Date: Thu, 30 Apr 2015 11:37:41 +0530
From: Susheel Khiani <skhiani@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [Question] ksm: rmap_item pointing to some stale vmas
References: <55268741.8010301@codeaurora.org> <alpine.LSU.2.11.1504101047200.28925@eggly.anvils> <552CBB49.5000308@codeaurora.org> <alpine.LSU.2.11.1504142155010.11693@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1504142155010.11693@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: akpm@linux-foundation.org, peterz@infradead.org, neilb@suse.de, dhowells@redhat.com, paulmcquad@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 04/15/15 11:52, Hugh Dickins wrote:
>> We are using kernel-3.10.49 and I have gone through patches of ksm above this
>> >kernel version but didn't find anything relevant w.r.t issue. The latest
>> >patch which we have for KSM on our tree is
>> >
>> >668f9abb: mm: close PageTail race
> I agree, I don't think 3.10.49 would be missing any relevant fix -
> unless there's a later fix to some "random" corruption which happens
> to hit you here in KSM.
>
> I wonder how you identified that this issue of un-unmappable pages
> is peculiar to KSM.  Have you established that ordinary anon pages
> (we need not worry about file pages here) are always successfully
> unmappable?  KSM is reliant upon anon_vmas working as intended
> (but then makes use of them in its own peculiar way).
>


We identified issue in try_to_unmap_ksm as part of debugging CMA 
allocation failures. During alloc_contig_range we do migrate_pages, 
where we were failing to migrate a specific page even after all the 
retries which we make in migrate_pages function. Digging deeper we were 
able to conclude that we were failing in try_to_unmap_ksm where we 
failed to find valid ptes.


>> >
>> >The issue otherwise is difficult to reproduce and is appearing after days of
>> >testing on 512MB Android platform. What I am not able to figure out is which
>> >code path in ksm could actually land us in situation where in stable_node we
>> >still have stale rmap_items with old vmas which are now unmapped.
> Whether that's something to worry about depends on what you mean.
>
> It's normal for a stable_node to have some stale rmap_items attached,
> now pointing to pages different from the stable page, or pointing to none.
> That's in the nature of KSM, the way ksmd builds up its structures by
> peeking at what's in each mm, moving on, and coming back a cycle later
> to discover what's changed.
>
> But the anon_vma which such a stale rmap_item points to should remain
> valid (KSM holds an additional reference to it), even if its interval
> tree is now empty, or none of the vmas that it holds now cover this
> mm,address (but any vmas held should still be valid vmas).
>
> I was concerned, not that the stable_node has stale rmap_items attached,
> but that you know the page to be mapped, yet try_to_unmap_ksm is unable
> to locate its mappings.
>
>> >
>> >In the dumps we can see the new vmas mapping to the page but the new
>> >rmap_items with these new vmas which maps the page are still not updated in
>> >stable_node.
> "still not updated" after how long?
> I assume you to mean that, how ever long you wait (but at least
> one full scan), the stable_node is not updated with an rmap_item
> pointing to an anon_vma whose interval tree contains one of these
> new vmas which maps the page?


I have not yet concluded if we are waiting for one full scan or not. 
Since I was debugging this w.r.t CMA allocation failure by saying "still 
not updated" , I meant that even after all the number of retries which 
we make in CMA allocation path to migrate pages, the stable_node was not 
updated with rmap_item. But now I understand that we need to wait for at 
least one full ksm scan to see the update.


>
> (When setting up a new stable node, it will take several scans to
> establish, and can be delayed by various races, such as shifts in
> the unstable tree, and the trylock_page in try_to_merge_one_page.
> But I think that once you can see a stable ksm page mapped somewhere,
> all pointers to it should be captured within a single scan.)


I am actually thinking the reason for my issue could be that we might 
have not waited sufficient time to ensure that ksm scan ran once. The 
reason for this is I was able to track down mm_slot structure which we 
create in __ksm_enter and it contained mm_struct which had vma where our 
page is mapped. But rmap_list of this mm_slot was still NULL which I 
guess would get populate once ksm_do_scan runs.


>
> That's bad, but I have no idea of the cause.  I mention corruption
> above, because that would be one possibility; though unlikely if
> it always hits you here in KSM only.


Yes, even we have ruled out corruption since now we have seen multiple 
instances with similar symptoms.


>
> Whereas if you mean that a new mapping of the stable page may not
> be unmapped until ksmd has completed a full scan, that is also
> wrong, but not so serious.  Or would even that be a serious issue
> for you?  Please describe how this comes to be a problem for you.


Right now I don't have enough data points to claim that new mapping of 
the stable page may not be unmapped until ksmd has completed a full 
scan. But I am debugging in this direction and would get back once I 
have sufficient data.


>
> I believe I have found two bugs that would explain the latter case;
> but both of them require fork, and legend has it that Android avoids
> fork (correct me if wrong); so I doubt they're responsible for your
> case, and expect both to be corrected within one full scan.
>
> The lesser of the bugs is this: KSM reclaim (dependent on anon_vmas)
> was introduced in 2.6.33, but then anon_vma_chains were introduced
> in 2.6.34, and I suspect that the conversion ought to have updated
> try_to_merge_with_ksm_page, to take rmap_item->anon_vma from page
> instead of from vma.  I believe that some fork-connected mappings
> may be missed for a scan because of that.
>
> But fixing it doesn't help much: because the greater bug (mine) is
> that the search_new_forks code is not working as well as intended.
> It relies on using one rmap_item's anon_vma to locate the page in
> newer mappings forked from it, before ksmd reaches them to create
> their own rmap_items; but we're doing nothing to prevent that
> earlier rmap_item from being removed too soon.
>
> I would much rather be sending a patch, than trying to describe
> this so obscurely; but I have not succeeded and time has run out.
>
> I got far enough, I think, to confirm that this happens for me,
> and can be fixed by delaying the removal of such rmap_items.
> But I did not get far enough to stop them from leaking wildly;
> and although I've searched for quick and easy ways to do it,
> have come to the conclusion that fixing it safely without leaks
> will require more time and care than I can afford at present.
>
> (And even with those fixed, there would still be rare cases when
> a new mapping could not immediately be unmapped: for example,
> replace_page increments kpage's mapcount, but a racing
> try_to_unmap_ksm may hold kpage's page lock, preventing the
> relevant rmap_item from being appended to the stable tree.)
>
> I do hate to put down half-finished work, and would have liked
> to send you a patch, even if only to confirm that my problem
> is actually not your problem.  But I now see no alternative to
> merely informing you of this, and wishing you luck in your own
> investigation: I'm sorry, I just don't know.
>
> But if I've misunderstood, and you think that what you're seeing
> fits with the transient forking bugs I've (not quite) described,
> and you can explain why even the transient case is important for
> you to have fixed, then I really ought to redouble my efforts.
>
> Hugh


-- 
Susheel Khiani QUALCOMM INDIA, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
