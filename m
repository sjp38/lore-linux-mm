Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5AE6C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 846BB20840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 23:00:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="os1d9NLE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 846BB20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C46E8E0006; Thu,  7 Mar 2019 18:00:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64ACA8E0002; Thu,  7 Mar 2019 18:00:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C9FB8E0006; Thu,  7 Mar 2019 18:00:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7668E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 18:00:44 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id y1so17939400pgo.0
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 15:00:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SQTP2I1IGTAHWCfjeZNx8sn2B6cnWOl+ZJBV9SuBK5k=;
        b=hX+mdnF7A6Eklxnw4KLN4Qq5ZsEJeFjLEHMK9dZIl888bQTb+731WYDBQWLk5YDZAF
         aMsklQ77bStBd+USVb+nF887AmBOwBnvyKELkXFHSCHoApKIRXqzMPAZQj8KGVV3JxL4
         b0kcIMOMWcUrSI7x8JJalWIKozZ2VGjo2VoQ+kzMgjmJX6PF2cdb2oj7mWvdTVf58Q44
         clQG5NUMkVFm0+OIQChl+Ua78fDZgv/MTCPGKozw/x2B8odzasTehwqtSD61AlBMzRa/
         mLX1NjhXyDe7sz55xMpBeHeOLQE7P0zDI6BO5f3NGgVmEP7exzg54MAm0ewRlPBYYEAm
         7JFw==
X-Gm-Message-State: APjAAAVGVKj1I3TdIclauitf7Tg3jPCz1sfG1qHUYsRdT55H158fOrJ7
	6gk6cpEY99/PQCP3lLldEVMwzFAwsuLEt3dj6YZJHq7ngrSjCCg3d6C5muKSgMY2awNUGXT4BAA
	X2+xCBPZTCAiPl/DmDLLrSoBoGFwsagoooVhggrt2sjYrviSFW3czc3o+sDBEhvUtzGQJZChPGe
	Nxm1RXZ/w3pX6StZdcTsIv5bx+r7dnmgsSpO4sqdT35yExPhIIaQGzieQLEGUsEfw4tLdVe8oSC
	bMMTwT3KPWLoma3LXTUrmo4TBhokkFRDyhPNTB1MSCP10KLExVcNUoen3HvOBYmAp9Se/zbwwOK
	o0DGK2NdKsJ7aHNeXeoi9dE5GDQJrCYQVI1DlMyuzbKXnielDPgoXTNFJvRSXtcTb+wCy+zOBvi
	/
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr15611005pla.27.1551999643678;
        Thu, 07 Mar 2019 15:00:43 -0800 (PST)
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr15610797pla.27.1551999641318;
        Thu, 07 Mar 2019 15:00:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551999641; cv=none;
        d=google.com; s=arc-20160816;
        b=HWpGQcYOk4QKEj0v3/yZebub6YnXiIj988sTo/AFM/Sw8x1YsNtR6hai+V0inMGE/d
         IYexkv4bGieT6Ejm6vjW0arpWCmcuP10glkGCA5PfiVB2z4PYo5s5j55/leHHxxItsld
         f4TFdyOMySLNnp8bpBhroIMsroqSejo+NsRrOFVnevdIftC4iYPlRvNZ6icEX16mOgEg
         ZrqzZcTQT9eZEPRaVd6Fy8Hr6xEA9ziCTBSld6PP9OMsFXGsH3DMg2E5fu3RcJfBq18i
         KAxMl8Ww5aiVhKATjxTn3WP8rdH3MxrAcn6eWCpTfLdh+/7iqmBWu6T9wA+03uruFvdv
         O0nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=SQTP2I1IGTAHWCfjeZNx8sn2B6cnWOl+ZJBV9SuBK5k=;
        b=caHEfG5CfoujyeuTq0tSoYcSy/w+87kN7eXMIfrjPM5m770mTUf1GAtqAnuuzMDyVE
         RWV61p451hyKGhvMz7Ru8CnN2DtdwpIYvlHl+xVkQ3giMTqIBoka1wsbSJgQtI3TwTnd
         DeGdWnE5ALF7dYio0MlRE4GdmVTFXYfT2sZ9dnY1CkJv6I6V4URHfov1hfcTeljPf1lO
         IfmaVr1bQTGWHJvbimRTxy4RqqsTbO7XUtkuIja17AY0jTFqMRvle4jRuz9VgX3EQmg6
         9ZRPvfLHPat1UCz7qhySJxCrpjHsYZoDk+/BVky67M9RPWDswp4K3AfbIsHjkMRbh3x6
         Qcfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=os1d9NLE;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z185sor9691992pgd.55.2019.03.07.15.00.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 15:00:41 -0800 (PST)
Received-SPF: pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=os1d9NLE;
       spf=pass (google.com: domain of guroan@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=guroan@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=SQTP2I1IGTAHWCfjeZNx8sn2B6cnWOl+ZJBV9SuBK5k=;
        b=os1d9NLEH5YF0msLsK9q6RDbE3XUiJPCFohANPKSxtyy1x/weqPxw5h9t+FkSwtb+9
         saeQFtoUHoBKFJasOMziLWJlyrqai9AU7rUCxmaiyWN5dE7t1mi2fYabAXmOvFRwbK/v
         dH9lNacjzQFRf+ia+gZQGZm8ZmRvl3FRXnt9eYMPesZ5xe6i/oC+USIAcfXUri7eXDCV
         bMWVeR5OD3oIIWdgoP/mz2x/zWuhPgEhzIJ1NiBqqtmSMCpZpsWbCakalGsqdNT/htmf
         dE7pCH1s6pZXaYOsvVhNaz6SWXisByM0sEPp9jVJEFN7bbWPi0Urx7ssMWxDxyGmVT3X
         jPlg==
X-Google-Smtp-Source: APXvYqzuaBCXJLZFV1Hn/0UeWiWtkt2B6OPUoPpFb7ChIAkLJsa7GOYp5MTkoZaxbfQmXh2nd3BiVA==
X-Received: by 2002:a63:4e1d:: with SMTP id c29mr13842615pgb.433.1551999640819;
        Thu, 07 Mar 2019 15:00:40 -0800 (PST)
Received: from tower.thefacebook.com ([2620:10d:c090:200::2:d18b])
        by smtp.gmail.com with ESMTPSA id i126sm11864806pfb.15.2019.03.07.15.00.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 15:00:40 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
X-Google-Original-From: Roman Gushchin <guro@fb.com>
To: linux-mm@kvack.org,
	kernel-team@fb.com
Cc: linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Roman Gushchin <guro@fb.com>
Subject: [PATCH 3/5] mm: release memcg percpu data prematurely
Date: Thu,  7 Mar 2019 15:00:31 -0800
Message-Id: <20190307230033.31975-4-guro@fb.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190307230033.31975-1-guro@fb.com>
References: <20190307230033.31975-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

To reduce the memory footprint of a dying memory cgroup, let's
release massive percpu data (vmstats_percpu) as early as possible,
and use atomic counterparts instead.

A dying cgroup can remain in the dying state for quite a long
time, being pinned in memory by any reference. For example,
if a page mlocked by some other cgroup, is charged to the dying
cgroup, it won't go away until the page will be released.

A dying memory cgroup can have some memory activity (e.g. dirty
pages can be flushed after cgroup removal), but in general it's
not expected to be very active in comparison to living cgroups.

So reducing the memory footprint by releasing percpu data
and switching over to atomics seems to be a good trade off.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h |  4 ++++
 mm/memcontrol.c            | 24 +++++++++++++++++++++++-
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 8ac04632002a..569337514230 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -275,6 +275,10 @@ struct mem_cgroup {
 
 	/* memory.stat */
 	struct memcg_vmstats_percpu __rcu /* __percpu */ *vmstats_percpu;
+	struct memcg_vmstats_percpu __percpu *vmstats_percpu_offlined;
+
+	/* used to release non-used percpu memory */
+	struct rcu_head rcu;
 
 	MEMCG_PADDING(_pad2_);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8f3cac02221a..8c55954e6f23 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4469,7 +4469,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
 
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
-	free_percpu(memcg->vmstats_percpu);
+	WARN_ON_ONCE(memcg->vmstats_percpu != NULL);
 	kfree(memcg);
 }
 
@@ -4612,6 +4612,26 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	return 0;
 }
 
+static void mem_cgroup_free_percpu(struct rcu_head *rcu)
+{
+	struct mem_cgroup *memcg = container_of(rcu, struct mem_cgroup, rcu);
+
+	free_percpu(memcg->vmstats_percpu_offlined);
+	WARN_ON_ONCE(memcg->vmstats_percpu);
+
+	css_put(&memcg->css);
+}
+
+static void mem_cgroup_offline_percpu(struct mem_cgroup *memcg)
+{
+	memcg->vmstats_percpu_offlined = (struct memcg_vmstats_percpu __percpu*)
+		rcu_dereference(memcg->vmstats_percpu);
+	rcu_assign_pointer(memcg->vmstats_percpu, NULL);
+
+	css_get(&memcg->css);
+	call_rcu(&memcg->rcu, mem_cgroup_free_percpu);
+}
+
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
@@ -4638,6 +4658,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	drain_all_stock(memcg);
 
 	mem_cgroup_id_put(memcg);
+
+	mem_cgroup_offline_percpu(memcg);
 }
 
 static void mem_cgroup_css_released(struct cgroup_subsys_state *css)
-- 
2.20.1

