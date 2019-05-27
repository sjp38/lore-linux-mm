Return-Path: <SRS0=UsNd=T3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81E19C07542
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:19:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40E172184C
	for <linux-mm@archiver.kernel.org>; Mon, 27 May 2019 15:19:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sp5TtVt0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40E172184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37EA26B0284; Mon, 27 May 2019 11:19:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FC9F6B0285; Mon, 27 May 2019 11:19:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 128286B0286; Mon, 27 May 2019 11:19:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 92DD46B0284
	for <linux-mm@kvack.org>; Mon, 27 May 2019 11:19:02 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id x204so2130211lfd.12
        for <linux-mm@kvack.org>; Mon, 27 May 2019 08:19:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=v/69OPvwjOinzl+9ALg7GpdBlRB0Izx4CLNV/SO6CVY=;
        b=AIZIzGH+/7wDafBAd3epAOTBpHVr5zTbJfnBJrBpGt9U2Fc7zoqsq+0h/LoDkYczr1
         RXTb6OUP6T9eLi/lK0bRhtMHTCmNUQ6Yg+zUNFg2d/R3nWmMgxYr+Ilo5xbtno1LNcLl
         6jUUJOO1aUALYl0IP2RcQWHfD3MIoWm2JO7A1veh1swShCxKmCV1WOEwcyHJ+x4klCle
         9JbKwNEUIad0DJkJe8/Rt1RFD93wKYlZ2MuWz1cGFkxUfDlNvaTztFK/+cM1Igo4LJxp
         dJvi/1mdBMgtL35+K7RFCwLGkGjekYluodsnhMS5zB1PtIZzo8dVdiVO0WniwPlbuWiE
         7WTA==
X-Gm-Message-State: APjAAAXprA2vlIoN8Sd4p0k8f9STWkiY7Pt/3MYqezZM7BFvI2wA8Oxc
	xgN6KUs8QKXWs5odFCP2mDtOjbKIoR7dHPT+koPW2UwMUbKfyVULVko773ysU0OgiHUr9iqveg1
	GoVNRSxoVuvc+1qUFFrDZq9z6mQq3idTHJd9k7JVK3tE2RGlUjqIqx521WhGACYUQWQ==
X-Received: by 2002:ac2:5546:: with SMTP id l6mr28413783lfk.50.1558970342044;
        Mon, 27 May 2019 08:19:02 -0700 (PDT)
X-Received: by 2002:ac2:5546:: with SMTP id l6mr28413732lfk.50.1558970340969;
        Mon, 27 May 2019 08:19:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558970340; cv=none;
        d=google.com; s=arc-20160816;
        b=dFuboKEM/Mt+pOGQYfI6rYnkspX0UC1oAk5T4EczasDB/+EK9eHG+0eB0gQvDXtT5q
         U5G7L96yXuxX8rf2Tu2WFZtnBjPLcITQ3V9WbjjuF7M024xKZ1LMHxO/VIkAKQhrl9cP
         sq6PyOHN7/DXF/vKuFEKGYTjSgJn5T3Fery4TZWw5Gg8n4DuqcH30nPLXSHg5UU24pLG
         Zaym1/ByKO7XkVFdt4dglECf00YLMC424jHJEn1Yvae42+fk0KdJq+5yTugEMO84dp54
         pNYBfKwytzXdIsxAk3jYv1qeDIm1hx+z5TKpIsYCPH1V+GUzJ/220Ld9ReJw1rzv0qLa
         z7yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=v/69OPvwjOinzl+9ALg7GpdBlRB0Izx4CLNV/SO6CVY=;
        b=bCjp8qBS2xFgDEMP6ldvEar3tbBMp9PuRHgW2dr/m7iftQoA28XxW/h/gEwsSg7Q7Q
         sTOYIFaKTJ9oZ+cT0MZeYlYts7xwDOlNjtyed9Ow9d9om8x9r/qZT+S39lhOIyPCdlDx
         WntQmA5d0fhxTREm+3uUQjE8bt/ixwMBSTe5noC9eY9UsQv/o4fUJX0DZg5umjLsFD3w
         1Z7iHd3MxCO7vsbI7sPRUqhZ/2dA6vRRdJN5M7LIyKsCQNOd7dcre8kz1nAif5e2vBxD
         db3LDqrTMq6tTh+wcLUHxWWDkEqb8qhIwTtIxp9zicCuaSlNQNkeAkX8d+/r/s/B8UKP
         /tSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sp5TtVt0;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p27sor5462024ljp.8.2019.05.27.08.19.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 May 2019 08:19:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=sp5TtVt0;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=v/69OPvwjOinzl+9ALg7GpdBlRB0Izx4CLNV/SO6CVY=;
        b=sp5TtVt0QWossyePsI0pwfUwbXk0kwuyZ3Q6WK9mDv5RwWtoQH2e93S6VPSdJf2Pd7
         ueQNA2nVax3EAVEuU8+zB9l+e6ZKexa0Sala5JZsZhaJkmkJcpYsiX2BtKsY6VLpRuaT
         vz5fnHdqqbVuD1f6oHE4OTdmhb8AF9lGaT6wYx1HAS2P8EG6G7W2XULg76DyX3veqI56
         aND2VwK69f/iqhtVR9U2YgL0Oui6eD75hK3Ld9JxCrOVIw5jKVlZDCRI5hdghprkXpe/
         QazwvMFfeiMeEiR6SiWw/C3Rz70yvm0JA1FsRynowlMMKSyJTiry5opRgWMYWqNAP/H6
         LYQg==
X-Google-Smtp-Source: APXvYqwCoutspyS+zZrN5ZysSrHKllwv2mgh3TpyyOJ5FW6lX7OaWsa0f9YLi2ui4UlgnpRQBjECXg==
X-Received: by 2002:a2e:8796:: with SMTP id n22mr3489968lji.75.1558970340582;
        Mon, 27 May 2019 08:19:00 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id h25sm2308701ljb.80.2019.05.27.08.18.59
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 08:18:59 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Hillf Danton <hdanton@sina.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH v4 4/4] mm/vmap: switch to WARN_ON() and move it under unlink_va()
Date: Mon, 27 May 2019 17:18:43 +0200
Message-Id: <20190527151843.27416-5-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190527151843.27416-1-urezki@gmail.com>
References: <20190527151843.27416-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Trigger a warning if an object that is about to be freed is
detached. We used to have a BUG_ON(), but even though it is
considered as faulty behaviour that is not a good reason to
break a system.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 371aba9a4bf1..1dd459d0220a 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -533,11 +533,7 @@ link_va(struct vmap_area *va, struct rb_root *root,
 static __always_inline void
 unlink_va(struct vmap_area *va, struct rb_root *root)
 {
-	/*
-	 * During merging a VA node can be empty, therefore
-	 * not linked with the tree nor list. Just check it.
-	 */
-	if (!RB_EMPTY_NODE(&va->rb_node)) {
+	if (!WARN_ON(RB_EMPTY_NODE(&va->rb_node))) {
 		if (root == &free_vmap_area_root)
 			rb_erase_augmented(&va->rb_node,
 				root, &free_vmap_area_rb_augment_cb);
@@ -1187,8 +1183,6 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
 
 static void __free_vmap_area(struct vmap_area *va)
 {
-	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
-
 	/*
 	 * Remove from the busy tree/list.
 	 */
-- 
2.11.0

