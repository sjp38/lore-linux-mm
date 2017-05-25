Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8265C6B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 22:13:01 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e7so205596649pfk.9
        for <linux-mm@kvack.org>; Wed, 24 May 2017 19:13:01 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id x7si26274611pff.280.2017.05.24.19.13.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 May 2017 19:13:00 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/migrate: Fix ref-count handling when
 !hugepage_migration_supported()
Date: Thu, 25 May 2017 02:11:43 +0000
Message-ID: <20170525021142.GB26520@hori1.linux.bs1.fc.nec.co.jp>
References: <20170524154728.2492-1-punit.agrawal@arm.com>
 <20170524125610.8fbc644f8fa1cf8175b7757b@linux-foundation.org>
In-Reply-To: <20170524125610.8fbc644f8fa1cf8175b7757b@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3BB02A997C24BB429E89A0CCE36B595D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Punit Agrawal <punit.agrawal@arm.com>, "will.deacon@arm.com" <will.deacon@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "manoj.iyer@arm.com" <manoj.iyer@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "tbaicar@codeaurora.org" <tbaicar@codeaurora.org>, "timur@qti.qualcomm.com" <timur@qti.qualcomm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Wed, May 24, 2017 at 12:56:10PM -0700, Andrew Morton wrote:
> On Wed, 24 May 2017 16:47:28 +0100 Punit Agrawal <punit.agrawal@arm.com> =
wrote:
>=20
> > On failing to migrate a page, soft_offline_huge_page() performs the
> > necessary update to the hugepage ref-count. When
> > !hugepage_migration_supported() , unmap_and_move_hugepage() also
> > decrements the page ref-count for the hugepage. The combined behaviour
> > leaves the ref-count in an inconsistent state.
> >=20
> > This leads to soft lockups when running the overcommitted hugepage test
> > from mce-tests suite.
> >=20
> > Soft offlining pfn 0x83ed600 at process virtual address 0x400000000000
> > soft offline: 0x83ed600: migration failed 1, type
> > 1fffc00000008008 (uptodate|head)
> > INFO: rcu_preempt detected stalls on CPUs/tasks:
> >  Tasks blocked on level-0 rcu_node (CPUs 0-7): P2715
> >   (detected by 7, t=3D5254 jiffies, g=3D963, c=3D962, q=3D321)
> >   thugetlb_overco R  running task        0  2715   2685 0x00000008
> >   Call trace:
> >   [<ffff000008089f90>] dump_backtrace+0x0/0x268
> >   [<ffff00000808a2d4>] show_stack+0x24/0x30
> >   [<ffff000008100d34>] sched_show_task+0x134/0x180
> >   [<ffff0000081c90fc>] rcu_print_detail_task_stall_rnp+0x54/0x7c
> >   [<ffff00000813cfd4>] rcu_check_callbacks+0xa74/0xb08
> >   [<ffff000008143a3c>] update_process_times+0x34/0x60
> >   [<ffff0000081550e8>] tick_sched_handle.isra.7+0x38/0x70
> >   [<ffff00000815516c>] tick_sched_timer+0x4c/0x98
> >   [<ffff0000081442e0>] __hrtimer_run_queues+0xc0/0x300
> >   [<ffff000008144fa4>] hrtimer_interrupt+0xac/0x228
> >   [<ffff0000089a56d4>] arch_timer_handler_phys+0x3c/0x50
> >   [<ffff00000812f1bc>] handle_percpu_devid_irq+0x8c/0x290
> >   [<ffff0000081297fc>] generic_handle_irq+0x34/0x50
> >   [<ffff000008129f00>] __handle_domain_irq+0x68/0xc0
> >   [<ffff0000080816b4>] gic_handle_irq+0x5c/0xb0
> >=20
> > Fix this by dropping the ref-count decrement in
> > unmap_and_move_hugepage() when !hugepage_migration_supported().
> >=20
> > Fixes: 32665f2bbfed ("mm/migrate: correct failure handling if !hugepage=
_migration_support()")
> > Reported-by: Manoj Iyer <manoj.iyer@canonical.com>
> > Signed-off-by: Punit Agrawal <punit.agrawal@arm.com>
> > Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> > Cc: Christoph Lameter <cl@linux.com>
>=20
> 32665f2bbfed was three years ago.  Do you have any theory as to why
> this took so long to be detected?

My per-release testing only ran for "hugepage_migration_supported() =3D=3D =
true"
setting (i.e. x86 with CONFIG_HUGETLB_PAGE=3Dy). I need extend the coverage=
.
And other arch's developers recently have come to have interest in hugepage
migration.

>  And do you believe a -stable
> backport is warranted?

I agree to send the fix to stable, so the stable tag is wanted.

Cc: stable@kernel.org   # v3.14+

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
