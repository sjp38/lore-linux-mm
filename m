Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,UNPARSEABLE_RELAY,UNWANTED_LANGUAGE_BODY autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17EDBC282E3
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:14:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C73CB20833
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 02:14:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C73CB20833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 785666B000A; Sun, 21 Apr 2019 22:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7335D6B000C; Sun, 21 Apr 2019 22:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 626216B000D; Sun, 21 Apr 2019 22:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 270C56B000A
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 22:14:54 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b8so2116201pls.22
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 19:14:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=BgNh+vAF7phhzpkVy3grjGwDPnewjQrXNbDOE1trMjs=;
        b=Llgkq60dqn2gcEJfYiMGbhv7RG2xgBGh3zY9NUpf/b3/3g9tsKppJC50aPvlwexS0y
         16XLsFqi9EnApHwhl0cF7py7tHUkwdOYlPDl7mTSnEvpDCRonaH/yoP13FqIGZc69wT6
         K7nHdEH6/xOMCfBuGSBTE2uP6AGNNjOcPQ30oz4cUcmm5eW9ckxkzAbocXcis3E5OrCp
         nTcnhH/XKoS7Nu47jXZYCQ9kEAettu+7E2l7N56E+NrIJ0bt/JQdEv/a8OyRzvfNXCfe
         cCLtTU+5vWqq3va/WeFfenvg77IcxUE9WDy9nBfofFEFuXgM+WaJ8aTNvxAkjkp5v0kp
         XJnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWUgD/uwcpSEjjcDffxCTmdS9+yxbypSub8JituVgC6qbae2jXs
	8Gapbl3kbXGx1hG1Wav1p2rfspf51qKqeQzKtjTjmnviJtz4rYj9egLA2qPZGeEiLHV+bvR/prS
	Z/nPGjNcxmVHuZcM+zGbcdOzhQNAHNmn9kgWiZ3lr6JD0DnTXwVWJM3IZNP50lcY8fg==
X-Received: by 2002:a63:d607:: with SMTP id q7mr7447641pgg.213.1555899293707;
        Sun, 21 Apr 2019 19:14:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyY2HLB9po3VMY2p33kTuDICW84evdOPN0ewSy5cEZWq55FcDMy3fj1xiWh4xjr6Wcn8RHF
X-Received: by 2002:a63:d607:: with SMTP id q7mr7447576pgg.213.1555899292344;
        Sun, 21 Apr 2019 19:14:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555899292; cv=none;
        d=google.com; s=arc-20160816;
        b=c81QQFhLoE072C66UgA8w++06ZzyBBZf1bGZTRArUZICPohNSTH6EYXcIgaDdxvUyB
         NhT6VBoDbeSd/Hk0pnY2LKcYAMYdOZ3V2aZq0jU6ezFGczNGi+4H8ufajw4QzEHKpp1t
         imVDHDEHnpfYc2aShUBwHnTKMlc5pB7m2fIs1C66Q4mPFXfoFTGKS1JyI6FskzNrMETI
         vbG64La9flYL2rkMAEO0+rLLz5EnYMe8fnaUzdquyAkwf6I0TwpLZ9soDPJTosw+uWr7
         SR5qn2ToEBEegTtvfKa+l2g9xJ83Sl/XR1GAFK9kO7sGx505WhYgGBj+urFjkxgT9Iyf
         xAdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=BgNh+vAF7phhzpkVy3grjGwDPnewjQrXNbDOE1trMjs=;
        b=OomCPbNfKzKplUMRtgXRg448gCkZJxfro2fQ8bcWjpZ46QhrFpA+DSSJg01WK1bzD1
         oAdX9c31yVpY98jM8lCmqWJA8iaH0wOTMrVRPjwdXk1c0NquLdam4f6n6lnMsJ/N/Vz6
         IrLeURrBg3PZ2FW3dfiljZ2i0dC35iBUv8UHnS5K0zzPyifox2GVqCRxGf8hGeWW8qcb
         8aH19wt/iyBiktDvm5ZRrUzg8UjrWSjS0XXV1KOqzNBac2VVbXBeBB+qV5ICSkmQb72s
         26juSRvJaeQJTgVG/Ggwn4lOCxHSSZrejvs8ZaVXCKJWvs83haRCqIQ7lRBwVKhR/Yr+
         gaPA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id g20si12297281pfh.226.2019.04.21.19.14.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Apr 2019 19:14:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) client-ip=115.124.30.132;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.132 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R401e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04423;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TPtroFq_1555899288;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TPtroFq_1555899288)
          by smtp.aliyun-inc.com(127.0.0.1);
          Mon, 22 Apr 2019 10:14:48 +0800
Subject: [RFC PATCH 4/5] numa: introduce numa balancer infrastructure
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
To: Peter Zijlstra <peterz@infradead.org>, hannes@cmpxchg.org,
 mhocko@kernel.org, vdavydov.dev@gmail.com, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Message-ID: <42f47daa-22bb-3c93-9939-1514eb3bbda4@linux.alibaba.com>
Date: Mon, 22 Apr 2019 10:14:48 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now we have the way to estimate and adjust numa preferred node for each
memcg, next problem is how to use them.

Usually one will bind workloads with cpuset.cpus, combined with cpuset.mems
or maybe better the memory policy to achieve numa bonus, however in complicated
scenery like combined type of workloads or cpushare way of isolation, this
kind of administration could make one crazy, what we need is a way to gain
numa bonus automatically, maybe not maximum but as much as possible.

This patch introduced basic API for kernel module to do numa adjustment,
later coming the numa balancer module to use them and try to gain numa bonus
as much as possible, automatically.

API including:
  * numa preferred control
  * memcg callback hook
  * memcg per-node page number acquire

Signed-off-by: Michael Wang <yun.wang@linux.alibaba.com>
---
 include/linux/memcontrol.h |  26 ++++++++++++
 mm/memcontrol.c            | 101 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 127 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 0fd5eeb27c4f..7456b862d5a9 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -200,6 +200,11 @@ struct memcg_stat_numa {
 	u64 exectime;
 };

+struct memcg_callback {
+	void (*init)(struct mem_cgroup *memcg);
+	void (*exit)(struct mem_cgroup *memcg);
+};
+
 #endif
 #if defined(CONFIG_SMP)
 struct memcg_padding {
@@ -337,6 +342,8 @@ struct mem_cgroup {
 	struct memcg_stat_numa __percpu *stat_numa;
 	s64 numa_preferred;
 	struct mutex numa_mutex;
+	void *numa_private;
+	struct list_head numa_list;
 #endif

 	struct mem_cgroup_per_node *nodeinfo[0];
@@ -851,6 +858,10 @@ extern void memcg_stat_numa_update(struct task_struct *p);
 extern int memcg_migrate_prep(int target_nid, int page_nid);
 extern int memcg_preferred_nid(struct task_struct *p, gfp_t gfp);
 extern struct page *alloc_page_numa_preferred(gfp_t gfp, unsigned int order);
+extern int register_memcg_callback(void *cb);
+extern int unregister_memcg_callback(void *cb);
+extern void config_numa_preferred(struct mem_cgroup *memcg, int nid);
+extern u64 memcg_numa_pages(struct mem_cgroup *memcg, int nid, u32 mask);
 #else
 static inline void memcg_stat_numa_update(struct task_struct *p)
 {
@@ -868,6 +879,21 @@ static inline struct page *alloc_page_numa_preferred(gfp_t gfp,
 {
 	return NULL;
 }
+static inline int register_memcg_callback(void *cb)
+{
+	return -EINVAL;
+}
+static inline int unregister_memcg_callback(void *cb)
+{
+	return -EINVAL;
+}
+static inline void config_numa_preferred(struct mem_cgroup *memcg, int nid)
+{
+}
+static inline u64 memcg_numa_pages(struct mem_cgroup *memcg, int nid, u32 mask)
+{
+	return 0;
+}
 #endif

 #else /* CONFIG_MEMCG */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f1cb1e726430..dc232ecc904f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3525,6 +3525,102 @@ struct page *alloc_page_numa_preferred(gfp_t gfp, unsigned int order)
 	return __alloc_pages_node(pnid, gfp, order);
 }

+static struct memcg_callback *memcg_cb;
+
+static LIST_HEAD(memcg_cb_list);
+static DEFINE_MUTEX(memcg_cb_mutex);
+
+int register_memcg_callback(void *cb)
+{
+	int ret = 0;
+
+	mutex_lock(&memcg_cb_mutex);
+	if (memcg_cb || !cb) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	memcg_cb = (struct memcg_callback *)cb;
+	if (memcg_cb->init) {
+		struct mem_cgroup *memcg;
+
+		list_for_each_entry(memcg, &memcg_cb_list, numa_list)
+			memcg_cb->init(memcg);
+	}
+
+out:
+	mutex_unlock(&memcg_cb_mutex);
+	return ret;
+}
+EXPORT_SYMBOL(register_memcg_callback);
+
+int unregister_memcg_callback(void *cb)
+{
+	int ret = 0;
+
+	mutex_lock(&memcg_cb_mutex);
+	if (!memcg_cb || memcg_cb != cb) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	if (memcg_cb->exit) {
+		struct mem_cgroup *memcg;
+
+		list_for_each_entry(memcg, &memcg_cb_list, numa_list)
+			memcg_cb->exit(memcg);
+	}
+	memcg_cb = NULL;
+
+out:
+	mutex_unlock(&memcg_cb_mutex);
+	return ret;
+}
+EXPORT_SYMBOL(unregister_memcg_callback);
+
+void config_numa_preferred(struct mem_cgroup *memcg, int nid)
+{
+	mutex_lock(&memcg->numa_mutex);
+	memcg->numa_preferred = nid;
+	mutex_unlock(&memcg->numa_mutex);
+}
+EXPORT_SYMBOL(config_numa_preferred);
+
+u64 memcg_numa_pages(struct mem_cgroup *memcg, int nid, u32 mask)
+{
+	if (nid == NUMA_NO_NODE)
+		return mem_cgroup_nr_lru_pages(memcg, mask);
+	else
+		return mem_cgroup_node_nr_lru_pages(memcg, nid, mask);
+}
+EXPORT_SYMBOL(memcg_numa_pages);
+
+static void memcg_online_callback(struct mem_cgroup *memcg)
+{
+	mutex_lock(&memcg_cb_mutex);
+	list_add_tail(&memcg->numa_list, &memcg_cb_list);
+	if (memcg_cb && memcg_cb->init)
+		memcg_cb->init(memcg);
+	mutex_unlock(&memcg_cb_mutex);
+}
+
+static void memcg_offline_callback(struct mem_cgroup *memcg)
+{
+	mutex_lock(&memcg_cb_mutex);
+	if (memcg_cb && memcg_cb->exit)
+		memcg_cb->exit(memcg);
+	list_del_init(&memcg->numa_list);
+	mutex_unlock(&memcg_cb_mutex);
+}
+
+#else
+
+static void memcg_online_callback(struct mem_cgroup *memcg)
+{}
+
+static void memcg_offline_callback(struct mem_cgroup *memcg)
+{}
+
 #endif

 /* Universal VM events cgroup1 shows, original sort order */
@@ -4719,6 +4815,9 @@ static int mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	/* Online state pins memcg ID, memcg ID pins CSS */
 	refcount_set(&memcg->id.ref, 1);
 	css_get(css);
+
+	memcg_online_callback(memcg);
+
 	return 0;
 }

@@ -4727,6 +4826,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 	struct mem_cgroup_event *event, *tmp;

+	memcg_offline_callback(memcg);
+
 	/*
 	 * Unregister events and notify userspace.
 	 * Notify userspace about cgroup removing only after rmdir of cgroup
-- 
2.14.4.44.g2045bb6

