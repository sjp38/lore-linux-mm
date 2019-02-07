Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6EA8C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 04:04:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D1F82084D
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 04:04:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="nK9wO4n9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D1F82084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDA6F8E0014; Wed,  6 Feb 2019 23:04:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C89748E0002; Wed,  6 Feb 2019 23:04:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA0EF8E0014; Wed,  6 Feb 2019 23:04:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6D98E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 23:04:52 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id q193so8322271qke.12
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 20:04:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:subject:to:cc:message-id
         :date:user-agent:mime-version:content-language
         :content-transfer-encoding;
        bh=uqDFmLu9eRIl2FkZ8iL2rbGAF9xtpoxPtooDYLXchCs=;
        b=GBKyUkmKvQehAr/rHjpGmlzSuhoK+m9rIjLrHXJyFwLM5SKJ4id/R0XFeVyWOgj0UM
         319putn0Ty6TmGSDzI0/SspQS7QB6Nkpb6Be8DXmDKF6wVUNUX0+Uc68boJ+4lm19Ayd
         F0IIIDZlKN9FRS7ntu1I4CQGdDKIf7WAofuI+gLKl2FKdCCDOpo3dkzCYvxrkVs9nr0D
         8297p3+SwknzzELAr3BeiGmZ/Glwe+oQTIttBHNN303NkE5MqyZgjcIg65sIPxt0qZaO
         T/Z89W5k5ZjXS93zT3zo3HHCKSXi5jOB+ms2HIG41CvWtgt2HIDINA1xCZlyg6ueAzOb
         R4hQ==
X-Gm-Message-State: AHQUAuYyzgZnHuexT50y16KEX/3e/gIxAd19OG5eOBZQN67wNURlZKAz
	CfA66d3yhNz5ikGRs6xW5YTKClXjl9RkeHsy3icYGk48Bc4DMM/bL3eova+N2R8zhox399rkkz5
	EjSPWjpOGRi7SmMuUrUm09NEt8GP3jk7VJL6LHP3VffdVLf+kRzfjNlS3qz3gU9PGrHgv2YVqSs
	zVICfzWM2QrKYmXnGhBz6K0dH7JxR8uCy5BwJg7as3rom2Lml+iTtXJwa4Z5rkS1ZaoHcYEMtFX
	2ITR/dEMp000yn6Y4zAR0eQugUpfa9p2bt9xRZfad7j/1vM9waeVMGIIJqgBnNrzriualOaOAh8
	OSyv4oVR949duCN1CiI6QXMqlHlSxXzk3/5L7ocvXDxBKfvYleT/pl2s80aGJ4g1kbKXpF/+i9j
	N
X-Received: by 2002:a37:7e83:: with SMTP id z125mr5572437qkc.140.1549512292204;
        Wed, 06 Feb 2019 20:04:52 -0800 (PST)
X-Received: by 2002:a37:7e83:: with SMTP id z125mr5572406qkc.140.1549512291393;
        Wed, 06 Feb 2019 20:04:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549512291; cv=none;
        d=google.com; s=arc-20160816;
        b=pda9TWoY4O/KAmZ837cwOxm0muvcnIdDGIVzrYzE2jvKM2CV5yShFn8vFnL+jbgoI8
         u48Y4G2F0yy0x8bCqsEA2tN/g7GnHRD5B9iq1RntJvk674PuGYXr9Mh1r0iSnU/Y06NL
         rLfEM/cIJ19snpXx49i7TV+WJDNEjDIsaa/Qi0FFQjlsuDpfmXO+tXr5bCZDgxK16F9J
         PRPfDIhHnin2YPeOiIETcSItXCirJ98rrpzgZXl2U6dznZ8MMBN+Tf56pt8W5uY+akA3
         fTcHKUAcxgP4qqm/6WQHuBao0rMA6dyxjup3JoCM80GhJV8C6goGP27lgyMXDOFdpqKU
         34/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:mime-version:user-agent
         :date:message-id:cc:to:subject:from:dkim-signature;
        bh=uqDFmLu9eRIl2FkZ8iL2rbGAF9xtpoxPtooDYLXchCs=;
        b=ByDMUdxLmkEN2fvqkAQmtqf+UrITNSxBlLvYJ/J9E1QcTbuFMld+XqIhU5pKMOHZJB
         xEwhQlTJ+OynBw6F5LpVLX9oVmN+Eerfbgx58Ovnhgky53WYNa+gDQXqmxwXN/tUBPLl
         JKDznQr14nsK+Y4LYfN/Vm3xAxZQgQcpFvaRDOp9NyvqZjYZW05hftaLNsG7bit/y60g
         lpGY2kvyYB7XpJCcsp5FmCzs86vN1FOfCNm5yfE7gadSsljY086UEzFAx9imqC8MCfI3
         ElVxMmlTZ4HQJjxuMcfFBkcTWeIjuAEB/1H4iIhXkjuRep1gtqZyU9KRD56NEwa+38Pw
         HhrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=nK9wO4n9;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e10sor15571767qkg.11.2019.02.06.20.04.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 20:04:51 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=nK9wO4n9;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:subject:to:cc:message-id:date:user-agent:mime-version
         :content-language:content-transfer-encoding;
        bh=uqDFmLu9eRIl2FkZ8iL2rbGAF9xtpoxPtooDYLXchCs=;
        b=nK9wO4n9hul5JU8GgFYVhCNibSqu8CPms8VeFjFWNeQqvNTmfXf9JESFrxG59YupEe
         K0l2jH2cTExPDh0+4gWTP4L9ZJqpzeKA06RLmYDiRvkzM0/Hd3KP7yRyIlnjWNEUdEse
         OY55oZgBQFn0if+EfbRQ0p8GVLZgGgN2TBsHGdwexzvxz+vIjXgxP0lYdb4bBeCKUwKS
         oDtnCNWlHM1S+M+KAsYzoiVlbVPa8i4DV6zkrlv2RsnCeQE/58LpyOvgh4cnst6jgNA9
         UdQ8iljhl8Rs30CbX3TseIxW7A3782V/YrLusStdCKXKNtER4ao0fyFq767lpmG5wVcg
         NmGA==
X-Google-Smtp-Source: AHgI3IaCyqeuRDN8q9M2toLl+/2h6YXJ0F4f/uX5cv8rQLS/UtG939rlqX0VEtLEXDfeNC0vYo4x1Q==
X-Received: by 2002:a37:498a:: with SMTP id w132mr10349837qka.92.1549512290900;
        Wed, 06 Feb 2019 20:04:50 -0800 (PST)
Received: from ovpn-120-150.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id b6sm14515948qtq.29.2019.02.06.20.04.50
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 20:04:50 -0800 (PST)
From: Qian Cai <cai@lca.pw>
Subject: CONFIG_KASAN_SW_TAGS=y NULL pointer dereference at
 freelist_dereference()
To: Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: kasan-dev@googlegroups.com,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Linux-MM <linux-mm@kvack.org>
Message-ID: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw>
Date: Wed, 6 Feb 2019 23:04:49 -0500
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The kernel was compiled by clang-7.0.1 on a ThunderX2 server, and it fails to
boot. CONFIG_KASAN_GENERIC=y works fine.

deactivate_slab+0x84/0x6ac:
freelist_dereference at mm/slub.c:262
(inlined by) get_freepointer at mm/slub.c:268
(inlined by) deactivate_slab at mm/slub.c:2056

/* Returns the freelist pointer recorded at location ptr_addr. */
static inline void *freelist_dereference(const struct kmem_cache *s,
                                         void *ptr_addr)
{
        return freelist_ptr(s, (void *)*(unsigned long *)(ptr_addr),
                            (unsigned long)ptr_addr);
}

[    0.000000] Memory: 3259968K/100594752K available (15548K kernel code, 12360K
rwdata, 4096K rodata, 25536K init, 27244K bss, 7444672K reserved, 0K cma-reserved)
[    0.000000] Unable to handle kernel NULL pointer dereference at virtual
address 0000000000000078
[    0.000000] Mem abort info:
[    0.000000]   ESR = 0x96000005
[    0.000000]   Exception class = DABT (current EL), IL = 32 bits
[    0.000000]   SET = 0, FnV = 0
[    0.000000]   EA = 0, S1PTW = 0
[    0.000000] Data abort info:
[    0.000000]   ISV = 0, ISS = 0x00000005
[    0.000000]   CM = 0, WnR = 0
[    0.000000] [0000000000000078] user address but active_mm is swapper
[    0.000000] Internal error: Oops: 96000005 [#1] SMP
[    0.000000] Modules linked in:
[    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc5+ #6
[    0.000000] pstate: 60000089 (nZCv daIf -PAN -UAO)
[    0.000000] pc : deactivate_slab+0x84/0x6ac
[    0.000000] lr : deactivate_slab+0x1cc/0x6ac
[    0.000000] sp : ffff100012cf7be0
[    0.000000] x29: ffff100012cf7cc0 x28: ffff1000114e4f00
[    0.000000] x27: ffff1000114e4f20 x26: ffff1000114e4f08
[    0.000000] x25: ffff1000114e5078 x24: fb00000000000000
[    0.000000] x23: ffff7fe002080008 x22: ffff808abb5b72d0
[    0.000000] x21: ffff7fe002080020 x20: ffff7fe002080028
[    0.000000] x19: ffff7fe002080000 x18: ffff1000148a5538
[    0.000000] x17: 000000000000001b x16: 0000000000000000
[    0.000000] x15: 007ffffffc000201 x14: 04ff80082000fa80
[    0.000000] x13: 0000000080660002 x12: 0000000080660003
[    0.000000] x11: 4582a03bdc147ab9 x10: ffff100012d31c90
[    0.000000] x9 : fb00000000000078 x8 : ffff100012d31c80
[    0.000000] x7 : cccccccccccccccc x6 : ffff1000105d8db8
[    0.000000] x5 : 0000000000000000 x4 : 0000000000000000
[    0.000000] x3 : ffff808abb5b72d0 x2 : 04ff800820000580
[    0.000000] x1 : ffff7fe002080000 x0 : ffff1000114e4f00
[    0.000000] Process swapper (pid: 0, stack limit = 0x(____ptrval____))
[    0.000000] Call trace:
[    0.000000]  deactivate_slab+0x84/0x6ac
[    0.000000]  ___slab_alloc+0x648/0x6fc
[    0.000000]  kmem_cache_alloc_node+0x408/0x538
[    0.000000]  __kmem_cache_create+0x20c/0x6a8
[    0.000000]  create_boot_cache+0x68/0xac
[    0.000000]  kmem_cache_init+0xb0/0x19c
[    0.000000]  start_kernel+0x4b4/0xac4
[    0.000000] Code: 14000057 b9400369 f940032b 8b090309 (f940012a)
[    0.000000] ---[ end trace 54ad7e55e4749a96 ]---
[    0.000000] Kernel panic - not syncing: Fatal exception
[    0.000000] ---[ end Kernel panic - not syncing: Fatal exception ]---

