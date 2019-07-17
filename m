Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ADAFC76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 12:29:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1E472173B
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 12:29:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=yandex-team.ru header.i=@yandex-team.ru header.b="zUT/Ch2F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1E472173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=yandex-team.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87FAA6B0006; Wed, 17 Jul 2019 08:29:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80AA66B0008; Wed, 17 Jul 2019 08:29:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D1728E0001; Wed, 17 Jul 2019 08:29:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B6626B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 08:29:22 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id a19so5264641ljk.18
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 05:29:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=GkI1vFOT++uyatsCF9OkZ7BsUl/lwbKpS28Kcx4smEY=;
        b=dbZtdNKRUrKY3hSBaGhP7n2KXhJLyoLPk3h2jjuRPKnL7JNc1faKXo/QXM5UH4QFOn
         bwuEqK8g/yn0saV6nRgKASiKyQT5iR7bw1/vLMR8rMQMlmVLDObQcaoIR4lpedY6LDUE
         WJ4p1CwhQxCwLs4KMyt72IWkczhPpdKe+4YrG8TU+7rsANAM0o38+dt7Qh+rELbQjWl4
         6JQK57VbFr60td1olkISJvGRue0875/NxaBX+YWQQsflCCR1OtonsPLq0aDzoHr72Umx
         /MDlGiTFAjENCoSX1W8v8Xlkea3H6hqZKMKHIPZDzrQC4mE/yCUsgaY+ZEgtbJHhfYN5
         EjnA==
X-Gm-Message-State: APjAAAXrrxBzWQtceMfKXtki3jWkxt5OiO/ymqgqFbOsxjjbgMQZA1H3
	Rg16r27+GhbT/7+93ioL59529iKwkDUBaKaCXQNJHkX/9Kkt5SiGYrWi5gD4d5oBTkPtCvOVYI+
	afGhMmczepLXp+hKjjj0Bm5e95MJhNe/cmlmjfQVo+NSHEfksf5tBVKBEEFJzjbad5Q==
X-Received: by 2002:a2e:8681:: with SMTP id l1mr21381095lji.166.1563366561089;
        Wed, 17 Jul 2019 05:29:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqgdDI8UTqWWrFhTPv8S332P2NLEIX/YxL+9IS36W7nbb1ER7a7o5z48SijSHA6ePnvBbA
X-Received: by 2002:a2e:8681:: with SMTP id l1mr21381043lji.166.1563366559857;
        Wed, 17 Jul 2019 05:29:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563366559; cv=none;
        d=google.com; s=arc-20160816;
        b=z252tTw1/mp+UeAYl+GlIU22sTDlvcu/s2BFZPJLnNCLq7szON5SG2E02RWBwxJAEx
         /Av8W5F3+i47MvWxHJK1uIoCCCeEHaS9LDpYvLi+wweoBvX+uJLUBieeMHK0ymhAIn7n
         3l6J/wRxW4givpJe4rtOPFe4Z95zeiKhllJ3leBvHbh5RUKwnf3YW+VoZyrcYr39Bks3
         n17H1zbKm6gkM4/NhUIZF+a4V6IItHOt5hUl7HAJbk9KqJCDcuAipEeyg+tvT7qYqKRn
         gqM6Cm0sGnAlMz0Nh28tE9zIXjVeLwqvLcg+PdjX5gJzSlLDL/VIwr7rDgvsukm9XYZn
         Q2Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=GkI1vFOT++uyatsCF9OkZ7BsUl/lwbKpS28Kcx4smEY=;
        b=V6qCdwVtQNTHi07B0AT1mzBeIyvrdvXPvhzMjvPrmHLAM7TLLKBQcX75U6IwTY1t+Y
         uksuPvtsbStBtZu4K5/b9WFXBgaMJwUrn6jbdwif5J0+9J+Ej9vwQGsPek5oqC6XVhGA
         Mm+wm2yy6E2DYUId6/sk26ZR+uLcvF7vH0nvkh9u07S53v33wyAHuQMkUHQa0GeQ4xtd
         NHVXnzjnHOR361WPJwA5akbkoUzYcLTy29+LnnJRGzmu3KEUIAq14nw4ZwGNvYrsBbU1
         6pEpkULjq1QwXBt8HFiBWySYN/fyFucLmYdkkHZBYk3t8sWlHuCEDxjdA+66Wox5EnCI
         nl9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="zUT/Ch2F";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from forwardcorp1j.mail.yandex.net (forwardcorp1j.mail.yandex.net. [5.45.199.163])
        by mx.google.com with ESMTPS id n4si19921823lfa.63.2019.07.17.05.29.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 05:29:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) client-ip=5.45.199.163;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@yandex-team.ru header.s=default header.b="zUT/Ch2F";
       spf=pass (google.com: domain of khlebnikov@yandex-team.ru designates 5.45.199.163 as permitted sender) smtp.mailfrom=khlebnikov@yandex-team.ru;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=yandex-team.ru
Received: from mxbackcorp1o.mail.yandex.net (mxbackcorp1o.mail.yandex.net [IPv6:2a02:6b8:0:1a2d::301])
	by forwardcorp1j.mail.yandex.net (Yandex) with ESMTP id 9B7102E14E7;
	Wed, 17 Jul 2019 15:29:18 +0300 (MSK)
Received: from smtpcorp1o.mail.yandex.net (smtpcorp1o.mail.yandex.net [2a02:6b8:0:1a2d::30])
	by mxbackcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTP id ttVOnIowdA-TIiK6lFj;
	Wed, 17 Jul 2019 15:29:18 +0300
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=yandex-team.ru; s=default;
	t=1563366558; bh=GkI1vFOT++uyatsCF9OkZ7BsUl/lwbKpS28Kcx4smEY=;
	h=Message-ID:Date:To:From:Subject:Cc;
	b=zUT/Ch2FRAuXKeKsUy2GKoCVeAkDxPWMsQKVKduAaqW60pGTqyj+A45AGb1DawgVP
	 MhAIsZPLGfda0d8ynwBQb/V2+vASQeWhVGFkFNW0577I3VsRlsH4Y6q0imiXzx1uA7
	 O/PaU60Bb7ohzDoMklbMGaba3gSt68RBzaw0dLfQ=
Authentication-Results: mxbackcorp1o.mail.yandex.net; dkim=pass header.i=@yandex-team.ru
Received: from dynamic-red.dhcp.yndx.net (dynamic-red.dhcp.yndx.net [2a02:6b8:0:40c:38d2:81d0:9f31:221f])
	by smtpcorp1o.mail.yandex.net (nwsmtp/Yandex) with ESMTPSA id Q1tjHAsjiv-TI98o0cW;
	Wed, 17 Jul 2019 15:29:18 +0300
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(Client certificate not present)
Subject: [PATCH 1/2] mm/memcontrol: fix flushing per-cpu counters in
 memcg_hotplug_cpu_dead
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Date: Wed, 17 Jul 2019 15:29:17 +0300
Message-ID: <156336655741.2828.4721531901883313745.stgit@buzz>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Use correct memcg pointer.

Fixes: 42a300353577 ("mm: memcontrol: fix recursive statistics correctness & scalabilty")
Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 mm/memcontrol.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 249671873aa9..06d33dfc4ec4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2259,7 +2259,7 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 			x = this_cpu_xchg(memcg->vmstats_percpu->stat[i], 0);
 			if (x)
 				for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
-					atomic_long_add(x, &memcg->vmstats[i]);
+					atomic_long_add(x, &mi->vmstats[i]);
 
 			if (i >= NR_VM_NODE_STAT_ITEMS)
 				continue;
@@ -2282,7 +2282,7 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 			x = this_cpu_xchg(memcg->vmstats_percpu->events[i], 0);
 			if (x)
 				for (mi = memcg; mi; mi = parent_mem_cgroup(mi))
-					atomic_long_add(x, &memcg->vmevents[i]);
+					atomic_long_add(x, &mi->vmevents[i]);
 		}
 	}
 

