Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id B87856B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 20:48:37 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t1-v6so11979445plb.5
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 17:48:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u7-v6sor1563786plq.61.2018.04.03.17.48.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Apr 2018 17:48:36 -0700 (PDT)
Date: Tue, 3 Apr 2018 17:48:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [mm] b1f0502d04: INFO:trying_to_register_non-static_key
In-Reply-To: <aa6f2ff1-ff67-106a-e0e4-522ac82a7bf0@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1804031748120.27686@chino.kir.corp.google.com>
References: <20180317075119.u6yuem2bhxvggbz3@inn> <792c0f75-7e7f-cd81-44ae-4205f6e4affc@linux.vnet.ibm.com> <alpine.DEB.2.20.1803251510040.80485@chino.kir.corp.google.com> <aa6f2ff1-ff67-106a-e0e4-522ac82a7bf0@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: kernel test robot <fengguang.wu@intel.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, lkp@01.org

On Wed, 28 Mar 2018, Laurent Dufour wrote:

> On 26/03/2018 00:10, David Rientjes wrote:
> > On Wed, 21 Mar 2018, Laurent Dufour wrote:
> > 
> >> I found the root cause of this lockdep warning.
> >>
> >> In mmap_region(), unmap_region() may be called while vma_link() has not been
> >> called. This happens during the error path if call_mmap() failed.
> >>
> >> The only to fix that particular case is to call
> >> seqcount_init(&vma->vm_sequence) when initializing the vma in mmap_region().
> >>
> > 
> > Ack, although that would require a fixup to dup_mmap() as well.
> 
> You're right, I'll fix that too.
> 

I also think the following is needed:

diff --git a/fs/exec.c b/fs/exec.c
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -312,6 +312,10 @@ static int __bprm_mm_init(struct linux_binprm *bprm)
 	vma->vm_flags = VM_SOFTDIRTY | VM_STACK_FLAGS | VM_STACK_INCOMPLETE_SETUP;
 	vma->vm_page_prot = vm_get_page_prot(vma->vm_flags);
 	INIT_LIST_HEAD(&vma->anon_vma_chain);
+#ifdef CONFIG_SPECULATIVE_PAGE_FAULT
+	seqcount_init(&vma->vm_sequence);
+	atomic_set(&vma->vm_ref_count, 0);
+#endif
 
 	err = insert_vm_struct(mm, vma);
 	if (err)
