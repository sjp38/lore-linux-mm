Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D3F5C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:51:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2A36222BA
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 09:51:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="Al4jtBgl";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="Lk0Cf7eE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2A36222BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80EB18E0002; Wed, 13 Feb 2019 04:51:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BE8D8E0001; Wed, 13 Feb 2019 04:51:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AD378E0002; Wed, 13 Feb 2019 04:51:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2726E8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 04:51:41 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id 12so1327524plb.18
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 01:51:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:references:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=riCSVMPsnvdFnWVGfWkfPB1JBUB7mR3kxbiYU6inJYs=;
        b=CglB/uob5rVKFh86zbF892Rxj66bz1g1W2B4JsAbdrfcSv6SQQ+yr821tCgjV5mB+7
         gNZCxKLgKlc2gUPg7+J1fDpNbh7FHKLKmfJs+Vxq6IkdJOheXgFBoznyixasCGeyNqqd
         YwE//QFTLmLfmfbTHVfWoRfFikJKgPY7i73rBk+OUquFmueCwQf1OEXNnOJJFkSnQjfh
         1w1HNuPvEj85ZM2PclgeV7Amp2B/O6dY8DehMQwzA7oAOuxVjlEZCMO9V1SxDLwp+j/r
         WrJojOtG7T/nHU9JEGkVzuNDuCzY/VomHYe32XhcRi3lzTgQKytaDS4LEehWt/O/vpV4
         Kifg==
X-Gm-Message-State: AHQUAuZ1ghYMg6hnQKmBWn8TQSTz8cfQ+dmqh60A2RDW6rAb1RyKp/zG
	SgpI59MIyC4Qs6ise8EIhIvdc1yiRf6hKMWoyRj2zo1gc5PNnCBO54bmOPuqsvpPO9yWL51hwzy
	OqZ5wJv62RSnR5o/mBdjg60erI4ADgUh4Twu8MeIYruXIffL3nrZszHoytau9bP2/Nw==
X-Received: by 2002:a63:6184:: with SMTP id v126mr8036807pgb.277.1550051500737;
        Wed, 13 Feb 2019 01:51:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibyl+7XgkLp3uOaTPeIL/gtRkpczC5o10B/8/g2xO4mCAm1KHSTpfMq4z7BZ0395GbX7MvH
X-Received: by 2002:a63:6184:: with SMTP id v126mr8036770pgb.277.1550051499958;
        Wed, 13 Feb 2019 01:51:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550051499; cv=none;
        d=google.com; s=arc-20160816;
        b=iDmupFRVqv/D91mkbnmZjdIrE28t2W1Csm1EDkT/PRmN+4N/w7xncaUoNI/8ArS1dW
         fH8tPkmKF2tSlOOGOnEz3rP9633YLUt8DZDEeu7qT8uCRRB+gm+G1Guj+jcffhmq+YQ6
         brO2ugsWnOKp+I0efONUyCUZfMzR70i4DgZoTJJCSpHptx4f4rBEKp1J1z9RHHYqIMf/
         nCrpLd/tsbdtkxRBFtZrSKZlRxMyhKHVx5GktFEcOrQ5s5aevqOVrtxMKRfSVSZRHFRZ
         P2AOpaxA+9QoHx/UpILB1pcmeOYFhjXYJB8i/SrWPKlQdJHm/1vsj1GhFLD4YD9jnZY+
         4GWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject:dmarc-filter
         :dkim-signature:dkim-signature;
        bh=riCSVMPsnvdFnWVGfWkfPB1JBUB7mR3kxbiYU6inJYs=;
        b=sK5TUv7ThWY5ikjLtVtz9D01P65qljxD2krjepWG3pqGt//bjVpzWpx8wGpqbm6Pa1
         WCMBr3+dPGmzYEVAXoExE8ql1Zo3w0QwFZk3Pde8K+Z6E4hl/Fhu9pnOMzO+VB0BCUUZ
         enNjgyLf6RjCQpYTbqvu1Pm78YIc7MqL/c6tUEp7wjLnxIYCDC4GgS/UsYDEAjfGcq9Z
         WdtbhnhCuhZjJ50JW8AmU297M3/LeQZP+BQffJ+DWv+xHZfXiExWar+dh4b2zhTp/4i7
         we9QuzviqCOo6XVqEyZWonfrxvqfGnL3hzCmM1uaxE5Gs/xv7Tx0TNOHREAo4EVKcNBX
         kLpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=Al4jtBgl;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=Lk0Cf7eE;
       spf=pass (google.com: domain of saiprakash.ranjan@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=saiprakash.ranjan@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id x6si3572016pgp.367.2019.02.13.01.51.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 01:51:39 -0800 (PST)
Received-SPF: pass (google.com: domain of saiprakash.ranjan@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=Al4jtBgl;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=Lk0Cf7eE;
       spf=pass (google.com: domain of saiprakash.ranjan@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=saiprakash.ranjan@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 1A85C60740; Wed, 13 Feb 2019 09:51:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1550051499;
	bh=Vs+50u4QSysEwvPfccTmoCqeFX05ffDTaj3MJz0B670=;
	h=Subject:To:References:From:Date:In-Reply-To:From;
	b=Al4jtBgl5La/iug7F1/r93K6MwbhWPJhZ2Sr7FVWgmMdda/qkPYGyIUsj0tZNA76W
	 Y1rzeD+o9waRqCOlCIR8Owz6rLFvLfaSIsGa8i+KQ6SA+Wt+BiKH6llixH8pgv00ar
	 pOReyBZY7E+MB4Bbl3stT3nwQZaMCdyDnQ4xmkRw=
Received: from [10.79.128.39] (blr-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.18.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: saiprakash.ranjan@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 9CDC26087F;
	Wed, 13 Feb 2019 09:51:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1550051498;
	bh=Vs+50u4QSysEwvPfccTmoCqeFX05ffDTaj3MJz0B670=;
	h=Subject:To:References:From:Date:In-Reply-To:From;
	b=Lk0Cf7eE02GVh2/hv2jM4yg7+BAET8jRgyBDoHlgNTzh/153Uc7pmhY5uRJ0Q9mvu
	 FKuFpUYBecuDyepAqDygn+goftI6OKmxRfjqcqMl07dJlyxem1PeGoZpbFMlTC2IHx
	 KRvs0sqn9+Bw679Hz1JK4nqAFFpOXRbgP0J6AGGE=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 9CDC26087F
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=saiprakash.ranjan@codeaurora.org
Subject: Re: BUG: sleeping function called from invalid context at
 kernel/locking/rwsem.c:65
To: Pintu Agarwal <pintu.ping@gmail.com>,
 open list <linux-kernel@vger.kernel.org>,
 linux-arm-kernel@lists.infradead.org, linux-rt-users@vger.kernel.org,
 linux-mm@kvack.org, Jorge Ramirez <jorge.ramirez-ortiz@linaro.org>,
 "Xenomai@xenomai.org" <xenomai@xenomai.org>
References: <CAOuPNLgaDJm27nECxq1jtny=+ixt=GPf2C7zyDsVgbsLvtDarA@mail.gmail.com>
From: Sai Prakash Ranjan <saiprakash.ranjan@codeaurora.org>
Message-ID: <6183c865-2e90-5fb9-9e10-1339ae491b71@codeaurora.org>
Date: Wed, 13 Feb 2019 15:21:32 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CAOuPNLgaDJm27nECxq1jtny=+ixt=GPf2C7zyDsVgbsLvtDarA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pintu,

On 2/13/2019 2:04 PM, Pintu Agarwal wrote:
> 
> This is the complete logs at the time of crash:
> 
> [   21.681020] VFS: Mounted root (ext4 filesystem) readonly on device 8:6.
> [   21.690441] devtmpfs: mounted
> [   21.702517] Freeing unused kernel memory: 6528K
> [   21.766665] BUG: sleeping function called from invalid context at
> kernel/locking/rwsem.c:65
> [   21.775108] in_atomic(): 0, irqs_disabled(): 128, pid: 1, name: init
> [   21.781532] ------------[ cut here ]------------
> [   21.786209] kernel BUG at kernel/sched/core.c:8490!
> [   21.791157] ------------[ cut here ]------------
> [   21.795831] kernel BUG at kernel/sched/core.c:8490!
> [   21.800763] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP
> [   21.806319] Modules linked in:
> [   21.809474] CPU: 0 PID: 1 Comm: init Not tainted 4.9.103+ #115
> [   21.815375] Hardware name: Qualcomm Technologies, Inc. MSM XXXX
> [   21.822584] task: ffffffe330440080 task.stack: ffffffe330448000
> [   21.828584] PC is at ___might_sleep+0x140/0x188
> [   21.833175] LR is at ___might_sleep+0x128/0x188
> [   21.837759] pc : [<ffffff88b8ce65a8>] lr : [<ffffff88b8ce6590>]
> pstate: 604001c5

<snip...>

> 0000000000000000 ffffffe33044b8d0
> [   22.135279] bac0: 0000000000000462 0000000000000006
> [   22.140224] [<ffffff88b8ce65a8>] ___might_sleep+0x140/0x188
> [   22.145862] [<ffffff88b8ce6648>] __might_sleep+0x58/0x90
> [   22.151249] [<ffffff88b9d43f84>] down_write_killable+0x2c/0x80
> [   22.157155] [<ffffff88b8e53cd8>] setup_arg_pages+0xb8/0x208
> [   22.162792] [<ffffff88b8eb7534>] load_elf_binary+0x434/0x1298
> [   22.168600] [<ffffff88b8e55674>] search_binary_handler+0xac/0x1f0
> [   22.174763] [<ffffff88b8e560ec>] do_execveat_common.isra.15+0x504/0x6c8
> [   22.181452] [<ffffff88b8e562f4>] do_execve+0x44/0x58
> [   22.186481] [<ffffff88b8c84030>] run_init_process+0x38/0x48
> [   22.192122] [<ffffff88b9d3db1c>] kernel_init+0x8c/0x108
> [   22.197411] [<ffffff88b8c83f00>] ret_from_fork+0x10/0x50
> [   22.202790] Code: b9453800 0b000020 6b00027f 540000c1 (d4210000)
> [   22.208965] ---[ end trace d775a851176a61ec ]---
> [   22.220051] Kernel panic - not syncing: Attempted to kill init!
> exitcode=0x0000000b
> 

This might be the work of CONFIG_PANIC_ON_SCHED_BUG which is extra debug 
option enabled in *sdm845_defconfig*. You can disable it or better
I would suggest to use *sdm845-perf_defconfig* instead of
sdm845_defconfig since there are a lot of debug options enabled
in the latter which may be not compatible when IPIPE patches
are applied.

Thanks,
Sai

-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a member
of Code Aurora Forum, hosted by The Linux Foundation

