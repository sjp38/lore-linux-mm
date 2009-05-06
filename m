Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A4F0B6B00A1
	for <linux-mm@kvack.org>; Wed,  6 May 2009 10:45:19 -0400 (EDT)
Date: Wed, 6 May 2009 16:45:58 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/6] ksm: change the KSM_REMOVE_MEMORY_REGION ioctl.
Message-ID: <20090506144558.GZ16078@random.random>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com> <1241475935-21162-2-git-send-email-ieidus@redhat.com> <1241475935-21162-3-git-send-email-ieidus@redhat.com> <1241475935-21162-4-git-send-email-ieidus@redhat.com> <4A00DF9B.1080501@redhat.com> <4A014C7B.9080702@redhat.com> <Pine.LNX.4.64.0905061110470.3519@blonde.anvils> <20090506133434.GX16078@random.random> <Pine.LNX.4.64.0905061453320.21067@blonde.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0905061453320.21067@blonde.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Izik Eidus <ieidus@redhat.com>, Rik van Riel <riel@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, alan@lxorguk.ukuu.org.uk, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Wed, May 06, 2009 at 03:25:25PM +0100, Hugh Dickins wrote:
> And in the interim, insist on capable(CAP_IPC_LOCK)?
> If that's okay for KVM's usage, that's fine by me for now.

KVM has been in the kernel for years without being able to swap
reliably (if any spte mapped any anon page) and yet it didn't require
capable(CAP_IPC_LOCK).

Sure if we were to use the madvise syscall we'd be forced to make it
fail with -EPERM without capable(CAP_IPC_LOCK) but with the /dev/ksm
permissions I don't see big deal, it's definitely not worth requiring
userland changes given we'll make the ksm pages swappable later.

> Whether not having privilege means it should fail or silently ignore
> the advice it's been given, I'm not sure: fail appears more helpful, but

Fail surely is more helpful. The app is free to ignore the failure of
course! But there's no reason to forbid the app to know about it. Not
checking the 'rax' value when 'call' returns is good and fast enough.

> silently ignore may fit better with whether module has been loaded yet
> (we can keep a list of what's registered, for when module is loaded).

NOTE: it will not fail if the module isn't loaded yet. It must
succeed! Otherwise it would also need to fail after it succeeded if we
unload the module later...

> You're right to be concerned about the malicious, but I was thinking
> rather of apps just wanting to say they may contain a goodly number
> of duplicate pages, and wanting to register themselves for merging,
> no malice intended.

NOTE: it's not big deal if all users can register, admin still can
kill them and kksmd reschedule fine and it won't ever be noticeable. I
just think it's nicer if you don't give /dev/ksm to the whole world in
a system where you only use KSM for the KVM virtual machines and you
have lusers in the same system doing other stuff in the host. But
perhaps you're right and it's not worth ever returning -EPERM.

> If only for my hacked-up testing, I'm interested in having a workable
> system on which every process has opted the whole of its address space
> into this merging: never be optimal, but I'd like workable.

That's doable sure.

> And please don't think of non-KVM users of KSM as malicious lusers!

Sure not as we've provided feedback on non-KVM users too. Like I
already mentioned in previous email in scientific environments where
there's no malicious luser, ksm should be chowned 777 and given to
everyone.

> Is that in updates yet to come?  I see things like
> 	for (pages_count = 0; pages_count < slot->npages; ++pages_count)
> and
> 		ksm_scan->page_index++;
> which will, of course, eventually get across any hole and move into
> vma->vm_next, but take vastly longer to do so than necessary.

Update is yet to come, but this isn't relevant for the API.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
