Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 997486B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 11:08:42 -0500 (EST)
Message-ID: <50DC7287.1080302@yahoo.ca>
Date: Thu, 27 Dec 2012 11:08:39 -0500
From: Alex Xu <alex_y_xu@yahoo.ca>
MIME-Version: 1.0
Subject: Re: kernel BUG at mm/huge_memory.c:1798!
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com> <535932623.34838584.1356410331076.JavaMail.root@redhat.com> <CAJd=RBB9Tqv9c_Wv+N8yJOftfkJeUS10vLuz14eoLH1eEtjmBQ@mail.gmail.com>
In-Reply-To: <CAJd=RBB9Tqv9c_Wv+N8yJOftfkJeUS10vLuz14eoLH1eEtjmBQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, mgorman@suse.de, hughd@google.com, Andrea Arcangeli <aarcange@redhat.com>

On 25/12/12 07:05 AM, Hillf Danton wrote:
> On Tue, Dec 25, 2012 at 12:38 PM, Zhouping Liu <zliu@redhat.com> wrote:
>> Hello all,
>>
>> I found the below kernel bug using latest mainline(637704cbc95),
>> my hardware has 2 numa nodes, and it's easy to reproduce the issue
>> using LTP test case: "# ./mmap10 -a -s -c 200":
> 
> Can you test with 5a505085f0 and 4fc3f1d66b1 reverted?
> 
> Hillf
>

(for people from mailing lists, please cc me when replying)

Same thing?

mapcount 0 page_mapcount 1
------------[ cut here ]------------
kernel BUG at mm/huge_memory.c:1798!
invalid opcode: 0000 [#1] SMP
Modules linked in: usb_storage wacom
CPU 3
Pid: 1287, comm: thunderbird Not tainted 3.8.0-rc1+ #5 HP-Pavilion
AU992AA-ABL e9262f/Indio
RIP: 0010:[<ffffffff810c12c0>]  [<ffffffff810c12c0>] 0xffffffff810c12c0
RSP: 0018:ffff880216887c58  EFLAGS: 00010297
RAX: 0000000000000001 RBX: ffffea00065d0000 RCX: 0000000000000038
RDX: 000000000000002c RSI: 0000000000000046 RDI: ffffffff818e9e34
RBP: ffff880216887cd8 R08: 000000000000000a R09: 0000000000000000
R10: 0000000000000272 R11: 0000000000000271 R12: ffff880203fbad10
R13: 00007f1160e00000 R14: 0000000000000000 R15: ffffea00065d0000
FS:  00007f1180fca740(0000) GS:ffff88022fd80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fca86e18000 CR3: 00000002168e3000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process thunderbird (pid: 1287, threadinfo ffff880216886000, task
ffff8802259c4380)
Stack:
 ffff880216887c68 ffffffff8145f284 ffff880216887cb8 ffff8801f9c24ac0
 00000000065d0000 ffff8801f9c24af0 0000000000000000 ffff880216887cf8
 0000000000000000 00000007f1160e00 0000000000000000 ffffea00065d0000
Call Trace:
 [<ffffffff8145f284>] ? 0xffffffff8145f284
 [<ffffffff810c2310>] 0xffffffff810c2310
 [<ffffffff810a69ea>] 0xffffffff810a69ea
 [<ffffffff8106bbd8>] ? 0xffffffff8106bbd8
 [<ffffffff810a7710>] 0xffffffff810a7710
 [<ffffffff810a4a1d>] 0xffffffff810a4a1d
 [<ffffffff8106e062>] ? 0xffffffff8106e062
 [<ffffffff810adf84>] ? 0xffffffff810adf84
 [<ffffffff81460952>] 0xffffffff81460952
Code: 6d 81 31 c0 8b 75 c4 83 c2 01 e8 c4 94 39 00 e9 83 fb ff ff 0f 0b
0f 0b 0f 0b f3 90 48 8b 03 a9 00 00 80 00 75 f4 e9 b6 fb ff ff <0f> 0b
0f 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 49 89 d1 48
RIP  [<ffffffff810c12c0>] 0xffffffff810c12c0
 RSP <ffff880216887c58>
---[ end trace 0d442da0022ecdd1 ]---

I don't have KALLSYMS, so after running through ksymoops:

>>RIP; ffffffff810c12c0 <split_huge_page+600/610>   <=====

>>RBX; ffffea00065d0000 <phys_startup_64+ffffea00055d0000/ffffffff80000000>
>>RDI; ffffffff818e9e34 <logbuf_lock+0/4>
>>RBP; ffff880216887cd8 <phys_startup_64+ffff880215887cd8/ffffffff80000000>
>>R12; ffff880203fbad10 <phys_startup_64+ffff880202fbad10/ffffffff80000000>
>>R13; 00007f1160e00000 <phys_startup_64+7f115fe00000/ffffffff80000000>
>>R15; ffffea00065d0000 <phys_startup_64+ffffea00055d0000/ffffffff80000000>

Trace; ffffffff8145f284 <schedule+24/70>
Trace; ffffffff810c2310 <__split_huge_page_pmd+b0/1b0>
Trace; ffffffff810a69ea <unmap_single_vma+25a/700>
Trace; ffffffff8106bbd8 <futex_wake+108/130>
Trace; ffffffff810a7710 <zap_page_range+90/d0>
Trace; ffffffff810a4a1d <sys_madvise+25d/690>
Trace; ffffffff8106e062 <sys_futex+142/1a0>
Trace; ffffffff810adf84 <vm_munmap+54/70>
Trace; ffffffff81460952 <system_call_fastpath+16/1b>

Code;  ffffffff810c1295 <split_huge_page+5d5/610>
0000000000000000 <_RIP>:
Code;  ffffffff810c1295 <split_huge_page+5d5/610>
   0:   6d                        insl   (%dx),%es:(%rdi)
Code;  ffffffff810c1296 <split_huge_page+5d6/610>
   1:   81 31 c0 8b 75 c4         xorl   $0xc4758bc0,(%rcx)
Code;  ffffffff810c129c <split_huge_page+5dc/610>
   7:   83 c2 01                  add    $0x1,%edx
Code;  ffffffff810c129f <split_huge_page+5df/610>
   a:   e8 c4 94 39 00            callq  3994d3 <_RIP+0x3994d3>
Code;  ffffffff810c12a4 <split_huge_page+5e4/610>
   f:   e9 83 fb ff ff            jmpq   fffffffffffffb97
<_RIP+0xfffffffffffffb97>
Code;  ffffffff810c12a9 <split_huge_page+5e9/610>
  14:   0f 0b                     ud2
Code;  ffffffff810c12ab <split_huge_page+5eb/610>
  16:   0f 0b                     ud2
Code;  ffffffff810c12ad <split_huge_page+5ed/610>
  18:   0f 0b                     ud2
Code;  ffffffff810c12af <split_huge_page+5ef/610>
  1a:   f3 90                     pause
Code;  ffffffff810c12b1 <split_huge_page+5f1/610>
  1c:   48 8b 03                  mov    (%rbx),%rax
Code;  ffffffff810c12b4 <split_huge_page+5f4/610>
  1f:   a9 00 00 80 00            test   $0x800000,%eax
Code;  ffffffff810c12b9 <split_huge_page+5f9/610>
  24:   75 f4                     jne    1a <_RIP+0x1a>
Code;  ffffffff810c12bb <split_huge_page+5fb/610>
  26:   e9 b6 fb ff ff            jmpq   fffffffffffffbe1
<_RIP+0xfffffffffffffbe1>
Code;  ffffffff810c12c0 <split_huge_page+600/610>   <=====
  2b:   0f 0b                     ud2       <=====
Code;  ffffffff810c12c2 <split_huge_page+602/610>
  2d:   0f 0b                     ud2
Code;  ffffffff810c12c4 <split_huge_page+604/610>
  2f:   66 66 66 2e 0f 1f 84      data32 data32 nopw %cs:0x0(%rax,%rax,1)
Code;  ffffffff810c12cb <split_huge_page+60b/610>
  36:   00 00 00 00 00
Code;  ffffffff810c12d0 <do_huge_pmd_wp_page+0/840>
  3b:   55                        push   %rbp
Code;  ffffffff810c12d1 <do_huge_pmd_wp_page+1/840>
  3c:   49 89 d1                  mov    %rdx,%r9
Code;  ffffffff810c12d4 <do_huge_pmd_wp_page+4/840>
  3f:   48                        rex.W

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
