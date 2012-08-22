Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 22D876B0044
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 00:12:57 -0400 (EDT)
Received: by iahk25 with SMTP id k25so522605iah.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 21:12:56 -0700 (PDT)
Date: Tue, 21 Aug 2012 21:12:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: mmu_notifier: fix inconsistent memory between
 secondary MMU and host
In-Reply-To: <50345735.2000807@linux.vnet.ibm.com>
Message-ID: <alpine.LSU.2.00.1208212105370.3415@eggly.anvils>
References: <503358FF.3030009@linux.vnet.ibm.com> <20120821150618.GJ27696@redhat.com> <50345735.2000807@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, 22 Aug 2012, Xiao Guangrong wrote:
> On 08/21/2012 11:06 PM, Andrea Arcangeli wrote:
> > 
> > The KSM usage of it looks safe because it will only establish readonly
> > ptes with it.
> 
> Hmm, in KSM code, i found this code in replace_page:
> 
> set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
> 
> It is possible to establish a writable pte, no?

No: we only do KSM in private vmas (!VM_SHARED), and because of the
need to CopyOnWrite in those, vm_page_prot excludes write permission:
write permission has to be added on COW fault.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
