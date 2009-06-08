Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 088AD6B0055
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 11:07:35 -0400 (EDT)
Date: Mon, 8 Jun 2009 17:18:57 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 0/4] RFC - ksm api change into madvise
In-Reply-To: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
Message-ID: <Pine.LNX.4.64.0906081555360.22943@sister.anvils>
References: <1242261048-4487-1-git-send-email-ieidus@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, chrisw@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 May 2009, Izik Eidus wrote:

> This is comment request for ksm api changes.
> The following patchs move the api to use madvise instead of ioctls.

Thanks a lot for doing this.

I'm afraid more than three weeks have gone past, and the 2.6.31
merge window is almost upon us, and you haven't even got a comment
out of me: I apologize for that.

Although my (lack of) response is indistinguishable from a conspiracy
to keep KSM out of the kernel, I beg to assure you that's not the case.
I do want KSM to go in - though I never shared Andrew's optimism that it
is 2.6.31 material: I've too long a list of notes/doubts on the existing
implementation, which I've not had time to expand upon to you; but I
don't think there are any killer issues, we should be able to work
things out as 2.6.31 goes through its -rcs, and aim for 2.6.32.

But let's get this change of interface sorted out first.

I remain convinced that it's right to go the madvise() route,
though I don't necessarily like the details in your patches.
And I've come to the conclusion that the only way I can force
myself to contribute constructively, is to start from these
patches, and shift things around until it's as I think it
should be, then see what you think of the result.

I notice that you chose to integrate fully (though not fully enough)
with vmas, adding a VM_MERGEABLE flag.  Fine, that's probably going
to be safest in the end, and I'll follow you; but it is further than
I was necessarily asking you to go - it might have been okay to use
the madvise() interface, but just to declare areas of address space
(not necessarily backed by mappings) to ksm.c, as you did via /dev/ksm.
But it's fairly likely that if you had stayed with that, it would have
proved problematic later, so let's go forward with the full integration
with vmas.

> 
> Before i will describe the patchs, i want to note that i rewrote this
> patch seires alot of times, all the other methods that i have tried had some
> fandumatel issues with them.
> The current implemantion does have some issues with it, but i belive they are
> all solveable and better than the other ways to do it.
> If you feel you have better way how to do it, please tell me :).
> 
> Ok when we changed ksm to use madvise instead of ioctls we wanted to keep
> the following rules:
> 
> Not to increase the host memory usage if ksm is not being used (even when it
> is compiled), this mean not to add fields into mm_struct / vm_area_struct...
> 
> Not to effect the system performence with notifiers that will have to block
> while ksm code is running under some lock - ksm is helper, it should do it
> work quitely, - this why i dropped patch that i did that add mmu notifiers
> support inside ksm.c and recived notifications from the MM (for example
> when vma is destroyed (invalidate_range...)
> 
> Not to change the MM logic.
> 
> Trying to touch as less code as we can outisde ksm.c

These are well-intentioned goals, and thank you for making the effort
to follow them; but I'm probably going to depart from them.  I'd
rather we put in what's necessary and appropriate, and then cut
that down if necessary.

> 
> Taking into account all this rules, the end result that we have came with is:
> mmlist is now not used only by swapoff, but by ksm as well, this mean that
> each time you call to madvise for to set vma as MERGEABLE, madvise will check
> if the mm_struct is inside the mmlist and will insert it in case it isnt.
> It is belived that it is better to hurt little bit the performence of swapoff
> than adding another list into the mm_struct.

That was a perfectly sensible thing for you to do, given your rules
above; but I don't really like the result, and think it'll be clearer
to have your own list.  Whether by mm or by vma, I've not yet decided:
by mm won't add enough #idef CONFIG_KSM bloat to worry about; by vma,
we might be able to reuse some prio_tree fields, I've not checked yet.

> 
> One issue that should be note is: after mm_struct is going into the mmlist, it
> wont be kicked from it until the procsses is die (even if there are no more
> VM_MERGEABLE vmas), this doesnt mean memory is wasted, but it does mean ksm
> will spend little more time in doing cur = cur->next if(...).
> 
> Another issue is: when procsess is die, ksm will have to find (when scanning)
> that its mm_users == 1 and then do mmput(), this mean that there might be dealy
> from the time that someone do kill until the mm is really free -
> i am open for suggestions on how to improve this...

You've resisted putting in the callbacks you need.  I think they were
always (i.e. even when using /dev/ksm) necessary, but should become
more obvious now we have this tighter integration with mm's vmas.

You seem to have no callback in fork: doesn't that mean that KSM
pages get into mms of which mm/ksm.c has no knowledge?  You had
no callback in mremap move: doesn't that mean that KSM pages could
be moved into areas which mm/ksm.c never tracked?  Though that's
probably no issue now we move over to vmas: they should now travel
with their VM flag.  You have no callback in unmap: doesn't that
mean that KSM never knows when its pages have gone away?

(Closing the /dev/ksm fd used to clean up some of this, in the
end; but the lifetime of the fd can be so different from that of
the mapped area, I've felt very unsafe with that technique - a good
technique when you're trying to sneak in special handling for your
special driver, but not a good technique once you go to mainline.)

I haven't worked out the full consequences of these lost pages:
perhaps it's no worse than that you could never properly enforce
your ksm_thread_max_kernel_pages quota.

> 
> (when someone do echo 0 > /sys/kernel/mm/ksm/run ksm will throw away all the
> memory, so condtion when the memory wont ever be free wont happen)
> 
> 
> Another important thing is: this is request for comment, i still not sure few
> things that we have made here are totaly safe:
> (the mmlist sync with drain_mmlist, and the handle_vmas() function in madvise,
> the logic inside ksm for searching the next virtual address on the vmas,
> and so on...)
> The main purpuse of this is to ask if the new interface is what you guys
> want..., and if you like the impelmantion desgin.

It's in the right direction.  But it would be silly for me to start
criticizing your details now: I need to try doing the same, that will
force me to think deeply enough about it, and I may then be led to
the same decisions as you made.

> 
> (I have added option to scan closed support applications as well)

That's a nice detail that I'll find very useful for testing,
but we might want to hold it back longer than the rest.  I just get
naturally more cautious when we consider interfaces for doing things
to other processes, and want to spend even longer over it.

> 
> 
> Thanks.
> 
> Izik Eidus (4):
>   madvice: add MADV_SHAREABLE and MADV_UNSHAREABLE calls.

I didn't understand why you went over to VM_MERGEABLE but stuck
with MADV_SHAREABLE: there's a confusing mix of shareables and
mergeables, I'll head for mergeables throughout, though keep to "KSM".

>   mmlist: share mmlist with ksm.
>   ksm: change ksm api to use madvise instead of ioctls.
>   ksm: add support for scanning procsses that were not modifided to use
>     ksm

While I'm being communicative, let me mention two things,
not related to this RFC patchset, but to what's currently in mmotm.

I've a bugfix patch to scan_get_next_index(), I'll send that to you
in a few moments.

And a question on your page_wrprotect() addition to mm/rmap.c: though
it may contain some important checks (I'm thinking of the get_user_pages
protection), isn't it essentially redundant, and should be removed from
the patchset?  If we have a private page which is mapped into more than
the one address space by which we arrive at it, then, quite independent
of KSM, it needs to be write-protected already to prevent mods in one
address space leaking into another - doesn't it?  So I see no need for
the rmap'ped write-protection there, just make the checks and write
protect the pte you have in ksm.c.  Or am I missing something?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
