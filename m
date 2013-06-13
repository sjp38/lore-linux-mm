Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 7BC8290001B
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:29:13 -0400 (EDT)
Date: Thu, 13 Jun 2013 15:29:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mem_cgroup_page_lruvec: BUG: unable to handle kernel NULL
 pointer dereference at 00000000000001a8
Message-ID: <20130613132908.GC23070@dhcp22.suse.cz>
References: <CAFLxGvzKes7mGknTJgqFamr_-ODPBArf6BajF+m5x-S4AEtdmQ@mail.gmail.com>
 <20130613120248.GB23070@dhcp22.suse.cz>
 <51B9B5BC.4090702@nod.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51B9B5BC.4090702@nod.at>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups mailinglist <cgroups@vger.kernel.org>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, bsingharora@gmail.com, hannes@cmpxchg.org


On Thu 13-06-13 14:06:20, Richard Weinberger wrote:
[...]
> All code
> ========
>    0:   89 50 08                mov    %edx,0x8(%rax)
>    3:   48 89 d1                mov    %rdx,%rcx
>    6:   0f 1f 40 00             nopl   0x0(%rax)
>    a:   49 8b 04 24             mov    (%r12),%rax
>    e:   48 89 c2                mov    %rax,%rdx
>   11:   48 c1 e8 38             shr    $0x38,%rax
>   15:   83 e0 03                and    $0x3,%eax
					nid = page_to_nid
>   18:   48 c1 ea 3a             shr    $0x3a,%rdx
					zid = page_zonenum

>   1c:   48 69 c0 38 01 00 00    imul   $0x138,%rax,%rax
>   23:   48 03 84 d1 e0 02 00    add    0x2e0(%rcx,%rdx,8),%rax
					&memcg->nodeinfo[nid]->zoneinfo[zid]

>   2a:   00
>   2b:*  48 3b 58 70             cmp    0x70(%rax),%rbx     <-- trapping instruction

OK, so this maps to:
        if (unlikely(lruvec->zone != zone)) <<<
                lruvec->zone = zone;

> [35355.883056] RSP: 0000:ffff88003d523aa8  EFLAGS: 00010002
> [35355.883056] RAX: 0000000000000138 RBX: ffff88003fffa600 RCX: ffff88003e04a800
> [35355.883056] RDX: 0000000000000020 RSI: 0000000000000000 RDI: 0000000000028500
> [35355.883056] RBP: ffff88003d523ab8 R08: 0000000000000000 R09: 0000000000000000
> [35355.883056] R10: 0000000000000000 R11: dead000000100100 R12: ffffea0000a14000
> [35355.883056] R13: ffff88003e04b138 R14: ffff88003d523bb8 R15: ffffea0000a14020
> [35355.883056] FS:  0000000000000000(0000) GS:ffff88003fd80000(0000)

RAX (lruvec) is obviously incorrect and it doesn't make any sense. rax should
contain an address at an offset from ffff88003e04a800 But there is 0x138 there
instead.

Is this easily reproducible? Could you configure kdump.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
