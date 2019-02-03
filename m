Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6425EC282D7
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 01:21:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 083D42084A
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 01:21:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 083D42084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F11B8E0019; Sat,  2 Feb 2019 20:21:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A2D38E0001; Sat,  2 Feb 2019 20:21:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 491558E0019; Sat,  2 Feb 2019 20:21:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05F158E0001
	for <linux-mm@kvack.org>; Sat,  2 Feb 2019 20:21:23 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id c14so8625242pls.21
        for <linux-mm@kvack.org>; Sat, 02 Feb 2019 17:21:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:cc:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=gAwv3i0e4yQUBJreKEsStXgXdvSEn8ZW8ySEkygsCO0=;
        b=AQuBdyG63hVP3GSWeL9y4zy72Pk4590UE7t55R0fjLZ/V9vKlxSPVW01Moj8BTrMp1
         GJdSGpQKhhnFMCwCT+azDKy//qQIyBYXrtcJ4eRaA/B8vqzL28XHGLThsVAZGrJ/kV+o
         UZ/+4m4zZ6wCWdZTgYmOrmhNpqOFcru04brgRlDv9ENxhD9AEOTscsCOIxePcBD92zr8
         tjIOBdXuG+6B0wjMezGgJ0J/4tzg6otDUMF5/HlkbseDd6k/foI4cinte8swLZTgnS7G
         dvCo9FiO0WxDPF6LdRS/Hgj5caARNB//U0bVjPp45u8c+MODhB1/bTtVOgjCG9aMHiwU
         J0SQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuYC6u3+wtsAnea6lIoAFWicNFrzkYrK5VXxWHEggZnEhE+44F0T
	PBpafgq/DajNbc7BsSxottEUiPQ2lEhy3w7++vtbAEGmbcZwYgq3JPECWbKCVg6mgOyUc03l1xI
	0l+i5Tbo19MrjYVhE+n5iWqwpr07DZCmx47XIzDpYDNAK9qgsejdXrX7sx2unBLTx1Q==
X-Received: by 2002:a62:22c9:: with SMTP id p70mr17248130pfj.114.1549156882634;
        Sat, 02 Feb 2019 17:21:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib04y8s4K4m0e8TnXh0C6/UYIdM4+JRiWykHCycssMiXjH0ppU9wQYAwxB4W/32etazKWPm
X-Received: by 2002:a62:22c9:: with SMTP id p70mr17248081pfj.114.1549156881029;
        Sat, 02 Feb 2019 17:21:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549156881; cv=none;
        d=google.com; s=arc-20160816;
        b=yhPOrPTR/lX27S4ZqsM9ZJJCCRU5s8InNq+blicR7ULiPZupNHFm5HKWcIBCO3Erca
         EFjI+WLDJZ89GMDcMY2WReSgnmVE6pQ/1CMIzM6tEZPx4bsisnczvbPwtToWGDJnOh/+
         dxFkzPwIXGpkNTq7+T4ijAgxnTZIBKHyh69A51tuNBUbCafs0AW+18vWnPLwNmjqXZdD
         G1qOb33VyolX5FuT9SaIloDmmprZROFDNp3jsXsWlIALUKAs8jNICNXN/dz50iUayOtj
         y00Bf7IxKMEAg5LGhES4yb1KXkehmpAL2TgjWfmIu0xLXgpRIdrWmPWW2hZgy/s5YlEP
         VDpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:cc:references:to:subject;
        bh=gAwv3i0e4yQUBJreKEsStXgXdvSEn8ZW8ySEkygsCO0=;
        b=MKJKMgcFnPqNYKGV1+QCQjIuom5ydzE5ep7KFsiiqDnpAvQmLUU0gX1wRzF45wDY4f
         6CoPP/cDumAjWU1xf3qbHFZfd9zpVgjAkVGqlcweOohKt4IK3B4kR866VhadJ5v/mgL6
         tGr/7ZmzZQW8Noks3XVAIbWILqajxl83zo2SqdQckYKQ+XEZQL3fCfs0Mwkd1+IwmHSf
         eJLeZD/eBg+UhlbGaZV/3HisMvsLoTLFWNau9pGFMU0oL2rXWr+3Litu0MKWdU76qTpT
         EjX24wkzgvesIvy5ahtrAJhQARjJYitqu1a0SnwKyUgE3DJs0pzvXOXYIaQye1pguMY4
         /83g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w67si6892797pgw.84.2019.02.02.17.21.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Feb 2019 17:21:20 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav102.sakura.ne.jp (fsav102.sakura.ne.jp [27.133.134.229])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x131LEju064592;
	Sun, 3 Feb 2019 10:21:14 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav102.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav102.sakura.ne.jp);
 Sun, 03 Feb 2019 10:21:14 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav102.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x131L8dA064535
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Sun, 3 Feb 2019 10:21:13 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: linux-next: tracebacks in workqueue.c/__flush_work()
To: Guenter Roeck <linux@roeck-us.net>,
        Chris Metcalf <chris.d.metcalf@gmail.com>,
        Rusty Russell <rusty@rustcorp.com.au>
References: <18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Tejun Heo <tj@kernel.org>, linux-mm <linux-mm@kvack.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <72e7d782-85f2-b499-8614-9e3498106569@i-love.sakura.ne.jp>
Date: Sun, 3 Feb 2019 10:21:06 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <18a30387-6aa5-6123-e67c-57579ecc3f38@roeck-us.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(Adding Chris Metcalf and Rusty Russell.)

If NR_CPUS == 1 due to CONFIG_SMP=n, for_each_cpu(cpu, &has_work) loop does not
evaluate "struct cpumask has_work" modified by cpumask_set_cpu(cpu, &has_work) at
previous for_each_online_cpu() loop. Guenter Roeck found a problem among three
commits listed below.

  Commit 5fbc461636c32efd ("mm: make lru_add_drain_all() selective")
  expects that has_work is evaluated by for_each_cpu().

  Commit 2d3854a37e8b767a ("cpumask: introduce new API, without changing anything")
  assumes that for_each_cpu() does not need to evaluate has_work.

  Commit 4d43d395fed12463 ("workqueue: Try to catch flush_work() without INIT_WORK().")
  expects that has_work is evaluated by for_each_cpu().

What should we do? Do we explicitly evaluate has_mask if NR_CPUS == 1 ?

 mm/swap.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 4929bc1..5f07734 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -698,7 +698,8 @@ void lru_add_drain_all(void)
 	}
 
 	for_each_cpu(cpu, &has_work)
-		flush_work(&per_cpu(lru_add_drain_work, cpu));
+		if (NR_CPUS > 1 || cpumask_test_cpu(cpu, &has_work))
+			flush_work(&per_cpu(lru_add_drain_work, cpu));
 
 	mutex_unlock(&lock);
 }

On 2019/02/03 7:20, Guenter Roeck wrote:
> Commit "workqueue: Try to catch flush_work() without INIT_WORK()" added
> a warning if flush_work() is called without worker function.
> 
> This results in the following tracebacks, typically observed during
> system shutdown.
> 
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 101 at kernel/workqueue.c:3018 __flush_work+0x2a4/0x2e0
> Modules linked in:
> CPU: 0 PID: 101 Comm: umount Not tainted 5.0.0-rc4-next-20190201 #1
>        fffffc0007dcbd18 0000000000000000 fffffc00003338a0 fffffc00003517d4
>        fffffc00003517d4 fffffc0000e56c98 fffffc0000e56c98 fffffc0000ebc1d8
>        fffffc0000ec0bd8 ffffffffa8024010 0000000000000bca 0000000000000000
>        fffffc00003d3ea4 fffffc0000e56c98 fffffc0000e56c60 fffffc0000ebc1d8
>        fffffc0000ec0bd8 0000000000000000 0000000000000001 0000000000000000
>        fffffc000782d520 0000000000000000 fffffc000044ef50 fffffc0007c4b540
> Trace:
> [<fffffc00003338a0>] __warn+0x160/0x190
> [<fffffc00003517d4>] __flush_work+0x2a4/0x2e0
> [<fffffc00003517d4>] __flush_work+0x2a4/0x2e0
> [<fffffc00003d3ea4>] lru_add_drain_all+0xe4/0x190
> [<fffffc000044ef50>] shrink_dcache_sb+0x70/0xb0
> [<fffffc0000478dc4>] invalidate_bh_lru+0x44/0x80
> [<fffffc00003a94fc>] on_each_cpu_cond+0x5c/0x90
> [<fffffc0000478d80>] invalidate_bh_lru+0x0/0x80
> [<fffffc000047fe7c>] invalidate_bdev+0x3c/0x70
> [<fffffc0000432ca8>] reconfigure_super+0x178/0x2c0
> [<fffffc000045ee64>] ksys_umount+0x664/0x680
> [<fffffc000045ee9c>] sys_umount+0x1c/0x30
> [<fffffc00003115d4>] entSys+0xa4/0xc0
> [<fffffc00003115d4>] entSys+0xa4/0xc0
> 
> ---[ end trace 613cea34708701f1 ]---
> 
> The problem is seen with several (but not all) architectures. Affected
> architectures/platforms are:
>     alpha
>     arm:versatilepb
>     m68k
>     mips, mips64 (boot from IDE drive or MMC, SMP disabled)
>     parisc (nosmp builds)
>     sparc, sparc64 (nosmp builds)
> 
> There may be others; several of my tests fail with build failures.
> 
> If/when it is seen, the problem is persistent.
> 
> Common denominator seems to be that SMP is disabled. It does appear that
> for_each_cpu() ignores the mask for nosmp builds, but I don't really
> understand why.
> 
> Guenter
> 

