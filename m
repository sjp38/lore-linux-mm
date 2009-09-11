Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B56C46B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 17:37:24 -0400 (EDT)
Subject: Re: [Bugme-new] [Bug 14148] New: kernel panic: do_wp_page assert_pte_locked failed when DEBUG_VM
Mime-Version: 1.0 (Apple Message framework v1076)
Content-Type: text/plain; charset=us-ascii; format=flowed; delsp=yes
From: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <20090911130940.a99708dc.akpm@linux-foundation.org>
Date: Fri, 11 Sep 2009 16:37:19 -0500
Content-Transfer-Encoding: 7bit
Message-Id: <D6EDFC5E-F6B6-4689-B3CF-67BA4E034707@kernel.crashing.org>
References: <bug-14148-10286@http.bugzilla.kernel.org/> <20090911130940.a99708dc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linuxppc-dev@ozlabs.org, wangbj@lzu.edu.cn, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org
List-ID: <linux-mm.kvack.org>


On Sep 11, 2009, at 3:09 PM, Andrew Morton wrote:

>
> (switched to email.  Please respond via emailed reply-to-all, not  
> via the
> bugzilla web interface).
>
> On Wed, 9 Sep 2009 15:09:15 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=14148
>>
>>           Summary: kernel panic: do_wp_page assert_pte_locked  
>> failed when
>>                    DEBUG_VM
>>           Product: Platform Specific/Hardware
>>           Version: 2.5
>>    Kernel Version: 2.6.31-rc3, 2.6.31-rc9-git2
>>          Platform: All
>>        OS/Version: Linux
>>              Tree: Mainline
>>            Status: NEW
>>          Severity: normal
>>          Priority: P1
>>         Component: PPC-32
>>        AssignedTo: platform_ppc-32@kernel-bugs.osdl.org
>>        ReportedBy: wangbj@lzu.edu.cn
>>        Regression: Yes
>>
>>
>> Created an attachment (id=23049)
>> --> (http://bugzilla.kernel.org/attachment.cgi?id=23049)
>> problematic config file for mpc8548cds
>>
>> powerpc mpc8548cds (I only have this board on hand) will kernel  
>> panic if
>> DEBUG_VM (kernel hacking) is enabled due to assertion failed in  
>> function
>> do_wp_page(). I think it highly possible for other ppc boards like  
>> 44x have the
>> same problem too, but I don't have the board.
>>
>> here is the full log from power up (after u-boot). and the  
>> attachment is
>> related .config, NOTE the kernel boot successfully if  
>> CONFIG_DEBUG_VM is not
>> enabled.
>>
>> host system is gentoo, the gcc (powerpc-unknown-linux-gnu-gcc) is  
>> build by
>> gentoo crossdev, version 4.4.1, (cross) glibc is 2.9, (cross)  
>> binutils is
>> 2.19.1, (cross) kernel headers is 2.6.30. target (mpc8548cds) root  
>> filesystem
>> is also gentoo (200907xx, extracted from stage3 tarball).
>>
>> I have running similar test on x86 using qemu (0.10.6, +kvm), the  
>> result seems
>> OK, especially x86 pass all lock api test suite.
>
> First question:
>
>> [10611.192802] ------------[ cut here ]------------
>> [10611.197409] Kernel BUG at c0014d70 [verbose debug info  
>> unavailable]
>
> Why did we not get the file-n-line?  That's iritating.
>
> Oh, CONFIG_DEBUG_BUGVERBOSE=n.  Don't do that.  We should make that  
> thing
> harder to get at, to stop people shooting our feet off.
>
>> [10611.203660] Oops: Exception in kernel mode, sig: 5 [#1]
>> [10611.208866] PREEMPT MPC85xx CDS
>> [10611.211997] Modules linked in:
>> [10611.215040] NIP: c0014d70 LR: c0014eb4 CTR: 00000002
>> [10611.219988] REGS: cf82db40 TRAP: 0700   Not tainted  (2.6.31-rc3)
>> [10611.226061] MSR: 00029000 <EE,ME,CE>  CR: 88448044  XER: 20000000
>> [10611.232162] TASK = cf828000[1] 'init' THREAD: cf82c000
>> [10611.237108] GPR00: 00000001 cf82dbf0 cf828000 cf9781c0 bf8031d8  
>> cf9f400c
>> 0057902f 00000001
>> [10611.245471] GPR08: cf978200 cf9f4000 00000002 00000000 28448042  
>> 1001b0b0
>> 00000001 cf88ee00
>> [10611.253833] GPR16: c05c0000 bf8031d8 00000002 10000000 48000000  
>> 00000001
>> 00000008 c05ecf20
>> [10611.262196] GPR24: 0057902b 0057902f cf82c000 00000000 cf9f400c  
>> 00000001
>> bf8031d8 cf98b000
>> [10611.270749] NIP [c0014d70] assert_pte_locked+0x3c/0x44
>> [10611.275872] LR [c0014eb4] ptep_set_access_flags+0xa8/0xf4
>> [10611.281252] Call Trace:
>> [10611.283687] [cf82dbf0] [bf8031d8] 0xbf8031d8 (unreliable)
>> [10611.289079] [cf82dc10] [c008e87c] do_wp_page+0xf8/0x82c
>> [10611.294292] [cf82dc60] [c0014770] do_page_fault+0x2c0/0x480
>> [10611.299851] [cf82dd10] [c0011078] handle_page_fault+0xc/0x80
>> [10611.305504] [cf82ddd0] [c00f2b4c] load_elf_binary+0x8a8/0x121c
>> [10611.311325] [cf82de50] [c00af418] search_binary_handler 
>> +0x144/0x37c
>> [10611.317578] [cf82dea0] [c00b0bc8] do_execve+0x270/0x2c8
>> [10611.322794] [cf82dee0] [c0008754] sys_execve+0x68/0xa4
>> [10611.327919] [cf82df00] [c0010c38] ret_from_syscall+0x0/0x3c
>> [10611.333482] [cf82dfc0] [c00b9350] sys_dup+0x38/0x78
>> [10611.338349] [cf82dfd0] [c0002030] init_post+0x94/0x108
>> [10611.343478] [cf82dfe0] [c054c234] kernel_init+0x114/0x130
>> [10611.348865] [cf82dff0] [c00109b8] kernel_thread+0x4c/0x68
>> [10611.354249] Instruction dump:
>> [10611.357206] 4d9e0020 38000000 0f000000 0f000000 81230024  
>> 5480653a 7c09002e
>> 54090027
>> [10611.364959] 7c000026 54001ffe 0f000000 38000001 <0f000000>  
>> 4e800020 7c0802a6
>> 9421fff0
>> [10611.372887] ---[ end trace 0cda2392272f221a ]---
>
> So do_wp_page() called ptep_set_access_flags().  If CONFIG_DEBUG_VM=y,
> powerpc's ptep_set_access_flags() will call
> arch/powerpc/mm/pgtable.c:assert_pte_locked().  Because of the lack of
> file-n-line info it is unclear which of those many assertions
> triggered.  It looks like BUG_ON(!pmd_present(*pmd)).  Perhaps.
>
>
> Please set CONFIG_DEBUG_BUGVERBOSE=y in your .config and then tell us
> (via emailed reply-to-all) which line in arch/powerpc/mm/pgtable.c
> triggered the BUG.  Please actually quote that line, or tell us  
> exactly
> which kernel version you're using so we can see which line it was in
> the source code.
>
> Thanks.

I think I fixed this:

commit 797a747a82e23530ee45d2927bf84f3571c1acb2
Author: Kumar Gala <galak@kernel.crashing.org>
Date:   Tue Aug 18 15:21:40 2009 +0000

     powerpc/mm: Fix assert_pte_locked to work properly on uniprocessor

     Since the pte_lockptr is a spinlock it gets optimized away on
     uniprocessor builds so using spin_is_locked is not correct.  We  
can use
     assert_spin_locked instead and get the proper behavior between UP  
and
     SMP builds.

     Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
     Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

But the patch was queued up for .32 not .31

- k

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
