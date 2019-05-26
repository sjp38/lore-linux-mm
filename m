Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC3A5C282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E17C20815
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 21:22:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kW8EQGCX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E17C20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8925F6B026A; Sun, 26 May 2019 17:22:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8436E6B026B; Sun, 26 May 2019 17:22:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70A346B026C; Sun, 26 May 2019 17:22:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07B0A6B026A
	for <linux-mm@kvack.org>; Sun, 26 May 2019 17:22:29 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id a25so473149lfl.0
        for <linux-mm@kvack.org>; Sun, 26 May 2019 14:22:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=nMiFTZq9m8Tud2oYGi2GiJ1Z+X/2sbQtc11N2qZi8ps=;
        b=UW9tDapsb+sI+puvb6VV9coMbBh+ko5zL752/Hn8y+mn/w6h9pgRRurak27Pm6PTiL
         1ALcsJB27Y3apwYz4r8cX+M3BYKJQjnb2cInzZcilzJNx+/33JuUrdjKILio9oJRdTOz
         0o48SngZlacJEG/TIFFwld7PHq2FtRsIMJJKpreGUJBnjaC/g4rp2sFEcq4DyOG1U5tO
         mxiaHXhILu4RQ5DzDrxeu/4UnCfN/0uuhYexSs9Shtk6hsnN+XjxOOoJ2J+NQM9Za6en
         2D8Y3lY2TOw8WT/c954qC2A7ufM5hj0iqgrchCxCaFVRffaUz+yOzREw/ngpmR3Fmmbr
         I4kA==
X-Gm-Message-State: APjAAAUB9tOYKOM6Wn6/rzgm/fYxMt5luQZ4SOZm4sqz9zhwMa4bcC+e
	KwcNHSB3HYjSWiH1KREBFcUPi1gzvJggvdd6AcMhm4vakxZOejF1uIbgQhFtMvlQcoEW2mJmu04
	Z2s6hIYRAXJvhmBU6z8aGhAtcIF1M9NfgRHKc+M5+prZXaHrgQU2NdtH4UmU5dHTbtA==
X-Received: by 2002:a19:e05c:: with SMTP id g28mr5620085lfj.167.1558905748479;
        Sun, 26 May 2019 14:22:28 -0700 (PDT)
X-Received: by 2002:a19:e05c:: with SMTP id g28mr5620064lfj.167.1558905747430;
        Sun, 26 May 2019 14:22:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558905747; cv=none;
        d=google.com; s=arc-20160816;
        b=act50UKuhNEfQmAJeXtZY4ApK18MsyCBQbjqJ8kZdyUQwp07Sarx535NGSkJ8QSVJ+
         j+w0tDNXgtBWNdOhRz17DpXxJwZF5/Cswv3zu/3hvkT3iIK6gCipQdekzjX8kWa3NMFe
         oR+D6IjJba8TYHa2t9goqwdwwYqhbc9PMQLWgNUy0z/PMwkipHvYVm+HS5HoZN4F7Xac
         okvmJDcyNid2dzqE0M5kqJ9hRTh6TXooHMA7OWFTgfmbAqmilYzaAO01PF+1IMr8P83Q
         Nxu3iSpx7OmZVwwxiHHL3E9gvF3UE1hFyM+9bGY67ZDtamn8/FQDdrCjSUy5R5QngPl/
         Rh7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=nMiFTZq9m8Tud2oYGi2GiJ1Z+X/2sbQtc11N2qZi8ps=;
        b=KDLdZKwCdyvBXFBO0GVyXshR+1GRvQv2k/trft4ktO5OtwJO3m0pgyROW9Tddj+ETg
         vT2eNrZmofdr2qLMw2ITCA8THTr0+MN5JaJcSFxa6MjTwdAVpSSPoRjayc+BIbM465Fm
         Osy7wc/R8pH0xfJVi5rzAoaUuLePor1WZiQZBTVkAT/ukx7VQVd03bjzKjhCrAy1Of1D
         fmj433lve5MhnZ1/CYT1hOuoOLfN2PzsBniwnV0J9eeNetBxu/KlllxyYML5XT/kCoCU
         uNU2VosHd96VVfSLNkNACNI5YVXVrC2QPQgdsRkQ5wInH+Z9PbXZsUokNP/pKB6it5dj
         aALA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kW8EQGCX;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p27sor4135813ljp.8.2019.05.26.14.22.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 26 May 2019 14:22:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kW8EQGCX;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=nMiFTZq9m8Tud2oYGi2GiJ1Z+X/2sbQtc11N2qZi8ps=;
        b=kW8EQGCX9RPA7Y1Hbh9+m37Rg3nnmFcAhCEEN+Wn4d6HHxofUWi5NJZicvFduiIiWH
         Z4tWfptAT8kbByu96/Af1k9A65xG9kG1xwVMP+zdYzfi5mBI3MfRi++wLymSduYdjNPS
         el25ZYIltNE8kQrBHpSMo9w+RS1fCViSv708fFUtKfLosmGswxo1c4tg/wZs9epUFFel
         ipOv7KktBtXHfm5LZmxBImQl05kSuQGLu5g/C2/JEqvzEanQeYq1WFYBsfHbm4lXQFMl
         0gdsAkkrqKf4WYwHkn8KFBNHuGoBxYk55CqocVHv6l8pqAYsNa0wErxcHIB5sV+ZYsyz
         bOwA==
X-Google-Smtp-Source: APXvYqwLtfKo3g1XsLcA3UgctcSE5rh7e9LElVzrf5Zs8QIa2LJrFz7rsW567IrrpGxEhHMpbftXEw==
X-Received: by 2002:a2e:8985:: with SMTP id c5mr14828724lji.84.1558905747025;
        Sun, 26 May 2019 14:22:27 -0700 (PDT)
Received: from pc636.lan (h5ef52e31.seluork.dyn.perspektivbredband.net. [94.245.46.49])
        by smtp.gmail.com with ESMTPSA id y4sm1885105lje.24.2019.05.26.14.22.25
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 May 2019 14:22:26 -0700 (PDT)
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
Subject: [PATCH v2 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Date: Sun, 26 May 2019 23:22:13 +0200
Message-Id: <20190526212213.5944-5-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190526212213.5944-1-urezki@gmail.com>
References: <20190526212213.5944-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
function, it means if an empty node gets freed it is a BUG
thus is considered as faulty behaviour.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 6f91136f2cc8..0cd2a152826e 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -533,20 +533,16 @@ link_va(struct vmap_area *va, struct rb_root *root,
 static __always_inline void
 unlink_va(struct vmap_area *va, struct rb_root *root)
 {
-	/*
-	 * During merging a VA node can be empty, therefore
-	 * not linked with the tree nor list. Just check it.
-	 */
-	if (!RB_EMPTY_NODE(&va->rb_node)) {
-		if (root == &free_vmap_area_root)
-			rb_erase_augmented(&va->rb_node,
-				root, &free_vmap_area_rb_augment_cb);
-		else
-			rb_erase(&va->rb_node, root);
+	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
 
-		list_del(&va->list);
-		RB_CLEAR_NODE(&va->rb_node);
-	}
+	if (root == &free_vmap_area_root)
+		rb_erase_augmented(&va->rb_node,
+			root, &free_vmap_area_rb_augment_cb);
+	else
+		rb_erase(&va->rb_node, root);
+
+	list_del(&va->list);
+	RB_CLEAR_NODE(&va->rb_node);
 }
 
 #if DEBUG_AUGMENT_PROPAGATE_CHECK
@@ -1188,8 +1184,6 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
 
 static void __free_vmap_area(struct vmap_area *va)
 {
-	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
-
 	/*
 	 * Remove from the busy tree/list.
 	 */
-- 
2.11.0

