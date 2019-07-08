Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 322DBC606C1
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 15:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D309721670
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 15:05:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D309721670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4337D8E001B; Mon,  8 Jul 2019 11:05:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3E40D8E001A; Mon,  8 Jul 2019 11:05:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D2F98E001B; Mon,  8 Jul 2019 11:05:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0A2BB8E001A
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 11:05:36 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id t124so16538467qkh.3
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 08:05:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=20M7KDomLReO6Q78cKUuYTnw9RHJCW0JDgM2rMub9R0=;
        b=TdEyWFS1/jp1tvfWGv1WPhJcrXKaWw0y6HWjOB5yeZcvsoMJhfuaa9+N7jGvFDBpnq
         STM7UKl3/keuNvwk6JV/hfm/V+4Cpr2iupd7oA8ybn/B+BwFKEtjMkNGR4QsfxJb6vVl
         r+4uL6VVdtq32mBwke2+KK5MifUAJZbM+ndkL+AMnh/8MauH0u/1Xy+a+BBanJOz0g8h
         WeuzSc+ivZUXay+8cUYeV09NvRhT3rSbrh9JL5gQ2w3zMOdyJj0etHI+qYbc4s+Dhw4b
         xslKhfAFp0MpVqXSovqxQb12PI+S0g8Ql9iE69KWBznVqSobn3dOhuSYgSU4wq8aQA1N
         8F/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUBmmfu6ycpCJKmYS4I4iXZsO3d9hHAG2PT6eSpcFtC3WAeOvDp
	jbiIzLfVv0YuZP0RBTr1UI/QRSG1n6SvMjhoJZ64fGKE5gCKThmx9nyoSBnE1DlnFbkpsND1Y/W
	U8T3DiAJqbGQW30jxyBcMLA49Itcy+JWx7vu+r6G6VkLMvLSBn3ZeU3P87K9bvhs=
X-Received: by 2002:a37:d247:: with SMTP id f68mr15391961qkj.177.1562598335815;
        Mon, 08 Jul 2019 08:05:35 -0700 (PDT)
X-Received: by 2002:a37:d247:: with SMTP id f68mr15391901qkj.177.1562598335057;
        Mon, 08 Jul 2019 08:05:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562598335; cv=none;
        d=google.com; s=arc-20160816;
        b=sIEFufyagliSL6+/0Nl3/ZD+7b7K3H+inxrOR5388FrA4erZ9fznlH2keAbWC9IkId
         d7WC4qO33WP69KfJWAYqhr3z7/3nxtxw6mDHqfYAjDtA7L9x0oIn8kvezMKJvFXGwrsD
         naxq/ti0tMc9tByV95qiDr7POIqP8BrCF5hFApljLRYXz5B7ElVuQbTnvKDJJFwUFHq9
         f2gesb7bxAiY+1e51zWbOFJ50mMsl5Lif59c7nGe/yJpkehZqg1L+XlX0ae5fDf3K0Yh
         ++Nsel2a5LyZkh2XaFBCGw3k732CmoZntt7kCgqdzuXsuonSSo1XASpBlUveqM4/V2b+
         Orow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=20M7KDomLReO6Q78cKUuYTnw9RHJCW0JDgM2rMub9R0=;
        b=WV4C8SUgbyXtX79LgFLMoOpOCEQyzk07F2Yo4Pwx/pTi4u+5hyabUHW5UflhlXtIuw
         brAeA+yA0gAmpNtwb3HS1ISRVfJ57rkEUZoRj+2czTsb3dFSFdHQSjcNH2FiWEFjpC00
         VenJWMz5p0/agRoLuCloReyu1VgncehXAxjOQaXjMb3Qg23HWpZEGao3jkJSoZu6LxqX
         zKzVDAexO0hYZZWnKhC8jX/57nuS7+6KtpkjAoTUjal3Hf/xeZS1kZtk+f1avvPg6xl+
         pr7WFrR7WYvm17P3maud3EgmtQBU9nZbX/l2yarXh5WYDxxo70DCK7DawVyvQUnPucJ+
         0wwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t63sor9970054qkc.177.2019.07.08.08.05.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 08:05:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqzaXu29O4BsQ5xcZ0Kye2zBoQDtCA69U6z63UZcnxNvtOex5ISkiTcVAA6I8WS3glgv7KrIgQ==
X-Received: by 2002:a05:620a:68c:: with SMTP id f12mr14608641qkh.197.1562598334612;
        Mon, 08 Jul 2019 08:05:34 -0700 (PDT)
Received: from dennisz-mbp ([2620:10d:c091:500::3:8b5a])
        by smtp.gmail.com with ESMTPSA id g54sm8989306qtc.61.2019.07.08.08.05.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jul 2019 08:05:33 -0700 (PDT)
Date: Mon, 8 Jul 2019 11:05:32 -0400
From: Dennis Zhou <dennis@kernel.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>
Cc: Tejun Heo <tj@kernel.org>, Kefeng Wang <wangkefeng.wang@huawei.com>,
	kasan-dev@googlegroups.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: kasan: paging percpu + kasan causes a double fault
Message-ID: <20190708150532.GB17098@dennisz-mbp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrey, Alexander, and Dmitry,

It was reported to me that when percpu is ran with param
percpu_alloc=page or the embed allocation scheme fails and falls back to
page that a double fault occurs.

I don't know much about how kasan works, but a difference between the
two is that we manually reserve vm area via vm_area_register_early().
I guessed it had something to do with the stack canary or the irq_stack,
and manually mapped the shadow vm area with kasan_add_zero_shadow(), but
that didn't seem to do the trick.

RIP resolves to the fixed_percpu_data declaration.

Double fault below:
[    0.000000] PANIC: double fault, error_code: 0x0
[    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.2.0-rc7-00007-ge0afe6d4d12c-dirty #299
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.el7 04/01/2014
[    0.000000] RIP: 0010:no_context+0x38/0x4b0
[    0.000000] Code: df 41 57 41 56 4c 8d bf 88 00 00 00 41 55 49 89 d5 41 54 49 89 f4 55 48 89 fd 4c8
[    0.000000] RSP: 0000:ffffc8ffffffff28 EFLAGS: 00010096
[    0.000000] RAX: dffffc0000000000 RBX: ffffc8ffffffff50 RCX: 000000000000000b
[    0.000000] RDX: fffff52000000030 RSI: 0000000000000003 RDI: ffffc90000000130
[    0.000000] RBP: ffffc900000000a8 R08: 0000000000000001 R09: 0000000000000000
[    0.000000] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000003
[    0.000000] R13: fffff52000000030 R14: 0000000000000000 R15: ffffc90000000130
[    0.000000] FS:  0000000000000000(0000) GS:ffffc90000000000(0000) knlGS:0000000000000000
[    0.000000] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.000000] CR2: ffffc8ffffffff18 CR3: 0000000002e0d001 CR4: 00000000000606b0
[    0.000000] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[    0.000000] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[    0.000000] Call Trace:
[    0.000000] Kernel panic - not syncing: Machine halted.
[    0.000000] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.2.0-rc7-00007-ge0afe6d4d12c-dirty #299
[    0.000000] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.11.0-2.el7 04/01/2014
[    0.000000] Call Trace:
[    0.000000]  <#DF>
[    0.000000]  dump_stack+0x5b/0x90
[    0.000000]  panic+0x17e/0x36e
[    0.000000]  ? __warn_printk+0xdb/0xdb
[    0.000000]  ? spurious_kernel_fault_check+0x1a/0x60
[    0.000000]  df_debug+0x2e/0x39
[    0.000000]  do_double_fault+0x89/0xb0
[    0.000000]  double_fault+0x1e/0x30
[    0.000000] RIP: 0010:no_context+0x38/0x4b0
[    0.000000] Code: df 41 57 41 56 4c 8d bf 88 00 00 00 41 55 49 89 d5 41 54 49 89 f4 55 48 89 fd 4c8
[    0.000000] RSP: 0000:ffffc8ffffffff28 EFLAGS: 00010096
[    0.000000] RAX: dffffc0000000000 RBX: ffffc8ffffffff50 RCX: 000000000000000b
[    0.000000] RDX: fffff52000000030 RSI: 0000000000000003 RDI: ffffc90000000130
[    0.000000] RBP: ffffc900000000a8 R08: 0000000000000001 R09: 0000000000000000
[    0.000000] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000003
[ 0.000000] R13: fffff52000000030 R14: 0000000000000000 R15: ffffc90000000130

Thanks,
Dennis

