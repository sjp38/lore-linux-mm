Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAC6BC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:41:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72496216FD
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:41:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ckInvDlJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72496216FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 263FD6B000A; Fri, 26 Apr 2019 21:41:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 213946B000C; Fri, 26 Apr 2019 21:41:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 129AB6B000D; Fri, 26 Apr 2019 21:41:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD7006B000A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:41:50 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id j12so3172914pgl.14
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:41:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Vi4T6hxSwq3G73XHQoSiCXDXJSYbyNXZsyIwOF3tJSU=;
        b=dKqoZb5UUkTav/CUMDZ9YcgskcIGma0+MDYk+QUppRX1056jV3UFAfPAar338Nfd1w
         Br9x0mOBMUO/T2koNmp7ijvEmvRBqSctu53va9nL24PgCMA/UO94lDjhMnVz/Y42R2u4
         LYXJFR51WiztLav67KRPoe/Z44AR/jdQ30yy25PZyWGxF3W4WtvoZ9Bqwosjj4KGXiwX
         BHrP4aKO3nHb5VmJl2ArM32Ap69PDF0XYgJveQ9FzQaypBzQ53k64f9ETyaFtWqIG1A6
         s9A1p0NBUhG+f/th92LtaZoz/8Fa+lKszufhFB+GljIGStnW17v0mSFjb6MdCCkIW3Hn
         n6Wg==
X-Gm-Message-State: APjAAAUEOgt6/CcL6Kc9gRcAnPMrc+yh7z/IRtRbByxisTRk0yNAoo4U
	wyqZlcYpKM5VixvPnskDK0yHTP7E7fzyzewaZu9jiIP253whivYk9tcuN63R2a0dvASojd79nPK
	ggMcxjI6yc7GIM3Hkyg6GF1NopZ+mjog5nHUa3WQVXeBd9L59az12hd7XXtGNLUj0Jw==
X-Received: by 2002:a63:6503:: with SMTP id z3mr47640906pgb.113.1556329310442;
        Fri, 26 Apr 2019 18:41:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlJ9RqMT61XdEJGNQ1nsUQUCQAQtcgjEfj88o/9RKL/YSlJpteJEnEnJc4CK6UW1XNDiwz
X-Received: by 2002:a63:6503:: with SMTP id z3mr47640865pgb.113.1556329309747;
        Fri, 26 Apr 2019 18:41:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329309; cv=none;
        d=google.com; s=arc-20160816;
        b=X0P392Nc1+zmy4q0Uf1BEChcGNqw7rsB/eefLTo+BuRkhTp0sGDzUOgSubICveLmcX
         Y6bB61jxGJT4cq0WR0kZCUIYCd+uH8AnhrHAnmgfoewdzFvePcnexZMqzxNeT7/soxEj
         jPJE/skO9KSqoUC3ZZwH7IAQR0O0U1eFIkE79xoT/Yo3EHwW26XaDHe8vLgVGS8rDFfC
         Z+/hG9N471SJG8qZ8+SprfbfwDrhKpekrmiQ/oFsCY45MUW/8rFUOLNyZ6KqQZ/j2owh
         Pqrf5jNnoyg8XvYWWFMgsWCqcGwdKkm6xul3rLc0blZpC3u06/gB38ApXMHxalA9O3ml
         m6Kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Vi4T6hxSwq3G73XHQoSiCXDXJSYbyNXZsyIwOF3tJSU=;
        b=Q1bQkpc2J5YKkk3xKshMIIqc1N08C/Q0+lHRYMxuNiTx8bBKtd6i1KPo5H9S0iakJA
         KdEFW9diA8iQLX46k/FIV8PJFtklavTdeInSgOStSZtk/ZSlmHrkRqmEZ4r+mkOhTr67
         QOdeQnDYzh+JRUCfJ62BQFSFcdP1aY+foOta7c7Ez/Eq26wWFgScOgXfHfu5quzs9VpI
         01aDU1A8d1MsP/pOirnjeENzkItQ696qEvlgBSFOY71aCxbRDzne66lb7KBTZTInB/Sj
         umwZ5oGqhdYhqz+DWDC17ViboRtseap3COtFpOZ80E8Akac4vWkh8x0glAR1LdVPAz8u
         UxmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ckInvDlJ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id be1si9966624plb.286.2019.04.26.18.41.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:41:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ckInvDlJ;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 84C352173E;
	Sat, 27 Apr 2019 01:41:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329309;
	bh=Dfb0m+dKOjZ261kAFokQFS5zgR8yMauVoqIuHnLIdPc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=ckInvDlJkaiDNO4yr2qRD3YevaF9QkOMk05JxjSb6+dZhaDM6XUPZxuQnDBjSTmY+
	 O98ZPRYxLRroxhVSkbQclDVwCszvtxtC399+xvRRcHd3x7SvDW3laAg/yD8I9RKPrG
	 b+nLJ66gVpjpxKxrJQ7RNBDYrMOsw7NBPLVDZzGk=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Qian Cai <cai@lca.pw>,
	Tejun Heo <tj@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 34/53] slab: fix a crash by reading /proc/slab_allocators
Date: Fri, 26 Apr 2019 21:40:31 -0400
Message-Id: <20190427014051.7522-34-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427014051.7522-1-sashal@kernel.org>
References: <20190427014051.7522-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Qian Cai <cai@lca.pw>

[ Upstream commit fcf88917dd435c6a4cb2830cb086ee58605a1d85 ]

The commit 510ded33e075 ("slab: implement slab_root_caches list")
changes the name of the list node within "struct kmem_cache" from "list"
to "root_caches_node", but leaks_show() still use the "list" which
causes a crash when reading /proc/slab_allocators.

You need to have CONFIG_SLAB=y and CONFIG_MEMCG=y to see the problem,
because without MEMCG all slab caches are root caches, and the "list"
node happens to be the right one.

Fixes: 510ded33e075 ("slab: implement slab_root_caches list")
Signed-off-by: Qian Cai <cai@lca.pw>
Reviewed-by: Tobin C. Harding <tobin@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/slab.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index b8e0ec74330f..018d32496e8d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -4305,7 +4305,8 @@ static void show_symbol(struct seq_file *m, unsigned long address)
 
 static int leaks_show(struct seq_file *m, void *p)
 {
-	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
+	struct kmem_cache *cachep = list_entry(p, struct kmem_cache,
+					       root_caches_node);
 	struct page *page;
 	struct kmem_cache_node *n;
 	const char *name;
-- 
2.19.1

