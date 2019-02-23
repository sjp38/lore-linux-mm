Return-Path: <SRS0=E+cj=Q6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7CD4C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 06:35:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 868EA20652
	for <linux-mm@archiver.kernel.org>; Sat, 23 Feb 2019 06:35:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rjb+/2w2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 868EA20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0B5E8E014B; Sat, 23 Feb 2019 01:35:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D8FF48E0141; Sat, 23 Feb 2019 01:35:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C32178E014B; Sat, 23 Feb 2019 01:35:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8798E0141
	for <linux-mm@kvack.org>; Sat, 23 Feb 2019 01:35:55 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id u24so1820721otk.13
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 22:35:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=yhOgIfVhgUxGNA3/y93NZzblYSFJxAnLZ4az1Uovz+g=;
        b=LYl+zglgEF/Ycj4kl19L3ImRNhCrFgrpZps1TwDw5vMLRvaR2Xsc/tQJe36vOfpKwH
         MPC2mdBXCQqSwisUN0IG7bzHbtCWygZpK3ztCTL840CY3FPP65Yi0GbibAOQBbUEdN90
         pQlHJjS1niY+nlTHCasiS5gzX+DKPlJwxsuVDCwIDBnfRw64a2dT3202A3CI8d99Mwko
         kB4PlzHnWGy1nBkhXJqcW4oZA8vWDDSz0/md2e9IWwFz+SPMT6StAPjyqQxe+2OQyRKH
         SG1cWTevtT5Er114w3sXnduqWUSBIEgDF9yyFUVwFBy3eW2GRo0O3SWSiWJvN7C5GStB
         MXPw==
X-Gm-Message-State: AHQUAuaM9f4ovyVgj+KgOVElUL6Fx6kwghPnpECSZ4C1xFatD0ZyrlRg
	dzqC9OHXrZYuhkZf4M5t2OdbpgwoDugB2ZYlniDrEv9o/PfeqATkJr3JVhCI+xxRpt/9t8iKn5M
	5TKNH3KNBVdxbM4m0iBIcsy/AxyKU/9u0lyAPJBOsEUYCLLnPeXk6N6a7+mnOHAT7suXWx1ho2Y
	ncuC0ffdohMtB6CS/HMIL+mTjA/ZGiDF7XKSSjd00fgyFrvCMGGdiRGbCekpwicgJreXDoMvrXG
	6pgj6Q96mPMbOlVEoNL1W4B2TXuBUh6GaxJF1Vp3ciEhmxM8HOKci7sUZX5lB3pn1su0OhLPSVR
	f9kmzjiaKXSmlqM4joivS11no1vK+GVyWUZZWhZZ8JCh30uBqY/3E6dbfQtBBPBAL2jabLYsLM4
	R
X-Received: by 2002:aca:b7c4:: with SMTP id h187mr5011397oif.112.1550903755226;
        Fri, 22 Feb 2019 22:35:55 -0800 (PST)
X-Received: by 2002:aca:b7c4:: with SMTP id h187mr5011371oif.112.1550903754487;
        Fri, 22 Feb 2019 22:35:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550903754; cv=none;
        d=google.com; s=arc-20160816;
        b=rUq/bBovwivDtpLDGt42SPudJDwOMlryNtBWhDnBQg1P2Yjo2gqHV5eBE102bL6lof
         gTeK4pe2+bPUzEWR7r3TQw8QgAxPl4OONdd6z9K4DD5PwY2nqd9G6UScBBjb+QaS6hnc
         0fE0ZSuNoi0xkza+soGFc6xY4fAltlpL5X2rDIKkzb2I+wysCE6kHr/7yyIkB0NZqd4t
         phjitvRP/CAnTIQgzZEe5l0vb6e8AvRqr1lBN3CIfA4sq+Sbp0LnXSmudGAnWQ/eL5me
         z+j5smnPlZ2s1YKmi8hNXapvfDuasvbqH47g2F6cJmpclQcmN8FlEIsU5BK2JBwNZZEb
         wsjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=yhOgIfVhgUxGNA3/y93NZzblYSFJxAnLZ4az1Uovz+g=;
        b=xTA9RX5qFQyF/K6dH39MfPfn8X82ynn/hwCeymxm8U6oNBQp8/lvkG0KA0WLinYpeY
         Gk0PsagbddzJxHwBI/wQkLuakPVoN4d2OEVQlFiYEtjo4qULKvjdyaBKSwHOlEqXllV1
         LayE2wCzmPS+1LNYdq3sCWY2Ts/GA8QIQdBqfPrjwfKegn2beo+bdVtUmy/fIg898Q8m
         4i4yv/AhXcpPNru2ZrapN+jvM7DbHNAHFyNkhLZH4/Nkq8vtdWOdMW3nGcY1kdheyKZx
         olQ2/V2lFF9p9LKTlCXrhhATF3ouoIt1Ua8y4cAd0ZKzWH8ywGJVYQNBuPp710uTmA4R
         /UZg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="rjb+/2w2";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c8sor1897093oto.81.2019.02.22.22.35.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 22:35:54 -0800 (PST)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="rjb+/2w2";
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=yhOgIfVhgUxGNA3/y93NZzblYSFJxAnLZ4az1Uovz+g=;
        b=rjb+/2w2PubEGHI9lliFmVPoFeNasdkJCgxE/2BySo9p4LpVxc8wZn+GyDpMxmmfUF
         0Pti/QbQ1y61AV9qVdT62xQelKgS5bn7luAnZKkc/J9x80tajd4eBFtPnGFqm/j4Gr+H
         u6NyvXrZ+FKzzU4mGJInLoR0QVTc/SPdqZsJ3v1QZ272YkjBnP0zUSdT1syIAMcDDcb9
         Q8yq31NXt9uvXpbqdtJLyaLVGIUD3h0McapYgi1EfQhynpA3mbhNzueTag3g2R34h6Tt
         SjmE7USfjl2LgKC2jGG5y+7hk9mGNfunxYrq4PJ7+MDcMNRU2wuMLmyAMHHWPG+kkwqt
         VClA==
X-Google-Smtp-Source: AHgI3Ib7kGGQwRjZumRNBfzx4tHBxgD5HSybVQ45ClMb0XYFBia3t/NURMgVbTKpAkpjL+nJ7awQsg==
X-Received: by 2002:a9d:4b13:: with SMTP id q19mr5304066otf.304.1550903753684;
        Fri, 22 Feb 2019 22:35:53 -0800 (PST)
Received: from eggly.attlocal.net (172-10-233-147.lightspeed.sntcca.sbcglobal.net. [172.10.233.147])
        by smtp.gmail.com with ESMTPSA id c24sm1510112otl.67.2019.02.22.22.35.52
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 22 Feb 2019 22:35:52 -0800 (PST)
Date: Fri, 22 Feb 2019 22:35:32 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Linus Torvalds <torvalds@linux-foundation.org>
cc: "Darrick J. Wong" <darrick.wong@oracle.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Matej Kupljen <matej.kupljen@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
    Dan Carpenter <dan.carpenter@oracle.com>, linux-kernel@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: [PATCH] tmpfs: fix uninitialized return value in shmem_link
In-Reply-To: <20190221222123.GC6474@magnolia>
Message-ID: <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
References: <20190221222123.GC6474@magnolia>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Darrick J. Wong" <darrick.wong@oracle.com>

When we made the shmem_reserve_inode call in shmem_link conditional, we
forgot to update the declaration for ret so that it always has a known
value.  Dan Carpenter pointed out this deficiency in the original patch.

Fixes: 1062af920c07 ("tmpfs: fix link accounting when a tmpfile is linked in")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 0905215fb016..2c012eee133d 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -2848,7 +2848,7 @@ static int shmem_create(struct inode *dir, struct dentry *dentry, umode_t mode,
 static int shmem_link(struct dentry *old_dentry, struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = d_inode(old_dentry);
-	int ret;
+	int ret = 0;
 
 	/*
 	 * No ordinary (disk based) filesystem counts links as inodes;

