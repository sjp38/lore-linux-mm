Received: from woody.fsl.noaa.gov (woody.fsl.noaa.gov [127.0.0.1])
	by woody.fsl.noaa.gov (8.12.5/8.12.5) with ESMTP id gA8KXkbl026967
	for <linux-mm@kvack.org>; Fri, 8 Nov 2002 13:33:46 -0700
Received: (from tierney@localhost)
	by woody.fsl.noaa.gov (8.12.5/8.12.5/Submit) id gA8KXkuA026965
	for linux-mm@kvack.org; Fri, 8 Nov 2002 13:33:46 -0700
Date: Fri, 8 Nov 2002 13:33:46 -0700
From: Craig Tierney <ctierney@hpti.com>
Subject: Null pointer dereference, mprotect.c, linux-2.4.18
Message-ID: <20021108203346.GA26955@hpti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I am having a problem on my machines.  Occasionally
on a node the kernel will report:

"Unable to handle kernel NULL pointer dereference"

The problem always starts in either sys_mprotect
or mprotect_fixup_start.  It happens more on some
nodes than others, but I cannot figure out what
activity might cause it to happen more.

Kernel: 2.4.18 + trond's nfs patches
Node: P4 Xeon 2.2 Ghz 2way SMP
      1 GB ram
      Myrinet 

Ksymoops output:

ksymoops 2.4.5 on i686 2.4.18nfs.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.18nfs/ (default)
     -m /boot/System.map-2.4.18nfs (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Nov  8 05:01:00 g0062 kernel: Unable to handle kernel NULL pointer dereference at virtual address 0000000a
Nov  8 05:01:00 g0062 kernel: c013501f
Nov  8 05:01:00 g0062 kernel: *pde = 00000000
Nov  8 05:01:00 g0062 kernel: Oops: 0000
Nov  8 05:01:00 g0062 kernel: CPU:    1
Nov  8 05:01:00 g0062 kernel: EIP:    0010:[mprotect_fixup_start+15/320]    Tainted: P 
Nov  8 05:01:00 g0062 kernel: EIP:    0010:[<c013501f>]    Tainted: P 
Using defaults from ksymoops -t elf32-i386 -a i386
Nov  8 05:01:00 g0062 kernel: EFLAGS: 00010296
Nov  8 05:01:00 g0062 kernel: eax: 0000000a   ebx: 40000000   ecx: 0000000a   edx: f6494730
Nov  8 05:01:00 g0062 kernel: esi: 0000000a   edi: 00000016   ebp: f6494730   esp: e0689e5c
Nov  8 05:01:00 g0062 kernel: ds: 0018   es: 0018   ss: 0018
Nov  8 05:01:00 g0062 kernel: Process grep (pid: 4929, stackpage=e0689000)
Nov  8 05:01:00 g0062 kernel: Stack: 00000018 00000018 40000000 0000000a 00000016 f7f26158 c0132b14 f6494730 
Nov  8 05:01:00 g0062 kernel:        0000000a f7f26158 00000016 f6494680 f6494730 e9a1fc00 eeabf080 f5fecd80 
Nov  8 05:01:00 g0062 kernel:        00000000 e9fdd028 c012e490 f5fecd80 4000a000 00000000 c012dd37 f5fec480 
Nov  8 05:01:00 g0062 kernel: Call Trace: [filemap_nopage+196/560] [do_no_page+128/576] [do_wp_page+247/736] [handle_
mm_fault+129/288] [do_page_fault+412/1384] 
Nov  8 05:01:00 g0062 kernel: Call Trace: [<c0132b14>] [<c012e490>] [<c012dd37>] [<c012e6d1>] [<c01193dc>] 
Nov  8 05:01:00 g0062 kernel:    [<c0105ee2>] [<c0119240>] [<c010795c>] 
Nov  8 05:01:00 g0062 kernel: Code: 8b 10 89 28 85 d2 74 0c 8b 45 04 39 42 08 0f 84 c5 00 00 00 


>>EIP; c013501f <mprotect_fixup_start+f/140>   <=====

>>ebx; 40000000 Before first symbol
>>edx; f6494730 <_end+360c05f4/384aeec4>
>>ebp; f6494730 <_end+360c05f4/384aeec4>
>>esp; e0689e5c <_end+202b5d20/384aeec4>

Trace; c0132b14 <filemap_nopage+c4/230>
Trace; c012e490 <do_no_page+80/240>
Trace; c012dd37 <do_wp_page+f7/2e0>
Trace; c012e6d1 <handle_mm_fault+81/120>
Trace; c01193dc <do_page_fault+19c/568>
Trace; c0105ee2 <sys_execve+72/80>
Trace; c0119240 <do_page_fault+0/568>
Trace; c010795c <error_code+34/3c>

Code;  c013501f <mprotect_fixup_start+f/140>
00000000 <_EIP>:
Code;  c013501f <mprotect_fixup_start+f/140>   <=====
   0:   8b 10                     mov    (%eax),%edx   <=====
Code;  c0135021 <mprotect_fixup_start+11/140>
   2:   89 28                     mov    %ebp,(%eax)
Code;  c0135023 <mprotect_fixup_start+13/140>
   4:   85 d2                     test   %edx,%edx
Code;  c0135025 <mprotect_fixup_start+15/140>
   6:   74 0c                     je     14 <_EIP+0x14> c0135033 <mprotect_fixup_start+23/140>
Code;  c0135027 <mprotect_fixup_start+17/140>
   8:   8b 45 04                  mov    0x4(%ebp),%eax
Code;  c013502a <mprotect_fixup_start+1a/140>
   b:   39 42 08                  cmp    %eax,0x8(%edx)
Code;  c013502d <mprotect_fixup_start+1d/140>
   e:   0f 84 c5 00 00 00         je     d9 <_EIP+0xd9> c01350f8 <mprotect_fixup_start+e8/140>


Nov  8 05:01:00 g0062 kernel:  <1>Unable to handle kernel NULL pointer dereference at virtual address 0000007d
Nov  8 05:01:00 g0062 kernel: c0134ce0
Nov  8 05:01:00 g0062 kernel: *pde = 00000000
Nov  8 05:01:00 g0062 kernel: Oops: 0002
Nov  8 05:01:00 g0062 kernel: CPU:    1
Nov  8 05:01:00 g0062 kernel: EIP:    0010:[sys_mprotect+0/608]    Tainted: P 
Nov  8 05:01:00 g0062 kernel: EIP:    0010:[<c0134ce0>]    Tainted: P 
Nov  8 05:01:00 g0062 kernel: EFLAGS: 00010287
Nov  8 05:01:00 g0062 kernel: eax: 0000007d   ebx: f67a0000   ecx: 00008be8   edx: 00000018
Nov  8 05:01:00 g0062 kernel: esi: 40022000   edi: 00133000   ebp: bfffee44   esp: f67a1fc0
Nov  8 05:01:00 g0062 kernel: ds: 0018   es: 0018   ss: 0018
Nov  8 05:01:00 g0062 kernel: Process which (pid: 4932, stackpage=f67a1000)
Nov  8 05:01:00 g0062 kernel: Stack: c010786b 40155000 00008be8 00000000 40022000 00133000 bfffee44 0000007d 
Nov  8 05:01:00 g0062 kernel:        0000002b 0000002b 0000007d 400129d4 00000023 00000206 bfffecb4 0000002b 
Nov  8 05:01:00 g0062 kernel: Call Trace: [system_call+51/56] 
Nov  8 05:01:00 g0062 kernel: Call Trace: [<c010786b>] 
Nov  8 05:01:00 g0062 kernel: Code: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 


>>EIP; c0134ce0 <sys_mprotect+0/260>   <=====

>>ebx; f67a0000 <_end+363cbec4/384aeec4>
>>ecx; 00008be8 Before first symbol
>>esi; 40022000 Before first symbol
>>edi; 00133000 Before first symbol
>>ebp; bfffee44 Before first symbol
>>esp; f67a1fc0 <_end+363cde84/384aeec4>

Trace; c010786b <system_call+33/38>

Code;  c0134ce0 <sys_mprotect+0/260>
00000000 <_EIP>:


Thanks,
Craig

-- 
Craig Tierney (ctierney@hpti.com)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
