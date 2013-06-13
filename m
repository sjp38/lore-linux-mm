Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 0414990001B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 10:46:00 -0400 (EDT)
Message-ID: <51B9DB23.7010609@nod.at>
Date: Thu, 13 Jun 2013 16:45:55 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: mem_cgroup_page_lruvec: BUG: unable to handle kernel NULL pointer
 dereference at 00000000000001a8
References: <CAFLxGvzKes7mGknTJgqFamr_-ODPBArf6BajF+m5x-S4AEtdmQ@mail.gmail.com> <20130613120248.GB23070@dhcp22.suse.cz> <51B9B5BC.4090702@nod.at> <20130613132908.GC23070@dhcp22.suse.cz> <20130613133244.GD23070@dhcp22.suse.cz> <51B9CA83.9070001@nod.at> <20130613143946.GF23070@dhcp22.suse.cz>
In-Reply-To: <20130613143946.GF23070@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups mailinglist <cgroups@vger.kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, bsingharora@gmail.com, hannes@cmpxchg.org

Am 13.06.2013 16:39, schrieb Michal Hocko:
> On Thu 13-06-13 15:34:59, Richard Weinberger wrote:
>> Am 13.06.2013 15:32, schrieb Michal Hocko:
>>> Ohh and could you post the config please? Sorry should have asked
>>> earlier.
>>
>> See attachment.
>
> Nothing unusual there. Could you enable CONFIG_DEBUG_VM maybe it will
> help too catch the problem earlier.

OK

>>> On Thu 13-06-13 15:29:08, Michal Hocko wrote:
>>>>
>>>> On Thu 13-06-13 14:06:20, Richard Weinberger wrote:
>>>> [...]
>>>>> All code
>>>>> ========
>>>>>     0:   89 50 08                mov    %edx,0x8(%rax)
>>>>>     3:   48 89 d1                mov    %rdx,%rcx
>>>>>     6:   0f 1f 40 00             nopl   0x0(%rax)
>>>>>     a:   49 8b 04 24             mov    (%r12),%rax
>>>>>     e:   48 89 c2                mov    %rax,%rdx
>>>>>    11:   48 c1 e8 38             shr    $0x38,%rax
>>>>>    15:   83 e0 03                and    $0x3,%eax
>>>> 					nid = page_to_nid
>>>>>    18:   48 c1 ea 3a             shr    $0x3a,%rdx
>>>> 					zid = page_zonenum
>
> Ohh, I am wrong here. rdx should be nid and eax the zid.
>
>>>>
>>>>>    1c:   48 69 c0 38 01 00 00    imul   $0x138,%rax,%rax
>>>>>    23:   48 03 84 d1 e0 02 00    add    0x2e0(%rcx,%rdx,8),%rax
>>>> 					&memcg->nodeinfo[nid]->zoneinfo[zid]
>>>>
>>>>>    2a:   00
>>>>>    2b:*  48 3b 58 70             cmp    0x70(%rax),%rbx     <-- trapping instruction
>>>>
>>>> OK, so this maps to:
>>>>          if (unlikely(lruvec->zone != zone)) <<<
>>>>                  lruvec->zone = zone;
>>>>
>>>>> [35355.883056] RSP: 0000:ffff88003d523aa8  EFLAGS: 00010002
>>>>> [35355.883056] RAX: 0000000000000138 RBX: ffff88003fffa600 RCX: ffff88003e04a800
>>>>> [35355.883056] RDX: 0000000000000020 RSI: 0000000000000000 RDI: 0000000000028500
>>>>> [35355.883056] RBP: ffff88003d523ab8 R08: 0000000000000000 R09: 0000000000000000
>>>>> [35355.883056] R10: 0000000000000000 R11: dead000000100100 R12: ffffea0000a14000
>>>>> [35355.883056] R13: ffff88003e04b138 R14: ffff88003d523bb8 R15: ffffea0000a14020
>>>>> [35355.883056] FS:  0000000000000000(0000) GS:ffff88003fd80000(0000)
>>>>
>>>> RAX (lruvec) is obviously incorrect and it doesn't make any sense. rax should
>>>> contain an address at an offset from ffff88003e04a800 But there is 0x138 there
>>>> instead.
>
> Hmm, now that I am looking at the registers again. RDX which should be
> nid seems to be quite big. It says this is node 32. Does the machine
> have really so many NUMA nodes?

No. It's a KVM guest with two CPUs. Nothing special.
qemu command line:
qemu-kvm -m 1G -drive file=lxc_host.qcow2,if=virtio -nographic -kernel linux/arch/x86/boot/bzImage -append console=ttyS0 root=/dev/vda2 -net user,hostfwd=tcp::5555-:22 -net 
nic,model=e1000 -smp 4

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
