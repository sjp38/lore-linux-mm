Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: What if a TLB flush needed to sleep?
Date: Tue, 25 Mar 2008 13:49:54 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843ECE9DF60@orsmsx424.amr.corp.intel.com>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

ia64 processors have a "ptc.g" instruction that will purge
a TLB entry across all processors in a system.  On current
cpus there is a limitation that only one ptc.g instruction may
be in flight at a time, so we serialize execution with code
like this:

	spin_lock(&ptcg_lock);
	... execute ptc.g
	spin_unlock(&ptcg_lock);

The architecture allows for more than one purge at a time.
So (without making any declarations about features of
unreleased processors) it seemed like time to update the
code to grab the maximum count from PAL, use that to
initialize a semaphore, and change the code to:

	down(&ptcg_sem);
	... execute ptc.g
	up(&ptcg_sem);

This code lasted about a week before someone ran hackbench
with parameters chosen to cause some swap activity (memory
footprint ~8.5GB on an 8GB system).  The machine promptly
deadlocked because VM code called the tlbflush code while
holding an anon_vma_lock, the semaphore happened to sleep
because some other processor was also trying to do a purge,
and the test was on a system where the limit was still just
one ptc.g at a time, and the process got swapped.

Now for the questions:

1) Is holding a spin lock a problem for any other arch when
doing a TLB flush (I'm particularly thinking of those that
need to use IPI shootdown for the purge)?

2) Is it feasible to rearrange the MM code so that we don't
hold any locks while doing a TLB flush?  Or should I implement
some sort of spin_only_semaphore?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
