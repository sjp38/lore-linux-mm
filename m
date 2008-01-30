Date: Wed, 30 Jan 2008 17:38:45 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [patch 1/6] mmu_notifier: Core code
Message-ID: <20080130163845.GO7233@v2.random>
References: <20080130022909.677301714@sgi.com> <20080130022944.236370194@sgi.com> <20080130153749.GN7233@v2.random> <20080130155306.GA13746@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080130155306.GA13746@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2008 at 09:53:06AM -0600, Jack Steiner wrote:
> That will also resolve the problem we discussed yesterday. 
> I want to unregister my mmu_notifier when a GRU segment is
> unmapped. This would not necessarily be at task termination.

My proof that there is something wrong in the smp locking of the
current code is very simple: it can't be right to use
hlist_for_each_entry_safe_rcu and rcu_read_lock inside
mmu_notifier_release, and then to call hlist_del_rcu without any
spinlock or semaphore. If we walk the list with
hlist_for_each_entry_safe_rcu (and not with
hlist_for_each_entry_safe), it means the list _can_ change from under
us, and in turn the hlist_del_rcu must be surrounded by a spinlock or
sempahore too!

If by design the list _can't_ change from under us and calling
hlist_del_rcu was safe w/o locks, then hlist_for_each_entry_safe is
_sure_ enough for mmu_notifier_release, and rcu_read_lock most
certainly can be removed too.

To make an usage case where the race could trigger, I was thinking at
somebody bumping the mm_count (not mm_users) and registering a
notifier while mmu_notifier_release runs and relaying on ->release to
know if it has to run mmu_notifier_unregister. However I now started
wondering how it can relay on ->release to know that if ->release is
called after hlist_del_rcu because with the latest changes ->release
will also allow the mn to release itself ;). It's unsafe to call
list_del_rcu twice (the second will crash on a poisoned entry).

This starts to make me think we should remove the auto-disarming
feature and require the notifier-user to have the ->release call
mmu_notifier_unregister first and to free the "mn" inside ->release
too if needed. Or alternatively the notifier-user can bump mm_count
and to call a mmu_notifier_unregister before calling mmdrop (like kvm
could do).

Another approach is to simply define mmu_notifier_release as
implicitly serialized by other code design, with a real lock (not rcu)
against the whole register/unregister operations. So to guarantee the
notifier list can't change from under us while mmu_notifier_release
runs. If we go this route, yes, the auto-disarming hlist_del can be
kept, the current code would have been safe, but to avoid confusion
the mmu_notifier_release shall become this:

void mmu_notifier_release(struct mm_struct *mm)
{
	struct mmu_notifier *mn;
	struct hlist_node *n, *t;

	if (unlikely(!hlist_empty(&mm->mmu_notifier.head))) {
		hlist_for_each_entry_safe(mn, n, t,
					  &mm->mmu_notifier.head, hlist) {
			hlist_del(&mn->hlist);
			if (mn->ops->release)
				mn->ops->release(mn, mm);
		}
	}
}

> However, the mmap_sem is already held for write by the core
> VM at the point I would call the unregister function.
> Currently, there is no __mmu_notifier_unregister() defined.
> 
> Moving to a different lock solves the problem.

Unless the mmu_notifier_release becomes like above and we rely on the
user of the mmu notifiers to implement a highlevel external lock that
will we definitely forbid to bump the mm_count of the mm, and to call
register/unregister while mmu_notifier_release could run, 1) moving to a
different lock and 2) removing the auto-disarming hlist_del_rcu from
mmu_notifier_release sounds the only possible smp safe way.

As far as KVM is concerned mmu_notifier_released could be changed to
the version I written above and everything should be ok. For KVM the
mm_count bump is done by the task that also holds a mm_user, so when
exit_mmap runs I don't think the list could possible change anymore.

Anyway those are details that can be perfected after mainline merging,
so this isn't something to worry about too much right now. My idea is
to keep working to perfect it while I hope progress is being made by
Christoph to merge the mmu notifiers V3 patchset in mainline ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
