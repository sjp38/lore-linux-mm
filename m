Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id E516F6B0044
	for <linux-mm@kvack.org>; Thu, 26 Jul 2012 17:03:52 -0400 (EDT)
Message-ID: <5011B0B3.7040501@redhat.com>
Date: Thu, 26 Jul 2012 17:03:47 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <50118E7F.8000609@redhat.com>
In-Reply-To: <50118E7F.8000609@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

On 07/26/2012 02:37 PM, Rik van Riel wrote:
> On 07/23/2012 12:04 AM, Hugh Dickins wrote:
>
>> I spent hours trying to dream up a better patch, trying various
>> approaches.  I think I have a nice one now, what do you think?  And
>> more importantly, does it work?  I have not tried to test it at all,
>> that I'm hoping to leave to you, I'm sure you'll attack it with gusto!
>>
>> If you like it, please take it over and add your comments and signoff
>> and send it in.  The second part won't come up in your testing, and 
>> could
>> be made a separate patch if you prefer: it's a related point that struck
>> me while I was playing with a different approach.
>>
>> I'm sorely tempted to leave a dangerous pair of eyes off the Cc,
>> but that too would be unfair.
>>
>> Subject-to-your-testing-
>> Signed-off-by: Hugh Dickins <hughd@google.com>
>
> This patch looks good to me.
>
> Larry, does Hugh's patch survive your testing?
>
>
It doesnt.  However its got a slightly different footprint because this 
is RHEL6 and
there have been changes to the hugetlbfs_inode code.  Also, we are 
seeing the
problem via group_exit() rather than shmdt().  Also, I print out the 
actual _mapcount
at the BUG and most of the time its 1 but have seen it as high as 6.



dell-per620-01.lab.bos.redhat.com login: MAPCOUNT = 2
------------[ cut here ]------------
kernel BUG at mm/filemap.c:131!
invalid opcode: 0000 [#1] SMP
last sysfs file: /sys/devices/system/cpu/cpu23/cache/index2/shared_cpu_map
CPU 8
Modules linked in: autofs4 sunrpc ipv6 acpi_pad power_meter dcdbas 
microcode sb_edac edac_core iTCO_wdt i]

Pid: 3106, comm: mpitest Not tainted 2.6.32-289.el6.sharedpte.x86_64 #17 
Dell Inc. PowerEdge R620/07NDJ2
RIP: 0010:[<ffffffff81114a42>]  [<ffffffff81114a42>] 
__remove_from_page_cache+0xe2/0x100
RSP: 0018:ffff880434897b78  EFLAGS: 00010002
RAX: 0000000000000001 RBX: ffffea00074ec000 RCX: 00000000000010f6
RDX: 0000000000000000 RSI: 0000000000000046 RDI: 0000000000000046
RBP: ffff880434897b88 R08: ffffffff81c01a00 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000004 R12: ffff880432683d98
R13: ffff880432683db0 R14: 0000000000000000 R15: ffffea00074ec000
FS:  0000000000000000(0000) GS:ffff880028280000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000003a1d38c4a8 CR3: 0000000001a85000 CR4: 00000000000406e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process mpitest (pid: 3106, threadinfo ffff880434896000, task 
ffff880431abb500)
Stack:
  ffffea00074ec000 0000000000000000 ffff880434897bb8 ffffffff81114ab4
<d> ffff880434897bb8 00000000000002ab 00000000000002a0 ffff880434897c08
<d> ffff880434897cb8 ffffffff811f758d ffff880000022dd8 0000000000000000
Call Trace:
  [<ffffffff81114ab4>] remove_from_page_cache+0x54/0x90
  [<ffffffff811f758d>] truncate_hugepages+0x11d/0x200
  [<ffffffff811f7670>] ? hugetlbfs_delete_inode+0x0/0x30
  [<ffffffff811f7688>] hugetlbfs_delete_inode+0x18/0x30
  [<ffffffff8119618e>] generic_delete_inode+0xde/0x1d0
  [<ffffffff811f76fd>] hugetlbfs_drop_inode+0x5d/0x70
  [<ffffffff81195132>] iput+0x62/0x70
  [<ffffffff81191c90>] dentry_iput+0x90/0x100
  [<ffffffff81191df1>] d_kill+0x31/0x60
  [<ffffffff8119381c>] dput+0x7c/0x150
  [<ffffffff8117c979>] __fput+0x189/0x210
  [<ffffffff8117ca25>] fput+0x25/0x30
  [<ffffffff8117844d>] filp_close+0x5d/0x90
  [<ffffffff8106e45f>] put_files_struct+0x7f/0xf0
  [<ffffffff8106e523>] exit_files+0x53/0x70
  [<ffffffff8107059d>] do_exit+0x18d/0x870
  [<ffffffff810d6cc2>] ? audit_syscall_entry+0x272/0x2a0
  [<ffffffff81070cd8>] do_group_exit+0x58/0xd0
  [<ffffffff81070d67>] sys_exit_group+0x17/0x20
  [<ffffffff8100b0f2>] system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
