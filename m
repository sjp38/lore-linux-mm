Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 677F76B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 16:57:28 -0500 (EST)
Date: Tue, 12 Feb 2013 13:57:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: export mmu notifier invalidates
Message-Id: <20130212135726.a40ff76f.akpm@linux-foundation.org>
In-Reply-To: <20130212213534.GA5052@sgi.com>
References: <20130212213534.GA5052@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: linux-mm@kvack.org, aarcange@redhat.com, mgorman@suse.de

On Tue, 12 Feb 2013 15:35:34 -0600
Cliff Wickman <cpw@sgi.com> wrote:

> 
> Commenting on this patch ended with Andrea's post on 07Jan, which was
> a more-or-less endorsement and a question about support for extended vma
> abstractions in kernel modules out of tree.
> (that comment can be found at http://marc.info/?l=linux-mm&m=135757292605395&w=2)
> 
> I'd like to make the request again to consider export of these two symbols. 
> 
> 
> We at SGI have a need to address some very high physical address ranges with
> our GRU (global reference unit), sometimes across partitioned machine boundaries
> and sometimes with larger addresses than the cpu supports.
> We do this with the aid of our own 'extended vma' module which mimics the vma.
> When something (either unmap or exit) frees an 'extended vma' we use the mmu
> notifiers to clean them up.
> 
> We had been able to mimic the functions __mmu_notifier_invalidate_range_start()
> and __mmu_notifier_invalidate_range_end() by locking the per-mm lock and 
> walking the per-mm notifier list.  But with the change to a global srcu
> lock (static in mmu_notifier.c) we can no longer do that.  Our module has
> no access to that lock.
> 
> So we request that these two functions be exported.
> 
> ...
>
> +EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
> +EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);

erk.  Having remote, modular, out-of-tree *sending* mmu notifications
is pretty abusive :(

I don't have a problem with the patch personally.  It's a GPL export
and it's only 2 lines and if we break it, you own both pieces ;)

But in a better world, the core kernel would support your machines
adequately and you wouldn't need to maintain that out-of-tree MM code. 
What are the prospects of this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
