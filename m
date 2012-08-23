Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C50606B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 03:25:45 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 23 Aug 2012 17:24:42 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7N7GWAS21758132
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:16:33 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7N7POex003406
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 17:25:24 +1000
Message-ID: <5035DAE0.7050901@linux.vnet.ibm.com>
Date: Thu, 23 Aug 2012 15:25:20 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmu_notifier: fix inconsistent memory between secondary
 MMU and host
References: <503358FF.3030009@linux.vnet.ibm.com> <20120821150618.GJ27696@redhat.com> <50345735.2000807@linux.vnet.ibm.com> <20120822163746.GU29978@redhat.com>
In-Reply-To: <20120822163746.GU29978@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Avi Kivity <avi@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 08/23/2012 12:37 AM, Andrea Arcangeli wrote:
> On Wed, Aug 22, 2012 at 11:51:17AM +0800, Xiao Guangrong wrote:
>> Hmm, in KSM code, i found this code in replace_page:
>>
>> set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
>>
>> It is possible to establish a writable pte, no?
> 
> Hugh already answered this thanks. Further details on the vm_page_prot
> are in top of mmap.c, and KSM never scans MAP_SHARED vmas.
> 

Yes, i see that, thank you, Andrea!

>> Unfortunately, all these bugs are triggered by test cases.
> 
> Sure, I've seen the very Oops for the other one, and this one also can
> trigger if unlucky.
> 
> This one can trigger with KVM but only if KSM is enabled or with live
> migration or with device hotplug or some other event that triggers a
> fork in qemu.
> 
> My curiosity about the other one in the exit/unregister/release paths
> is if it really ever triggered with KVM. Because I can't easily see
> how it could trigger. By the time kvm_destroy_vm or exit_mmap() runs,
> no vcpu can be in guest mode anymore, so it cannot matter whatever the
> status of any leftover spte at that time.
> 

vcpu is not in guest mode, but the memory can be still hold in KVM MMU.

Consider this case:

   CPU 0                      CPU 1

   create kvm
   create vcpu thread

   [ Guest is happily running ]

                          send kill signal to the process

   call do_exit
      mmput mm
      exit_mmap, then
         delete mmu_notify

                         reclaim the memory of these threads
                            !!!!!!
                         Now, the page has been reclaimed but
                         it is still hold in KVM MMU

        mmu_notify->release
             !!!!!!
           delete spte, and call
           mark_page_accessed/mark_page_dirty for
           the page which has already been freed on CPU 1


     exit_files
        release kvm/vcpu file, then
        kvm and vcpu are destroyed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
