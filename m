Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 841F2C742D7
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 333A9217D6
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 23:55:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Mhx3IUNO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 333A9217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 994758E016D; Fri, 12 Jul 2019 19:55:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 943A88E0003; Fri, 12 Jul 2019 19:55:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 832648E016D; Fri, 12 Jul 2019 19:55:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49ADB8E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 19:55:25 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d187so6613039pga.7
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 16:55:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:subject
         :in-reply-to:references:message-id;
        bh=99b+bQ3jjhTS3lK0HcVLyh0jMxoipCPj+S6A3RcOxWY=;
        b=kDqmPrTZtvGPULeYyCthQitvpM72xtJVLi5wMHZC6mt8RFTTfew/j5YRD8pKnK/xFI
         Xv5iVdhFGeVPY7EONhNmYQ0WcmCOVIZjk4F+47OfRbro6BYkt/Y8laJ1ct7uI0M5s43v
         iyYvCIhHeGXZQ2164jE39jNtExvUFW3nePgPRT70MtEKT1f7QHFNb5aC+M+XufQztqhs
         wquPZvGUiUTPspyy/BB3mEA+Paw6trCyAjihL7Ym24rq5TOo7qu44wKXmz0f4dGpyErq
         fM792jjvBPpeQfKUrfDJzTXAKPe6bGHFZ5RMgroGie/q3h49BFtwNCfL53GDPIng3QPV
         ip9Q==
X-Gm-Message-State: APjAAAVnR7snaqIZ/QX//jRH1PIRHb+zm4UT1S2gqM/XwKxiGdlVM+aj
	bWa5IV3rvqAcm1EqHzEPJ72xdXE7VFYY0HyrlCDDsJoHasRogh359UmCiMK5erPTS4zpDwQgnrY
	EJX39DlrwfyaRxj9FN/4S2PW3UJImOTvDetTT8JUb42cX6KgpZ8VuOsSPCQojB7SfCA==
X-Received: by 2002:a63:5114:: with SMTP id f20mr14244017pgb.173.1562975724759;
        Fri, 12 Jul 2019 16:55:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyGKWarfkItHS6BqpgYiaQoLZ9rNn0cN/sCAe2Omukeuq6JMIvgjmgvVfCIzq7OmY+iI7qJ
X-Received: by 2002:a63:5114:: with SMTP id f20mr14243930pgb.173.1562975723839;
        Fri, 12 Jul 2019 16:55:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562975723; cv=none;
        d=google.com; s=arc-20160816;
        b=ZaRQTTTqjqJqsmCT1qdI9Qm4U9JJIf07isdxoqKvKaAbUTmQczFX6bsIPVd+n6PLUH
         Cn5pI1A6stpVfCtild5LiIgGHd+9oTgDNpKH7674X1+sQgoTUsH/Lm7roU7uxBTMxoKu
         eOtfIp452C2SsvbVUrO565trHwSr4hYOMLex9gFj0r7QGJBB/nHvEIkpNJZ2siM8xFPB
         CSHfQSL4mzpeNx5XjVrjWsiiNmmLMssRwIKg3ny9xoGGwTHo71yrYDmLF/QQHFExd+5N
         WdH6W9I5iQCWEezYsctSkgDOGA2Gadz8+HWoglj/DQB/e6xvguqQeEb3cnvgPFd5OPWF
         Jyfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:to:to:to:from:date
         :dkim-signature;
        bh=99b+bQ3jjhTS3lK0HcVLyh0jMxoipCPj+S6A3RcOxWY=;
        b=BqZpZxi8jEpZB4EeIQN0HDIgxBhJtuFczEl75je/TFhnKcPWzSThZ7RQZm/qeiV9ew
         YlyntxET5HmSqHClRgWKwguBQTDrslna36P+o8498i5Xc0Gg72PkpFY/+kjcTSTSj/cC
         w21S/Nl+3Qk0jAZ3cxsCC6pEWmchlA6Dn50RlJ+2pgPzMUkb114YL6sloAm19mXAVwpa
         PcnpphILQbEhPDY0FN38dPKbB+KO+ASDmVI8xYghxepD8i+BF+h53oMBP2gB/Hqbxtm7
         qBz3IYMY+rBlg+HyNmYZeSTQLpuyjp7RanfuJWNVUhSc4ATNaMRz1xE5ZrGuedf5ZFhQ
         llXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Mhx3IUNO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t185si9773879pgd.596.2019.07.12.16.55.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 16:55:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Mhx3IUNO;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3A90E20874;
	Fri, 12 Jul 2019 23:55:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562975723;
	bh=edqXpo4zBRiTB7boPadC15QReuBXuqvMoJ0EzOGbVWs=;
	h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:From;
	b=Mhx3IUNOipXWjWIkrzaV5Vb1XfamZJfoiB4P2EDJ+WHAE0xpkQcOnChdgtJ2Gfoei
	 hvIBAY9uWe6OiVN82c8Ez+fEImw1j5wu+M4qfRVByc+I9LBl+E0BSBIc231ONF9+X3
	 vq3Lj1sOdDO2pCGIkN56r6J6zcawsiqtMFqSiwQo=
Date: Fri, 12 Jul 2019 23:55:21 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To: Jan Kara <jack@suse.cz>
To: <linux-fsdevel@vger.kernel.org>
Cc: <linux-mm@kvack.org>,
Cc: stable@vger.kernel.org
Subject: Re: [PATCH 2/3] fs: Export generic_fadvise()
In-Reply-To: <20190711140012.1671-3-jack@suse.cz>
References: <20190711140012.1671-3-jack@suse.cz>
Message-Id: <20190712235523.3A90E20874@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v5.2, v5.1.17, v4.19.58, v4.14.133, v4.9.185, v4.4.185.

v5.2: Build OK!
v5.1.17: Build OK!
v4.19.58: Build OK!
v4.14.133: Failed to apply! Possible dependencies:
    17ef445f9bef ("Documentation/filesystems: update documentation of file_operations")
    312db1aa1dc7 ("fs: add ksys_mount() helper; remove in-kernel calls to sys_mount()")
    36028d5dd711 ("fs: add ksys_p{read,write}64() helpers; remove in-kernel calls to syscalls")
    3a18ef5c1b39 ("fs: add ksys_umount() helper; remove in-kernel call to sys_umount()")
    3ce4a7bf6626 ("fs: add ksys_read() helper; remove in-kernel calls to sys_read()")
    45cd0faae371 ("vfs: add the fadvise() file operation")
    6e8b704df584 ("fs: update documentation to mention __poll_t and match the code")
    70f68ee81e2e ("fs: add ksys_sync() helper; remove in-kernel calls to sys_sync()")
    806cbae1228c ("fs: add ksys_sync_file_range helper(); remove in-kernel calls to syscall")
    819671ff849b ("syscalls: define and explain goal to not call syscalls in the kernel")
    9b32105ec6b1 ("kernel: add ksys_unshare() helper; remove in-kernel calls to sys_unshare()")
    9d5b7c956b09 ("mm: add ksys_fadvise64_64() helper; remove in-kernel call to sys_fadvise64_64()")
    a16fe33ab557 ("fs: add ksys_chroot() helper; remove-in kernel calls to sys_chroot()")
    c7248321a3d4 ("fs: add ksys_dup{,3}() helper; remove in-kernel calls to sys_dup{,3}()")
    e2aaa9f42336 ("kernel: add ksys_setsid() helper; remove in-kernel call to sys_setsid()")
    e7a3e8b2edf5 ("fs: add ksys_write() helper; remove in-kernel calls to sys_write()")
    edf292c76b88 ("fs: add ksys_fallocate() wrapper; remove in-kernel calls to sys_fallocate()")

v4.9.185: Failed to apply! Possible dependencies:
    17ef445f9bef ("Documentation/filesystems: update documentation of file_operations")
    3859a271a003 ("randstruct: Mark various structs for randomization")
    45cd0faae371 ("vfs: add the fadvise() file operation")
    5613fda9a503 ("sched/cputime: Convert task/group cputime to nsecs")
    60f3e00d25b4 ("sysv,ipc: cacheline align kern_ipc_perm")
    6e8b704df584 ("fs: update documentation to mention __poll_t and match the code")
    8c8b73c4811f ("sched/cputime, powerpc: Prepare accounting structure for cputime flush on tick")
    a19ff1a2cc92 ("sched/cputime, powerpc/vtime: Accumulate cputime and account only on tick/task switch")
    b18b6a9cef7f ("timers: Omit POSIX timer stuff from task_struct when disabled")
    baa73d9e478f ("posix-timers: Make them configurable")
    c3edc4010e9d ("sched/headers: Move task_struct::signal and task_struct::sighand types and accessors into <linux/sched/signal.h>")
    d69dece5f5b6 ("LSM: Add /sys/kernel/security/lsm")
    f828c3d0aeba ("sched/cputime, powerpc: Migrate stolen_time field to the accounting structure")

v4.4.185: Failed to apply! Possible dependencies:
    04b38d601239 ("vfs: pull btrfs clone API to vfs layer")
    17ef445f9bef ("Documentation/filesystems: update documentation of file_operations")
    29732938a628 ("vfs: add copy_file_range syscall and vfs helper")
    3859a271a003 ("randstruct: Mark various structs for randomization")
    3db11b2eecc0 ("btrfs: add .copy_file_range file operation")
    45cd0faae371 ("vfs: add the fadvise() file operation")
    54dbc1517237 ("vfs: hoist the btrfs deduplication ioctl to the vfs")
    6e8b704df584 ("fs: update documentation to mention __poll_t and match the code")
    75ba1d07fd6a ("seq/proc: modify seq_put_decimal_[u]ll to take a const char *, not char")
    81243eacfa40 ("cred: simpler, 1D supplementary groups")
    d79bdd52d8be ("vfs: wire up compat ioctl for CLONE/CLONE_RANGE")
    f7a5f132b447 ("proc: faster /proc/*/status")


NOTE: The patch will not be queued to stable trees until it is upstream.

How should we proceed with this patch?

--
Thanks,
Sasha

