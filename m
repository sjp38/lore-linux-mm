Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BEA7C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 084E220693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:33:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 084E220693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBDAB8E0015; Wed, 31 Jul 2019 22:33:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF8438E0001; Wed, 31 Jul 2019 22:33:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A26978E0015; Wed, 31 Jul 2019 22:33:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 517D58E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:33:38 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so44562920pfo.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:33:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=55GU3i+l+wcvajR7XSfByHlGeW26xiXSp3BdXEb9npw=;
        b=QLfmRvVBHAiG7UHNGNA232ojBZD1pKus+/n+WBgYRRgwmokdqoRv5z8GMWcUzuQpCl
         wX5l2SKLhl9/PbgVzoNTb5rFwa3irqHYmfz7TIIUhFSJ6yQbi1Pq1MCplPPBFOjzCuEC
         dWqw5oOPyVYkSfMC5kxEA/E3RRJuZdizG9HjOyTJmRx3jQjGH7zig29vtiZ1H2p8BxzB
         a+ATbmrHKhAbQEs2h4Otfm3v+mgfT9SPhn8Xr1O+tqoH/+ziY3yrYWxGvVjr/TBBxaE6
         1e+GX05dr8UbhP6m/GNnn1NNJioEZ+L2lxTn7/b2Spn1SpwFSuQbw2cymSkjeDlwVFnQ
         MxTg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXhzsmZ9vLDQlp3uzgcQHdjLAMwZRPw86cspDhkDoVmbpGgQR0s
	9KfCmqC9BzvKjpN6p1S547FxYGckm4f5rv/hWbNhHzgBYp6MZ91TgR60OWWi9YhMiS9wPAupD9k
	Zz3PsZVI+ZzzhdKc3TOINZ1U3+FsKjhO8ycG8Vokqw6nlFNiTfscPARMNIGoCG8A=
X-Received: by 2002:a17:90a:4f0e:: with SMTP id p14mr5779490pjh.40.1564626818017;
        Wed, 31 Jul 2019 19:33:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsuwAirNE0vuHGwKgeRAWxCjxWzTFQDBn2hJFJMB3G9nL7SxnG7c+lAGIYEXI8b9KvPqO8
X-Received: by 2002:a17:90a:4f0e:: with SMTP id p14mr5779458pjh.40.1564626817343;
        Wed, 31 Jul 2019 19:33:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564626817; cv=none;
        d=google.com; s=arc-20160816;
        b=m7oQfqyR5gGPW3Amg9MwCkTmnBvXyTeWtDeZ0RYAmYD/qSDWKHE+Oyu3/FAhAkHd3T
         3KKvWHZHYQ5yG4SgoVCcdEGvqsTtxkxVTZHrqym18niOsBeygGWPLCFL+EXKQYjwUcT3
         KDPGB7muuCJYu+dzuaZyggfcT913bYOeIlZf09t2sbEyRz1/ubZ79Acl0Z4RU5ig9IHG
         E8Bybh4ZtbXPblIfK+gk7S5OIcegt80W56J4yRAtShgPZG6urLngUBqi8x4kRwT2mv62
         WXpLwqEQirGWOzTDSL7n4QmmdiMrewYUGVJN3ZgwODHDKxFlTnNpNIjExXdrfpYnD6Dp
         ACTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=55GU3i+l+wcvajR7XSfByHlGeW26xiXSp3BdXEb9npw=;
        b=cNq9ke2Yvhrl0/5o3Ki/CTwjv8Q49zAgHN2r6U8n2RFphXX0aWcHAGGn0mRY4RHx7F
         1C+fzP2s7c2D6K60h3jVJiE5gzAGCp2osLdIyxTegIwYtpGav/wmHBARlTiWw/nG/mZ+
         eZObaIHDy5aVY5pQ2ZpKDhMp6+AmzEdAnVbpSf9TW3jSu6TU6oDPqM1towk8nbH7ysq/
         Ar5RoXIUA1XtQ0vSRONoof9KaZc4sG7nozfDrq+2RuitopHW5WYm5bArQ8niJBS/njpB
         X/jz+FtWmAbXFRdda8CYAU69TYs73QZT70BrOITHCGehpvz3q7Z52fVrj4uI5vy6eKF1
         d3FQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id d34si15373856pla.283.2019.07.31.19.33.36
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:33:37 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id A3D6A36193F
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 12:33:35 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003b5-80; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001lH-5l; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 15/24] xfs: eagerly free shadow buffers to reduce CIL footprint
Date: Thu,  1 Aug 2019 12:17:43 +1000
Message-Id: <20190801021752.4986-16-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=Z3AahodxQ8A0aNDaG7EA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

The CIL can pin a lot of memory and effectively defines the lower
free memory boundary of operation for XFS. The way we hang onto
log item shadow buffers "just in case" effectively doubles the
memory footprint of the CIL for dubious reasons.

That is, we hang onto the old shadow buffer in case the next time
we log the item it will fit into the shadow buffer and we won't have
to allocate a new one. However, we only ever tend to grow dirty
objects in the CIL through relogging, so once we've allocated a
larger buffer the old buffer we set as a shadow buffer will never
get reused as the amount we log never decreases until the item is
clean. And then for buffer items we free the log item and the shadow
buffers, anyway. Inode items will hold onto their shadow buffer
until they are reclaimed - this could double the inode's memory
footprint for it's lifetime...

Hence we should just free the old log item buffer when we replace it
with a new shadow buffer rather than storing it for later use. It's
not useful, get rid of it as early as possible.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_log_cil.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/xfs/xfs_log_cil.c b/fs/xfs/xfs_log_cil.c
index fa5602d0fd7f..1863a9bdf4a9 100644
--- a/fs/xfs/xfs_log_cil.c
+++ b/fs/xfs/xfs_log_cil.c
@@ -238,9 +238,7 @@ xfs_cil_prepare_item(
 	/*
 	 * If there is no old LV, this is the first time we've seen the item in
 	 * this CIL context and so we need to pin it. If we are replacing the
-	 * old_lv, then remove the space it accounts for and make it the shadow
-	 * buffer for later freeing. In both cases we are now switching to the
-	 * shadow buffer, so update the the pointer to it appropriately.
+	 * old_lv, then remove the space it accounts for and free it.
 	 */
 	if (!old_lv) {
 		if (lv->lv_item->li_ops->iop_pin)
@@ -251,7 +249,8 @@ xfs_cil_prepare_item(
 
 		*diff_len -= old_lv->lv_bytes;
 		*diff_iovecs -= old_lv->lv_niovecs;
-		lv->lv_item->li_lv_shadow = old_lv;
+		kmem_free(old_lv);
+		lv->lv_item->li_lv_shadow = NULL;
 	}
 
 	/* attach new log vector to log item */
-- 
2.22.0

