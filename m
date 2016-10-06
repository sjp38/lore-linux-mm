Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA6EA6B0038
	for <linux-mm@kvack.org>; Thu,  6 Oct 2016 17:01:07 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r16so8577085pfg.4
        for <linux-mm@kvack.org>; Thu, 06 Oct 2016 14:01:07 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id b6si4776707pfd.48.2016.10.06.14.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 06 Oct 2016 14:01:07 -0700 (PDT)
Message-ID: <57F6BB8F.7070208@windriver.com>
Date: Thu, 6 Oct 2016 15:01:03 -0600
From: Chris Friesen <chris.friesen@windriver.com>
MIME-Version: 1.0
Subject: "swap_free: Bad swap file entry" and "BUG: Bad page map in process"
 but no swap configured
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org


I have Linux host running as a kvm hypervisor.  It's running CentOS.  (So the 
kernel is based on 3.10 but with loads of stuff backported by RedHat.)  I 
realize this is not a mainline kernel, but I was wondering if anyone is aware of 
similar issues that had been fixed in mainline.

When doing a bunch of live migrations eventually I hit a bunch of errors that 
look like this.

2016-10-03T23:13:54.017 controller-1 kernel: err [247517.457614] swap_free: Bad 
swap file entry 001fe858
2016-10-03T23:13:54.017 controller-1 kernel: alert [247517.463191] BUG: Bad page 
map in process qemu-kvm  pte:3fd0b000 pmd:4557cb067
2016-10-03T23:13:54.017 controller-1 kernel: alert [247517.471352] 
addr:00007fefa9be4000 vm_flags:00100073 anon_vma:ffff88043f87ff80 mapping: 
     (null) index:7fefa9be4
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483510] CPU: 0 PID: 
154525 Comm: qemu-kvm Tainted: G           OE  ------------ 
3.10.0-327.28.3.7.tis.x86_64 #1
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483513] Hardware 
name: Intel Corporation S2600WT2R/S2600WT2R, BIOS 
SE5C610.86B.01.01.0016.033120161139 03/31/2016
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483516] 
00007fefa9be4000 0000000007795eb9 ffff88044007bc60 ffffffff81670503
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483524] 
ffff88044007bca8 ffffffff8115e70f 000000003fd0b000 00000007fefa9be4
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483531] 
ffff8804557cbf20 000000003fd0b000 00007fefa9c00000 00007fefa9be4000
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483538] Call Trace:
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483548] 
[<ffffffff81670503>] dump_stack+0x19/0x1b
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483553] 
[<ffffffff8115e70f>] print_bad_pte+0x1af/0x250
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483557] 
[<ffffffff81160000>] unmap_page_range+0x5a0/0x7f0
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483561] 
[<ffffffff811602a9>] unmap_single_vma+0x59/0xd0
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483564] 
[<ffffffff81161595>] zap_page_range+0x105/0x170
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483568] 
[<ffffffff8115dd7c>] SyS_madvise+0x3bc/0x7d0
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483573] 
[<ffffffff810ca1e0>] ? SyS_futex+0x80/0x180
2016-10-03T23:13:54.017 controller-1 kernel: warning [247517.483577] 
[<ffffffff81678f89>] system_call_fastpath+0x16/0x1b


One interesting thing about the "Bad swap file entry" error is that these hosts 
do not have any swap configured:

compute-4:~$ free
               total        used        free      shared  buff/cache   available
Mem:      131805464   122187644     8815864      245456      801956     9193644
Swap:             0           0           0

So why is the kernel calling swap_info_get()?


In the second error, the offset in the SyS_madvise routine is here:
    0xffffffff8115dd77 <+951>:   callq  0xffffffff81161490 <zap_page_range>
    0xffffffff8115dd7c <+956>:   xor    %eax,%eax

this maps to the second zap_page_range() call below in madvise_dontneed():

	if (unlikely(vma->vm_flags & VM_NONLINEAR)) {
		struct zap_details details = {
			.nonlinear_vma = vma,
			.last_index = ULONG_MAX,
		};
		zap_page_range(vma, start, end - start, &details);
	} else
		zap_page_range(vma, start, end - start, NULL);


print_bad_pte() is called from this code in zap_pte_range():

		if (pte_file(ptent)) {
			if (unlikely(!(vma->vm_flags & VM_NONLINEAR)))
				print_bad_pte(vma, addr, ptent, NULL);

Here's the interesting bit...we're calling print_bad_pte() here if 
"vma->vm_flags & VM_NONLINEAR" is not true...but we called zap_page_range() with 
a "details" of NULL specifically because it was not true.  So probably 
pte_file(ptent) should not be true--but it is.


Any of this sound familiar to anyone?  Anyone have suggestions on how to bottom 
it out?

Chris

PS: Please CC me on replies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
