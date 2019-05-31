Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE616C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 19:16:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0FC926E24
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 19:16:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="ZopKFNJc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0FC926E24
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F2E46B0278; Fri, 31 May 2019 15:16:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A3576B027C; Fri, 31 May 2019 15:16:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 193506B027E; Fri, 31 May 2019 15:16:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFBE16B0278
	for <linux-mm@kvack.org>; Fri, 31 May 2019 15:16:50 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g56so1442090qte.4
        for <linux-mm@kvack.org>; Fri, 31 May 2019 12:16:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=DjQwDIi/X61xUHV4KfxSIoA+Qjc34xm4m1RHGFioGsc=;
        b=gEoUdp9h1NIxWBz71biKBVl6qyvjDRoNtC4rAlsau7OyGVHxbJVUX8bf3F0VPE1kVn
         dYgFtoawJKmq17X3G4qIxyO9gIr/EoSGewZTADZAsqZQRrFD/kEEg3c2dKtt4AWsQTuH
         fRNpxA6UvxJ9UOUDCzGLAAwVk7/3dvVK6srdxAHdOGNLwzFL88aVfH/DR91kOjNhbN1K
         A1aOw6dFHIXmA0d6gLIsTuFSdy5XdNOvayWgH/+BlXbkIKB57b7HxxcbYlDKTQ/zeJQH
         bwPv9OGMkrjTbGLBfMs9Q0m7xCLZw/ummP09sAuSW+auwnVmva3I92gzcxnUhEaCTE5O
         Vwcg==
X-Gm-Message-State: APjAAAU8UvjNcaUD2RdRlHz74k++AFLvPIcxdJckC+mBAyKDTlugVT0e
	Q13YWVLBHf0wBipQ6cJhDvIGkSEOfNi9tHSebhJow96mB2txG7UWUgvmN5ibnSnJSr+9Wl03/ij
	Nj/O6C6Ja2LMWLZEfLEQ+4izPIQ+N0V6pSa1chvvbxRmcs3CzBTf2BUWYeG37giMGYw==
X-Received: by 2002:a0c:f88d:: with SMTP id u13mr10329916qvn.153.1559330210709;
        Fri, 31 May 2019 12:16:50 -0700 (PDT)
X-Received: by 2002:a0c:f88d:: with SMTP id u13mr10329859qvn.153.1559330209984;
        Fri, 31 May 2019 12:16:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559330209; cv=none;
        d=google.com; s=arc-20160816;
        b=qW9JZeL8NJIvIuc2cFeNqw9FV6P396SPNzUJRaFC0oKybK/d5NKUpBPYItQW1tezL1
         jqWcmcAxKdVUH4bfgPJGbP6x7SfolQg52behcYRmU551Cp7io0B2tvcV4txOodqytQlJ
         UKWiQSi6RHqNtBH6Vn2zaffG6h46xlCPSIFdQ4KyNWWiiqSAafgcAi2fHii/W6uc/fgW
         GLzUUdETGCVFievjMFSeJBdID+hj29xzybAyxeFOEl0AFV4PrSQ/Aq+Rbd4mflLEVwEW
         qceO4T7mQ2Xe9A/FzmURvYx+BowY9wfyUPvCzAi+3ejAeIYlaSszhvFvDYfPnOiXlRst
         6n6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=DjQwDIi/X61xUHV4KfxSIoA+Qjc34xm4m1RHGFioGsc=;
        b=TUDhBbpAgtUCwvpynM/ixqv5Qben2L+bpAF+IUgQzoYNbjX/fuuSjxg8xOzaavIV/T
         kL8dngelqfaMIE4KT/Ie8nvdj4jfjmWQO2htSiGRiTsw7XoLABrEfvobkP19qi3MX3sv
         JpSrtEueJlX7zh0zHwVikX9lFMGI14xN8Rqn1633ORz7XycAkrHVOYxjj6t5HqSU/GjC
         iKABca9O4rn7DvnLp5BVNcjpAAiwcR7mMDfCpyj4uWrBTokFAqOUPgluF+d/49I/rBNl
         nmjJycT7NsQw+NqBxcK4XkWpMIU6padcciovlBYH+DwtPym9b43prh1paAFtnO10xftM
         A1lw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ZopKFNJc;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l188sor1201268qkd.73.2019.05.31.12.16.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 12:16:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=ZopKFNJc;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=DjQwDIi/X61xUHV4KfxSIoA+Qjc34xm4m1RHGFioGsc=;
        b=ZopKFNJcSrYMQh6vJRz0XiFxwmu0mpansaayj5Zy/797bC9u6uwCvaV/kLUFXhh4Pj
         m0LsqckNjFJ9MsMDJIn/w11kTW/SHyrveVAqJEOdAcUA+Dp6x05Jax7sj/DF70JwiXq5
         3a7DqsSZeVqrOnWM5eQM2k8SaJPkv/bqVm5LmDUA4sQEeRd9rv/d8k31ZJKUtoJvv/v0
         W40JXHgcIaAdttiEYsvjY02NeA0ODQC1PCUTizEBq1DxCdzYzZTKF9cUh0FDI23o2m/7
         KsSeZbZXTX3EROMNlBhLLMaTR2YKXps1Y9ev55CDExQ/13/WEMUVwhNJzZqoIuG6ZbJ+
         zgCA==
X-Google-Smtp-Source: APXvYqyPjbwFhw2HufCMmO5Mbi/bXaaurR1eY6i/8VWpHY8/6yWPn2euWzS6Uk8mpww2IQ9B+DlCjg==
X-Received: by 2002:a37:490f:: with SMTP id w15mr10187190qka.165.1559330209566;
        Fri, 31 May 2019 12:16:49 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id p1sm1905606qti.83.2019.05.31.12.16.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 12:16:48 -0700 (PDT)
Message-ID: <1559330205.6132.40.camel@lca.pw>
Subject: Re: [PATCH -mm] mm, swap: Fix bad swap file entry warning
From: Qian Cai <cai@lca.pw>
To: Dexuan-Linux Cui <dexuan.linux@gmail.com>, Mike Kravetz
	 <mike.kravetz@oracle.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton
 <akpm@linux-foundation.org>, linux-mm@kvack.org, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Andrea Parri
 <andrea.parri@amarulasolutions.com>,  "Paul E . McKenney"
 <paulmck@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim
 <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Dexuan Cui
 <decui@microsoft.com>, v-lide@microsoft.com, Yury Norov <ynorov@marvell.com>
Date: Fri, 31 May 2019 15:16:45 -0400
In-Reply-To: <CAA42JLZ=X_gzvH6e3Kt805gJc0PSLSgmE5ozPDjXeZbiSipuXA@mail.gmail.com>
References: <20190531024102.21723-1-ying.huang@intel.com>
	 <2d8e1195-e0f1-4fa8-b0bd-b9ea69032b51@oracle.com>
	 <CAA42JLZ=X_gzvH6e3Kt805gJc0PSLSgmE5ozPDjXeZbiSipuXA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-05-31 at 11:27 -0700, Dexuan-Linux Cui wrote:
> Hi,
> Did you know about the panic reported here:
> https://marc.info/?t=155930773000003&r=1&w=2
> 
> "Kernel panic - not syncing: stack-protector: Kernel stack is
> corrupted in: write_irq_affinity.isra"
> 
> This panic is reported on PowerPC and x86.
> 
> In the case of x86, we see a lot of "get_swap_device: Bad swap file entry"
> errors before the panic:
> 
> ...
> [   24.404693] get_swap_device: Bad swap file entry 5800000000000001
> [   24.408702] get_swap_device: Bad swap file entry 5c00000000000001
> [   24.412510] get_swap_device: Bad swap file entry 6000000000000001
> [   24.416519] get_swap_device: Bad swap file entry 6400000000000001
> [   24.420217] get_swap_device: Bad swap file entry 6800000000000001
> [   24.423921] get_swap_device: Bad swap file entry 6c00000000000001
> [   24.427685] get_swap_device: Bad swap file entry 7000000000000001
> [   24.760678] Kernel panic - not syncing: stack-protector: Kernel
> stack is corrupted in: write_irq_affinity.isra.7+0xe5/0xf0
> [   24.760975] CPU: 25 PID: 1773 Comm: irqbalance Not tainted
> 5.2.0-rc2-2fefea438dac #1
> [   24.760975] Hardware name: Microsoft Corporation Virtual
> Machine/Virtual Machine, BIOS 090007  06/02/2017
> [   24.760975] Call Trace:
> [   24.760975]  dump_stack+0x46/0x5b
> [   24.760975]  panic+0xf8/0x2d2
> [   24.760975]  ? write_irq_affinity.isra.7+0xe5/0xf0
> [   24.760975]  __stack_chk_fail+0x15/0x20
> [   24.760975]  write_irq_affinity.isra.7+0xe5/0xf0
> [   24.760975]  proc_reg_write+0x40/0x60
> [   24.760975]  vfs_write+0xb3/0x1a0
> [   24.760975]  ? _cond_resched+0x16/0x40
> [   24.760975]  ksys_write+0x5c/0xe0
> [   24.760975]  do_syscall_64+0x4f/0x120
> [   24.760975]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [   24.760975] RIP: 0033:0x7f93bcdde187
> [   24.760975] Code: c3 66 90 41 54 55 49 89 d4 53 48 89 f5 89 fb 48
> 83 ec 10 e8 6b 05 02 00 4c 89 e2 41 89 c0 48 89 ee 89 df b8 01 00 00
> 00 0f 05 <48> 3d 00 f0 ff ff 77 35 44 89 c7 48 89 44 24 08 e8 a4 05 02
> 00 48
> [   24.760975] RSP: 002b:00007ffc4600d900 EFLAGS: 00000293 ORIG_RAX:
> 0000000000000001
> [   24.760975] RAX: ffffffffffffffda RBX: 0000000000000006 RCX:
> 00007f93bcdde187
> [   24.760975] RDX: 0000000000000008 RSI: 00005595ad515540 RDI:
> 0000000000000006
> [   24.760975] RBP: 00005595ad515540 R08: 0000000000000000 R09:
> 00005595ab381820
> [   24.760975] R10: 0000000000000008 R11: 0000000000000293 R12:
> 0000000000000008
> [   24.760975] R13: 0000000000000008 R14: 00007f93bd0b62a0 R15:
> 00007f93bd0b5760
> [   24.760975] Kernel Offset: 0x3a000000 from 0xffffffff81000000
> (relocation range: 0xffffffff80000000-0xffffffffbfffffff)
> [   24.760975] ---[ end Kernel panic - not syncing: stack-protector:
> Kernel stack is corrupted in: write_irq_affinity.isra.7+0xe5/0xf0 ]---

Looks familiar,

https://lore.kernel.org/lkml/1559242868.6132.35.camel@lca.pw/

I suppose Andrew might be better of reverting the whole series first before Yury
came up with a right fix, so that other people who is testing linux-next don't
need to waste time for the same problem.


