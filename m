Subject: Re: [PATCH][RFC] pte notifiers -- support for external page tables
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <11890207643068-git-send-email-avi@qumranet.com>
References: <11890207643068-git-send-email-avi@qumranet.com>
Content-Type: text/plain
Date: Thu, 06 Sep 2007 12:28:19 +0800
Message-Id: <1189052899.6224.5.camel@sli10-conroe.sh.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-09-05 at 22:32 +0300, Avi Kivity wrote:
> [resend due to bad alias expansion resulting in some recipients
>  being bogus]
> 
> Some hardware and software systems maintain page tables outside the normal
> Linux page tables, which reference userspace memory.  This includes
> Infiniband, other RDMA-capable devices, and kvm (with a pending patch).
> 
> Because these systems maintain external page tables (and external tlbs),
> Linux cannot demand page this memory and it must be locked.  For kvm at
> least, this is a significant reduction in functionality.
> 
> This sample patch adds a new mechanism, pte notifiers, that allows drivers
> to register an interest in a changes to ptes. Whenever Linux changes a
> pte, it will call a notifier to allow the driver to adjust the external
> page table and flush its tlb.
> 
> Note that only one notifier is implemented, ->clear(), but others should be
> similar.
> 
> pte notifiers are different from paravirt_ops: they extend the normal
> page tables rather than replace them; and they provide high-level
> information
> such as the vma and the virtual address for the driver to use.
Looks great. So for kvm, all guest pages will be vma mapped?
There are lock issues in kvm between kvm lock and page lock. 
Will shadow page table be still stored in page->private? If yes, the
page->private must be cleaned before add_to_swap.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
