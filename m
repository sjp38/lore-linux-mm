Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B10EEC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:10:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75EF220879
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:10:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ruSnW7Uo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75EF220879
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C8C46B0008; Wed, 22 May 2019 11:09:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5520F6B000A; Wed, 22 May 2019 11:09:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30C5B6B000C; Wed, 22 May 2019 11:09:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB8476B0008
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:09:56 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id g8so455047lja.12
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:09:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=HFExWlr1uO9x+HQMZPCc0rJnteE0HEqVX28pJUGOwfI=;
        b=pj/brO6BWQu6spQ8MAWXjfiI8wdW3CmpQGKySIUzZHroAZtq9Zr0LORKzqqDecMYsF
         gn+AJmPmvBsKpehq+j1yYHaH3fOFp8Jov8RQGGcNrzHxgAKBPdynFmfMt81MoKZIcIbq
         QUD6he/bSY0FTm/v70lpaP9Upqmuw3DnYG9Igx2g1kU+TmGzGkJ+TyCRyUZMvMVgnJBl
         d1haGu9d8CgwVi8UdJF5fIst3c6KauNHYnZtxCagUj22wjEwsVmn/VqfevLLdL4673vA
         M/WRI2za4xOl6qBEZzkNJ4WoHCqNBWpCYs7xx5HNY6fDKR7Hd9ryNeQ1M5IiERS+3AE0
         zg7Q==
X-Gm-Message-State: APjAAAVj4lrH0idctBoJlV3cZadxiBiz1gQNm7uOxKxTKkB0WMWyrbP6
	81RcQQhsD5GY7+z3GisPYC7P2tSIc9xUf8iAbswcyt+VeidD/ckuitrBKxkVQOweQR2pnqn3GD8
	dLyQQSiMpR8t3GBBRyk62Hxigc6DfDqfwivF88dobTQobBnQPpQ3yeFzyI1F/VlhEow==
X-Received: by 2002:a19:2b84:: with SMTP id r126mr43734764lfr.86.1558537796160;
        Wed, 22 May 2019 08:09:56 -0700 (PDT)
X-Received: by 2002:a19:2b84:: with SMTP id r126mr43734721lfr.86.1558537795109;
        Wed, 22 May 2019 08:09:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558537795; cv=none;
        d=google.com; s=arc-20160816;
        b=NzcYdWGfwIKYNL+vyGAfl9B7rzhpM57qIDTUZAJczCcGMB8d0mA8LLWjWAv96igjpc
         KycRaVOrH/b7R6LUGLEFyVom6esrQz9h6MI37DHpI05jRKSvPZPGsDZY2J8rgm/YbBJo
         wdxgqJNLOBXG/zaIyHjFXtNtnQQW53K5Zy90+Pqm/6GH5tgnMd/1aA0NUHTUICtUcJP4
         pr3VDBgPW/9zevXeVPfq0D8hgDBjV9MNJaQYCIfD7iHxQYL/zYI597ZeJxxSJZBi/07p
         XdCsCG9oH6GJYu+bTKM54eavBUD+/mR/gOr7yCI/L/UYHWZyE1+BedisgY676NBvb57i
         NxxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=HFExWlr1uO9x+HQMZPCc0rJnteE0HEqVX28pJUGOwfI=;
        b=OntXidEq/4PKRDlJdKSsi+6R1JE4P38x/bz3B40cTX+yrEfDT9JYS81XYTEKILqByy
         ouuNkzWj4L3eKy6P87v7zd+2qQlAbiMXphYNB6oDn55g/czlCocPQEA4vL3jT5cYQqhX
         uqN+ESD74K0KDhALeSSsLU7MbMnGFRq0kHSqrWEEAeOfxcW6qqZ6mHvNGD5ZuYEuC+aj
         n/EtGALuFU0nSifnDM7VI0XOhQYqR4Mf3b0AyxzJODCknEmD5ODAjt03df77FRSVc34j
         CWEr2PGA0sCI38SKEJvkQ+cgJBeULJ4jqGU7NrwzfC7d695kzHTvOOV+wtjE+GtAfBQb
         LhQA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ruSnW7Uo;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f17sor628184ljg.16.2019.05.22.08.09.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:09:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ruSnW7Uo;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=HFExWlr1uO9x+HQMZPCc0rJnteE0HEqVX28pJUGOwfI=;
        b=ruSnW7UoKugOt8Wk1U1vu2eypYhGi77d8sGeCoBp0oSFU+eDgdC9MwQtjOXVfQNXuV
         6KJdjb33wUXIuVd6jL6/hrMIkIwfRg6u25wtb98ZvjDdRkC8gQ5YNKjlKIERjDCtgBpF
         YTMccV5Ssgz03q4pn1PtYWTiu9ac7xUwgjKnVrljLksEI+e5xpoedgjRRhXPKAg0jQd7
         bphzSaFhRjZD4d1D9guADzeRVcCpyJyuiNn/S7k2cEay/j2r19+H6JHZF1iVQFe7KZYI
         wIiDn56+llj1MsRwEDWcT2FNWLpU0Kj75jessgu3OTtCThc/G7QGX3XDY0oUaBgCEhVl
         VxPw==
X-Google-Smtp-Source: APXvYqxhdEDHSoE2NHR+WwYFSvC801p+AYV2zVp/M5sMm0EjyGz/P8bAl+KcSdmxXbpFBa/oszd+gQ==
X-Received: by 2002:a2e:9d09:: with SMTP id t9mr12001686lji.151.1558537794729;
        Wed, 22 May 2019 08:09:54 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id t22sm5303615lje.58.2019.05.22.08.09.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 08:09:53 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roman Gushchin <guro@fb.com>,
	Uladzislau Rezki <urezki@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: [PATCH 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Date: Wed, 22 May 2019 17:09:39 +0200
Message-Id: <20190522150939.24605-4-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190522150939.24605-1-urezki@gmail.com>
References: <20190522150939.24605-1-urezki@gmail.com>
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
index 89b8f44e8837..47f7e7e83e23 100644
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
@@ -1190,8 +1186,6 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
 
 static void __free_vmap_area(struct vmap_area *va)
 {
-	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
-
 	/*
 	 * Remove from the busy tree/list.
 	 */
-- 
2.11.0

