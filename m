Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7VLmaCg004593
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 17:48:36 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7VLlC2J524086
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 17:47:12 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7VLlCkm011150
	for <linux-mm@kvack.org>; Fri, 31 Aug 2007 17:47:12 -0400
Subject: Re: [RFC:PATCH 00/07] VM File Tails
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
In-Reply-To: <20070831180006.2033828d@localhost>
References: <20070829205325.28328.67953.sendpatchset@norville.austin.ibm.com>
	 <20070831180006.2033828d@localhost>
Content-Type: text/plain
Date: Fri, 31 Aug 2007 16:47:06 -0500
Message-Id: <1188596826.20134.6.camel@norville.austin.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-08-31 at 18:00 -0300, Luiz Fernando N. Capitulino wrote:
> Hi Dave,
> 
> Em Wed, 29 Aug 2007 16:53:25 -0400
> Dave Kleikamp <shaggy@linux.vnet.ibm.com> escreveu:
> 
> | This is a rewrite of my "VM File Tails" work.  The idea is to store tails
> | of files that are smaller than the base page size in kmalloc'ed memory,
> | allowing more efficient use of memory.  This is especially important when
> | the base page size is large, such as 64 KB on powerpc.
> 
>  I've got the OOPS below while trying this series.
> 
>  It has happened while halting the machine, but before this one I've
> got two hangs and a OOPS, but was unable to get the backtrace because
> the serial console wasn't working properly. Now it did.
> 
>  I've tried to reproduce it many times w/o success.
> 
> [ 2618.789047] BUG: unable to handle kernel NULL pointer dereference at virtual address 00000044
> [ 2618.891267]  printing eip:
> [ 2618.923588] c0157120
> [ 2618.949679] *pde = 00000000
> [ 2618.983052] Oops: 0000 [#1]
> [ 2619.016400] SMP 
> [ 2619.038542] Modules linked in: nfs lockd nfs_acl sunrpc capability commoncap af_packet ipv6 ide_cd ide_core binfmt_misd
> [ 2619.546147] CPU:    0
> [ 2619.546148] EIP:    0060:[<c0157120>]    Not tainted VLI
> [ 2619.546149] EFLAGS: 00010286   (2.6.23-rc4-vm1 #5)
> [ 2619.694076] EIP is at find_get_page+0x10/0xa0
> [ 2619.746151] eax: c0368ee0   ebx: d96c0060   ecx: 00000000   edx: 0000000a
> [ 2619.827340] esi: d96c0000   edi: c0368ee0   ebp: d8627e28   esp: d8627e18
> [ 2619.908526] ds: 007b   es: 007b   fs: 00d8  gs: 0033  ss: 0068
> [ 2619.978280] Process udevd (pid: 18087, ti=d8627000 task=d42f3080 task.ti=d8627000)
> [ 2620.066743] Stack: 0000000a d96c0060 d96c0000 d96c0018 d8627e30 c016cbef d8627e74 c01721c5 
> [ 2620.167577]        d8627f7c c0178b5f 00008001 c03c70c0 d8627ed0 00000000 d96c0060 c01753b1 
> [ 2620.268412]        d96c0114 0000000a d8627e84 00000000 d96c0060 00000019 00000000 d8627e98 
> [ 2620.369247] Call Trace:
> [ 2620.400641]  [<c01053fa>] show_trace_log_lvl+0x1a/0x30
> [ 2620.462181]  [<c01054bb>] show_stack_log_lvl+0xab/0xd0
> [ 2620.523720]  [<c01056b1>] show_registers+0x1d1/0x2d0
> [ 2620.583183]  [<c01058c6>] die+0x116/0x250
> [ 2620.631208]  [<c011bb6b>] do_page_fault+0x28b/0x6a0
> [ 2620.689631]  [<c02e80ca>] error_code+0x72/0x78
> [ 2620.742854]  [<c016cbef>] lookup_swap_cache+0xf/0x30
> [ 2620.802316]  [<c01721c5>] shmem_getpage+0x225/0x690
> [ 2620.860736]  [<c017271a>] shmem_fault+0x7a/0xb0
> [ 2620.914999]  [<c01630d5>] __do_fault+0x55/0x3a0
> [ 2620.969265]  [<c0165677>] handle_mm_fault+0x107/0x740
> [ 2621.029765]  [<c011bcfd>] do_page_fault+0x41d/0x6a0
> [ 2621.088186]  [<c02e80ca>] error_code+0x72/0x78
> [ 2621.141411]  =======================
> [ 2621.184134] Code: c3 0f 0b eb fe 8d b6 00 00 00 00 8b 52 0c eb b8 8d 74 26 00 8d bc 27 00 00 00 00 55 89 e5 57 89 c7 5 
> [ 2621.416574] EIP: [<c0157120>] find_get_page+0x10/0xa0 SS:ESP 0068:d8627e18
> [ 2621.499188] note: udevd[18087] exited with preempt_count 1

I'm not sure exactly what's going on.  mapping->host can't be NULL, can
it?  This patch is an improvement, but I'm not sure if it will fix the
problem.  I won't have much time to look at this until next week, but
feel free to give this a try.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>

diff -Nurp linux.orig/include/linux/vm_file_tail.h linux/include/linux/vm_file_tail.h
--- linux.orig/include/linux/vm_file_tail.h	2007-08-29 13:27:46.000000000 -0500
+++ linux/include/linux/vm_file_tail.h	2007-08-31 16:25:49.000000000 -0500
@@ -54,7 +54,7 @@ void vm_file_tail_unpack(struct address_
 static inline void vm_file_tail_unpack_index(struct address_space *mapping,
 					     unsigned long index)
 {
-	if (index == vm_file_tail_index(mapping) && mapping->tail)
+	if (mapping->tail && index == vm_file_tail_index(mapping))
 		vm_file_tail_unpack(mapping);
 }
 

Thanks,
Shaggy
-- 
David Kleikamp
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
