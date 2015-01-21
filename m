Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f171.google.com (mail-vc0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 3664A6B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 09:06:05 -0500 (EST)
Received: by mail-vc0-f171.google.com with SMTP id hq11so4885857vcb.2
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 06:06:05 -0800 (PST)
Received: from mail-vc0-x235.google.com (mail-vc0-x235.google.com. [2607:f8b0:400c:c03::235])
        by mx.google.com with ESMTPS id z12si7377994vcn.100.2015.01.21.06.06.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 06:06:03 -0800 (PST)
Received: by mail-vc0-f181.google.com with SMTP id id10so2496707vcb.12
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 06:06:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150121132308.GB23700@dhcp22.suse.cz>
References: <20150121132308.GB23700@dhcp22.suse.cz>
Date: Wed, 21 Jan 2015 15:06:03 +0100
Message-ID: <CAJKOXPdgSsd8cr7ctKOGCwFTRMxcq71k7Pb5mQgYy--tGW8+_w@mail.gmail.com>
Subject: Re: mmotm: mm-slub-optimize-alloc-free-fastpath-by-removing-preemption-on-off.patch
 is causing preemptible splats
From: =?UTF-8?Q?Krzysztof_Koz=C5=82owski?= <k.kozlowski.k@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

2015-01-21 14:23 GMT+01:00 Michal Hocko <mhocko@suse.cz>:
> Hi,
> I am getting tons of splats like this:
> [ 187.593291] BUG: using smp_processor_id() in preemptible [00000000] code: kworker/u4:1/24
> [ 187.593293] caller is debug_smp_processor_id+0x17/0x19
> [ 187.599127] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
> [  187.601997]  ffffffff8181786e ffff8800068a3d78 ffffffff8151a4b8 ffffffff81078e0e
> [  187.604373]  0000000000000000 ffff8800068a3da8 ffffffff81280ac0 ffff8800068acac8
> [  187.606619]  00000000000029b2 ffff880007401500 00000000000000d0 ffff8800068a3db8
> [  187.608869] Call Trace:
> [  187.609602]  [<ffffffff8151a4b8>] dump_stack+0x4f/0x7c
> [  187.615881]  [<ffffffff81078e0e>] ? down_trylock+0x2d/0x37
> [  187.617468]  [<ffffffff81280ac0>] check_preemption_disabled+0xe7/0xf9
> [  187.619295]  [<ffffffff81280ae9>] debug_smp_processor_id+0x17/0x19
> [  187.621055]  [<ffffffff8113b2f6>] kmem_cache_alloc_trace+0x78/0x22e
> [  187.622854]  [<ffffffff81088d36>] ? do_syslog+0xb2/0x452
> [  187.624376]  [<ffffffff81088d36>] do_syslog+0xb2/0x452
> [  187.626030]  [<ffffffff811675b4>] ? __fdget_pos+0x3d/0x43
> [  187.627557]  [<ffffffff810745ac>] ? wait_woken+0x5d/0x5d
> [  187.629073]  [<ffffffff811675b4>] ? __fdget_pos+0x3d/0x43
> [  187.630611]  [<ffffffff811a787b>] kmsg_read+0x2d/0x54
> [  187.632069]  [<ffffffff8119c4ff>] proc_reg_read+0x4a/0x6c
> [  187.633775]  [<ffffffff8114e4d8>] vfs_read+0xa5/0x141
> [  187.635242]  [<ffffffff8114ee35>] SyS_read+0x51/0x8f
> [  187.636666]  [<ffffffff81522892>] system_call_fastpath+0x12/0x17

Same here :) [1] . So actually only ARM seems affected (both armv7 and
armv8) because it is the only one which uses smp_processor_id() in
my_cpu_offset.

[1] https://lkml.org/lkml/2015/1/20/162

Best regards,
Krzysztof

>
> $ grep "BUG: using smp_processor_id" mmap.qcow_serial.log | wc -l
> 660
> after few minutes of runtime when running the current mmotm tree
> (https://git.kernel.org/cgit/linux/kernel/git/mhocko/mm.git/log/?h=since-3.18).
>
> The warning seems to come from this_cpu_ptr which is using my_cpu_offset
> which is
> #define my_cpu_offset per_cpu_offset(smp_processor_id())
> if CONFIG_DEBUG_PREEMPT
>
> So it matches the following code in slab_alloc_node resp. slab_free:
>         do {
>                 tid = this_cpu_read(s->cpu_slab->tid);
>                 c = this_cpu_ptr(s->cpu_slab); <<< HERE
>         } while (IS_ENABLED(CONFIG_PREEMPT) && unlikely(tid != c->tid));
>
> This is with:
> CONFIG_PREEMPT=y
> CONFIG_PREEMPT_COUNT=y
> CONFIG_DEBUG_PREEMPT=y
>
> I am not sure how to fix this but it sounds like this_cpu_ptr should
> offer the same preempt expectations as other this_cpu_* functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
