Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7342C6B0007
	for <linux-mm@kvack.org>; Tue,  1 May 2018 09:05:05 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id m68so10321965pfm.20
        for <linux-mm@kvack.org>; Tue, 01 May 2018 06:05:05 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a138sor2969772pfd.27.2018.05.01.06.05.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 May 2018 06:05:03 -0700 (PDT)
Date: Tue, 1 May 2018 22:04:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 06/25] mm: make pte_unmap_same compatible with SPF
Message-ID: <20180501130452.GA118722@rodete-laptop-imager.corp.google.com>
References: <1523975611-15978-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523975611-15978-7-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180423063157.GB114098@rodete-desktop-imager.corp.google.com>
 <dd5c4338-3cbb-c65a-f0c1-c71e2a0037ee@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dd5c4338-3cbb-c65a-f0c1-c71e2a0037ee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On Mon, Apr 30, 2018 at 04:07:30PM +0200, Laurent Dufour wrote:
> On 23/04/2018 08:31, Minchan Kim wrote:
> > On Tue, Apr 17, 2018 at 04:33:12PM +0200, Laurent Dufour wrote:
> >> pte_unmap_same() is making the assumption that the page table are still
> >> around because the mmap_sem is held.
> >> This is no more the case when running a speculative page fault and
> >> additional check must be made to ensure that the final page table are still
> >> there.
> >>
> >> This is now done by calling pte_spinlock() to check for the VMA's
> >> consistency while locking for the page tables.
> >>
> >> This is requiring passing a vm_fault structure to pte_unmap_same() which is
> >> containing all the needed parameters.
> >>
> >> As pte_spinlock() may fail in the case of a speculative page fault, if the
> >> VMA has been touched in our back, pte_unmap_same() should now return 3
> >> cases :
> >> 	1. pte are the same (0)
> >> 	2. pte are different (VM_FAULT_PTNOTSAME)
> >> 	3. a VMA's changes has been detected (VM_FAULT_RETRY)
> >>
> >> The case 2 is handled by the introduction of a new VM_FAULT flag named
> >> VM_FAULT_PTNOTSAME which is then trapped in cow_user_page().
> > 
> > I don't see such logic in this patch.
> > Maybe you introduces it later? If so, please comment on it.
> > Or just return 0 in case of 2 without introducing VM_FAULT_PTNOTSAME.
> 
> Late in the series, pte_spinlock() will check for the VMA's changes and may
> return 1. This will be then required to handle the 3 cases presented above.
> 
> I can move this handling later in the series, but I wondering if this will make
> it more easier to read.

Just nit:
During reviewing this patch, I was just curious you introduced new thing
here but I couldn't find any site where use it. It makes review hard. :(
That's why I said to you that please commet on it if you will use new thing
late in this series.
If you think as-is is better for review, it would be better to mention it
explicitly.

Thanks.
