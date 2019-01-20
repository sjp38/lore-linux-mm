Return-Path: <SRS0=a6Xk=P4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6025AC312E2
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 23:16:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDD2620880
	for <linux-mm@archiver.kernel.org>; Sun, 20 Jan 2019 23:16:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sF18++4H"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDD2620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39CBD8E0003; Sun, 20 Jan 2019 18:16:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34B888E0001; Sun, 20 Jan 2019 18:16:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23C6C8E0003; Sun, 20 Jan 2019 18:16:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF9F78E0001
	for <linux-mm@kvack.org>; Sun, 20 Jan 2019 18:16:13 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so19119465qtj.21
        for <linux-mm@kvack.org>; Sun, 20 Jan 2019 15:16:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=c3o0SX1EcTLKZLgoGhVUqzZpnqsfWcLGF/pNqNohEcA=;
        b=a2Q3pleLR6I8xoVczDPGWYNJ+UcdcIz9QmKIGtpgNmiMSNYNCtNcFu0iwDERnXB7tF
         S8eAAVemSFPucp03FVwnSyKHakyGkF6ioZ4cXyvVptV0mFd5huvwmatShJlXgkvpkCvb
         U6plm/RZ8H7oq5xeItmdXGfLVgaZCUMMLrt/VsFio3aE2Kte3KxEXeMPG8IcBA/OohMW
         IixYy3T+PnNHftD11QXTS2en0tRi4AmLUzv+3JRWi7D7/0kotIPmCpBrC6TVHo6qnEAj
         nJTaGS1upovhkkqJeqxqPDL+00oaAdgM28c5RML35f7Yai+FwTr8yqrHWN535BWKTbQ6
         bjvQ==
X-Gm-Message-State: AJcUukex+fzTJJ+PfA07AANES6E0VYZRvD/p1+7xasp0dwHYLOuzINXl
	b9p0s9hpTMeId2sOGuDOk3d17Uyb9rn1VFTf28uu0+1tBMupGBl1z44pBRGiXh1oi08b+bpJfdv
	e6WTAxu3huffKdb9j5WfsIE7a5inR+RdkCq4uqgmwKU9zz7qvumGKtjKB8t8mF3LdwPj1lAdnz+
	YPwBO2+i9pUq42CSyBZAGfi0xmHjgL+pelMqfuR2bRGu5nfAAFoXmrZKkSSoduESv3m6udR3YIA
	73+bcA9bhckmilufEDxamQoWoQU6iMvP7DfLOzTJeqGtg7Qu1xqvHUIHyy833VwqVY9rZynYXVz
	dKshdnWmRA8EjnawapPeaxmLChZ7UMjpX1HvEY4Spcp/AFWK9vxaEN1oy8fmRYv8uqPVaUVhXcw
	o
X-Received: by 2002:a37:85c7:: with SMTP id h190mr22235170qkd.225.1548026173547;
        Sun, 20 Jan 2019 15:16:13 -0800 (PST)
X-Received: by 2002:a37:85c7:: with SMTP id h190mr22235144qkd.225.1548026172721;
        Sun, 20 Jan 2019 15:16:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548026172; cv=none;
        d=google.com; s=arc-20160816;
        b=B4aFmUy43PvahjDyzfm1VvgUpAxGtEqZeJ6LcA3JGH7QirisrLZyEY798zTef5nvfj
         HAOUCOQDDy6m7EjYFRuEDLoJSIenc7fBRLpHqejSWW9BvyeuNWqXdPK2ehe9R+O6N54z
         AWkyu4AMaXNO5NMazQL3anhc0aE006k+WF+93lx7FOvDVYeNrJSlCVbW3MFK06GNPuOo
         5AASBjUseqH/a1A57Dyikd6Bz//WUlgljwL7yKIK3OMZk9JMZYAJzQW6YAnsD3mf9dHL
         yy/bPNUrtT3X36Uf85uA69lr3bMrSLouOnJWAM29LK2x47MTZ9wXVHaNrLI2AbOWvsow
         s8lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=c3o0SX1EcTLKZLgoGhVUqzZpnqsfWcLGF/pNqNohEcA=;
        b=GOBQt8qGK83e9C76GnF+qF8fCRXU+MMGtxPLglShYf272SG6LQ++0wd9zO+HuyMqTr
         PNInTKaATc4jJKmehmtoIkWKnmUeZ2ptpF547BhtIA610ganSRR9aQeRxv1r1bulHv84
         9t5GG9uSadxv0N9y2Zntxu6OfK33sxO9Lh26Y4fsGmNBRup9SX5xeupK7TSFA2UgR+X4
         vJ8HyT29ceVmftWLVjjjp0YtBBJp03kt0iQwPopIZd/SYyS/zNDdd+/YIsdjZb19zMbT
         AqH8rizHXhBIUc9kPYm8rQQnfvx+cswkVEfvEMKRcUcdmOsalFr82kVholZuFhfKrcOJ
         +Xjg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sF18++4H;
       spf=pass (google.com: domain of 3paffxagkcdspexhbbiydlldib.zljifkru-jjhsxzh.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3PAFFXAgKCDspeXhbbiYdlldib.Zljifkru-jjhsXZh.lod@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l15sor107011993qtr.63.2019.01.20.15.16.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 20 Jan 2019 15:16:12 -0800 (PST)
Received-SPF: pass (google.com: domain of 3paffxagkcdspexhbbiydlldib.zljifkru-jjhsxzh.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sF18++4H;
       spf=pass (google.com: domain of 3paffxagkcdspexhbbiydlldib.zljifkru-jjhsxzh.lod@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3PAFFXAgKCDspeXhbbiYdlldib.Zljifkru-jjhsXZh.lod@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=c3o0SX1EcTLKZLgoGhVUqzZpnqsfWcLGF/pNqNohEcA=;
        b=sF18++4Hbk/acIU1Sl8XkBCFAvC4j5XQqvg8A5LX8cCPuSjcsiXxxaCH/Q8+6lknnW
         kD1N8rBEs+OSwmX1uQHlbwPHgkD7xHFLl0UwbLbx3m6VQqMzLE7Yo8D4T3tGQXb6jtlH
         H4pisxKZBWoU2MIwiydTAFp7Wvt8uJR4wNo9jG8uVmStvX1wbPMpJM88paD0ItRrQO0n
         yIsh1wn/jJwfEJyAEV+ygsfRUFUAYxy0yl/FscYhdJqQAOZ+temPB+5RTtPjPWILz3Wx
         +uwzwk9QdUHJ5C0iIgzynMgQW0EJee2pAHcDu5GEgHiKTITuqkNaou1jQcAGgLqvMlq1
         8Jqw==
X-Google-Smtp-Source: ALg8bN7RdNVzQoEyncOsT1RWzMUyfExI+JAEZGVwhDQF8pzmy/Nx8QMgTI1lSbD2dRRxiv1oc8YxAwUQo8Ftlg==
X-Received: by 2002:ac8:2a15:: with SMTP id k21mr18957405qtk.49.1548026172373;
 Sun, 20 Jan 2019 15:16:12 -0800 (PST)
Date: Sun, 20 Jan 2019 15:15:51 -0800
In-Reply-To: <CAHbLzkoRGk9nE6URO9xJKaAQ+8HDPJQosJuPyR1iYuaUBroDMg@mail.gmail.com>
Message-Id: <20190120231551.213847-1-shakeelb@google.com>
Mime-Version: 1.0
References: <CAHbLzkoRGk9nE6URO9xJKaAQ+8HDPJQosJuPyR1iYuaUBroDMg@mail.gmail.com>
X-Mailer: git-send-email 2.20.1.321.g9e740568ce-goog
Subject: memory cgroup pagecache and inode problem
From: Shakeel Butt <shakeelb@google.com>
To: Yang Shi <shy828301@gmail.com>, Fam Zheng <zhengfeiran@bytedance.com>
Cc: cgroups@vger.kernel.org, Linux MM <linux-mm@kvack.org>, tj@kernel.org, 
	Johannes Weiner <hannes@cmpxchg.org>, lizefan@huawei.com, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, duanxiongchun@bytedance.com, 
	"=?UTF-8?q?=E5=BC=A0=E6=B0=B8=E8=82=83?=" <zhangyongsu@bytedance.com>, liuxiaozhou@bytedance.com, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190120231551.NlPYwhDDkt0S1k7xwzc22UZTMMkOXbs1UML2wWw6e2U@z>

On Wed, Jan 16, 2019 at 9:07 PM Yang Shi <shy828301@gmail.com> wrote:
...
> > > You mean it solves the problem by retrying more times?  Actually, I'm
> > > not sure if you have swap setup in your test, but force_empty does do
> > > swap if swap is on. This may cause it can't reclaim all the page cache
> > > in 5 retries.  I have a patch within that series to skip swap.
> >
> > Basically yes, retrying solves the problem. But compared to immediate retries, a scheduled retry in a few seconds is much more effective.
>
> This may suggest doing force_empty in a worker is more effective in
> fact. Not sure if this is good enough to convince Johannes or not.
>

From what I understand what we actually want is to force_empty an
offlined memcg. How about we change the semantics of force_empty on
root_mem_cgroup? Currently force_empty on root_mem_cgroup returns
-EINVAL. Rather than that, let's do force_empty on all offlined memcgs
if user does force_empty on root_mem_cgroup. Something like following.

---
 mm/memcontrol.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a4ac554be7e8..51daa2935c41 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2898,14 +2898,16 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
  *
  * Caller is responsible for holding css reference for memcg.
  */
-static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
+static int mem_cgroup_force_empty(struct mem_cgroup *memcg, bool online)
 {
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 
 	/* we call try-to-free pages for make this cgroup empty */
-	lru_add_drain_all();
 
-	drain_all_stock(memcg);
+	if (online) {
+		lru_add_drain_all();
+		drain_all_stock(memcg);
+	}
 
 	/* try to free all pages in this cgroup */
 	while (nr_retries && page_counter_read(&memcg->memory)) {
@@ -2915,7 +2917,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *memcg)
 			return -EINTR;
 
 		progress = try_to_free_mem_cgroup_pages(memcg, 1,
-							GFP_KERNEL, true);
+							GFP_KERNEL, online);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -2932,10 +2934,16 @@ static ssize_t mem_cgroup_force_empty_write(struct kernfs_open_file *of,
 					    loff_t off)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(of_css(of));
+	struct mem_cgroup *mi;
 
-	if (mem_cgroup_is_root(memcg))
-		return -EINVAL;
-	return mem_cgroup_force_empty(memcg) ?: nbytes;
+	if (mem_cgroup_is_root(memcg)) {
+		for_each_mem_cgroup_tree(mi, memcg) {
+			if (!mem_cgroup_online(mi))
+				mem_cgroup_force_empty(mi, false);
+		}
+		return 0;
+	}
+	return mem_cgroup_force_empty(memcg, true) ?: nbytes;
 }
 
 static u64 mem_cgroup_hierarchy_read(struct cgroup_subsys_state *css,
-- 
2.20.1.321.g9e740568ce-goog

