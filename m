Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 758256B004D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 10:35:21 -0500 (EST)
Date: Mon, 7 Jan 2013 16:35:10 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-ID: <20130107153510.GC9163@redhat.com>
References: <E1Tr9P7-0001AN-S4@eag09.americas.sgi.com>
 <20130107141446.GF3885@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130107141446.GF3885@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Cliff Wickman <cpw@sgi.com>, akpm@linux-foundation.org, avi@redhat.com, hughd@google.com, linux-mm@kvack.org

Hi Mel,

On Mon, Jan 07, 2013 at 02:14:46PM +0000, Mel Gorman wrote:
> On Fri, Jan 04, 2013 at 09:41:53AM -0600, Cliff Wickman wrote:
> > From: Cliff Wickman <cpw@sgi.com>
> > 
> > Avi, Andrea, Andrew, Hugh, Mel,
> > 
> > We at SGI have a need to address some very high physical address ranges with
> > our GRU (global reference unit), sometimes across partitioned machine boundaries
> > and sometimes with larger addresses than the cpu supports.
> > We do this with the aid of our own 'extended vma' module which mimics the vma.
> > When something (either unmap or exit) frees an 'extended vma' we use the mmu
> > notifiers to clean them up.
> > 
> > We had been able to mimic the functions __mmu_notifier_invalidate_range_start()
> > and __mmu_notifier_invalidate_range_end() by locking the per-mm lock and 
> > walking the per-mm notifier list.  But with the change to a global srcu
> > lock (static in mmu_notifier.c) we can no longer do that.  Our module has
> > no access to that lock.
> > 
> > So we request that these two functions be exported.
> > 
> 
> I do not believe I wrote any of the MMU notifier code so it's not up to
> me how it should be exported (or if it should even be allowed). I find it
> curious that it appears that no other driver needs this and wonder if you
> could also abuse the vma_ops->close interface to do some of the cleanup
> but I've no idea what your module is doing. I've no objection to the
> export as such but it's really not my call.

The patch itself is zero risk and in fact it will make life easier to
their out-of-tree kernel module (that will be able to use the common
code in mmu_notifier.c and remove some duplicate).

The real question is if we're going to support extended vma
abstractions in kernel modules out of tree and that's not only my call
so I suggest others to comment too. If yes then applying this patch to
mmu notifier (so the device driver can call those methods) sounds fine
with me. I'm neutral on the broader question.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
