Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BEA4C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:57:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C8C920693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:57:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="Klea5ifB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C8C920693
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78416B0003; Mon, 15 Jul 2019 23:57:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B02096B0005; Mon, 15 Jul 2019 23:57:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DFC56B0006; Mon, 15 Jul 2019 23:57:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC6B46B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 23:57:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so15191302edd.22
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 20:57:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version
         :content-transfer-encoding;
        bh=wO1H7pm1vCJbg/MeYw66TC7ove6x7eKuLPF1WGsO2NI=;
        b=SmqiCewvzfSSDXTmRaFKTtDqVcoiEMicqDohqmynnVsEciXkudhO0vIWEzIKboSTdu
         ln3JJqD7MyXniDqVqWqbMOn+L0EkJEQMCDcWM94Yy+cw/bUxIx2YwEU+b9Dw/HvdNWS6
         TP/w5UtEkbnSIYk7wHg4mokuhtajngEsaL1RCOkNX5OyUo4ps1iEnGUHK62SfNaN4I4w
         Zz+ccaZod5kBamZ7Ol6WY4UccK6BHOF7VIUgdC9+U9FM7r9wi9gxKdg04XuaO3oeWGmb
         qvMcejjIE3VojcBrR/9jYMTD2+v4NoLSU1wj8U0XXlWy98HBwLTf36A8BUnp5l0dLvu2
         fBwQ==
X-Gm-Message-State: APjAAAVE5swclqIUOVIdFxvquILYNf+VXkQm7Sc/2JwkYveqhwZoeA1a
	ceMYr3fZcWGr96pb7kM6xzDEAWNa4Qs+hlsvjGQjvNfcuvSsQIJnOIRKP+HeZO7uGGV+1IoBD4e
	RLUAtG/qeL1gGTxPYC2EMS0PhzZ60GD5zUdCfXIhhE5qT7CMQuxYyxP2zmTAD4fIrKA==
X-Received: by 2002:a50:ba81:: with SMTP id x1mr26477889ede.257.1563249459195;
        Mon, 15 Jul 2019 20:57:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXmMFy2M+4xRueqJY7RLbn+3m1JTBBx/kRJn1LAt/1iIGLMk6ONd7jI8HpEdT4dHwPdM3n
X-Received: by 2002:a50:ba81:: with SMTP id x1mr26477758ede.257.1563249456186;
        Mon, 15 Jul 2019 20:57:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563249456; cv=none;
        d=google.com; s=arc-20160816;
        b=hVvLzHoNcrj/lhHniHKp9BWdblEMfYYV+NLlamMZPkqidt0UdygQOgZCi9AnMQ+jad
         qqyOeCYv+KOTtYqA5yMHxvHhIo6xWTfPJtPyxcSlUcYClDLRWUv2WjeP1jYCOtrcwRx/
         1BBQ6bXl9JgYrjNJ9LtNPRrXeWyCmFxur0/GmvL/3AayblJYf+seuPAwmFGxedOtGe8+
         /nynXBSkbppMF8P2X1CRySfKLncw+PEOeXOCYbN4FjwMldOB0S8dQANN4SV5D5msdSLz
         sEea+J2fwd7v4P1WYWr5LTpLeAD5gL1UA0MW1wYu8UgtTK7PLReFNYgldqV01VWI7Kf1
         TN6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:feedback-id:references
         :in-reply-to:message-id:subject:reply-to:cc:from:to:dkim-signature
         :date;
        bh=wO1H7pm1vCJbg/MeYw66TC7ove6x7eKuLPF1WGsO2NI=;
        b=uTdWU3At1R226OP6CxoLv7kEvg2fYmiHVCB8jxr9tKYRcwcnPmKmAEKGYKPLpfWCaR
         XiWeiTpexMyWbT2cVFolp/nsBqIRbMDUke8NJ62qSEO36Z7VOkhfr3ParkvPz4VwEUmk
         S6sDuDJeTkyN2iCVu0i0Hc0OeIdVDWJ3AYVSFvzy1xAduckfKBMr64BcIdtEvxJ6/eZi
         mPQ+/SPZMVR2dH3vyHV+X+fRQTaVpFrpG9FueNSU2/ySAItWtdHzspFMp2vGCJHSbTE+
         mvRKkQ2VJ5itvBOTcx9s/ulkPUFvCpWVfso+oXnkNwrCk/PYegLwH65S09McJ5ts3l1n
         7i2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=Klea5ifB;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Received: from mail-40136.protonmail.ch (mail-40136.protonmail.ch. [185.70.40.136])
        by mx.google.com with ESMTPS id b11si11969259edd.72.2019.07.15.20.57.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 20:57:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) client-ip=185.70.40.136;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=Klea5ifB;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Date: Tue, 16 Jul 2019 03:57:30 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=default; t=1563249451;
	bh=wO1H7pm1vCJbg/MeYw66TC7ove6x7eKuLPF1WGsO2NI=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=Klea5ifBCa4do7cFQ4Q8MZc+vur6ki8DIEfmThcM4hQ4xn0OkSm7YxpitH0PALQaD
	 PI2ruWDN6Rc7rpMjTardIoefBfV/3VdQGE169ke2xYRgPaqpehNeLGeRY2Zf+IISiG
	 o1oL35kvX3t+t99jlf7YmfYMoJvEMWgk6zBLexTM=
To: Andrew Morton <akpm@linux-foundation.org>
From: howaboutsynergy@protonmail.com
Cc: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Reply-To: howaboutsynergy@protonmail.com
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
In-Reply-To: <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
 <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
 <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
Feedback-ID: cNV1IIhYZ3vPN2m1zihrGlihbXC6JOgZ5ekTcEurWYhfLPyLhpq0qxICavacolSJ7w0W_XBloqfdO_txKTblOQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90 Original Me=
ssage =E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90=E2=80=90
On Tuesday, July 16, 2019 5:25 AM, <howaboutsynergy@protonmail.com> wrote:

> I got more info/better stacktrace(seen at the end):
>
> [ 4793.539013] sysrq: Show backtrace of all active CPUs
> [ 4793.539019] NMI backtrace for cpu 8
> [ 4793.539026] CPU: 8 PID: 21120 Comm: stress Kdump: loaded Tainted: G U =
5.2.1-g527a3db363a3 #68
> [ 4793.539029] Hardware name: System manufacturer System Product Name/PRI=
ME Z370-A, BIOS 1002 07/02/2018
> [ 4793.539032] Call Trace:
> [ 4793.539036] <IRQ>
> [ 4793.539047] dump_stack+0x46/0x60
> [ 4793.539054] nmi_cpu_backtrace.cold+0x14/0x53
> [ 4793.539061] ? lapic_can_unplug_cpu.cold+0x42/0x42
> [ 4793.539067] nmi_trigger_cpumask_backtrace+0x8e/0x90
> [ 4793.539073] __handle_sysrq.cold+0x48/0x102
> [ 4793.539078] sysrq_filter+0x2ea/0x3b0
> [ 4793.539084] input_to_handler+0x4d/0xf0
> [ 4793.539090] input_pass_values.part.0+0x109/0x130
> [ 4793.539096] input_handle_event+0x171/0x5a0
> [ 4793.539101] input_event+0x4d/0x70
> [ 4793.539107] hidinput_report_event+0x2e/0x40
> [ 4793.539112] hid_report_raw_event+0x260/0x430
> [ 4793.539118] hid_input_report+0xfb/0x150
> [ 4793.539124] hid_irq_in+0x168/0x190
> [ 4793.539131] __usb_hcd_giveback_urb+0x77/0xe0
> [ 4793.539148] xhci_giveback_urb_in_irq.isra.0+0x62/0x90 [xhci_hcd]
> [ 4793.539163] xhci_td_cleanup+0xf7/0x140 [xhci_hcd]
> [ 4793.539177] xhci_irq+0x7e8/0x1be0 [xhci_hcd]
> [ 4793.539185] __handle_irq_event_percpu+0x2f/0xc0
> [ 4793.539191] handle_irq_event_percpu+0x2c/0x80
> [ 4793.539196] handle_irq_event+0x23/0x43
> [ 4793.539202] handle_edge_irq+0x78/0x190
> [ 4793.539208] handle_irq+0x17/0x20
> [ 4793.539215] do_IRQ+0x3e/0xd0
> [ 4793.539221] common_interrupt+0xf/0xf
> [ 4793.539225] </IRQ>
> [ 4793.539231] RIP: 0010:isolate_migratepages_block+0x1d3/0xa50
> [ 4793.539237] Code: df 77 27 45 84 ed 74 22 4d 85 d2 0f 85 a7 00 00 00 4=
1 8b 44 24 60 be 01 00 00 00 c4 e2 f9 f7 c6 4c 8d 3c 18 48 f7 d8 49 21 c7 <=
f6> c3 1f 0f 84 ec 00 00 00 48 ff 44 24 10 48 8b 05 68 b3 d1 00 48
> [ 4793.539240] RSP: 0018:ffff9cb9a9f57958 EFLAGS: 00000206 ORIG_RAX: ffff=
ffffffffffde
> [ 4793.539246] RAX: ffff9cb9a9f57b49 RBX: 00000000004b4b00 RCX: 000000000=
000000c
> [ 4793.539249] RDX: 00000000004b4c00 RSI: 0000000000000007 RDI: 000000000=
0000000
> [ 4793.539252] RBP: ffff8fd8cdfde000 R08: ffff8fd8cdfd9960 R09: ffff8fd8a=
da5d550
> [ 4793.539254] R10: 0000000000000000 R11: ffff8fd8ada5cb80 R12: ffff9cb9a=
9f57ad0
> [ 4793.539257] R13: 0000000000000001 R14: ffff9cb9a9f57ad0 R15: 000000000=
04b4c00
> [ 4793.539264] ? isolate_migratepages_block+0xd5/0xa50
> [ 4793.539269] compact_zone+0x577/0xa70
> [ 4793.539275] compact_zone_order+0xde/0x120
> [ 4793.539280] try_to_compact_pages+0x187/0x240
> [ 4793.539286] __alloc_pages_direct_compact+0x87/0x170
> [ 4793.539291] __alloc_pages_slowpath+0x20e/0xc20
> [ 4793.539297] ? release_pages+0x348/0x3b0
> [ 4793.539303] ? __pagevec_lru_add_fn+0x189/0x2a0
> [ 4793.539307] __alloc_pages_nodemask+0x268/0x2b0
> [ 4793.539314] do_huge_pmd_anonymous_page+0x131/0x5c0
> [ 4793.539321] __handle_mm_fault+0xc0c/0x1310
> [ 4793.539327] handle_mm_fault+0xa9/0x1d0
> [ 4793.539333] __do_page_fault+0x237/0x480
> [ 4793.539339] do_page_fault+0x1d/0x67
> [ 4793.539345] ? page_fault+0x8/0x30
> [ 4793.539350] page_fault+0x1e/0x30
> [ 4793.539355] RIP: 0033:0x5879fc8c4c10
> [ 4793.539360] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c=
0 89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <=
c6> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
> [ 4793.539363] RSP: 002b:00007ffd393aa0d0 EFLAGS: 00010206
> [ 4793.539367] RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 000071435=
8a5a3db
> [ 4793.539370] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 000071410=
4876000
> [ 4793.539373] RBP: 00005879fc8c5a54 R08: 0000714104876010 R09: 000000000=
0000000
> [ 4793.539376] R10: 0000000000000022 R11: 00000002540be400 R12: fffffffff=
fffffff
> [ 4793.539379] R13: 0000000000000002 R14: 0000000000001000 R15: 000000025=
40be400
> [ 4793.539385] Sending NMI from CPU 8 to CPUs 0-7,9-11:
> [ 4793.539450] NMI backtrace for cpu 0 skipped: idling at intel_idle+0x7d=
/0x120
> [ 4793.539541] NMI backtrace for cpu 1 skipped: idling at intel_idle+0x7d=
/0x120
> [ 4793.539606] NMI backtrace for cpu 2 skipped: idling at intel_idle+0x7d=
/0x120
> [ 4793.539815] NMI backtrace for cpu 3
>
> crash> task 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 4 COMMAND: "stress"
> struct task_struct {
> thread_info =3D {
> flags =3D 2147500036,
> status =3D 0
> },
> state =3D 0,
> stack =3D 0xffff9cb9a9f54000,
> usage =3D {
> refs =3D {
> counter =3D 2
> }
> },
> flags =3D 20990016,
> ptrace =3D 0,
> wake_entry =3D {
> next =3D 0x0
> },
> on_cpu =3D 1,
> cpu =3D 4,
> wakee_flips =3D 0,
> wakee_flip_decay_ts =3D 4299663580,
> last_wakee =3D 0xffff8fd8a9e01e40,
> recent_used_cpu =3D 4,
> wake_cpu =3D 4,
> on_rq =3D 1,
> prio =3D 120,
> static_prio =3D 120,
> normal_prio =3D 120,
> rt_priority =3D 0,
> sched_class =3D 0xffffffff98c0f700,
> se =3D {
> load =3D {
> weight =3D 1048576,
> inv_weight =3D 4194304
> },
> runnable_weight =3D 1048576,
> run_node =3D {
> __rb_parent_color =3D 1,
> rb_right =3D 0x0,
> rb_left =3D 0x0
> },
> group_node =3D {
> next =3D 0xffff8fd8ad85d550,
> prev =3D 0xffff8fd8ad85d550
> },
> on_rq =3D 1,
> exec_start =3D 4987351794570,
> sum_exec_runtime =3D 275188015038,
> vruntime =3D 268378190293,
> prev_sum_exec_runtime =3D 275071762024,
> nr_migrations =3D 75,
> statistics =3D {
> wait_start =3D 0,
> wait_max =3D 0,
> wait_count =3D 0,
> wait_sum =3D 0,
> iowait_count =3D 0,
> iowait_sum =3D 0,
> sleep_start =3D 0,
> sleep_max =3D 0,
> sum_sleep_runtime =3D 0,
> block_start =3D 0,
> block_max =3D 0,
> exec_max =3D 0,
> slice_max =3D 0,
> nr_migrations_cold =3D 0,
> nr_failed_migrations_affine =3D 0,
> nr_failed_migrations_running =3D 0,
> nr_failed_migrations_hot =3D 0,
> nr_forced_migrations =3D 0,
> nr_wakeups =3D 0,
> nr_wakeups_sync =3D 0,
> nr_wakeups_migrate =3D 0,
> nr_wakeups_local =3D 0,
> nr_wakeups_remote =3D 0,
> nr_wakeups_affine =3D 0,
> nr_wakeups_affine_attempts =3D 0,
> nr_wakeups_passive =3D 0,
> nr_wakeups_idle =3D 0
> },
> depth =3D 1,
> parent =3D 0xffff8fd38de23000,
> cfs_rq =3D 0xffff8fd38de20e00,
> my_q =3D 0x0,
> avg =3D {
> last_update_time =3D 4987351793664,
> load_sum =3D 47037,
> runnable_load_sum =3D 47037,
> util_sum =3D 48192640,
> period_contrib =3D 320,
> load_avg =3D 1023,
> runnable_load_avg =3D 1023,
> util_avg =3D 1024,
> util_est =3D {
> enqueued =3D 100,
> ewma =3D 75
> }
> }
> },
> rt =3D {
> run_list =3D {
> next =3D 0xffff8fd7f10ddd00,
> prev =3D 0xffff8fd7f10ddd00
> },
> timeout =3D 0,
> watchdog_stamp =3D 0,
> time_slice =3D 100,
> on_rq =3D 0,
> on_list =3D 0,
> back =3D 0x0
> },
> sched_task_group =3D 0xffff8fd8a69f7480,
> dl =3D {
> rb_node =3D {
> __rb_parent_color =3D 18446620756357799224,
> rb_right =3D 0x0,
> rb_left =3D 0x0
> },
> dl_runtime =3D 0,
> dl_deadline =3D 0,
> dl_period =3D 0,
> dl_bw =3D 0,
> dl_density =3D 0,
> runtime =3D 0,
> deadline =3D 0,
> flags =3D 0,
> dl_throttled =3D 0,
> dl_boosted =3D 0,
> dl_yielded =3D 0,
> dl_non_contending =3D 0,
> dl_overrun =3D 0,
> dl_timer =3D {
> node =3D {
> node =3D {
> __rb_parent_color =3D 18446620756357799312,
> rb_right =3D 0x0,
> rb_left =3D 0x0
> },
> expires =3D 0
> },
> _softexpires =3D 0,
> function =3D 0xffffffff980dac70,
> base =3D 0xffff8fd8ad958b00,
> state =3D 0 '\000',
> is_rel =3D 0 '\000',
> is_soft =3D 0 '\000'
> },
> inactive_timer =3D {
> node =3D {
> node =3D {
> __rb_parent_color =3D 18446620756357799376,
> rb_right =3D 0x0,
> rb_left =3D 0x0
> },
> expires =3D 0
> },
> _softexpires =3D 0,
> function =3D 0xffffffff980d8ca0,
> base =3D 0xffff8fd8ad958b00,
> state =3D 0 '\000',
> is_rel =3D 0 '\000',
> is_soft =3D 0 '\000'
> }
> },
> policy =3D 0,
> nr_cpus_allowed =3D 12,
> cpus_allowed =3D {
> bits =3D {4095}
> },
> sched_info =3D {
> pcount =3D 927,
> run_delay =3D 10768613805,
> last_arrival =3D 4997587172423,
> last_queued =3D 0
> },
> tasks =3D {
> next =3D 0xffff8fd7ef4e8380,
> prev =3D 0xffff8fd80b12a1c0
> },
> pushable_tasks =3D {
> prio =3D 140,
> prio_list =3D {
> next =3D 0xffff8fd7f10dde58,
> prev =3D 0xffff8fd7f10dde58
> },
> node_list =3D {
> next =3D 0xffff8fd7f10dde68,
> prev =3D 0xffff8fd7f10dde68
> }
> },
> pushable_dl_tasks =3D {
> __rb_parent_color =3D 18446620756357799544,
> rb_right =3D 0x0,
> rb_left =3D 0x0
> },
> mm =3D 0xffff8fd84a0c0000,
> active_mm =3D 0xffff8fd84a0c0000,
> vmacache =3D {
> seqnum =3D 0,
> vmas =3D {0xffff8fd8064dcd80, 0xffff8fd188b0ce40, 0xffff8fd73833ed80, 0x0=
}
> },
> rss_stat =3D {
> events =3D 59,
> count =3D {0, 54, 0, 0}
> },
> exit_state =3D 0,
> exit_code =3D 0,
> exit_signal =3D 17,
> pdeath_signal =3D 0,
> jobctl =3D 0,
> personality =3D 0,
> sched_reset_on_fork =3D 0,
> sched_contributes_to_load =3D 1,
> sched_migrated =3D 0,
> sched_remote_wakeup =3D 0,
> sched_psi_wake_requeue =3D 0,
> in_execve =3D 0,
> in_iowait =3D 0,
> restore_sigmask =3D 0,
> in_user_fault =3D 1,
> no_cgroup_migration =3D 0,
> frozen =3D 0,
> use_memdelay =3D 0,
> atomic_flags =3D 0,
> restart_block =3D {
> fn =3D 0xffffffff980a97b0,
> {
> futex =3D {
> uaddr =3D 0x791b80,
> val =3D 0,
> flags =3D 0,
> bitset =3D 30,
> time =3D 685393978,
> uaddr2 =3D 0x0
> },
> nanosleep =3D {
> clockid =3D 7936896,
> type =3D TT_NONE,
> {
> rmtp =3D 0x0,
> compat_rmtp =3D 0x0
> },
> expires =3D 30
> },
> poll =3D {
> ufds =3D 0x791b80,
> nfds =3D 0,
> has_timeout =3D 0,
> tv_sec =3D 30,
> tv_nsec =3D 685393978
> }
> }
> },
> pid =3D 21120,
> tgid =3D 21120,
> stack_canary =3D 2699928380174480896,
> real_parent =3D 0xffff8fd80b129e40,
> parent =3D 0xffff8fd80b129e40,
> children =3D {
> next =3D 0xffff8fd7f10ddf60,
> prev =3D 0xffff8fd7f10ddf60
> },
> sibling =3D {
> next =3D 0xffff8fd7ef4e84b0,
> prev =3D 0xffff8fd80b12a2e0
> },
> group_leader =3D 0xffff8fd7f10ddac0,
> ptraced =3D {
> next =3D 0xffff8fd7f10ddf88,
> prev =3D 0xffff8fd7f10ddf88
> },
> ptrace_entry =3D {
> next =3D 0xffff8fd7f10ddf98,
> prev =3D 0xffff8fd7f10ddf98
> },
> thread_pid =3D 0xffff8fd8a5c6e000,
> pid_links =3D {{
> next =3D 0x0,
> pprev =3D 0xffff8fd8a5c6e008
> }, {
> next =3D 0x0,
> pprev =3D 0xffff8fd8a5c6e010
> }, {
> next =3D 0xffff8fd80b12a350,
> pprev =3D 0xffff8fd7ef4e8510
> }, {
> next =3D 0xffff8fd80b12a360,
> pprev =3D 0xffff8fd7ef4e8520
> }},
> thread_group =3D {
> next =3D 0xffff8fd7f10ddff0,
> prev =3D 0xffff8fd7f10ddff0
> },
> thread_node =3D {
> next =3D 0xffff8fd18547bfd0,
> prev =3D 0xffff8fd18547bfd0
> },
> vfork_done =3D 0x0,
> set_child_tid =3D 0x714358935a10,
> clear_child_tid =3D 0x714358935a10,
> utime =3D 2991526,
> stime =3D 275229123556,
> gtime =3D 0,
> prev_cputime =3D {
> utime =3D 0,
> stime =3D 0,
> lock =3D {
> raw_lock =3D {
> {
> val =3D {
> counter =3D 0
> },
> {
> locked =3D 0 '\000',
> pending =3D 0 '\000'
> },
> {
> locked_pending =3D 0,
> tail =3D 0
> }
> }
> }
> }
> },
> vtime =3D {
> seqcount =3D {
> sequence =3D 0
> },
> starttime =3D 0,
> state =3D VTIME_INACTIVE,
> utime =3D 0,
> stime =3D 0,
> gtime =3D 0
> },
> tick_dep_mask =3D {
> counter =3D 0
> },
> nvcsw =3D 64,
> nivcsw =3D 862,
> start_time =3D 4707054953905,
> real_start_time =3D 4707054953927,
> min_flt =3D 16888,
> maj_flt =3D 0,
> cputime_expires =3D {
> utime =3D 0,
> stime =3D 0,
> sum_exec_runtime =3D 0
> },
> cpu_timers =3D {{
> next =3D 0xffff8fd7f10de0d8,
> prev =3D 0xffff8fd7f10de0d8
> }, {
> next =3D 0xffff8fd7f10de0e8,
> prev =3D 0xffff8fd7f10de0e8
> }, {
> next =3D 0xffff8fd7f10de0f8,
> prev =3D 0xffff8fd7f10de0f8
> }},
> ptracer_cred =3D 0x0,
> real_cred =3D 0xffff8fd188b0cd80,
> cred =3D 0xffff8fd188b0cd80,
> comm =3D "stress\000ce4-term",
> nameidata =3D 0x0,
> sysvsem =3D {
> undo_list =3D 0x0
> },
> sysvshm =3D {
> shm_clist =3D {
> next =3D 0xffff8fd7f10de140,
> prev =3D 0xffff8fd7f10de140
> }
> },
> last_switch_count =3D 0,
> last_switch_time =3D 0,
> fs =3D 0xffff8fd84b0e8f40,
> files =3D 0xffff8fd2944fd600,
> nsproxy =3D 0xffffffff990349a0,
> signal =3D 0xffff8fd18547bfc0,
> sighand =3D 0xffff8fd3c8277380,
> blocked =3D {
> sig =3D {0}
> },
> real_blocked =3D {
> sig =3D {0}
> },
> saved_sigmask =3D {
> sig =3D {512}
> },
> pending =3D {
> list =3D {
> next =3D 0xffff8fd7f10de1a0,
> prev =3D 0xffff8fd7f10de1a0
> },
> signal =3D {
> sig =3D {256}
> }
> },
> sas_ss_sp =3D 0,
> sas_ss_size =3D 0,
> sas_ss_flags =3D 2,
> task_works =3D 0x0,
> audit_context =3D 0x0,
> loginuid =3D {
> val =3D 1000
> },
> sessionid =3D 1,
> seccomp =3D {
> mode =3D 0,
> filter =3D 0x0
> },
> parent_exec_id =3D 15,
> self_exec_id =3D 15,
> alloc_lock =3D {
> {
> rlock =3D {
> raw_lock =3D {
> {
> val =3D {
> counter =3D 0
> },
> {
> locked =3D 0 '\000',
> pending =3D 0 '\000'
> },
> {
> locked_pending =3D 0,
> tail =3D 0
> }
> }
> }
> }
> }
> },
> pi_lock =3D {
> raw_lock =3D {
> {
> val =3D {
> counter =3D 0
> },
> {
> locked =3D 0 '\000',
> pending =3D 0 '\000'
> },
> {
> locked_pending =3D 0,
> tail =3D 0
> }
> }
> }
> },
> wake_q =3D {
> next =3D 0x0
> },
> pi_waiters =3D {
> rb_root =3D {
> rb_node =3D 0x0
> },
> rb_leftmost =3D 0x0
> },
> pi_top_task =3D 0x0,
> pi_blocked_on =3D 0x0,
> journal_info =3D 0x0,
> bio_list =3D 0x0,
> plug =3D 0x0,
> reclaim_state =3D 0x0,
> backing_dev_info =3D 0x0,
> io_context =3D 0xffff8fd84b2ce888,
> capture_control =3D 0xffff9cb9a9f57ac0,
> ptrace_message =3D 0,
> last_siginfo =3D 0x0,
> ioac =3D {
> rchar =3D 0,
> wchar =3D 0,
> syscr =3D 0,
> syscw =3D 0,
> read_bytes =3D 0,
> write_bytes =3D 0,
> cancelled_write_bytes =3D 0
> },
> psi_flags =3D 6,
> acct_rss_mem1 =3D 3212941986541,
> acct_vm_mem1 =3D 656456860857633,
> acct_timexpd =3D 275231119481,
> mems_allowed =3D {
> bits =3D {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
> },
> mems_allowed_seq =3D {
> sequence =3D 0
> },
> cpuset_mem_spread_rotor =3D -1,
> cpuset_slab_spread_rotor =3D -1,
> cgroups =3D 0xffff8fd8a4d01800,
> cg_list =3D {
> next =3D 0xffff8fd7ef4e88a8,
> prev =3D 0xffff8fd80b12a6e8
> },
> robust_list =3D 0x0,
> compat_robust_list =3D 0x0,
> pi_state_list =3D {
> next =3D 0xffff8fd7f10de388,
> prev =3D 0xffff8fd7f10de388
> },
> pi_state_cache =3D 0x0,
> perf_event_ctxp =3D {0x0, 0x0},
> perf_event_mutex =3D {
> owner =3D {
> counter =3D 0
> },
> wait_lock =3D {
> {
> rlock =3D {
> raw_lock =3D {
> {
> val =3D {
> counter =3D 0
> },
> {
> locked =3D 0 '\000',
> pending =3D 0 '\000'
> },
> {
> locked_pending =3D 0,
> tail =3D 0
> }
> }
> }
> }
> }
> },
> osq =3D {
> tail =3D {
> counter =3D 0
> }
> },
> wait_list =3D {
> next =3D 0xffff8fd7f10de3c0,
> prev =3D 0xffff8fd7f10de3c0
> }
> },
> perf_event_list =3D {
> next =3D 0xffff8fd7f10de3d0,
> prev =3D 0xffff8fd7f10de3d0
> },
> mempolicy =3D 0x0,
> il_prev =3D 0,
> pref_node_fork =3D 0,
> numa_scan_seq =3D 0,
> numa_scan_period =3D 1000,
> numa_scan_period_max =3D 0,
> numa_preferred_nid =3D -1,
> numa_migrate_retry =3D 0,
> node_stamp =3D 0,
> last_task_numa_placement =3D 0,
> last_sum_exec_runtime =3D 0,
> numa_work =3D {
> next =3D 0xffff8fd7f10de420,
> func =3D 0x0
> },
> numa_group =3D 0x0,
> numa_faults =3D 0x0,
> total_numa_faults =3D 0,
> numa_faults_locality =3D {0, 0, 0},
> numa_pages_migrated =3D 0,
> rseq =3D 0x0,
> rseq_sig =3D 0,
> rseq_event_mask =3D 5,
> tlb_ubc =3D {
> arch =3D {
> cpumask =3D {
> bits =3D {0}
> }
> },
> flush_required =3D false,
> writable =3D false
> },
> rcu =3D {
> next =3D 0x0,
> func =3D 0x0
> },
> splice_pipe =3D 0x0,
> task_frag =3D {
> page =3D 0x0,
> offset =3D 0,
> size =3D 0
> },
> delays =3D 0xffff8fd8a638d3c0,
> nr_dirtied =3D 0,
> nr_dirtied_pause =3D 32,
> dirty_paused_when =3D 0,
> latency_record_count =3D 0,
> latency_record =3D {{
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }, {
> backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> count =3D 0,
> time =3D 0,
> max =3D 0
> }},
> timer_slack_ns =3D 50000,
> default_timer_slack_ns =3D 50000,
> memcg_in_oom =3D 0x0,
> memcg_oom_gfp_mask =3D 0,
> memcg_oom_order =3D 0,
> memcg_nr_pages_over_high =3D 0,
> active_memcg =3D 0x0,
> throttle_queue =3D 0x0,
> pagefault_disabled =3D 0,
> oom_reaper_list =3D 0x0,
> stack_vm_area =3D 0xffff8fd3895a9fc0,
> stack_refcount =3D {
> refs =3D {
> counter =3D 1
> }
> },
> security =3D 0x0,
> thread =3D {
> tls_array =3D {{
> limit0 =3D 0,
> base0 =3D 0,
> base1 =3D 0,
> type =3D 0,
> s =3D 0,
> dpl =3D 0,
> p =3D 0,
> limit1 =3D 0,
> avl =3D 0,
> l =3D 0,
> d =3D 0,
> g =3D 0,
> base2 =3D 0
> }, {
> limit0 =3D 0,
> base0 =3D 0,
> base1 =3D 0,
> type =3D 0,
> s =3D 0,
> dpl =3D 0,
> p =3D 0,
> limit1 =3D 0,
> avl =3D 0,
> l =3D 0,
> d =3D 0,
> g =3D 0,
> base2 =3D 0
> }, {
> limit0 =3D 0,
> base0 =3D 0,
> base1 =3D 0,
> type =3D 0,
> s =3D 0,
> dpl =3D 0,
> p =3D 0,
> limit1 =3D 0,
> avl =3D 0,
> l =3D 0,
> d =3D 0,
> g =3D 0,
> base2 =3D 0
> }},
> sp =3D 18446634919967160496,
> es =3D 0,
> ds =3D 0,
> fsindex =3D 0,
> gsindex =3D 0,
> fsbase =3D 124534062798656,
> gsbase =3D 0,
> ptrace_bps =3D {0x0, 0x0, 0x0, 0x0},
> debugreg6 =3D 0,
> ptrace_dr7 =3D 0,
> cr2 =3D 0,
> trap_nr =3D 0,
> error_code =3D 0,
> io_bitmap_ptr =3D 0x0,
> iopl =3D 0,
> io_bitmap_max =3D 0,
> addr_limit =3D {
> seg =3D 140737488351232
> },
> sig_on_uaccess_err =3D 0,
> uaccess_err =3D 0,
> fpu =3D {
> last_cpu =3D 9,
> avx512_timestamp =3D 0,
> state =3D {
> fsave =3D {
> cwd =3D 0,
> swd =3D 0,
> twd =3D 0,
> fip =3D 0,
> fcs =3D 0,
> foo =3D 0,
> fos =3D 0,
> st_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}=
,
> status =3D 0
> },
> fxsave =3D {
> cwd =3D 0,
> swd =3D 0,
> twd =3D 0,
> fop =3D 0,
> {
> {
> rip =3D 0,
> rdp =3D 0
> },
> {
> fip =3D 0,
> fcs =3D 0,
> foo =3D 0,
> fos =3D 0
> }
> },
> mxcsr =3D 0,
> mxcsr_mask =3D 0,
> st_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,=
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> xmm_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0=
, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0=
, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> padding =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> {
> padding1 =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> sw_reserved =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
> }
> },
> soft =3D {
> cwd =3D 0,
> swd =3D 0,
> twd =3D 0,
> fip =3D 0,
> fcs =3D 0,
> foo =3D 0,
> fos =3D 0,
> st_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}=
,
> ftop =3D 0 '\000',
> changed =3D 0 '\000',
> lookahead =3D 0 '\000',
> no_update =3D 0 '\000',
> rm =3D 0 '\000',
> alimit =3D 0 '\000',
> info =3D 0x0,
> entry_eip =3D 0
> },
> xsave =3D {
> i387 =3D {
> cwd =3D 0,
> swd =3D 0,
> twd =3D 0,
> fop =3D 0,
> {
> {
> rip =3D 0,
> rdp =3D 0
> },
> {
> fip =3D 0,
> fcs =3D 0,
> foo =3D 0,
> fos =3D 0
> }
> },
> mxcsr =3D 0,
> mxcsr_mask =3D 0,
> st_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,=
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> xmm_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0=
, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0=
, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> padding =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> {
> padding1 =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
> sw_reserved =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
> }
> },
> header =3D {
> xfeatures =3D 0,
> xcomp_bv =3D 9223372036854775839,
> reserved =3D {0, 0, 0, 0, 0, 0}
> },
> extended_state_area =3D 0xffff8fd7f10df780 ""
> },
> __padding =3D "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0=
00\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\=
000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\00=
0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0=
00\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\=
000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\00=
0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0=
00\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\=
000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\00=
0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0=
00\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\=
000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\00=
0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0=
00\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\=
000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\00=
0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0=
00\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\=
000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\00=
0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0=
00\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\=
000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000=
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000"..=
.
> }
> }
> }
> }
>
> struct thread_info {
> flags =3D 2147500036,
> status =3D 0
> }
>
> crash>
>
> crash> bt -l 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> (active)
>
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35c6
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash>
>
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57918] compact_unlock_should_abort at ffffffff981b27f8
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac66d
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac660
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac675
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b350b
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3539
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b34e4
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b373f
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b34e4
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac662
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b2e
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac662
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b350b
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35a0
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b2e
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3552
> [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b35a5
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3572
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac662
> [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b35a5
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] _cond_resched at ffffffff987f5f2b
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35ec
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3591
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3546
> [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b35a5
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac675
> [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b35a5
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac675
> [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35a5
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac660
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35a0
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] compact_unlock_should_abort at ffffffff981b27f0
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b34f9
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3546
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3798
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57918] compact_unlock_should_abort at ffffffff981b2822
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57918] compact_unlock_should_abort at ffffffff981b27f8
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] compact_unlock_should_abort at ffffffff981b27f0
> [ffff9cb9a9f57930] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f579b8] isolate_migratepages_block at ffffffff981b378e
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b373f
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57918] compact_unlock_should_abort at ffffffff981b27f8
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b350b
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash>
>
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3798
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -t 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> START: __schedule at ffffffff987f5a0c
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3539
> [ffff9cb9a9f57930] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash>
>
> crash> bt -T 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
> [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
> [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
> [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
> [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
> [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
> [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
> [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
> [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
> [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
> [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
> [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
> [ffff9cb9a9f57700] record_times at ffffffff980e8140
> [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
> [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
> [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
> [ffff9cb9a9f577c0] __free_one_page at ffffffff981d66a4
> [ffff9cb9a9f577c8] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57808] __update_load_avg_cfs_rq at ffffffff980e085f
> [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3572
> [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -T 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
> [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
> [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
> [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
> [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
> [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
> [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
> [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
> [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
> [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
> [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
> [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
> [ffff9cb9a9f57700] record_times at ffffffff980e8140
> [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
> [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
> [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
> [ffff9cb9a9f577c0] __free_one_page at ffffffff981d66a4
> [ffff9cb9a9f577c8] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57808] __update_load_avg_cfs_rq at ffffffff980e085f
> [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b350b
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash>
>
> crash> bt -T 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
> [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
> [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
> [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
> [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
> [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
> [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
> [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
> [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
> [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
> [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
> [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
> [ffff9cb9a9f57700] record_times at ffffffff980e8140
> [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
> [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
> [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
> [ffff9cb9a9f577c0] __free_one_page at ffffffff981d66a4
> [ffff9cb9a9f577c8] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57808] __update_load_avg_cfs_rq at ffffffff980e085f
> [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f57918] rcu_all_qs at ffffffff980ff319
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -T 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 9 COMMAND: "stress"
> [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
> [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
> [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
> [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
> [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
> [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
> [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
> [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
> [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
> [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
> [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
> [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
> [ffff9cb9a9f57700] record_times at ffffffff980e8140
> [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
> [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
> [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
> [ffff9cb9a9f577c0] __free_one_page at ffffffff981d66a4
> [ffff9cb9a9f577c8] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57808] __update_load_avg_cfs_rq at ffffffff980e085f
> [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3582
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash>
>
> $ colordiff -up /tmp/{a,b}
> --- /tmp/a 2019-07-16 05:09:24.145246010 +0200
> +++ /tmp/b 2019-07-16 05:09:27.399245979 +0200
> @@ -29,7 +29,8 @@ PID: 21120 TASK: ffff8fd7f10ddac0 CPU:
> [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
>
> -   [ffff9cb9a9f57918] rcu_all_qs at ffffffff980ff319
>
> -   [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
> -   [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3582
>     [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
>     [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
>     [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
>     @@ -53,4 +54,4 @@ PID: 21120 TASK: ffff8fd7f10ddac0 CPU:
>     R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
>     R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
>     ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
>
>
> -
>
> +crash>
>
> crash> bt -T 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 0 COMMAND: "stress"
> [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
> [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
> [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
> [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
> [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
> [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
> [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
> [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
> [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
> [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
> [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
> [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
> [ffff9cb9a9f57700] record_times at ffffffff980e8140
> [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
> [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
> [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
> [ffff9cb9a9f577c8] try_to_wake_up at ffffffff980c3a06
> [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57850] set_next_entity at ffffffff980cdc29
> [ffff9cb9a9f57870] pick_next_task_fair at ffffffff980d4a50
> [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3bc0
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash> bt -T 21120
> PID: 21120 TASK: ffff8fd7f10ddac0 CPU: 0 COMMAND: "stress"
> [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
> [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
> [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
> [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
> [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
> [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
> [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
> [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
> [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
> [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
> [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
> [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
> [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
> [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
> [ffff9cb9a9f57700] record_times at ffffffff980e8140
> [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
> [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
> [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
> [ffff9cb9a9f577c8] try_to_wake_up at ffffffff980c3a06
> [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
> [ffff9cb9a9f57850] set_next_entity at ffffffff980cdc29
> [ffff9cb9a9f57870] pick_next_task_fair at ffffffff980d4a50
> [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
> [ffff9cb9a9f57928] node_page_state at ffffffff981ac66d
> [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
> [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
> [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
> [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
> [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
> [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
> [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
> [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
> [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
> [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
> [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
> [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
> [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
> [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
> [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
> [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
> RIP: 00005879fc8c4c10 RSP: 00007ffd393aa0d0 RFLAGS: 00010206
> RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a5a3db
> RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 0000714104876000
> RBP: 00005879fc8c5a54 R8: 0000714104876010 R9: 0000000000000000
> R10: 0000000000000022 R11: 00000002540be400 R12: ffffffffffffffff
> R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540be400
> ORIG_RAX: ffffffffffffffff CS: 0033 SS: 002b
> crash>
>
> Ok, I don't know why but I can't start any more terminals and exiting chr=
omium also made starter terminal unusable. Some kind of lockup/wait is at h=
and!

Ok I actually ran sysrq+w and this time it showed me what got stuck and i g=
ot their (better)stacktraces via `crash` program:
all info here: https://gist.github.com/howaboutsynergy/629578627783223eb9e7=
878733968507

but here's a sample:

[ 7664.139179] ps              D    0 25471  25445 0x00000004
[ 7664.139183] Call Trace:
[ 7664.139191]  ? __schedule+0x2cc/0x590
[ 7664.139196]  schedule+0x2e/0x90
[ 7664.139201]  rwsem_down_read_failed+0x11e/0x1c0
[ 7664.139209]  __access_remote_vm+0x52/0x200
[ 7664.139216]  proc_pid_cmdline_read+0x19f/0x390
[ 7664.139224]  vfs_read+0x98/0x150
[ 7664.139230]  ksys_read+0x5d/0xe0
[ 7664.139235]  do_syscall_64+0x50/0x170
[ 7664.139241]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
[ 7664.139244] RIP: 0033:0x71f9f42c0415
[ 7664.139250] Code: Bad RIP value.
[ 7664.139253] RSP: 002b:00007ffee096b4c8 EFLAGS: 00000246 ORIG_RAX: 000000=
0000000000
[ 7664.139256] RAX: ffffffffffffffda RBX: 000071f9f3a37010 RCX: 000071f9f42=
c0415
[ 7664.139259] RDX: 0000000000020000 RSI: 000071f9f3a37010 RDI: 00000000000=
00006
[ 7664.139262] RBP: 0000000000020000 R08: 00000000ffffffff R09: 00000000000=
00013
[ 7664.139264] R10: 0000000000000000 R11: 0000000000000246 R12: 000071f9f3a=
37010
[ 7664.139267] R13: 0000000000000000 R14: 0000000000000006 R15: 00000000000=
00000

crash> bt -Tsx 25471
PID: 25471  TASK: ffff8fd695d25ac0  CPU: 0   COMMAND: "ps"
  [ffff9cb94cdeb968] prep_new_page+0x65 at ffffffff981d56b5
  [ffff9cb94cdeb978] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb94cdeb9b0] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb94cdeb9d8] xas_load+0x5 at ffffffff987ee805
  [ffff9cb94cdebb08] page_counter_try_charge+0x18 at ffffffff9820aaa8
  [ffff9cb94cdebb10] __memcg_kmem_charge_memcg+0x76 at ffffffff98211926
  [ffff9cb94cdebb18] __mod_lruvec_state+0x3a at ffffffff9820edca
  [ffff9cb94cdebc08] update_load_avg+0x76 at ffffffff980cd6a6
  [ffff9cb94cdebc48] pick_next_task_fair+0x365 at ffffffff980d4825
  [ffff9cb94cdebc78] put_prev_entity+0x19 at ffffffff980ce889
  [ffff9cb94cdebcb8] __schedule+0x2cc at ffffffff987f5a0c
  [ffff9cb94cdebd10] schedule+0x2e at ffffffff987f5cfe
  [ffff9cb94cdebd28] rwsem_down_read_failed+0x11e at ffffffff987f896e
  [ffff9cb94cdebdb0] __access_remote_vm+0x52 at ffffffff981c2182
  [ffff9cb94cdebe30] proc_pid_cmdline_read+0x19f at ffffffff9829b76f
  [ffff9cb94cdebec0] vfs_read+0x98 at ffffffff9821fe88
  [ffff9cb94cdebef8] ksys_read+0x5d at ffffffff982201ad
  [ffff9cb94cdebf38] do_syscall_64+0x50 at ffffffff98001830
  [ffff9cb94cdebf50] entry_SYSCALL_64_after_hwframe+0x44 at ffffffff9880007=
c
    RIP: 000071f9f42c0415  RSP: 00007ffee096b4c8  RFLAGS: 00000246
    RAX: ffffffffffffffda  RBX: 000071f9f3a37010  RCX: 000071f9f42c0415
    RDX: 0000000000020000  RSI: 000071f9f3a37010  RDI: 0000000000000006
    RBP: 0000000000020000   R8: 00000000ffffffff   R9: 0000000000000013
    R10: 0000000000000000  R11: 0000000000000246  R12: 000071f9f3a37010
    R13: 0000000000000000  R14: 0000000000000006  R15: 0000000000000000
    ORIG_RAX: 0000000000000000  CS: 0033  SS: 002b
crash> bt -Tsx 25445
PID: 25445  TASK: ffff8fd37cfe5ac0  CPU: 11  COMMAND: "bash"
  [ffff9cb94cd738e8] prep_new_page+0x65 at ffffffff981d56b5
  [ffff9cb94cd738f8] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb94cd73968] prep_new_page+0x65 at ffffffff981d56b5
  [ffff9cb94cd73978] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb94cd73988] update_group_capacity+0x20 at ffffffff980d2530
  [ffff9cb94cd739b8] cpumask_next_and+0x18 at ffffffff987df928
  [ffff9cb94cd739c0] update_sd_lb_stats+0x159 at ffffffff980d2839
  [ffff9cb94cd73aa0] find_busiest_group+0x4f at ffffffff980d2e9f
  [ffff9cb94cd73b10] __inode_wait_for_writeback+0x79 at ffffffff9824b499
  [ffff9cb94cd73b30] fsnotify_grab_connector+0x45 at ffffffff98264d45
  [ffff9cb94cd73b48] fsnotify_destroy_marks+0x1d at ffffffff9826582d
  [ffff9cb94cd73b80] __inode_wait_for_writeback+0x79 at ffffffff9824b499
  [ffff9cb94cd73ba0] fsnotify_grab_connector+0x45 at ffffffff98264d45
  [ffff9cb94cd73bb8] fsnotify_destroy_marks+0x1d at ffffffff9826582d
  [ffff9cb94cd73c78] update_load_avg+0x76 at ffffffff980cd6a6
  [ffff9cb94cd73cb8] pick_next_task_fair+0x365 at ffffffff980d4825
  [ffff9cb94cd73ce8] put_prev_entity+0x19 at ffffffff980ce889
  [ffff9cb94cd73d28] __schedule+0x2cc at ffffffff987f5a0c
  [ffff9cb94cd73d38] wait_consider_task+0x88b at ffffffff9809d4db
  [ffff9cb94cd73d80] schedule+0x2e at ffffffff987f5cfe
  [ffff9cb94cd73d98] do_wait+0x1b4 at ffffffff9809d6e4
  [ffff9cb94cd73de8] kernel_wait4+0xa1 at ffffffff9809e9d1
  [ffff9cb94cd73e28] child_wait_callback at ffffffff9809c730
  [ffff9cb94cd73e78] __do_sys_wait4+0x85 at ffffffff9809eaf5
  [ffff9cb94cd73ea0] handle_mm_fault+0xa9 at ffffffff981c01f9
  [ffff9cb94cd73ec8] __do_page_fault+0x255 at ffffffff9803d5e5
  [ffff9cb94cd73f38] do_syscall_64+0x50 at ffffffff98001830
  [ffff9cb94cd73f50] entry_SYSCALL_64_after_hwframe+0x44 at ffffffff9880007=
c
    RIP: 000071c78c3487bd  RSP: 00007ffe9e1d0168  RFLAGS: 00000246
    RAX: ffffffffffffffda  RBX: 00005a4399257420  RCX: 000071c78c3487bd
    RDX: 0000000000000000  RSI: 00007ffe9e1d0180  RDI: 00000000ffffffff
    RBP: 00007ffe9e1d01b0   R8: 00007ffe9e1d0110   R9: 0000000000000000
    R10: 0000000000000000  R11: 0000000000000246  R12: 0000000000000000
    R13: 00007ffe9e1d1a00  R14: 0000000000000000  R15: 0000000000000000
    ORIG_RAX: 000000000000003d  CS: 0033  SS: 002b
crash>

