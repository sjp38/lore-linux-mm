Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF9216B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 10:01:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u65so2312260pfd.7
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 07:01:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 93-v6si78097plc.515.2018.02.08.07.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 07:01:15 -0800 (PST)
Date: Thu, 8 Feb 2018 07:00:25 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v7 04/24] mm: Dont assume page-table invariance during
 faults
Message-ID: <20180208150025.GD15846@bombadil.infradead.org>
References: <1517935810-31177-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1517935810-31177-5-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180206202831.GB16511@bombadil.infradead.org>
 <484242d8-e632-9e39-5c99-2e1b4b3b69a5@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <484242d8-e632-9e39-5c99-2e1b4b3b69a5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Thu, Feb 08, 2018 at 03:35:58PM +0100, Laurent Dufour wrote:
> I reviewed that part of code, and I think I could now change the way
> pte_unmap_safe() is checking for the pte's value. Since we now have all the
> needed details in the vm_fault structure, I will pass it to
> pte_unamp_same() and deal with the VMA checks when locking for the pte as
> it is done in the other part of the page fault handler by calling
> pte_spinlock().

This does indeed look much better!  Thank you!

> This means that this patch will be dropped, and pte_unmap_same() will become :
> 
> static inline int pte_unmap_same(struct vm_fault *vmf, int *same)
> {
> 	int ret = 0;
> 
> 	*same = 1;
> #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
> 	if (sizeof(pte_t) > sizeof(unsigned long)) {
> 		if (pte_spinlock(vmf)) {
> 			*same = pte_same(*vmf->pte, vmf->orig_pte);
> 			spin_unlock(vmf->ptl);
> 		}
> 		else
> 			ret = VM_FAULT_RETRY;
> 	}
> #endif
> 	pte_unmap(vmf->pte);
> 	return ret;
> }

I'm not a huge fan of auxiliary return values.  Perhaps we could do this
instead:

	ret = pte_unmap_same(vmf);
	if (ret != VM_FAULT_NOTSAME) {
		if (page)
			put_page(page);
		goto out;
	}
	ret = 0;

(we have a lot of unused bits in VM_FAULT_, so adding a new one shouldn't
be a big deal)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
