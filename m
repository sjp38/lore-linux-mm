Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2E9DC6B004D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:17:33 -0400 (EDT)
Message-ID: <4A560ED7.2070403@redhat.com>
Date: Thu, 09 Jul 2009 18:37:59 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: KSM: current madvise rollup
References: <Pine.LNX.4.64.0906291419440.5078@sister.anvils> <4A49E051.1080400@redhat.com> <Pine.LNX.4.64.0906301518370.967@sister.anvils> <4A4A5C56.5000109@redhat.com> <Pine.LNX.4.64.0907010057320.4255@sister.anvils> <4A4B317F.4050100@redhat.com> <Pine.LNX.4.64.0907082035400.10356@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0907082035400.10356@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Hi Izik,
>
> Sorry, I've not yet replied to your response of 1 July, nor shall I
> right now.  Instead, more urgent to send you my current KSM rollup,
> against 2.6.31-rc2, with which I'm now pretty happy - to the extent
> that I've put my signoff to it below.
>
> Though of course it's actually your and Andrea's and Chris's work,
> just played around with by me; I don't know what the order of
> signoffs should be in the end.
>
> What it mainly lacks is a Documentation file, and more statistics in
> sysfs: though we can already see how much is being merged, we don't
> see any comparison against how much isn't.
>
> But if you still like the patch below, let's advance to splitting
> it up and getting it into mmotm: I have some opinions on the splitup,
> I'll make some suggestions on that tomorrow.
>   

I like it very much, you really ~cleaned / optimized / made better 
interface~ it up i got to say, thanks you.
(Very high standard you have)

> You asked for a full diff against -rc2, but may want some explanation
> of differences from what I sent before.  The main changes are:-
>
> A reliable PageKsm(), not dependent on the nature of the vma it's in:
> it's like PageAnon, but with NULL anon_vma - needs a couple of slight
> adjustments outside ksm.c.
>   

Good change.

> Consequently, no reason to go on prohibiting KSM on private anonymous
> pages COWed from template file pages in file-backed vmas.
>   

Agree.

> Most of what get_user_pages did for us was unhelpful: now rely on
> find_vma and follow_page and handle_mm_fault directly, which allow
> us to check VM_MERGEABLE and PageKsm ourselves where needed.
>
> Which eliminates the separate is_present_pte checks, and spares us
> from wasting rmap_items on absent ptes.
>   

That is great, much better.
(I actually searched where you have exported follow_page and 
handle_mm_fault, and then realized that life are easier when you are not 
a modules anymore)

> Which then drew attention to the hyperactive allocation and freeing
> of tree_items, "slabinfo -AD" showing huge activity there, even when
> idling.  It's not much of a problem really, but might cause concern.
>
> And revealed that really those tree_items were a waste of space, can
> be packed within the rmap_items that pointed to them, while still
> keeping to the nice cache-friendly 64-byte or 32-byte rmap_item.
> (If another field needed later, can make rmap_list singly linked.)
>   

That change together with the "is_stable_tree" embedded inside the 
rmap_item address are my favorite changes.

> mremap move issue sorted, in simplest COW-breaking way.  My previous
> code to unmerge according to rmap_item->stable was racy/buggy for
> two reasons: ignore rmap_items there now, just scan the ptes.
>
> ksmd used to be running at higher priority: now nice 0.
>   


That is indeed logical change, maybe we can even punish it in another 5 
points in nice...

> Moved mm_slot hash functions together; made hash table smaller
> now it's used less frequently than it was in your design.
>
> More cleanup, making similar things more alike.
>   

Really quality work. (What i did was just walk from line 1 to the end of 
ksm.c with my eyes, I still want to apply the patch and play with it)

The only thing i was afraid is if the check inside the 
stable_tree_search is safe:

+			page2[0] = get_ksm_page(tree_rmap_item);
+			if (page2[0])
+				break;


But i convinced myself that it is safe due to the fact that the page is 
anonymous, so it wasnt be able to get remapped by the user (to try to 
corrupt the stable tree) without the page will get breaked.

So from my side I believe we can send it to mmotm I still want to run it 
on my machine and play with it, to add some bug_ons (just for my own 
testing) to see that everything
going well, but I couldn't find one objection to any of your changes. 
(And i did try hard to find at least one..., i thought maybe 
module_init() can be replaced with something different, but i then i saw 
it used in vmscan.c, so i gave up...)


What you want to do now? send it to mmotm or do you want to play with it 
more?


Big thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
