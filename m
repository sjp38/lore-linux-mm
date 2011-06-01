Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8F7A26B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 11:20:43 -0400 (EDT)
Date: Wed, 1 Jun 2011 17:20:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: do not expose uninitialized mem_cgroup_per_node
 to world
Message-ID: <20110601152039.GG4266@tiehlicka.suse.cz>
References: <1306925044-2828-1-git-send-email-imammedo@redhat.com>
 <20110601123913.GC4266@tiehlicka.suse.cz>
 <4DE6399C.8070802@redhat.com>
 <20110601134149.GD4266@tiehlicka.suse.cz>
 <4DE64F0C.3050203@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DE64F0C.3050203@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Mammedov <imammedo@redhat.com>
Cc: linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, containers@lists.linux-foundation.org

On Wed 01-06-11 16:39:08, Igor Mammedov wrote:
> On 06/01/2011 03:41 PM, Michal Hocko wrote:
> >[Let's CC some cgroup people]
> >
> >On Wed 01-06-11 15:07:40, Igor Mammedov wrote:
> >>Yes I've seen it (RHBZ#700565).
> >I am not subscribed so I will not get there.
> >
> Sorry, I've not realized that BZ wasn't public, just fixed it.
> It is public now.
> 
> OOPS backtrace looks like this:
> 
> Stopping cgconfig service: BUG: unable to handle kernel paging request at fffffffc

Looks like one pointer underflow from NULL.

> IP: [<c05235b3>] mem_cgroup_force_empty+0x123/0x4a0
> *pdpt = 00000000016a0001 *pde = 000000000000a067 *pte = 0000000000000000
> Oops: 0000 [#1] SMP
> last sysfs file: /sys/module/nf_conntrack/refcnt
> Modules linked in: xt_CHECKSUM tun bridge stp llc autofs4 sunrpc ipt_REJECT ip6t_REJECT ipv6 dm_mirror dm_region_hash dm_log uinput microcode xen_netfront sg i2c_piix4 i2c_core ext4 mbcache jbd2 sr_mod cdrom xen_blkfront ata_generic pata_acpi ata_piix dm_mod [last unloaded: nf_conntrack]
> 
> Pid: 2300, comm: cgclear Not tainted (2.6.32-131.0.10.el6.i686 #1) HVM domU

I realize that the issue is hard to reproduce but have you tried it with
the .39 vanilla?
Or at least try it with fce66477 (just a blind shot).

> EIP: 0060:[<c05235b3>] EFLAGS: 00010206 CPU: 0
> EIP is at mem_cgroup_force_empty+0x123/0x4a0
> EAX: 00000206 EBX: fffffff4 ECX: c0a3f1e0 EDX: 00000206
> ESI: 00000206 EDI: 00000000 EBP: f343ca00 ESP: f34e7e84
>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> Process cgclear (pid: 2300, ti=f34e6000 task=f35baab0 task.ti=f34e6000)
> Stack:
>  ffffffff 00000001 00000000 f34e7eb8 00000100 00000000 c0a3f1e0 c05a5af5
> <0>  f343ca00 f343cc00 00000000 00000000 00000000 00000000 00000000 00000000
> <0>  c0a3e7c0 f35172c0 00000005 00000000 f35172d0 f35baab0 00000000 f35172c0
> Call Trace:
>  [<c05a5af5>] ? may_link+0xc5/0x130
>  [<c049b246>] ? cgroup_rmdir+0x96/0x3f0
>  [<c0473f20>] ? autoremove_wake_function+0x0/0x40
>  [<c05339ce>] ? vfs_rmdir+0x9e/0xd0
>  [<c0536806>] ? do_rmdir+0xc6/0xe0
>  [<c0506702>] ? do_munmap+0x1f2/0x2c0
>  [<c04adecc>] ? audit_syscall_entry+0x21c/0x240
>  [<c04adbe6>] ? audit_syscall_exit+0x216/0x240
>  [<c0409adf>] ? sysenter_do_call+0x12/0x28
> Code: 89 7c 24 20 8b 54 95 08 31 ff 89 44 24 14 81 c2 00 01 00 00 89 54 24 10 e9 83 00 00 00 8d 76 00 8b 44 24 18 89 f2 e8 7d 12 30 00<8b>  73 08 8b 7c 24 24 8b 07 8b 40 18 85 c0 89 44 24 08 0f 84 c5
> EIP: [<c05235b3>] mem_cgroup_force_empty+0x123/0x4a0 SS:ESP 0068:f34e7e84
> CR2: 00000000fffffffc
Code: 89 7c 24 20 8b 54 95 08 31 ff 89 44 24 14 81 c2 00 01 00 00 89 54 24 10 e9 83 00 00 00 8d 76 00 8b 44 24 18 89 f2 e8 7d 12 30 00 <8b> 73 08 8b 7c 24 24 8b 07 8b 40 18 85 c0 89 44 24 08 0f 84 c5
All code
========
   0:   89 7c 24 20             mov    %edi,0x20(%esp)
   4:   8b 54 95 08             mov    0x8(%ebp,%edx,4),%edx
   8:   31 ff                   xor    %edi,%edi
   a:   89 44 24 14             mov    %eax,0x14(%esp)
   e:   81 c2 00 01 00 00       add    $0x100,%edx
  14:   89 54 24 10             mov    %edx,0x10(%esp)
  18:   e9 83 00 00 00          jmp    0xa0
  1d:   8d 76 00                lea    0x0(%esi),%esi
  20:   8b 44 24 18             mov    0x18(%esp),%eax
  24:   89 f2                   mov    %esi,%edx
  26:   e8 7d 12 30 00          call   0x3012a8
  2b:*  8b 73 08                mov    0x8(%ebx),%esi     <-- trapping instruction
  2e:   8b 7c 24 24             mov    0x24(%esp),%edi
  32:   8b 07                   mov    (%edi),%eax
  34:   8b 40 18                mov    0x18(%eax),%eax
  37:   85 c0                   test   %eax,%eax
  39:   89 44 24 08             mov    %eax,0x8(%esp)
  3d:   0f                      .byte 0xf
  3e:   84 c5                   test   %al,%ch

Could you send your config file. I cannot find out much from this.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
