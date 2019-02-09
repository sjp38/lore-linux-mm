Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3FF3C169C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 01:03:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31BA0217D8
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 01:03:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=mailprotect.be header.i=@mailprotect.be header.b="Kgi5Tg3t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31BA0217D8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD1288E00A8; Fri,  8 Feb 2019 20:03:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7E768E0002; Fri,  8 Feb 2019 20:03:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A466A8E00A8; Fri,  8 Feb 2019 20:03:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 36A628E0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2019 20:03:32 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m25so3243761edp.22
        for <linux-mm@kvack.org>; Fri, 08 Feb 2019 17:03:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=/9XSQv/RVAVGAfr8Hu7GVGGDas7Qqh3/3xiTV9rhKv8=;
        b=JJVZbbXAM/3cYIgJiYMdGEYmMUwQYkRtipqeREpQJxFRJIyiJjw210NX7kDnSAe/Nz
         dS+BlHQKqqK9j4jwWEx0l/IYXwYU1ERY7VK2i3Ra7obSgErmOn5QhqCxwC0eAc4mfLCy
         IdXM6mKqWMG49cmtSmK1U4kJXx0tbP19tGC+V+3camoI5Jd9EwosuN2DT06HHGV2YaDz
         G36qWAplHVOFsmKnkSci9ZbK2QiRR7Ky06XfgJeWQAcnVC9G0QIf6/UkI1AbJ4PQ8j1b
         uDPSkFqb2CAGq7D+S34ZKDi7gBS/dqsKDx1W0lLf+pR+LtfLLpP2BQp6iNhjW6WM3wTP
         /Trg==
X-Gm-Message-State: AHQUAuYoBoyzkHfxHxLjsMZML99a6bbLkq4S2I1bOcc1m8abw+r2uF4A
	yISzkCTBGpNyqp/Y+ESN4HfvyK6MbSi28+TBSamHO7VnP0HS30kwTxGvBApXFyT8A+DNhfGf2lE
	32/m9pyX8pSabWNiTYGXh4/zqSYG9pQ7k2AwPLmTCWMIWDEPKK4Tlk3QZHtHbQb8=
X-Received: by 2002:a50:c408:: with SMTP id v8mr18862490edf.144.1549674211643;
        Fri, 08 Feb 2019 17:03:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaKFDxH8NAyuUSb5uJ7Bw7FLVV67ZdHE07b4Zvzn56rzZSZAs2SpE6kKBJ98oJdZ1F5vj7k
X-Received: by 2002:a50:c408:: with SMTP id v8mr18862414edf.144.1549674209875;
        Fri, 08 Feb 2019 17:03:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549674209; cv=none;
        d=google.com; s=arc-20160816;
        b=s9J3bJ+abpGRk1SmQNMz5V2B9wAZkR6J2qjLVdnsSCkfDSHVHYgYZiy9SvN0MLj/1o
         hfYZqEG25I54lXRthlC/VIfnXaW3yb+hi7omphaiTbk0dKFEFGvFuLGc7iKRBZNL/Prm
         WZFSgcZhxc+lAc/00hnySgZwnQki5crjNH9RB60dYMtxXP9SyJQcTK8D5ptvXldWwd3q
         WRShnMLTfC4fx5+H8l+oOBcsLdBXWbRNj+NfXHTPW/u8JDB8XazE27SBUQqH8eodBmDV
         kNnAZRUVue9t4BtsF4dWo9DZ1bsjWOAtBrzBBimuOU65Jw9o2kgaa6YfVuCvPL+bpf8f
         N/WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=/9XSQv/RVAVGAfr8Hu7GVGGDas7Qqh3/3xiTV9rhKv8=;
        b=oTlfaINLNu4FmIY4rHJxPou0ebJ01IV9DRdxJexaPhEB4vUZHlf57cNd2PeLolGdE8
         wTxqf4Nsx6T02DownAH6VBNQZ+1uUZ4EBZSEfDb2j3NSW0uIrvWN3mNa8GosWPxufJMn
         dNtQuM4WAmWColtZnQB9yyFejGnryKD4Hm26ep41tIuv8MtSLazHtRZaBuhdWKtPhemy
         608/ih9baDXdsgpnFHx/0EBm2J3+WuJCgbDM9WSNxfd28egK7op+cZZ9/JAVZo2HaxwL
         CSUFa7zyoHRe+4YnocA9VCF40Lo2VecJx6AVWAgcpVeyjPMFtB/JPMHhD4mYHj97E+iR
         XrbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@mailprotect.be header.s=mail header.b=Kgi5Tg3t;
       spf=softfail (google.com: domain of transitioning bvanassche@acm.org does not designate 83.217.72.83 as permitted sender) smtp.mailfrom=bvanassche@acm.org
Received: from com-out001.mailprotect.be (com-out001.mailprotect.be. [83.217.72.83])
        by mx.google.com with ESMTPS id w13si630974edv.429.2019.02.08.17.03.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Feb 2019 17:03:29 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning bvanassche@acm.org does not designate 83.217.72.83 as permitted sender) client-ip=83.217.72.83;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@mailprotect.be header.s=mail header.b=Kgi5Tg3t;
       spf=softfail (google.com: domain of transitioning bvanassche@acm.org does not designate 83.217.72.83 as permitted sender) smtp.mailfrom=bvanassche@acm.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=mailprotect.be; s=mail; h=Content-Transfer-Encoding:MIME-Version:Message-Id
	:Date:Subject:Cc:To:From:reply-to:sender:bcc:in-reply-to:references:
	content-type; bh=/9XSQv/RVAVGAfr8Hu7GVGGDas7Qqh3/3xiTV9rhKv8=; b=Kgi5Tg3tAHll
	vSmBK9/e6SCqDGUafEsErHogVgCMNKmLuOepJhC7/fCNmhQIjissuBth2ETjMe1Kt6Z0298F7QU+D
	RnzewkAycIvdr5weHy7wBnvELyo8fC2I7EvPSprLBWbr7Ez6WvAIuYxskZEBGXSBpKsnNW+xeZ7dq
	ZNAV7DbqnWApsMZkr9NdruF3A0i5MDbyalmcxGcmFAXnh5CnUtXawoEGE6Y+h/BoK6a0Vd04WOj+q
	BpPoeBPDkHciMwUVRN4+g5lGv8Q+Dlbn4BCauiRQQr+Cr2Ss8w3sLIKTr7MveuGUVLNpOkJQSfsU2
	Vk0QK5UrN78M619zN2bfLg==;
Received: from smtp-auth.mailprotect.be ([178.208.39.159])
	by com-mpt-out001.mailprotect.be with esmtp (Exim 4.89)
	(envelope-from <bvanassche@acm.org>)
	id 1gsH3F-0008zr-BF; Sat, 09 Feb 2019 02:03:26 +0100
Received: from desktop-bart.svl.corp.google.com (unknown [104.133.8.89])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-auth.mailprotect.be (Postfix) with ESMTPSA id BCB2AC0926;
	Sat,  9 Feb 2019 02:03:18 +0100 (CET)
From: Bart Van Assche <bvanassche@acm.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org,
	Bart Van Assche <bvanassche@acm.org>,
	Christoph Hellwig <hch@infradead.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	stable@vger.kernel.org,
	syzbot <syzkaller@googlegroups.com>
Subject: [PATCH] fs/userfaultd: Fix a recently introduced lockdep complaint
Date: Fri,  8 Feb 2019 17:03:08 -0800
Message-Id: <20190209010308.115292-1-bvanassche@acm.org>
X-Mailer: git-send-email 2.20.1.791.gb4d0f1c61a-goog
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Originating-IP: 178.208.39.159
X-SpamExperts-Domain: mailprotect.be
X-SpamExperts-Username: 178.208.39.128/27
Authentication-Results: mailprotect.be; auth=pass smtp.auth=178.208.39.128/27@mailprotect.be
X-SpamExperts-Outgoing-Class: ham
X-SpamExperts-Outgoing-Evidence: SB/global_tokens (0.00207417865716)
X-Recommended-Action: accept
X-Filter-ID: EX5BVjFpneJeBchSMxfU5jcHkdeg4U1Q+xiMOYywf0x602E9L7XzfQH6nu9C/Fh9KJzpNe6xgvOx
 q3u0UDjvO1tLifGj39bI0bcPyaJsYTYYiiy70zs6xIwcvfBOV8As8zm5OiQsZ7r7lzEnyYpP4iWX
 o0SunJXNWsU4YtWbo+lEZl6BZs559WCoTQqspq0xFsEXKGqLGprMZqGuhrzgWVmgu1sX37K6siw5
 xPr0JTUGQrVP/SOmO6bW6IE1HQcoff5LuxzrPG/XqSNMJPUinSQVN75P+FMV26gz865tzSVTYi2b
 f0F0JzgUQ/o6tR7CP2Z0BPFt5b5pCLBWHJg8WeBnWEau7JcDXCVOBrich82VuAfQHc7upq20Yq1a
 2HeeePzncaL7/QifA3gLurBxQXZ6y2m1IDcxDv0FNAX55zTnflixTjNEqN6yUeXEb3CudMPVq96i
 2WCiml3f86Qj697pGo89PvllAFUxz4uLrVvpxOsB8gG0slV7ra6jI4BS1+w96/ss2n9PRXrBw2Il
 YfpluiiwIYYOt3H/IYSfrpElxpDER6moT/CNs+Wejmmrt6+Wn6r+yB7573dqb4LwXOfC5fGvBaRW
 nWe6WFte+h1HBQQL7n9+OTZ37LZfI/sW30YZMgUX6Z4ThlOFxTu4LSgthNtAwpEzrNvrou5cdSWk
 ASe0zzIoSVH5jzhBWWljP0+Yrc3yJ/hDG/J/KzxsIo/yXIk618YVJp5jM2kZcUgHPUbw7CVpNolc
 zSoTuJsRnENsSECCOsy4kitQ2EVON7qmMricrFscQjEDTPZmmyAdCImlOIACP5lcMfDQhCnROFLV
 itzSW5sh0zXHexcLCOp/fYdEAhcvFLGNAi49Bl6weaj65i50konxuLnHe1ulL90i3mEry6pZi2rN
 jRMo6eEPs/B5FR2DxQ26rHITgGNVXXNivsGnmtpVDp6La/3zUL8tt0mV0nzGe0cxxh9Zdp2jynN8
 kL8UJsyrAIl4gWyZLhdLj43b6pJ2LU0tKk+CH+J4C5itCzm22YlwXskBKVYlOKBPp3EGKXx0BpzT
 08Grja0apnSiP5oWi/7/Pj5od9uswVwkUZDzWTnmYZfNyLYGZHEZAp6DM6bNcPGZclqeTpcGFENX
 o3kNRiamRjFtFgh7QNOSmB7ovQFI+5xcQGcgoMWRyDQOgOfu0/aOm8s7w8AHH7f583yKbcz0aytv
 0oYJCvyFIwjQngUII4ny0UFTVL8eE/ddS4Fzroc1kQUxL7hrJSk60SF3F6RYOYr2
X-Report-Abuse-To: spam@com-mpt-mgt001.mailprotect.be
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Avoid that lockdep reports the following:

=====================================================
WARNING: SOFTIRQ-safe -> SOFTIRQ-unsafe lock order detected
5.0.0-rc4+ #56 Not tainted
-----------------------------------------------------
syz-executor5/9727 [HC0[0]:SC0[0]:HE0:SE1] is trying to acquire:
00000000a4278d31 (&ctx->fault_pending_wqh){+.+.}, at: spin_lock include/linux/spinlock.h:329 [inline]
00000000a4278d31 (&ctx->fault_pending_wqh){+.+.}, at: userfaultfd_ctx_read fs/userfaultfd.c:1040 [inline]
00000000a4278d31 (&ctx->fault_pending_wqh){+.+.}, at: userfaultfd_read+0x540/0x1940 fs/userfaultfd.c:1198

and this task is already holding:
000000000e5b4350 (&ctx->fd_wqh){....}, at: spin_lock_irq include/linux/spinlock.h:354 [inline]
000000000e5b4350 (&ctx->fd_wqh){....}, at: userfaultfd_ctx_read fs/userfaultfd.c:1036 [inline]
000000000e5b4350 (&ctx->fd_wqh){....}, at: userfaultfd_read+0x27a/0x1940 fs/userfaultfd.c:1198
which would create a new lock dependency:
 (&ctx->fd_wqh){....} -> (&ctx->fault_pending_wqh){+.+.}

but this new dependency connects a SOFTIRQ-irq-safe lock:
 (&(&ctx->ctx_lock)->rlock){..-.}

... which became SOFTIRQ-irq-safe at:
  lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
  __raw_spin_lock_irq include/linux/spinlock_api_smp.h:128 [inline]
  _raw_spin_lock_irq+0x60/0x80 kernel/locking/spinlock.c:160
  spin_lock_irq include/linux/spinlock.h:354 [inline]
  free_ioctx_users+0x2d/0x4a0 fs/aio.c:610
  percpu_ref_put_many include/linux/percpu-refcount.h:285 [inline]
  percpu_ref_put include/linux/percpu-refcount.h:301 [inline]
  percpu_ref_call_confirm_rcu lib/percpu-refcount.c:123 [inline]
  percpu_ref_switch_to_atomic_rcu+0x3e7/0x520 lib/percpu-refcount.c:158
  __rcu_reclaim kernel/rcu/rcu.h:240 [inline]
  rcu_do_batch kernel/rcu/tree.c:2452 [inline]
  invoke_rcu_callbacks kernel/rcu/tree.c:2773 [inline]
  rcu_process_callbacks+0x928/0x1390 kernel/rcu/tree.c:2754
  __do_softirq+0x266/0x95a kernel/softirq.c:292
  run_ksoftirqd kernel/softirq.c:654 [inline]
  run_ksoftirqd+0x8e/0x110 kernel/softirq.c:646
  smpboot_thread_fn+0x6ab/0xa10 kernel/smpboot.c:164
  kthread+0x357/0x430 kernel/kthread.c:246
  ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352

to a SOFTIRQ-irq-unsafe lock:
 (&ctx->fault_pending_wqh){+.+.}

... which became SOFTIRQ-irq-unsafe at:
...
  lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
  __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
  _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
  spin_lock include/linux/spinlock.h:329 [inline]
  userfaultfd_release+0x497/0x6d0 fs/userfaultfd.c:916
  __fput+0x2df/0x8d0 fs/file_table.c:278
  ____fput+0x16/0x20 fs/file_table.c:309
  task_work_run+0x14a/0x1c0 kernel/task_work.c:113
  tracehook_notify_resume include/linux/tracehook.h:188 [inline]
  exit_to_usermode_loop+0x273/0x2c0 arch/x86/entry/common.c:166
  prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
  syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
  do_syscall_64+0x52d/0x610 arch/x86/entry/common.c:293
  entry_SYSCALL_64_after_hwframe+0x49/0xbe

other info that might help us debug this:

Chain exists of:
  &(&ctx->ctx_lock)->rlock --> &ctx->fd_wqh --> &ctx->fault_pending_wqh

 Possible interrupt unsafe locking scenario:

       CPU0                    CPU1
       ----                    ----
  lock(&ctx->fault_pending_wqh);
                               local_irq_disable();
                               lock(&(&ctx->ctx_lock)->rlock);
                               lock(&ctx->fd_wqh);
  <Interrupt>
    lock(&(&ctx->ctx_lock)->rlock);

 *** DEADLOCK ***

1 lock held by syz-executor5/9727:
 #0: 000000000e5b4350 (&ctx->fd_wqh){....}, at: spin_lock_irq include/linux/spinlock.h:354 [inline]
 #0: 000000000e5b4350 (&ctx->fd_wqh){....}, at: userfaultfd_ctx_read fs/userfaultfd.c:1036 [inline]
 #0: 000000000e5b4350 (&ctx->fd_wqh){....}, at: userfaultfd_read+0x27a/0x1940 fs/userfaultfd.c:1198

the dependencies between SOFTIRQ-irq-safe lock and the holding lock:
 -> (&(&ctx->ctx_lock)->rlock){..-.} {
    IN-SOFTIRQ-W at:
                      lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
                      __raw_spin_lock_irq include/linux/spinlock_api_smp.h:128 [inline]
                      _raw_spin_lock_irq+0x60/0x80 kernel/locking/spinlock.c:160
                      spin_lock_irq include/linux/spinlock.h:354 [inline]
                      free_ioctx_users+0x2d/0x4a0 fs/aio.c:610
                      percpu_ref_put_many include/linux/percpu-refcount.h:285 [inline]
                      percpu_ref_put include/linux/percpu-refcount.h:301 [inline]
                      percpu_ref_call_confirm_rcu lib/percpu-refcount.c:123 [inline]
                      percpu_ref_switch_to_atomic_rcu+0x3e7/0x520 lib/percpu-refcount.c:158
                      __rcu_reclaim kernel/rcu/rcu.h:240 [inline]
                      rcu_do_batch kernel/rcu/tree.c:2452 [inline]
                      invoke_rcu_callbacks kernel/rcu/tree.c:2773 [inline]
                      rcu_process_callbacks+0x928/0x1390 kernel/rcu/tree.c:2754
                      __do_softirq+0x266/0x95a kernel/softirq.c:292
                      run_ksoftirqd kernel/softirq.c:654 [inline]
                      run_ksoftirqd+0x8e/0x110 kernel/softirq.c:646
                      smpboot_thread_fn+0x6ab/0xa10 kernel/smpboot.c:164
                      kthread+0x357/0x430 kernel/kthread.c:246
                      ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
    INITIAL USE at:
                     lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
                     __raw_spin_lock_irq include/linux/spinlock_api_smp.h:128 [inline]
                     _raw_spin_lock_irq+0x60/0x80 kernel/locking/spinlock.c:160
                     spin_lock_irq include/linux/spinlock.h:354 [inline]
                     free_ioctx_users+0x2d/0x4a0 fs/aio.c:610
                     percpu_ref_put_many include/linux/percpu-refcount.h:285 [inline]
                     percpu_ref_put include/linux/percpu-refcount.h:301 [inline]
                     percpu_ref_call_confirm_rcu lib/percpu-refcount.c:123 [inline]
                     percpu_ref_switch_to_atomic_rcu+0x3e7/0x520 lib/percpu-refcount.c:158
                     __rcu_reclaim kernel/rcu/rcu.h:240 [inline]
                     rcu_do_batch kernel/rcu/tree.c:2452 [inline]
                     invoke_rcu_callbacks kernel/rcu/tree.c:2773 [inline]
                     rcu_process_callbacks+0x928/0x1390 kernel/rcu/tree.c:2754
                     __do_softirq+0x266/0x95a kernel/softirq.c:292
                     run_ksoftirqd kernel/softirq.c:654 [inline]
                     run_ksoftirqd+0x8e/0x110 kernel/softirq.c:646
                     smpboot_thread_fn+0x6ab/0xa10 kernel/smpboot.c:164
                     kthread+0x357/0x430 kernel/kthread.c:246
                     ret_from_fork+0x3a/0x50 arch/x86/entry/entry_64.S:352
  }
  ... key      at: [<ffffffff8a5760a0>] __key.51972+0x0/0x40
  ... acquired at:
   __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
   _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
   spin_lock include/linux/spinlock.h:329 [inline]
   aio_poll fs/aio.c:1772 [inline]
   __io_submit_one fs/aio.c:1875 [inline]
   io_submit_one+0xedf/0x1cf0 fs/aio.c:1908
   __do_sys_io_submit fs/aio.c:1953 [inline]
   __se_sys_io_submit fs/aio.c:1923 [inline]
   __x64_sys_io_submit+0x1bd/0x580 fs/aio.c:1923
   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
   entry_SYSCALL_64_after_hwframe+0x49/0xbe

-> (&ctx->fd_wqh){....} {
   INITIAL USE at:
                   lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
                   __raw_spin_lock_irqsave include/linux/spinlock_api_smp.h:110 [inline]
                   _raw_spin_lock_irqsave+0x95/0xcd kernel/locking/spinlock.c:152
                   __wake_up_common_lock+0xc7/0x190 kernel/sched/wait.c:120
                   __wake_up+0xe/0x10 kernel/sched/wait.c:145
                   userfaultfd_release+0x4f5/0x6d0 fs/userfaultfd.c:924
                   __fput+0x2df/0x8d0 fs/file_table.c:278
                   ____fput+0x16/0x20 fs/file_table.c:309
                   task_work_run+0x14a/0x1c0 kernel/task_work.c:113
                   tracehook_notify_resume include/linux/tracehook.h:188 [inline]
                   exit_to_usermode_loop+0x273/0x2c0 arch/x86/entry/common.c:166
                   prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
                   syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
                   do_syscall_64+0x52d/0x610 arch/x86/entry/common.c:293
                   entry_SYSCALL_64_after_hwframe+0x49/0xbe
 }
 ... key      at: [<ffffffff8a575e20>] __key.44854+0x0/0x40
 ... acquired at:
   lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
   __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
   _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
   spin_lock include/linux/spinlock.h:329 [inline]
   userfaultfd_ctx_read fs/userfaultfd.c:1040 [inline]
   userfaultfd_read+0x540/0x1940 fs/userfaultfd.c:1198
   __vfs_read+0x116/0x8c0 fs/read_write.c:416
   vfs_read+0x194/0x3e0 fs/read_write.c:452
   ksys_read+0xea/0x1f0 fs/read_write.c:578
   __do_sys_read fs/read_write.c:588 [inline]
   __se_sys_read fs/read_write.c:586 [inline]
   __x64_sys_read+0x73/0xb0 fs/read_write.c:586
   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
   entry_SYSCALL_64_after_hwframe+0x49/0xbe

the dependencies between the lock to be acquired
 and SOFTIRQ-irq-unsafe lock:
-> (&ctx->fault_pending_wqh){+.+.} {
   HARDIRQ-ON-W at:
                    lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
                    __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
                    _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
                    spin_lock include/linux/spinlock.h:329 [inline]
                    userfaultfd_release+0x497/0x6d0 fs/userfaultfd.c:916
                    __fput+0x2df/0x8d0 fs/file_table.c:278
                    ____fput+0x16/0x20 fs/file_table.c:309
                    task_work_run+0x14a/0x1c0 kernel/task_work.c:113
                    tracehook_notify_resume include/linux/tracehook.h:188 [inline]
                    exit_to_usermode_loop+0x273/0x2c0 arch/x86/entry/common.c:166
                    prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
                    syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
                    do_syscall_64+0x52d/0x610 arch/x86/entry/common.c:293
                    entry_SYSCALL_64_after_hwframe+0x49/0xbe
   SOFTIRQ-ON-W at:
                    lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
                    __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
                    _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
                    spin_lock include/linux/spinlock.h:329 [inline]
                    userfaultfd_release+0x497/0x6d0 fs/userfaultfd.c:916
                    __fput+0x2df/0x8d0 fs/file_table.c:278
                    ____fput+0x16/0x20 fs/file_table.c:309
                    task_work_run+0x14a/0x1c0 kernel/task_work.c:113
                    tracehook_notify_resume include/linux/tracehook.h:188 [inline]
                    exit_to_usermode_loop+0x273/0x2c0 arch/x86/entry/common.c:166
                    prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
                    syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
                    do_syscall_64+0x52d/0x610 arch/x86/entry/common.c:293
                    entry_SYSCALL_64_after_hwframe+0x49/0xbe
   INITIAL USE at:
                   lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
                   __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
                   _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
                   spin_lock include/linux/spinlock.h:329 [inline]
                   userfaultfd_release+0x497/0x6d0 fs/userfaultfd.c:916
                   __fput+0x2df/0x8d0 fs/file_table.c:278
                   ____fput+0x16/0x20 fs/file_table.c:309
                   task_work_run+0x14a/0x1c0 kernel/task_work.c:113
                   tracehook_notify_resume include/linux/tracehook.h:188 [inline]
                   exit_to_usermode_loop+0x273/0x2c0 arch/x86/entry/common.c:166
                   prepare_exit_to_usermode arch/x86/entry/common.c:197 [inline]
                   syscall_return_slowpath arch/x86/entry/common.c:268 [inline]
                   do_syscall_64+0x52d/0x610 arch/x86/entry/common.c:293
                   entry_SYSCALL_64_after_hwframe+0x49/0xbe
 }
 ... key      at: [<ffffffff8a575ee0>] __key.44851+0x0/0x40
 ... acquired at:
   lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
   __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
   _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
   spin_lock include/linux/spinlock.h:329 [inline]
   userfaultfd_ctx_read fs/userfaultfd.c:1040 [inline]
   userfaultfd_read+0x540/0x1940 fs/userfaultfd.c:1198
   __vfs_read+0x116/0x8c0 fs/read_write.c:416
   vfs_read+0x194/0x3e0 fs/read_write.c:452
   ksys_read+0xea/0x1f0 fs/read_write.c:578
   __do_sys_read fs/read_write.c:588 [inline]
   __se_sys_read fs/read_write.c:586 [inline]
   __x64_sys_read+0x73/0xb0 fs/read_write.c:586
   do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
   entry_SYSCALL_64_after_hwframe+0x49/0xbe

stack backtrace:
CPU: 1 PID: 9727 Comm: syz-executor5 Not tainted 5.0.0-rc4+ #56
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:77 [inline]
 dump_stack+0x172/0x1f0 lib/dump_stack.c:113
 print_bad_irq_dependency kernel/locking/lockdep.c:1573 [inline]
 check_usage.cold+0x60f/0x940 kernel/locking/lockdep.c:1605
 check_irq_usage kernel/locking/lockdep.c:1661 [inline]
 check_prev_add_irq kernel/locking/lockdep_states.h:8 [inline]
 check_prev_add kernel/locking/lockdep.c:1871 [inline]
 check_prevs_add kernel/locking/lockdep.c:1979 [inline]
 validate_chain kernel/locking/lockdep.c:2350 [inline]
 __lock_acquire+0x1f47/0x4700 kernel/locking/lockdep.c:3338
 lock_acquire+0x16f/0x3f0 kernel/locking/lockdep.c:3841
 __raw_spin_lock include/linux/spinlock_api_smp.h:142 [inline]
 _raw_spin_lock+0x2f/0x40 kernel/locking/spinlock.c:144
 spin_lock include/linux/spinlock.h:329 [inline]
 userfaultfd_ctx_read fs/userfaultfd.c:1040 [inline]
 userfaultfd_read+0x540/0x1940 fs/userfaultfd.c:1198
 __vfs_read+0x116/0x8c0 fs/read_write.c:416
 vfs_read+0x194/0x3e0 fs/read_write.c:452
 ksys_read+0xea/0x1f0 fs/read_write.c:578
 __do_sys_read fs/read_write.c:588 [inline]
 __se_sys_read fs/read_write.c:586 [inline]
 __x64_sys_read+0x73/0xb0 fs/read_write.c:586
 do_syscall_64+0x103/0x610 arch/x86/entry/common.c:290
 entry_SYSCALL_64_after_hwframe+0x49/0xbe

Cc: Christoph Hellwig <hch@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: <stable@vger.kernel.org>
Fixes: ae62c16e105a ("userfaultfd: disable irqs when taking the waitqueue lock")
Reported-by: syzbot <syzkaller@googlegroups.com>
Signed-off-by: Bart Van Assche <bvanassche@acm.org>
---
 fs/userfaultfd.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89800fc7dc9d..4bcaaee1ee84 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -458,7 +458,7 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	blocking_state = return_to_userland ? TASK_INTERRUPTIBLE :
 			 TASK_KILLABLE;
 
-	spin_lock(&ctx->fault_pending_wqh.lock);
+	spin_lock_irq(&ctx->fault_pending_wqh.lock);
 	/*
 	 * After the __add_wait_queue the uwq is visible to userland
 	 * through poll/read().
@@ -470,7 +470,7 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	 * __add_wait_queue.
 	 */
 	set_current_state(blocking_state);
-	spin_unlock(&ctx->fault_pending_wqh.lock);
+	spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 
 	if (!is_vm_hugetlb_page(vmf->vma))
 		must_wait = userfaultfd_must_wait(ctx, vmf->address, vmf->flags,
@@ -552,13 +552,13 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 	 * kernel stack can be released after the list_del_init.
 	 */
 	if (!list_empty_careful(&uwq.wq.entry)) {
-		spin_lock(&ctx->fault_pending_wqh.lock);
+		spin_lock_irq(&ctx->fault_pending_wqh.lock);
 		/*
 		 * No need of list_del_init(), the uwq on the stack
 		 * will be freed shortly anyway.
 		 */
 		list_del(&uwq.wq.entry);
-		spin_unlock(&ctx->fault_pending_wqh.lock);
+		spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 	}
 
 	/*
@@ -583,7 +583,7 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 	init_waitqueue_entry(&ewq->wq, current);
 	release_new_ctx = NULL;
 
-	spin_lock(&ctx->event_wqh.lock);
+	spin_lock_irq(&ctx->event_wqh.lock);
 	/*
 	 * After the __add_wait_queue the uwq is visible to userland
 	 * through poll/read().
@@ -613,15 +613,15 @@ static void userfaultfd_event_wait_completion(struct userfaultfd_ctx *ctx,
 			break;
 		}
 
-		spin_unlock(&ctx->event_wqh.lock);
+		spin_unlock_irq(&ctx->event_wqh.lock);
 
 		wake_up_poll(&ctx->fd_wqh, EPOLLIN);
 		schedule();
 
-		spin_lock(&ctx->event_wqh.lock);
+		spin_lock_irq(&ctx->event_wqh.lock);
 	}
 	__set_current_state(TASK_RUNNING);
-	spin_unlock(&ctx->event_wqh.lock);
+	spin_unlock_irq(&ctx->event_wqh.lock);
 
 	if (release_new_ctx) {
 		struct vm_area_struct *vma;
@@ -913,10 +913,10 @@ static int userfaultfd_release(struct inode *inode, struct file *file)
 	 * the last page faults that may have been already waiting on
 	 * the fault_*wqh.
 	 */
-	spin_lock(&ctx->fault_pending_wqh.lock);
+	spin_lock_irq(&ctx->fault_pending_wqh.lock);
 	__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL, &range);
 	__wake_up(&ctx->fault_wqh, TASK_NORMAL, 1, &range);
-	spin_unlock(&ctx->fault_pending_wqh.lock);
+	spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 
 	/* Flush pending events that may still wait on event_wqh */
 	wake_up_all(&ctx->event_wqh);
@@ -1129,7 +1129,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 
 	if (!ret && msg->event == UFFD_EVENT_FORK) {
 		ret = resolve_userfault_fork(ctx, fork_nctx, msg);
-		spin_lock(&ctx->event_wqh.lock);
+		spin_lock_irq(&ctx->event_wqh.lock);
 		if (!list_empty(&fork_event)) {
 			/*
 			 * The fork thread didn't abort, so we can
@@ -1175,7 +1175,7 @@ static ssize_t userfaultfd_ctx_read(struct userfaultfd_ctx *ctx, int no_wait,
 			if (ret)
 				userfaultfd_ctx_put(fork_nctx);
 		}
-		spin_unlock(&ctx->event_wqh.lock);
+		spin_unlock_irq(&ctx->event_wqh.lock);
 	}
 
 	return ret;
@@ -1214,14 +1214,14 @@ static ssize_t userfaultfd_read(struct file *file, char __user *buf,
 static void __wake_userfault(struct userfaultfd_ctx *ctx,
 			     struct userfaultfd_wake_range *range)
 {
-	spin_lock(&ctx->fault_pending_wqh.lock);
+	spin_lock_irq(&ctx->fault_pending_wqh.lock);
 	/* wake all in the range and autoremove */
 	if (waitqueue_active(&ctx->fault_pending_wqh))
 		__wake_up_locked_key(&ctx->fault_pending_wqh, TASK_NORMAL,
 				     range);
 	if (waitqueue_active(&ctx->fault_wqh))
 		__wake_up(&ctx->fault_wqh, TASK_NORMAL, 1, range);
-	spin_unlock(&ctx->fault_pending_wqh.lock);
+	spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 }
 
 static __always_inline void wake_userfault(struct userfaultfd_ctx *ctx,
@@ -1872,7 +1872,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
 	wait_queue_entry_t *wq;
 	unsigned long pending = 0, total = 0;
 
-	spin_lock(&ctx->fault_pending_wqh.lock);
+	spin_lock_irq(&ctx->fault_pending_wqh.lock);
 	list_for_each_entry(wq, &ctx->fault_pending_wqh.head, entry) {
 		pending++;
 		total++;
@@ -1880,7 +1880,7 @@ static void userfaultfd_show_fdinfo(struct seq_file *m, struct file *f)
 	list_for_each_entry(wq, &ctx->fault_wqh.head, entry) {
 		total++;
 	}
-	spin_unlock(&ctx->fault_pending_wqh.lock);
+	spin_unlock_irq(&ctx->fault_pending_wqh.lock);
 
 	/*
 	 * If more protocols will be added, there will be all shown
-- 
2.20.1.791.gb4d0f1c61a-goog

