Date: Tue, 29 Jan 2008 13:35:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080129211759.GV7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801291327330.26649@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com>
 <20080129162004.GL7233@v2.random> <Pine.LNX.4.64.0801291153520.25300@schroedinger.engr.sgi.com>
 <20080129211759.GV7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008, Andrea Arcangeli wrote:

> > It seems to be okay to invalidate range if you hold mmap_sem writably. In 
> > that case no additional faults can happen that would create new ptes.
> 
> In that place the mmap_sem is taken but in readonly mode. I never rely
> on the mmap_sem in the mmu notifier methods. Not invoking the notifier

Well it seems that we have to rely on mmap_sem otherwise concurrent faults 
can occur. The mmap_sem seems to be acquired for write there.

              if (!has_write_lock) {
                        up_read(&mm->mmap_sem);
                        down_write(&mm->mmap_sem);
                        has_write_lock = 1;
                        goto retry;
                }


> before releasing the PT lock adds quite some uncertainty on the smp
> safety of the spte invalidates, because the pte may be unmapped and
> remapped by a minor fault before invalidate_range is invoked, but I
> didn't figure out a kernel crashing race yet thanks to the pin we take
> through get_user_pages (and only thanks to it). The requirement is
> that invalidate_range is invoked after the last ptep_clear_flush or it
> leaks pins that's why I had to move it at the end.
 
So "pins" means a reference count right? I still do not get why you 
have refcount problems. You take a refcount when you export the page 
through KVM and then drop the refcount in invalidate page right?

So you walk through the KVM ptes and drop the refcount for each spte you 
encounter?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
