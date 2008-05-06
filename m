Date: Tue, 6 May 2008 16:46:54 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
Message-ID: <20080506144654.GD8471@duo.random>
References: <patchbomb.1209740703@duo.random> <1489529e7b53d3f2dab8.1209740704@duo.random> <20080505162113.GA18761@sgi.com> <20080505171434.GF8470@duo.random> <20080505172506.GA9247@sgi.com> <20080505183405.GI8470@duo.random> <20080505194625.GA17734@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080505194625.GA17734@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 05, 2008 at 02:46:25PM -0500, Jack Steiner wrote:
> If a task fails to unmap a GRU segment, they still exist at the start of

Yes, this will also happen in case the well behaved task receives
SIGKILL, so you can test it that way too.

> exit. On the ->release callout, I set a flag in the container of my
> mmu_notifier that exit has started. As VMA are cleaned up, TLB flushes
> are skipped because of the flag is set. When the GRU VMA is deleted, I free

GRU TLB flushes aren't skipped because your flag is set but because
__mmu_notifier_release already executed
list_del_init_rcu(&grunotifier->hlist) before proceeding with
unmap_vmas.

> my structure containing the notifier.

As long as nobody can write through the already established gru tlbs
and nobody can establish new tlbs after exit_mmap run you don't
strictly need ->release.

> I _think_ works. Do you see any problems?

You can remove the flag and ->release and ->clear_flush_young (if you
keep clear_flush_young implemented it should return 0). The
synchronize_rcu after mmu_notifier_register can also be dropped thanks
to mm_lock(). gru_drop_mmu_notifier should be careful with current->mm
if you're using an fd and if the fd can be passed to a different task
through unix sockets (you should probably fail any operation if
current->mm != gru->mm).

The way I use ->release in KVM is to set the root hpa to -1UL
(invalid) as a debug trap. That's only for debugging because even if
tlb entries and sptes are still established on the secondary mmu they
are only relevant when the cpu jumps to guest mode and that can never
happen again after exit_mmap is started.

> I should also mention that I have an open-coded function that possibly
> belongs in mmu_notifier.c. A user is allowed to have multiple GRU segments.
> Each GRU has a couple of data structures linked to the VMA. All, however,
> need to share the same notifier. I currently open code a function that
> scans the notifier list to determine if a GRU notifier already exists.
> If it does, I update a refcnt & use it. Otherwise, I register a new
> one. All of this is protected by the mmap_sem.
> 
> Just in case I mangled the above description, I'll attach a copy of the GRU mmuops
> code.

Well that function needs fixing w.r.t. srcu. Are you sure you want to
search for mn->ops == gru_mmuops and not for mn == gmn?  And if you
search for mn why can't you keep track of the mn being registered or
unregistered outside of the mmu_notifier layer? Set a bitflag in the
container after mmu_notifier_register returns and a clear it after
_unregister returns. I doubt saving one bitflag is worth searching the
list and your approach make it obvious that you've to protect the
bitflag and the register/unregister under write-mmap_sem
yourself. Otherwise the find function will return an object that can
be freed at any time if somebody calls unregister and
kfree. (synchronize_srcu in mmu_notifier_unregister won't wait for
anything but some outstanding srcu_read_lock)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
