Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id A862D6B002B
	for <linux-mm@kvack.org>; Sun, 16 Dec 2012 12:04:06 -0500 (EST)
Date: Sun, 16 Dec 2012 17:04:03 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] mm: Downgrade mmap_sem before locking or populating on
 mmap
Message-ID: <20121216170403.GC4939@ZenIV.linux.org.uk>
References: <3b624af48f4ba4affd78466b73b6afe0e2f66549.1355463438.git.luto@amacapital.net>
 <20121214072755.GR4939@ZenIV.linux.org.uk>
 <CALCETrVw9Pc1sUZBL=wtLvsnBnkW5LAO5iu-i=T2oMOdwQfjHg@mail.gmail.com>
 <20121214144927.GS4939@ZenIV.linux.org.uk>
 <CALCETrUS7baKF7cdbrqX-o2qdeo1Uk=7Z4MHcxHMA3Luh+Obdw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUS7baKF7cdbrqX-o2qdeo1Uk=7Z4MHcxHMA3Luh+Obdw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, J??rn Engel <joern@logfs.org>

On Fri, Dec 14, 2012 at 08:12:45AM -0800, Andy Lutomirski wrote:
> On Fri, Dec 14, 2012 at 6:49 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> > On Fri, Dec 14, 2012 at 03:14:50AM -0800, Andy Lutomirski wrote:
> >
> >> > Wait a minute.  get_user_pages() relies on ->mmap_sem being held.  Unless
> >> > I'm seriously misreading your patch it removes that protection.  And yes,
> >> > I'm aware of execve-related exception; it's in special circumstances -
> >> > bprm->mm is guaranteed to be not shared (and we need to rearchitect that
> >> > area anyway, but that's a separate story).
> >>
> >> Unless I completely screwed up the patch, ->mmap_sem is still held for
> >> read (it's downgraded from write).  It's just not held for write
> >> anymore.
> >
> > Huh?  I'm talking about the call of get_user_pages() in aio_setup_ring().
> > With your patch it's done completely outside of ->mmap_sem, isn't it?
> 
> Oh, /that/ call to get_user_pages.  That would qualify as screwing up...
> 
> Since dropping and reacquiring mmap_sem there is probably a bad idea
> there, I'll rework this and post a v2.

FWIW, I've done some checking of ->mmap_sem uses yesterday.  Got further than
the last time; catch so far, just from find_vma() audit:
* arm swp_emulate.c - missing ->mmap_sem around find_vma().  Fix sent to
rmk.
* blackfin ptrace - find_vma() without any protection, definitely broken
* m68k sys_cacheflush() - ditto
* mips process_fpemu_return() - ditto
* mips octeon_flush_cache_sigtramp() - ditto
* omap_vout_uservirt_to_phys() - ditto, patch sent
* vb2_get_contig_userptr() - probaly a bug, unless I've misread the (very
twisty maze of) v4l2 code leading to it
* vb2_get_contig_userptr() - ditto
* gntdev_ioctl_get_offset_for_vaddr() - definitely broken
and there's a couple of dubious places in arch/* I hadn't finished with,
plus a lot in mm/* proper.

That's just from a couple of days of RTFS.  The locking in there is far too
convoluted as it is; worse, it's not localized code-wise, so rechecking
correctness is going to remain a big time-sink ;-/

Making it *more* complex doesn't look like a good idea, TBH...

BTW, the __get_user_pages()/find_extend_vma()/mlock_vma_pages_range() pile is
really asking for trouble; sure, the recursion there is limited, but it
deserves a comment.  Moreover, the damn thing is reachable from coredump
path and there we do *not* have ->mmap_sem held.  We don't reach the
VM_BUG_ON() in __mlock_vma_pages_range(), but the reason for that also
deserves a comment, IMO.

Moreover, I'm not quite convinced that huge_memory.c and ksm.c can't run
into all kinds of interesting races with ongoing coredump.  Looking into
it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
