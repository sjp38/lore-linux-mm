Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 108076B006E
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 14:34:40 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 5/8] sched, numa, mm: Add adaptive NUMA affinity support
References: <20121112160451.189715188@chello.nl>
	<20121112161215.782018877@chello.nl>
Date: Thu, 29 Nov 2012 11:34:15 -0800
In-Reply-To: <20121112161215.782018877@chello.nl> (Peter Zijlstra's message of
	"Mon, 12 Nov 2012 17:04:56 +0100")
Message-ID: <m2sj7sfbk8.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>

Peter Zijlstra <a.p.zijlstra@chello.nl> writes:

> +
> +		down_write(&mm->mmap_sem);
> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +			if (!vma_migratable(vma))
> +				continue;
> +			change_protection(vma, vma->vm_start, vma->vm_end, vma_prot_none(vma), 0);
> +		}

What happens if I have a 1TB process? Will you really unmap all of the
1TB in that timer?


>  
>  	case MPOL_PREFERRED:
>  		if (pol->flags & MPOL_F_LOCAL)
> -			polnid = numa_node_id();
> +			best_nid = numa_node_id();
>  		else
> -			polnid = pol->v.preferred_node;
> +			best_nid = pol->v.preferred_node;

So that's not the local node anymore?  That will change behaviour for
people using the NUMA affinity APIs explicitely.  I don't think that's a
good idea, if someone set the affinity explicitely the kernel better
follow that.

If you want to change behaviour for non DEFAULT like this
please use a new policy type.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
