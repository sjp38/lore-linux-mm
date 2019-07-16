Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A24BC76191
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:25:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 277CE20880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 03:25:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=protonmail.com header.i=@protonmail.com header.b="e7RugVhT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 277CE20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=protonmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 996356B0003; Mon, 15 Jul 2019 23:25:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91D916B0005; Mon, 15 Jul 2019 23:25:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7231C6B0006; Mon, 15 Jul 2019 23:25:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB59D6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 23:25:19 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i44so15198501eda.3
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 20:25:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:dkim-signature:to:from:cc:reply-to:subject
         :message-id:in-reply-to:references:feedback-id:mime-version
         :content-transfer-encoding;
        bh=tzDbOo82/8wwILRRzHdtYpHIpiKsGBo7Uu3Hwu3PDMk=;
        b=N6T5Fol2ZSl2szKtTAEQ+uJyKUbcZQVS1xUgb97mIkqJu/pmRBOCq89RxxCutPIRVO
         qtg7zwllz6VFYCf0q+661w7pgmGvzBwdPPG3mgrxjhtLbzq8r98bsYSNu2OL3qR/b4rS
         VgUEAA4ut2WqEK23ibdWzYjv4gRMRHHoIcgRK29wZ4jR7fyQj5dAKhXYx/8U9ui12sGu
         9Dkn+QUv8r6TaWOP2fj+bgH4BLIhbVp2dlhLNE+rN2PiWR6Gz8xFrWLnw3GNaHril5uY
         +rdaFuCToMIaNINzdsdqctnBDzEGQ2xkyGJVFNKSq9NeH7SROAXGZJSXVyc4x9PuBFVX
         kUWQ==
X-Gm-Message-State: APjAAAWr2c6Vb335VDDBRGetf5UREou9N9BSxuUojF+HKDFUzV7hmx6R
	xFxo78xVEXeUEHm8UXN2pupE7IwEMIxKJlzdaFwhiSoplXs3I9HtVdLblpHsqHi1ci15LcmimmU
	Ongw5Rp7IcZqmNXaCPfFdv+L6tunQVBJM9E6gCy8ioJO6UOBJvKMBcBViPtBlonCvzw==
X-Received: by 2002:a17:906:3f87:: with SMTP id b7mr23170272ejj.164.1563247519059;
        Mon, 15 Jul 2019 20:25:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMF7THlRiX/suezl3VAlvl+4q41fiIF/dz6l3Rp1/6AELHuuZlE+JQ/q8bP30mgDpH0J9t
X-Received: by 2002:a17:906:3f87:: with SMTP id b7mr23170099ejj.164.1563247514804;
        Mon, 15 Jul 2019 20:25:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563247514; cv=none;
        d=google.com; s=arc-20160816;
        b=yaxWu0XuEb8KZIVxOfiCSTEwVxyv5adtg+kplxEcmNd2v0fTGvxyH87eYfW9KN+weX
         JxclurrWhg6C9SHWd6tiIjbDVCk1mc3nit6a9A0FTXYRbxJXkjOls8/o5Uxg737Z815Q
         ePZcv+u27f1A3hc1pNisAjlN3XFzKnXR3S64Y4XzFm5R4akw3CwAp1Zk2CDmbOChNIr+
         sk/OBQLYP0IjlztkSi+4rZwXLGtl9JiD5xOmRvMODYo9a9F9NLS30WBClUYdUbcT9uoe
         y9wHyDAD2aP8T8chxaIL2E712Ycxx5+4mQ5fSwnVwJ3wIpnVVroMDCh0J2OGEnzluP1p
         FADg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:feedback-id:references
         :in-reply-to:message-id:subject:reply-to:cc:from:to:dkim-signature
         :date;
        bh=tzDbOo82/8wwILRRzHdtYpHIpiKsGBo7Uu3Hwu3PDMk=;
        b=RBUcDxh/hie9ZE6ejZ8BQwIvNXOlqyij1dn1ijP40Anb9YaAixxCCCa3jnxxElclL0
         VfrVEcA4k1vWe9J4oG4GXDrknHjdf8T8FTcuDI2to0OI4LBwYzvTu5JKMlx/fIY5G7Fa
         YnKZzVtbaMD1MKdqDJ3Dgtp0w7TzWWUf3XxpJHoosOlh6K7Pc+09TikPkW2Bj0VDxVgx
         /5RyHNNL7XT0yzMYAelBpa3c3+2C/UtkUy6T3Xlgc2GvQbGNxVWHgWUGdHMEqGtH/E87
         mMgOqMp5LGfQ9SQs0PnImHasGiBbVOLSQ9caxo0yOK1XwxS8zD0NQ0QYuwmRXxmL90/f
         q4eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=e7RugVhT;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Received: from mail-40136.protonmail.ch (mail-40136.protonmail.ch. [185.70.40.136])
        by mx.google.com with ESMTPS id n27si188927eja.377.2019.07.15.20.25.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 20:25:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) client-ip=185.70.40.136;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@protonmail.com header.s=default header.b=e7RugVhT;
       spf=pass (google.com: domain of howaboutsynergy@protonmail.com designates 185.70.40.136 as permitted sender) smtp.mailfrom=howaboutsynergy@protonmail.com;
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=protonmail.com
Date: Tue, 16 Jul 2019 03:25:04 +0000
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=protonmail.com;
	s=default; t=1563247508;
	bh=tzDbOo82/8wwILRRzHdtYpHIpiKsGBo7Uu3Hwu3PDMk=;
	h=Date:To:From:Cc:Reply-To:Subject:In-Reply-To:References:
	 Feedback-ID:From;
	b=e7RugVhTZH8PycXJLrPCFZ9heJ8+P4nkx1P1HM07bnh3TJqIbJEUUAUGMCOt8UeP/
	 8cgRUKTkIZCPCPbWuYDTWz43D0eW+GoRdxhcdVPFLxtS5A2Uo1B1riuzarHN56Gh9P
	 aBm1jDZPZLI3PojeTqqysPsqLV9+dBmzuI3c3qbM=
To: Andrew Morton <akpm@linux-foundation.org>
From: howaboutsynergy@protonmail.com
Cc: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@techsingularity.net>
Reply-To: howaboutsynergy@protonmail.com
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
In-Reply-To: <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
 <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
Feedback-ID: cNV1IIhYZ3vPN2m1zihrGlihbXC6JOgZ5ekTcEurWYhfLPyLhpq0qxICavacolSJ7w0W_XBloqfdO_txKTblOQ==:Ext:ProtonMail
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I got more info/better stacktrace(seen at the end):

[ 4793.539013] sysrq: Show backtrace of all active CPUs
[ 4793.539019] NMI backtrace for cpu 8
[ 4793.539026] CPU: 8 PID: 21120 Comm: stress Kdump: loaded Tainted: G     =
U            5.2.1-g527a3db363a3 #68
[ 4793.539029] Hardware name: System manufacturer System Product Name/PRIME=
 Z370-A, BIOS 1002 07/02/2018
[ 4793.539032] Call Trace:
[ 4793.539036]  <IRQ>
[ 4793.539047]  dump_stack+0x46/0x60
[ 4793.539054]  nmi_cpu_backtrace.cold+0x14/0x53
[ 4793.539061]  ? lapic_can_unplug_cpu.cold+0x42/0x42
[ 4793.539067]  nmi_trigger_cpumask_backtrace+0x8e/0x90
[ 4793.539073]  __handle_sysrq.cold+0x48/0x102
[ 4793.539078]  sysrq_filter+0x2ea/0x3b0
[ 4793.539084]  input_to_handler+0x4d/0xf0
[ 4793.539090]  input_pass_values.part.0+0x109/0x130
[ 4793.539096]  input_handle_event+0x171/0x5a0
[ 4793.539101]  input_event+0x4d/0x70
[ 4793.539107]  hidinput_report_event+0x2e/0x40
[ 4793.539112]  hid_report_raw_event+0x260/0x430
[ 4793.539118]  hid_input_report+0xfb/0x150
[ 4793.539124]  hid_irq_in+0x168/0x190
[ 4793.539131]  __usb_hcd_giveback_urb+0x77/0xe0
[ 4793.539148]  xhci_giveback_urb_in_irq.isra.0+0x62/0x90 [xhci_hcd]
[ 4793.539163]  xhci_td_cleanup+0xf7/0x140 [xhci_hcd]
[ 4793.539177]  xhci_irq+0x7e8/0x1be0 [xhci_hcd]
[ 4793.539185]  __handle_irq_event_percpu+0x2f/0xc0
[ 4793.539191]  handle_irq_event_percpu+0x2c/0x80
[ 4793.539196]  handle_irq_event+0x23/0x43
[ 4793.539202]  handle_edge_irq+0x78/0x190
[ 4793.539208]  handle_irq+0x17/0x20
[ 4793.539215]  do_IRQ+0x3e/0xd0
[ 4793.539221]  common_interrupt+0xf/0xf
[ 4793.539225]  </IRQ>
[ 4793.539231] RIP: 0010:isolate_migratepages_block+0x1d3/0xa50
[ 4793.539237] Code: df 77 27 45 84 ed 74 22 4d 85 d2 0f 85 a7 00 00 00 41 =
8b 44 24 60 be 01 00 00 00 c4 e2 f9 f7 c6 4c 8d 3c 18 48 f7 d8 49 21 c7 <f6=
> c3 1f 0f 84 ec 00 00 00 48 ff 44 24 10 48 8b 05 68 b3 d1 00 48
[ 4793.539240] RSP: 0018:ffff9cb9a9f57958 EFLAGS: 00000206 ORIG_RAX: ffffff=
ffffffffde
[ 4793.539246] RAX: ffff9cb9a9f57b49 RBX: 00000000004b4b00 RCX: 00000000000=
0000c
[ 4793.539249] RDX: 00000000004b4c00 RSI: 0000000000000007 RDI: 00000000000=
00000
[ 4793.539252] RBP: ffff8fd8cdfde000 R08: ffff8fd8cdfd9960 R09: ffff8fd8ada=
5d550
[ 4793.539254] R10: 0000000000000000 R11: ffff8fd8ada5cb80 R12: ffff9cb9a9f=
57ad0
[ 4793.539257] R13: 0000000000000001 R14: ffff9cb9a9f57ad0 R15: 00000000004=
b4c00
[ 4793.539264]  ? isolate_migratepages_block+0xd5/0xa50
[ 4793.539269]  compact_zone+0x577/0xa70
[ 4793.539275]  compact_zone_order+0xde/0x120
[ 4793.539280]  try_to_compact_pages+0x187/0x240
[ 4793.539286]  __alloc_pages_direct_compact+0x87/0x170
[ 4793.539291]  __alloc_pages_slowpath+0x20e/0xc20
[ 4793.539297]  ? release_pages+0x348/0x3b0
[ 4793.539303]  ? __pagevec_lru_add_fn+0x189/0x2a0
[ 4793.539307]  __alloc_pages_nodemask+0x268/0x2b0
[ 4793.539314]  do_huge_pmd_anonymous_page+0x131/0x5c0
[ 4793.539321]  __handle_mm_fault+0xc0c/0x1310
[ 4793.539327]  handle_mm_fault+0xa9/0x1d0
[ 4793.539333]  __do_page_fault+0x237/0x480
[ 4793.539339]  do_page_fault+0x1d/0x67
[ 4793.539345]  ? page_fault+0x8/0x30
[ 4793.539350]  page_fault+0x1e/0x30
[ 4793.539355] RIP: 0033:0x5879fc8c4c10
[ 4793.539360] Code: c0 0f 84 53 02 00 00 8b 54 24 0c 31 c0 85 d2 0f 94 c0 =
89 04 24 41 83 fd 02 0f 8f fa 00 00 00 31 c0 4d 85 ff 7e 10 0f 1f 40 00 <c6=
> 04 03 5a 4c 01 f0 49 39 c7 7f f4 4d 85 e4 0f 84 f4 01 00 00 7e
[ 4793.539363] RSP: 002b:00007ffd393aa0d0 EFLAGS: 00010206
[ 4793.539367] RAX: 0000000010b8a000 RBX: 0000714104876010 RCX: 0000714358a=
5a3db
[ 4793.539370] RDX: 0000000000000000 RSI: 00000002540bf000 RDI: 00007141048=
76000
[ 4793.539373] RBP: 00005879fc8c5a54 R08: 0000714104876010 R09: 00000000000=
00000
[ 4793.539376] R10: 0000000000000022 R11: 00000002540be400 R12: fffffffffff=
fffff
[ 4793.539379] R13: 0000000000000002 R14: 0000000000001000 R15: 00000002540=
be400
[ 4793.539385] Sending NMI from CPU 8 to CPUs 0-7,9-11:
[ 4793.539450] NMI backtrace for cpu 0 skipped: idling at intel_idle+0x7d/0=
x120
[ 4793.539541] NMI backtrace for cpu 1 skipped: idling at intel_idle+0x7d/0=
x120
[ 4793.539606] NMI backtrace for cpu 2 skipped: idling at intel_idle+0x7d/0=
x120
[ 4793.539815] NMI backtrace for cpu 3



crash> task 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 4   COMMAND: "stress"
struct task_struct {
  thread_info =3D {
    flags =3D 2147500036,
    status =3D 0
  },
  state =3D 0,
  stack =3D 0xffff9cb9a9f54000,
  usage =3D {
    refs =3D {
      counter =3D 2
    }
  },
  flags =3D 20990016,
  ptrace =3D 0,
  wake_entry =3D {
    next =3D 0x0
  },
  on_cpu =3D 1,
  cpu =3D 4,
  wakee_flips =3D 0,
  wakee_flip_decay_ts =3D 4299663580,
  last_wakee =3D 0xffff8fd8a9e01e40,
  recent_used_cpu =3D 4,
  wake_cpu =3D 4,
  on_rq =3D 1,
  prio =3D 120,
  static_prio =3D 120,
  normal_prio =3D 120,
  rt_priority =3D 0,
  sched_class =3D 0xffffffff98c0f700,
  se =3D {
    load =3D {
      weight =3D 1048576,
      inv_weight =3D 4194304
    },
    runnable_weight =3D 1048576,
    run_node =3D {
      __rb_parent_color =3D 1,
      rb_right =3D 0x0,
      rb_left =3D 0x0
    },
    group_node =3D {
      next =3D 0xffff8fd8ad85d550,
      prev =3D 0xffff8fd8ad85d550
    },
    on_rq =3D 1,
    exec_start =3D 4987351794570,
    sum_exec_runtime =3D 275188015038,
    vruntime =3D 268378190293,
    prev_sum_exec_runtime =3D 275071762024,
    nr_migrations =3D 75,
    statistics =3D {
      wait_start =3D 0,
      wait_max =3D 0,
      wait_count =3D 0,
      wait_sum =3D 0,
      iowait_count =3D 0,
      iowait_sum =3D 0,
      sleep_start =3D 0,
      sleep_max =3D 0,
      sum_sleep_runtime =3D 0,
      block_start =3D 0,
      block_max =3D 0,
      exec_max =3D 0,
      slice_max =3D 0,
      nr_migrations_cold =3D 0,
      nr_failed_migrations_affine =3D 0,
      nr_failed_migrations_running =3D 0,
      nr_failed_migrations_hot =3D 0,
      nr_forced_migrations =3D 0,
      nr_wakeups =3D 0,
      nr_wakeups_sync =3D 0,
      nr_wakeups_migrate =3D 0,
      nr_wakeups_local =3D 0,
      nr_wakeups_remote =3D 0,
      nr_wakeups_affine =3D 0,
      nr_wakeups_affine_attempts =3D 0,
      nr_wakeups_passive =3D 0,
      nr_wakeups_idle =3D 0
    },
    depth =3D 1,
    parent =3D 0xffff8fd38de23000,
    cfs_rq =3D 0xffff8fd38de20e00,
    my_q =3D 0x0,
    avg =3D {
      last_update_time =3D 4987351793664,
      load_sum =3D 47037,
      runnable_load_sum =3D 47037,
      util_sum =3D 48192640,
      period_contrib =3D 320,
      load_avg =3D 1023,
      runnable_load_avg =3D 1023,
      util_avg =3D 1024,
      util_est =3D {
        enqueued =3D 100,
        ewma =3D 75
      }
    }
  },
  rt =3D {
    run_list =3D {
      next =3D 0xffff8fd7f10ddd00,
      prev =3D 0xffff8fd7f10ddd00
    },
    timeout =3D 0,
    watchdog_stamp =3D 0,
    time_slice =3D 100,
    on_rq =3D 0,
    on_list =3D 0,
    back =3D 0x0
  },
  sched_task_group =3D 0xffff8fd8a69f7480,
  dl =3D {
    rb_node =3D {
      __rb_parent_color =3D 18446620756357799224,
      rb_right =3D 0x0,
      rb_left =3D 0x0
    },
    dl_runtime =3D 0,
    dl_deadline =3D 0,
    dl_period =3D 0,
    dl_bw =3D 0,
    dl_density =3D 0,
    runtime =3D 0,
    deadline =3D 0,
    flags =3D 0,
    dl_throttled =3D 0,
    dl_boosted =3D 0,
    dl_yielded =3D 0,
    dl_non_contending =3D 0,
    dl_overrun =3D 0,
    dl_timer =3D {
      node =3D {
        node =3D {
          __rb_parent_color =3D 18446620756357799312,
          rb_right =3D 0x0,
          rb_left =3D 0x0
        },
        expires =3D 0
      },
      _softexpires =3D 0,
      function =3D 0xffffffff980dac70,
      base =3D 0xffff8fd8ad958b00,
      state =3D 0 '\000',
      is_rel =3D 0 '\000',
      is_soft =3D 0 '\000'
    },
    inactive_timer =3D {
      node =3D {
        node =3D {
          __rb_parent_color =3D 18446620756357799376,
          rb_right =3D 0x0,
          rb_left =3D 0x0
        },
        expires =3D 0
      },
      _softexpires =3D 0,
      function =3D 0xffffffff980d8ca0,
      base =3D 0xffff8fd8ad958b00,
      state =3D 0 '\000',
      is_rel =3D 0 '\000',
      is_soft =3D 0 '\000'
    }
  },
  policy =3D 0,
  nr_cpus_allowed =3D 12,
  cpus_allowed =3D {
    bits =3D {4095}
  },
  sched_info =3D {
    pcount =3D 927,
    run_delay =3D 10768613805,
    last_arrival =3D 4997587172423,
    last_queued =3D 0
  },
  tasks =3D {
    next =3D 0xffff8fd7ef4e8380,
    prev =3D 0xffff8fd80b12a1c0
  },
  pushable_tasks =3D {
    prio =3D 140,
    prio_list =3D {
      next =3D 0xffff8fd7f10dde58,
      prev =3D 0xffff8fd7f10dde58
    },
    node_list =3D {
      next =3D 0xffff8fd7f10dde68,
      prev =3D 0xffff8fd7f10dde68
    }
  },
  pushable_dl_tasks =3D {
    __rb_parent_color =3D 18446620756357799544,
    rb_right =3D 0x0,
    rb_left =3D 0x0
  },
  mm =3D 0xffff8fd84a0c0000,
  active_mm =3D 0xffff8fd84a0c0000,
  vmacache =3D {
    seqnum =3D 0,
    vmas =3D {0xffff8fd8064dcd80, 0xffff8fd188b0ce40, 0xffff8fd73833ed80, 0=
x0}
  },
  rss_stat =3D {
    events =3D 59,
    count =3D {0, 54, 0, 0}
  },
  exit_state =3D 0,
  exit_code =3D 0,
  exit_signal =3D 17,
  pdeath_signal =3D 0,
  jobctl =3D 0,
  personality =3D 0,
  sched_reset_on_fork =3D 0,
  sched_contributes_to_load =3D 1,
  sched_migrated =3D 0,
  sched_remote_wakeup =3D 0,
  sched_psi_wake_requeue =3D 0,
  in_execve =3D 0,
  in_iowait =3D 0,
  restore_sigmask =3D 0,
  in_user_fault =3D 1,
  no_cgroup_migration =3D 0,
  frozen =3D 0,
  use_memdelay =3D 0,
  atomic_flags =3D 0,
  restart_block =3D {
    fn =3D 0xffffffff980a97b0,
    {
      futex =3D {
        uaddr =3D 0x791b80,
        val =3D 0,
        flags =3D 0,
        bitset =3D 30,
        time =3D 685393978,
        uaddr2 =3D 0x0
      },
      nanosleep =3D {
        clockid =3D 7936896,
        type =3D TT_NONE,
        {
          rmtp =3D 0x0,
          compat_rmtp =3D 0x0
        },
        expires =3D 30
      },
      poll =3D {
        ufds =3D 0x791b80,
        nfds =3D 0,
        has_timeout =3D 0,
        tv_sec =3D 30,
        tv_nsec =3D 685393978
      }
    }
  },
  pid =3D 21120,
  tgid =3D 21120,
  stack_canary =3D 2699928380174480896,
  real_parent =3D 0xffff8fd80b129e40,
  parent =3D 0xffff8fd80b129e40,
  children =3D {
    next =3D 0xffff8fd7f10ddf60,
    prev =3D 0xffff8fd7f10ddf60
  },
  sibling =3D {
    next =3D 0xffff8fd7ef4e84b0,
    prev =3D 0xffff8fd80b12a2e0
  },
  group_leader =3D 0xffff8fd7f10ddac0,
  ptraced =3D {
    next =3D 0xffff8fd7f10ddf88,
    prev =3D 0xffff8fd7f10ddf88
  },
  ptrace_entry =3D {
    next =3D 0xffff8fd7f10ddf98,
    prev =3D 0xffff8fd7f10ddf98
  },
  thread_pid =3D 0xffff8fd8a5c6e000,
  pid_links =3D {{
      next =3D 0x0,
      pprev =3D 0xffff8fd8a5c6e008
    }, {
      next =3D 0x0,
      pprev =3D 0xffff8fd8a5c6e010
    }, {
      next =3D 0xffff8fd80b12a350,
      pprev =3D 0xffff8fd7ef4e8510
    }, {
      next =3D 0xffff8fd80b12a360,
      pprev =3D 0xffff8fd7ef4e8520
    }},
  thread_group =3D {
    next =3D 0xffff8fd7f10ddff0,
    prev =3D 0xffff8fd7f10ddff0
  },
  thread_node =3D {
    next =3D 0xffff8fd18547bfd0,
    prev =3D 0xffff8fd18547bfd0
  },
  vfork_done =3D 0x0,
  set_child_tid =3D 0x714358935a10,
  clear_child_tid =3D 0x714358935a10,
  utime =3D 2991526,
  stime =3D 275229123556,
  gtime =3D 0,
  prev_cputime =3D {
    utime =3D 0,
    stime =3D 0,
    lock =3D {
      raw_lock =3D {
        {
          val =3D {
            counter =3D 0
          },
          {
            locked =3D 0 '\000',
            pending =3D 0 '\000'
          },
          {
            locked_pending =3D 0,
            tail =3D 0
          }
        }
      }
    }
  },
  vtime =3D {
    seqcount =3D {
      sequence =3D 0
    },
    starttime =3D 0,
    state =3D VTIME_INACTIVE,
    utime =3D 0,
    stime =3D 0,
    gtime =3D 0
  },
  tick_dep_mask =3D {
    counter =3D 0
  },
  nvcsw =3D 64,
  nivcsw =3D 862,
  start_time =3D 4707054953905,
  real_start_time =3D 4707054953927,
  min_flt =3D 16888,
  maj_flt =3D 0,
  cputime_expires =3D {
    utime =3D 0,
    stime =3D 0,
    sum_exec_runtime =3D 0
  },
  cpu_timers =3D {{
      next =3D 0xffff8fd7f10de0d8,
      prev =3D 0xffff8fd7f10de0d8
    }, {
      next =3D 0xffff8fd7f10de0e8,
      prev =3D 0xffff8fd7f10de0e8
    }, {
      next =3D 0xffff8fd7f10de0f8,
      prev =3D 0xffff8fd7f10de0f8
    }},
  ptracer_cred =3D 0x0,
  real_cred =3D 0xffff8fd188b0cd80,
  cred =3D 0xffff8fd188b0cd80,
  comm =3D "stress\000ce4-term",
  nameidata =3D 0x0,
  sysvsem =3D {
    undo_list =3D 0x0
  },
  sysvshm =3D {
    shm_clist =3D {
      next =3D 0xffff8fd7f10de140,
      prev =3D 0xffff8fd7f10de140
    }
  },
  last_switch_count =3D 0,
  last_switch_time =3D 0,
  fs =3D 0xffff8fd84b0e8f40,
  files =3D 0xffff8fd2944fd600,
  nsproxy =3D 0xffffffff990349a0,
  signal =3D 0xffff8fd18547bfc0,
  sighand =3D 0xffff8fd3c8277380,
  blocked =3D {
    sig =3D {0}
  },
  real_blocked =3D {
    sig =3D {0}
  },
  saved_sigmask =3D {
    sig =3D {512}
  },
  pending =3D {
    list =3D {
      next =3D 0xffff8fd7f10de1a0,
      prev =3D 0xffff8fd7f10de1a0
    },
    signal =3D {
      sig =3D {256}
    }
  },
  sas_ss_sp =3D 0,
  sas_ss_size =3D 0,
  sas_ss_flags =3D 2,
  task_works =3D 0x0,
  audit_context =3D 0x0,
  loginuid =3D {
    val =3D 1000
  },
  sessionid =3D 1,
  seccomp =3D {
    mode =3D 0,
    filter =3D 0x0
  },
  parent_exec_id =3D 15,
  self_exec_id =3D 15,
  alloc_lock =3D {
    {
      rlock =3D {
        raw_lock =3D {
          {
            val =3D {
              counter =3D 0
            },
            {
              locked =3D 0 '\000',
              pending =3D 0 '\000'
            },
            {
              locked_pending =3D 0,
              tail =3D 0
            }
          }
        }
      }
    }
  },
  pi_lock =3D {
    raw_lock =3D {
      {
        val =3D {
          counter =3D 0
        },
        {
          locked =3D 0 '\000',
          pending =3D 0 '\000'
        },
        {
          locked_pending =3D 0,
          tail =3D 0
        }
      }
    }
  },
  wake_q =3D {
    next =3D 0x0
  },
  pi_waiters =3D {
    rb_root =3D {
      rb_node =3D 0x0
    },
    rb_leftmost =3D 0x0
  },
  pi_top_task =3D 0x0,
  pi_blocked_on =3D 0x0,
  journal_info =3D 0x0,
  bio_list =3D 0x0,
  plug =3D 0x0,
  reclaim_state =3D 0x0,
  backing_dev_info =3D 0x0,
  io_context =3D 0xffff8fd84b2ce888,
  capture_control =3D 0xffff9cb9a9f57ac0,
  ptrace_message =3D 0,
  last_siginfo =3D 0x0,
  ioac =3D {
    rchar =3D 0,
    wchar =3D 0,
    syscr =3D 0,
    syscw =3D 0,
    read_bytes =3D 0,
    write_bytes =3D 0,
    cancelled_write_bytes =3D 0
  },
  psi_flags =3D 6,
  acct_rss_mem1 =3D 3212941986541,
  acct_vm_mem1 =3D 656456860857633,
  acct_timexpd =3D 275231119481,
  mems_allowed =3D {
    bits =3D {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
  },
  mems_allowed_seq =3D {
    sequence =3D 0
  },
  cpuset_mem_spread_rotor =3D -1,
  cpuset_slab_spread_rotor =3D -1,
  cgroups =3D 0xffff8fd8a4d01800,
  cg_list =3D {
    next =3D 0xffff8fd7ef4e88a8,
    prev =3D 0xffff8fd80b12a6e8
  },
  robust_list =3D 0x0,
  compat_robust_list =3D 0x0,
  pi_state_list =3D {
    next =3D 0xffff8fd7f10de388,
    prev =3D 0xffff8fd7f10de388
  },
  pi_state_cache =3D 0x0,
  perf_event_ctxp =3D {0x0, 0x0},
  perf_event_mutex =3D {
    owner =3D {
      counter =3D 0
    },
    wait_lock =3D {
      {
        rlock =3D {
          raw_lock =3D {
            {
              val =3D {
                counter =3D 0
              },
              {
                locked =3D 0 '\000',
                pending =3D 0 '\000'
              },
              {
                locked_pending =3D 0,
                tail =3D 0
              }
            }
          }
        }
      }
    },
    osq =3D {
      tail =3D {
        counter =3D 0
      }
    },
    wait_list =3D {
      next =3D 0xffff8fd7f10de3c0,
      prev =3D 0xffff8fd7f10de3c0
    }
  },
  perf_event_list =3D {
    next =3D 0xffff8fd7f10de3d0,
    prev =3D 0xffff8fd7f10de3d0
  },
  mempolicy =3D 0x0,
  il_prev =3D 0,
  pref_node_fork =3D 0,
  numa_scan_seq =3D 0,
  numa_scan_period =3D 1000,
  numa_scan_period_max =3D 0,
  numa_preferred_nid =3D -1,
  numa_migrate_retry =3D 0,
  node_stamp =3D 0,
  last_task_numa_placement =3D 0,
  last_sum_exec_runtime =3D 0,
  numa_work =3D {
    next =3D 0xffff8fd7f10de420,
    func =3D 0x0
  },
  numa_group =3D 0x0,
  numa_faults =3D 0x0,
  total_numa_faults =3D 0,
  numa_faults_locality =3D {0, 0, 0},
  numa_pages_migrated =3D 0,
  rseq =3D 0x0,
  rseq_sig =3D 0,
  rseq_event_mask =3D 5,
  tlb_ubc =3D {
    arch =3D {
      cpumask =3D {
        bits =3D {0}
      }
    },
    flush_required =3D false,
    writable =3D false
  },
  rcu =3D {
    next =3D 0x0,
    func =3D 0x0
  },
  splice_pipe =3D 0x0,
  task_frag =3D {
    page =3D 0x0,
    offset =3D 0,
    size =3D 0
  },
  delays =3D 0xffff8fd8a638d3c0,
  nr_dirtied =3D 0,
  nr_dirtied_pause =3D 32,
  dirty_paused_when =3D 0,
  latency_record_count =3D 0,
  latency_record =3D {{
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }, {
      backtrace =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
      count =3D 0,
      time =3D 0,
      max =3D 0
    }},
  timer_slack_ns =3D 50000,
  default_timer_slack_ns =3D 50000,
  memcg_in_oom =3D 0x0,
  memcg_oom_gfp_mask =3D 0,
  memcg_oom_order =3D 0,
  memcg_nr_pages_over_high =3D 0,
  active_memcg =3D 0x0,
  throttle_queue =3D 0x0,
  pagefault_disabled =3D 0,
  oom_reaper_list =3D 0x0,
  stack_vm_area =3D 0xffff8fd3895a9fc0,
  stack_refcount =3D {
    refs =3D {
      counter =3D 1
    }
  },
  security =3D 0x0,
  thread =3D {
    tls_array =3D {{
        limit0 =3D 0,
        base0 =3D 0,
        base1 =3D 0,
        type =3D 0,
        s =3D 0,
        dpl =3D 0,
        p =3D 0,
        limit1 =3D 0,
        avl =3D 0,
        l =3D 0,
        d =3D 0,
        g =3D 0,
        base2 =3D 0
      }, {
        limit0 =3D 0,
        base0 =3D 0,
        base1 =3D 0,
        type =3D 0,
        s =3D 0,
        dpl =3D 0,
        p =3D 0,
        limit1 =3D 0,
        avl =3D 0,
        l =3D 0,
        d =3D 0,
        g =3D 0,
        base2 =3D 0
      }, {
        limit0 =3D 0,
        base0 =3D 0,
        base1 =3D 0,
        type =3D 0,
        s =3D 0,
        dpl =3D 0,
        p =3D 0,
        limit1 =3D 0,
        avl =3D 0,
        l =3D 0,
        d =3D 0,
        g =3D 0,
        base2 =3D 0
      }},
    sp =3D 18446634919967160496,
    es =3D 0,
    ds =3D 0,
    fsindex =3D 0,
    gsindex =3D 0,
    fsbase =3D 124534062798656,
    gsbase =3D 0,
    ptrace_bps =3D {0x0, 0x0, 0x0, 0x0},
    debugreg6 =3D 0,
    ptrace_dr7 =3D 0,
    cr2 =3D 0,
    trap_nr =3D 0,
    error_code =3D 0,
    io_bitmap_ptr =3D 0x0,
    iopl =3D 0,
    io_bitmap_max =3D 0,
    addr_limit =3D {
      seg =3D 140737488351232
    },
    sig_on_uaccess_err =3D 0,
    uaccess_err =3D 0,
    fpu =3D {
      last_cpu =3D 9,
      avx512_timestamp =3D 0,
      state =3D {
        fsave =3D {
          cwd =3D 0,
          swd =3D 0,
          twd =3D 0,
          fip =3D 0,
          fcs =3D 0,
          foo =3D 0,
          fos =3D 0,
          st_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0},
          status =3D 0
        },
        fxsave =3D {
          cwd =3D 0,
          swd =3D 0,
          twd =3D 0,
          fop =3D 0,
          {
            {
              rip =3D 0,
              rdp =3D 0
            },
            {
              fip =3D 0,
              fcs =3D 0,
              foo =3D 0,
              fos =3D 0
            }
          },
          mxcsr =3D 0,
          mxcsr_mask =3D 0,
          st_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
          xmm_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,=
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,=
 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
          padding =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
          {
            padding1 =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            sw_reserved =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
          }
        },
        soft =3D {
          cwd =3D 0,
          swd =3D 0,
          twd =3D 0,
          fip =3D 0,
          fcs =3D 0,
          foo =3D 0,
          fos =3D 0,
          st_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0},
          ftop =3D 0 '\000',
          changed =3D 0 '\000',
          lookahead =3D 0 '\000',
          no_update =3D 0 '\000',
          rm =3D 0 '\000',
          alimit =3D 0 '\000',
          info =3D 0x0,
          entry_eip =3D 0
        },
        xsave =3D {
          i387 =3D {
            cwd =3D 0,
            swd =3D 0,
            twd =3D 0,
            fop =3D 0,
            {
              {
                rip =3D 0,
                rdp =3D 0
              },
              {
                fip =3D 0,
                fcs =3D 0,
                foo =3D 0,
                fos =3D 0
              }
            },
            mxcsr =3D 0,
            mxcsr_mask =3D 0,
            st_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0=
, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            xmm_space =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            padding =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
            {
              padding1 =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
              sw_reserved =3D {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
            }
          },
          header =3D {
            xfeatures =3D 0,
            xcomp_bv =3D 9223372036854775839,
            reserved =3D {0, 0, 0, 0, 0, 0}
          },
          extended_state_area =3D 0xffff8fd7f10df780 ""
        },
        __padding =3D "\000\000\000\000\000\000\000\000\000\000\000\000\000=
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
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\00=
0\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\0=
00\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\=
000"...
      }
    }
  }
}

struct thread_info {
  flags =3D 2147500036,
  status =3D 0
}

crash>


crash> bt -l 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
(active)

crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35c6
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash>

crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57918] compact_unlock_should_abort at ffffffff981b27f8
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac66d
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac660
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac675
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b350b
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3539
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b34e4
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b373f
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b34e4
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac662
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b2e
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac662
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b350b
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35a0
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b2e
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3552
  [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b35a5
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3572
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac662
  [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b35a5
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] _cond_resched at ffffffff987f5f2b
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35ec
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3591
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3546
  [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b35a5
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac675
  [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b35a5
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac675
  [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35a5
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac660
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b35a0
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] compact_unlock_should_abort at ffffffff981b27f0
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b34f9
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3546
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3798
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57918] compact_unlock_should_abort at ffffffff981b2822
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57918] compact_unlock_should_abort at ffffffff981b27f8
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4b69
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] compact_unlock_should_abort at ffffffff981b27f0
  [ffff9cb9a9f57930] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f579b8] isolate_migratepages_block at ffffffff981b378e
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b373f
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57918] compact_unlock_should_abort at ffffffff981b27f8
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b350b
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash>

crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3798
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -t 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
              START: __schedule at ffffffff987f5a0c
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3539
  [ffff9cb9a9f57930] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash>


crash> bt -T 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
  [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
  [ffff9cb9a9f57700] record_times at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
  [ffff9cb9a9f577c0] __free_one_page at ffffffff981d66a4
  [ffff9cb9a9f577c8] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57808] __update_load_avg_cfs_rq at ffffffff980e085f
  [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3572
  [ffff9cb9a9f57948] _cond_resched at ffffffff987f5f30
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -T 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
  [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
  [ffff9cb9a9f57700] record_times at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
  [ffff9cb9a9f577c0] __free_one_page at ffffffff981d66a4
  [ffff9cb9a9f577c8] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57808] __update_load_avg_cfs_rq at ffffffff980e085f
  [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b350b
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash>

crash> bt -T 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
  [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
  [ffff9cb9a9f57700] record_times at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
  [ffff9cb9a9f577c0] __free_one_page at ffffffff981d66a4
  [ffff9cb9a9f577c8] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57808] __update_load_avg_cfs_rq at ffffffff980e085f
  [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f57918] rcu_all_qs at ffffffff980ff319
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -T 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 9   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
  [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
  [ffff9cb9a9f57700] record_times at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
  [ffff9cb9a9f577c0] __free_one_page at ffffffff981d66a4
  [ffff9cb9a9f577c8] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57808] __update_load_avg_cfs_rq at ffffffff980e085f
  [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3582
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash>

$ colordiff -up /tmp/{a,b}
--- /tmp/a=092019-07-16 05:09:24.145246010 +0200
+++ /tmp/b=092019-07-16 05:09:27.399245979 +0200
@@ -29,7 +29,8 @@ PID: 21120  TASK: ffff8fd7f10ddac0  CPU:
   [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
   [ffff9cb9a9f57858] update_load_avg at ffffffff980cd6a6
   [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
-  [ffff9cb9a9f57918] rcu_all_qs at ffffffff980ff319
+  [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
+  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3582
   [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
   [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
   [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
@@ -53,4 +54,4 @@ PID: 21120  TASK: ffff8fd7f10ddac0  CPU:
     R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
     R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
     ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
-
+crash>

crash> bt -T 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 0   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
  [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
  [ffff9cb9a9f57700] record_times at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
  [ffff9cb9a9f577c8] try_to_wake_up at ffffffff980c3a06
  [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57850] set_next_entity at ffffffff980cdc29
  [ffff9cb9a9f57870] pick_next_task_fair at ffffffff980d4a50
  [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f57928] isolate_migratepages_block at ffffffff981b3bc0
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -T 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 0   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal at ffffffff9849ecbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal at ffffffff9849f709
  [ffff9cb9a9f575d8] ZSTD_compressEnd at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity at ffffffff980cea64
  [ffff9cb9a9f57700] record_times at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup at ffffffff980c2d02
  [ffff9cb9a9f577c8] try_to_wake_up at ffffffff980c3a06
  [ffff9cb9a9f57810] update_load_avg at ffffffff980cd6a6
  [ffff9cb9a9f57850] set_next_entity at ffffffff980cdc29
  [ffff9cb9a9f57870] pick_next_task_fair at ffffffff980d4a50
  [ffff9cb9a9f57890] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f578a0] apic_timer_interrupt at ffffffff9880146a
  [ffff9cb9a9f57928] node_page_state at ffffffff981ac66d
  [ffff9cb9a9f57950] isolate_migratepages_block at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash>

Ok, I don't know why but I can't start any more terminals and exiting chrom=
ium also made starter terminal unusable. Some kind of lockup/wait is at han=
d!
here's last of `strace bash -l`:
clone(child_stack=3DNULL, flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|S=
IGCHLD, child_tidptr=3D0x7733e277fa10) =3D 22571
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) =3D 0
rt_sigaction(SIGCHLD, {sa_handler=3D0x623cac34987a, sa_mask=3D[], sa_flags=
=3DSA_RESTORER|SA_RESTART, sa_restorer=3D0x7733e27c8910}, {sa_handler=3D0x6=
23cac34987a, sa_mask=3D[], sa_flags=3DSA_RESTORER|SA_RESTART, sa_restorer=
=3D0x7733e27c8910}, 8) =3D 0
close(4)                                =3D 0
read(3, "\33[4m", 512)                  =3D 4
read(3, "", 512)                        =3D 0
--- SIGCHLD {si_signo=3DSIGCHLD, si_code=3DCLD_EXITED, si_pid=3D22571, si_u=
id=3D1000, si_status=3D0, si_utime=3D0, si_stime=3D0} ---
wait4(-1, [{WIFEXITED(s) && WEXITSTATUS(s) =3D=3D 0}], WNOHANG, NULL) =3D 2=
2571
wait4(-1, 0x7ffc85dc1b50, WNOHANG, NULL) =3D -1 ECHILD (No child processes)
rt_sigreturn({mask=3D[]})                 =3D 0
close(3)                                =3D 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) =3D 0
rt_sigaction(SIGINT, {sa_handler=3D0x623cac347485, sa_mask=3D[], sa_flags=
=3DSA_RESTORER, sa_restorer=3D0x7733e27c8910}, {sa_handler=3D0x623cac36e877=
, sa_mask=3D[], sa_flags=3DSA_RESTORER, sa_restorer=3D0x7733e27c8910}, 8) =
=3D 0
rt_sigaction(SIGINT, {sa_handler=3D0x623cac36e877, sa_mask=3D[], sa_flags=
=3DSA_RESTORER, sa_restorer=3D0x7733e27c8910}, {sa_handler=3D0x623cac347485=
, sa_mask=3D[], sa_flags=3DSA_RESTORER, sa_restorer=3D0x7733e27c8910}, 8) =
=3D 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) =3D 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) =3D 0
pipe([3, 4])                            =3D 0
rt_sigprocmask(SIG_BLOCK, [INT CHLD], [CHLD], 8) =3D 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [INT CHLD], 8) =3D 0
rt_sigprocmask(SIG_SETMASK, [INT CHLD], NULL, 8) =3D 0
clone(child_stack=3DNULL, flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|S=
IGCHLD, child_tidptr=3D0x7733e277fa10) =3D 22572
rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) =3D 0
close(4)                                =3D 0
close(4)                                =3D -1 EBADF (Bad file descriptor)
rt_sigprocmask(SIG_BLOCK, [INT CHLD], [CHLD], 8) =3D 0
clone(child_stack=3DNULL, flags=3DCLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|S=
IGCHLD, child_tidptr=3D0x7733e277fa10) =3D 22573
rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) =3D 0
close(3)                                =3D 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [CHLD], 8) =3D 0
rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) =3D 0
rt_sigprocmask(SIG_BLOCK, [CHLD], [CHLD], 8) =3D 0
rt_sigaction(SIGINT, {sa_handler=3D0x623cac347485, sa_mask=3D[], sa_flags=
=3DSA_RESTORER, sa_restorer=3D0x7733e27c8910}, {sa_handler=3D0x623cac36e877=
, sa_mask=3D[], sa_flags=3DSA_RESTORER, sa_restorer=3D0x7733e27c8910}, 8) =
=3D 0
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1, 0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted =
if SA_RESTART is set)
--- SIGWINCH {si_signo=3DSIGWINCH, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D 61
wait4(-1,
^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted if SA_RE=
START is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, [{WIFSIGNALED(s) && WTERMSIG(s) =3D=3D SIGINT}], 0, NULL) =3D 225=
73
wait4(-1,
^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarted if SA_RE=
START is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1, ^C0x7ffc85dc2690, 0, NULL)      =3D ? ERESTARTSYS (To be restarte=
d if SA_RESTART is set)
--- SIGINT {si_signo=3DSIGINT, si_code=3DSI_KERNEL} ---
rt_sigreturn({mask=3D[CHLD]})             =3D -1 EINTR (Interrupted system =
call)
wait4(-1,

crash> bt -f 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 4   COMMAND: "stress"
(active)
crash> bt -F 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 4   COMMAND: "stress"
(active)
crash> bt -FF 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 4   COMMAND: "stress"
(active)
crash> bt -v 21120
No stack overflows detected

crash> bt -Tsx 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 4   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds+0x4f at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath+0x175 at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp+0xba at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt+0xa at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal+0x8db at ffffffff9849e=
cbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal+0xad at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal+0x1c9 at ffffffff9849f7=
09
  [ffff9cb9a9f575d8] ZSTD_compressEnd+0x1e at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc+0x1e3 at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg+0x42b at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue+0xbf at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity+0xe4 at ffffffff980cea64
  [ffff9cb9a9f57700] record_times+0x10 at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup+0x182 at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr+0x70 at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup+0x12 at ffffffff980c2d02
  [ffff9cb9a9f577c8] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f57810] update_load_avg+0x76 at ffffffff980cd6a6
  [ffff9cb9a9f57850] set_next_entity+0x89 at ffffffff980cdc29
  [ffff9cb9a9f57858] update_load_avg+0x76 at ffffffff980cd6a6
  [ffff9cb9a9f57890] apic_timer_interrupt+0xa at ffffffff9880146a
  [ffff9cb9a9f578a0] apic_timer_interrupt+0xa at ffffffff9880146a
  [ffff9cb9a9f57928] node_page_state+0x15 at ffffffff981ac675
  [ffff9cb9a9f57948] _cond_resched+0x10 at ffffffff987f5f30
  [ffff9cb9a9f57950] isolate_migratepages_block+0xd5 at ffffffff981b35a5
  [ffff9cb9a9f57a10] compact_zone+0x577 at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order+0xde at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages+0x187 at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact+0x87 at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath+0x20e at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages+0x348 at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn+0x189 at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask+0x268 at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page+0x131 at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault+0xc0c at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault+0xa9 at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault+0x237 at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault+0x1d at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault+0x8 at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault+0x1e at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b

crash> bt -Tsx 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 4   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds+0x4f at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath+0x175 at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp+0xba at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt+0xa at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal+0x8db at ffffffff9849e=
cbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal+0xad at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal+0x1c9 at ffffffff9849f7=
09
  [ffff9cb9a9f575d8] ZSTD_compressEnd+0x1e at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc+0x1e3 at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg+0x42b at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue+0xbf at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity+0xe4 at ffffffff980cea64
  [ffff9cb9a9f57700] record_times+0x10 at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup+0x182 at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr+0x70 at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup+0x12 at ffffffff980c2d02
  [ffff9cb9a9f577c8] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f57810] update_load_avg+0x76 at ffffffff980cd6a6
  [ffff9cb9a9f57850] set_next_entity+0x89 at ffffffff980cdc29
  [ffff9cb9a9f57870] pick_next_task_fair+0x590 at ffffffff980d4a50
  [ffff9cb9a9f57890] apic_timer_interrupt+0xa at ffffffff9880146a
  [ffff9cb9a9f578a0] apic_timer_interrupt+0xa at ffffffff9880146a
  [ffff9cb9a9f57928] isolate_migratepages_block+0x2a7 at ffffffff981b3777
  [ffff9cb9a9f57950] isolate_migratepages_block+0x2ed at ffffffff981b37bd
  [ffff9cb9a9f57a10] compact_zone+0x577 at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order+0xde at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages+0x187 at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact+0x87 at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath+0x20e at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages+0x348 at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn+0x189 at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask+0x268 at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page+0x131 at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault+0xc0c at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault+0xa9 at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault+0x237 at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault+0x1d at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault+0x8 at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault+0x1e at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash> bt -Tsx 21120
PID: 21120  TASK: ffff8fd7f10ddac0  CPU: 4   COMMAND: "stress"
  [ffff9cb9a9f57160] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57180] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57200] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f572f8] wake_all_kswapds+0x4f at ffffffff981d5e5f
  [ffff9cb9a9f57338] __alloc_pages_slowpath+0x175 at ffffffff981d9955
  [ffff9cb9a9f57368] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57378] get_page_from_freelist+0xe88 at ffffffff981d9078
  [ffff9cb9a9f57408] FSE_buildCTable_wksp+0xba at ffffffff98485f5a
  [ffff9cb9a9f57410] reschedule_interrupt+0xa at ffffffff9880152a
  [ffff9cb9a9f57478] ZSTD_compressSequences_internal+0x8db at ffffffff9849e=
cbb
  [ffff9cb9a9f57548] ZSTD_compressBlock_internal+0xad at ffffffff9849f4dd
  [ffff9cb9a9f57570] ZSTD_compressContinue_internal+0x1c9 at ffffffff9849f7=
09
  [ffff9cb9a9f575d8] ZSTD_compressEnd+0x1e at ffffffff9849f9ae
  [ffff9cb9a9f57620] zs_malloc+0x1e3 at ffffffff98217ad3
  [ffff9cb9a9f57648] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f57668] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f576b8] update_load_avg+0x42b at ffffffff980cda5b
  [ffff9cb9a9f576c0] account_entity_enqueue+0xbf at ffffffff980cc13f
  [ffff9cb9a9f576f8] enqueue_entity+0xe4 at ffffffff980cea64
  [ffff9cb9a9f57700] record_times+0x10 at ffffffff980e8140
  [ffff9cb9a9f57750] check_preempt_wakeup+0x182 at ffffffff980cd422
  [ffff9cb9a9f57798] check_preempt_curr+0x70 at ffffffff980c2ce0
  [ffff9cb9a9f577a8] ttwu_do_wakeup+0x12 at ffffffff980c2d02
  [ffff9cb9a9f577c8] __update_load_avg_se+0x200 at ffffffff980e05d0
  [ffff9cb9a9f57810] update_load_avg+0x76 at ffffffff980cd6a6
  [ffff9cb9a9f57850] set_next_entity+0x89 at ffffffff980cdc29
  [ffff9cb9a9f57870] pick_next_task_fair+0x590 at ffffffff980d4a50
  [ffff9cb9a9f57890] apic_timer_interrupt+0xa at ffffffff9880146a
  [ffff9cb9a9f578a0] apic_timer_interrupt+0xa at ffffffff9880146a
  [ffff9cb9a9f57928] isolate_migratepages_block+0xd5 at ffffffff981b35a5
  [ffff9cb9a9f57930] apic_timer_interrupt+0xa at ffffffff9880146a
  [ffff9cb9a9f57950] isolate_migratepages_block+0x2ed at ffffffff981b37bd
  [ffff9cb9a9f579b8] isolate_migratepages_block+0x9 at ffffffff981b34d9
  [ffff9cb9a9f57a10] compact_zone+0x577 at ffffffff981b4c07
  [ffff9cb9a9f57ab8] compact_zone_order+0xde at ffffffff981b51de
  [ffff9cb9a9f57b78] try_to_compact_pages+0x187 at ffffffff981b5a17
  [ffff9cb9a9f57bd8] __alloc_pages_direct_compact+0x87 at ffffffff981d95a7
  [ffff9cb9a9f57c30] __alloc_pages_slowpath+0x20e at ffffffff981d99ee
  [ffff9cb9a9f57cd0] release_pages+0x348 at ffffffff9819aa08
  [ffff9cb9a9f57d00] __pagevec_lru_add_fn+0x189 at ffffffff9819ada9
  [ffff9cb9a9f57d40] __alloc_pages_nodemask+0x268 at ffffffff981da668
  [ffff9cb9a9f57da0] do_huge_pmd_anonymous_page+0x131 at ffffffff98202c01
  [ffff9cb9a9f57df0] __handle_mm_fault+0xc0c at ffffffff981bfa4c
  [ffff9cb9a9f57ea0] handle_mm_fault+0xa9 at ffffffff981c01f9
  [ffff9cb9a9f57ec8] __do_page_fault+0x237 at ffffffff9803d5c7
  [ffff9cb9a9f57f28] do_page_fault+0x1d at ffffffff9803d85d
  [ffff9cb9a9f57f48] page_fault+0x8 at ffffffff98800de8
  [ffff9cb9a9f57f50] page_fault+0x1e at ffffffff98800dfe
    RIP: 00005879fc8c4c10  RSP: 00007ffd393aa0d0  RFLAGS: 00010206
    RAX: 0000000010b8a000  RBX: 0000714104876010  RCX: 0000714358a5a3db
    RDX: 0000000000000000  RSI: 00000002540bf000  RDI: 0000714104876000
    RBP: 00005879fc8c5a54   R8: 0000714104876010   R9: 0000000000000000
    R10: 0000000000000022  R11: 00000002540be400  R12: ffffffffffffffff
    R13: 0000000000000002  R14: 0000000000001000  R15: 00000002540be400
    ORIG_RAX: ffffffffffffffff  CS: 0033  SS: 002b
crash>

diff of the above two:
$ colordiff -up /tmp/{c,d}
--- /tmp/c=092019-07-16 05:20:20.959239746 +0200
+++ /tmp/d=092019-07-16 05:20:29.450239665 +0200
@@ -29,8 +29,10 @@ PID: 21120  TASK: ffff8fd7f10ddac0  CPU:
   [ffff9cb9a9f57870] pick_next_task_fair+0x590 at ffffffff980d4a50
   [ffff9cb9a9f57890] apic_timer_interrupt+0xa at ffffffff9880146a
   [ffff9cb9a9f578a0] apic_timer_interrupt+0xa at ffffffff9880146a
-  [ffff9cb9a9f57928] isolate_migratepages_block+0x2a7 at ffffffff981b3777
+  [ffff9cb9a9f57928] isolate_migratepages_block+0xd5 at ffffffff981b35a5
+  [ffff9cb9a9f57930] apic_timer_interrupt+0xa at ffffffff9880146a
   [ffff9cb9a9f57950] isolate_migratepages_block+0x2ed at ffffffff981b37bd
+  [ffff9cb9a9f579b8] isolate_migratepages_block+0x9 at ffffffff981b34d9
   [ffff9cb9a9f57a10] compact_zone+0x577 at ffffffff981b4c07
   [ffff9cb9a9f57ab8] compact_zone_order+0xde at ffffffff981b51de
   [ffff9cb9a9f57b78] try_to_compact_pages+0x187 at ffffffff981b5a17


