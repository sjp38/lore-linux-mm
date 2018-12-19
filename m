Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EFF368E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 15:46:44 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id p79so21855789qki.15
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:46:44 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id u66si2748012qkb.252.2018.12.19.12.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Dec 2018 12:46:44 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH 1/2] ARC: show_regs: avoid page allocator
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
Date: Wed, 19 Dec 2018 13:46:15 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <114881A8-8960-4436-AAE4-DE40BFFCFB4B@oracle.com>
References: <1545159239-30628-1-git-send-email-vgupta@synopsys.com>
 <1545159239-30628-2-git-send-email-vgupta@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>


> On Dec 18, 2018, at 11:53 AM, Vineet Gupta =
<Vineet.Gupta1@synopsys.com> wrote:
>=20
> Use on-stack smaller buffers instead of dynamic pages.
>=20
> The motivation for this change was to address lockdep splat when
> signal handling code calls show_regs (with preemption disabled) and
> ARC show_regs calls into sleepable page allocator.
>=20
> | potentially unexpected fatal signal 11.
> | BUG: sleeping function called from invalid context at =
../mm/page_alloc.c:4317
> | in_atomic(): 1, irqs_disabled(): 0, pid: 57, name: segv
> | no locks held by segv/57.
> | Preemption disabled at:
> | [<8182f17e>] get_signal+0x4a6/0x7c4
> | CPU: 0 PID: 57 Comm: segv Not tainted 4.17.0+ #23
> |
> | Stack Trace:
> |  arc_unwind_core.constprop.1+0xd0/0xf4
> |  __might_sleep+0x1f6/0x234
> |  __get_free_pages+0x174/0xca0
> |  show_regs+0x22/0x330
> |  get_signal+0x4ac/0x7c4     # print_fatal_signals() -> =
preempt_disable()
> |  do_signal+0x30/0x224
> |  resume_user_mode_begin+0x90/0xd8
>=20
> Despite this, lockdep still barfs (see next change), but this patch
> still has merit as in we use smaller/localized buffers now and there's
> less instructoh trace to sift thru when debugging pesky issues.
>=20
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>

I would rather see 256 as a #define somewhere rather than a magic number =
sprinkled
around arch/arc/kernel/troubleshoot.c.

Still, that's what the existing code does, so I suppose it's OK.

Otherwise the change looks good.

Reviewed-by: William Kucharski <william.kucharski@oracle.com>
