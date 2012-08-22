Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 087286B0080
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 12:37:48 -0400 (EDT)
Date: Wed, 22 Aug 2012 18:37:46 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: mmu_notifier: fix inconsistent memory between
 secondary MMU and host
Message-ID: <20120822163746.GU29978@redhat.com>
References: <503358FF.3030009@linux.vnet.ibm.com>
 <20120821150618.GJ27696@redhat.com>
 <50345735.2000807@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50345735.2000807@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Wed, Aug 22, 2012 at 11:51:17AM +0800, Xiao Guangrong wrote:
> Hmm, in KSM code, i found this code in replace_page:
> 
> set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
> 
> It is possible to establish a writable pte, no?

Hugh already answered this thanks. Further details on the vm_page_prot
are in top of mmap.c, and KSM never scans MAP_SHARED vmas.

> Unfortunately, all these bugs are triggered by test cases.

Sure, I've seen the very Oops for the other one, and this one also can
trigger if unlucky.

This one can trigger with KVM but only if KSM is enabled or with live
migration or with device hotplug or some other event that triggers a
fork in qemu.

My curiosity about the other one in the exit/unregister/release paths
is if it really ever triggered with KVM. Because I can't easily see
how it could trigger. By the time kvm_destroy_vm or exit_mmap() runs,
no vcpu can be in guest mode anymore, so it cannot matter whatever the
status of any leftover spte at that time.

The process in the oops certainly wasn't qemu*. This is what I meant
in the previous email about this. Of course the fix was certainly good
and needed for other mmu notifier users, great fix.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
