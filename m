Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAA56C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:53:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A62A120989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:53:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A62A120989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 603528E0008; Wed, 30 Jan 2019 13:53:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58BA38E0001; Wed, 30 Jan 2019 13:53:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42F268E0008; Wed, 30 Jan 2019 13:53:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 127B38E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:53:12 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id w18so632030qts.8
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:53:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=mlGwKIY/E9SCB+00js2v/xNWhVvGerrcKO1O55Kntjc=;
        b=cj78oUcPchXk379LjV647pf/cPIFLTZv6WoMrONh7uPkuwMsz3aNz5la6fFe1ELOqv
         v+miU+vSXfdKgLVaQ+D40XVrMhPSD+nG4pwnGHHvzk+CPOAZ8trgTMg/Lcp3RnWWDa2U
         rkcOB0I/Sttn8tnTtFTRdxy4ja3LTwhhe7dswWlaUrmC9WuN7j3cofuvn8yAcmMNz6Tp
         N1qUTQZsK6Cct1OXN/zqgXqXVXIYRgnhLQMgjFd5Fqb6qSfyKyhlAFWRNDMWRnTyjt9C
         i0n1YM6CzNLXl5cVvtpKBb/06OvTAUQEc1Y5eACigzhTlSEUby7g/xl2PLNCS1UV4by5
         HMjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeHBMQnveTBfKyviWJ1I4CI8TWOhFxulzNdbWozKt7hHtl8vqwH
	YppkYWCi7E0ziJc4SagMeOHHVHTH6eVT5atLAW+00MF/gOuLtFrsikNdW0IIDemQ0EEuIRnL0u7
	uqLYAYnrRJ0QR/3nVn7jyGZW+cav+Vbp2RaDnwApUgrgzNZ8Na2vqHfFjlonG6PzrRw==
X-Received: by 2002:ac8:3d51:: with SMTP id u17mr31360588qtf.127.1548874391852;
        Wed, 30 Jan 2019 10:53:11 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4bOindhbSLTe7S0dNzlKEqJalcJYsqQeDPmk6GZevtDo8F4CTtOZ3KQWLQ1/3SvYNWQUET
X-Received: by 2002:ac8:3d51:: with SMTP id u17mr31360553qtf.127.1548874391300;
        Wed, 30 Jan 2019 10:53:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548874391; cv=none;
        d=google.com; s=arc-20160816;
        b=VaZ/j78VsPHpDBi6qKBMLwVSZyCuJpPjto06MHJ7dT2vha535wycJN0x+cktTtIrzX
         tAtPKfoBoi1loXxek8ip/BKvxiI/HyA43L8h6GUGIoVdbSHBml1UU/dGmyOixxABHmQs
         2Lqv9YgLj9eAj4l/E0OusYHBY9MM+cN0gwg9XkoF6EccUFboOQwk+nqGNKCAFPVvCkP7
         toePpXOoFBfBsadty/E8ZUdnQGCY8fPlannJwHAGCP7GakCIsOy+x273biOF3aHhLE32
         hjOO2YOwoCrP91Ua0bP8GeF9whUZJrhoeD0Y+m1VtSHvSB2TO+sn9DjKkxXGw709wIAQ
         Jl7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=mlGwKIY/E9SCB+00js2v/xNWhVvGerrcKO1O55Kntjc=;
        b=XY98mBfAQ/f9eGZaFa+GWyIhOVTRH+AnFbTKewhgEODv6zaF39TvgHUrDXoKdue+4a
         Ya/kN2F1sNph6REA7X6X56DMt+8lrRNNcvhiC108bDGeWfm/vhlweGawvH7/UhVO4Oso
         vVUOkdZJgMY95cZbqpSBpFwxojRsnMgr80tz0xuTfy9F0K/jQ0G8KqYJDjTLxq4o1vME
         GrW6g1JmfmvESuyE1wRLnPKXgNGqM03RV1JWbWmN3fawXarXOaZWOK7FUj2i2aqeDm6I
         7UnZfc85okloAuqnwBOyQ6OdGOKS8//wio7Df7/asWur8H/fzQGo9bvjMVRRrBCEV74j
         jdYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o2si684521qkg.259.2019.01.30.10.53.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:53:11 -0800 (PST)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2F954C002961;
	Wed, 30 Jan 2019 18:53:10 +0000 (UTC)
Received: from llong.com (dhcp-17-59.bos.redhat.com [10.18.17.59])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4FBFC378D;
	Wed, 30 Jan 2019 18:53:07 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-doc@vger.kernel.org,
	"Luis R. Rodriguez" <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jan Kara <jack@suse.cz>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Miklos Szeredi <mszeredi@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Larry Woodman <lwoodman@redhat.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	"Wangkai (Kevin C)" <wangkai86@huawei.com>,
	Michal Hocko <mhocko@kernel.org>,
	Waiman Long <longman@redhat.com>,
	stable@vger.kernel.org
Subject: [RESEND PATCH v4 1/3] fs/dcache: Fix incorrect nr_dentry_unused accounting in shrink_dcache_sb()
Date: Wed, 30 Jan 2019 13:52:36 -0500
Message-Id: <1548874358-6189-2-git-send-email-longman@redhat.com>
In-Reply-To: <1548874358-6189-1-git-send-email-longman@redhat.com>
References: <1548874358-6189-1-git-send-email-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 30 Jan 2019 18:53:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The nr_dentry_unused per-cpu counter tracks dentries in both the
LRU lists and the shrink lists where the DCACHE_LRU_LIST bit is set.
The shrink_dcache_sb() function moves dentries from the LRU list to a
shrink list and subtracts the dentry count from nr_dentry_unused. This
is incorrect as the nr_dentry_unused count Will also be decremented in
shrink_dentry_list() via d_shrink_del(). To fix this double decrement,
the decrement in the shrink_dcache_sb() function is taken out.

Fixes: 4e717f5c1083 ("list_lru: remove special case function list_lru_dispose_all."
Cc: stable@vger.kernel.org

Signed-off-by: Waiman Long <longman@redhat.com>
Reviewed-by: Dave Chinner <dchinner@redhat.com>
---
 fs/dcache.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 2593153..44e5652 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -1188,15 +1188,11 @@ static enum lru_status dentry_lru_isolate_shrink(struct list_head *item,
  */
 void shrink_dcache_sb(struct super_block *sb)
 {
-	long freed;
-
 	do {
 		LIST_HEAD(dispose);
 
-		freed = list_lru_walk(&sb->s_dentry_lru,
+		list_lru_walk(&sb->s_dentry_lru,
 			dentry_lru_isolate_shrink, &dispose, 1024);
-
-		this_cpu_sub(nr_dentry_unused, freed);
 		shrink_dentry_list(&dispose);
 	} while (list_lru_count(&sb->s_dentry_lru) > 0);
 }
-- 
1.8.3.1

