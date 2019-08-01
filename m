Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF141C32751
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A028E20693
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 02:18:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A028E20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 079A88E0006; Wed, 31 Jul 2019 22:18:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01B668E0001; Wed, 31 Jul 2019 22:18:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4C068E0006; Wed, 31 Jul 2019 22:18:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD2458E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 22:18:01 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n4so38136174plp.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F++oM0IFb4Dzarbnf6aTsMjUhikuU7xqUEteruzc4xs=;
        b=Lj7kkCa0JLxMKkpcEb1JRxeF/M/pvgEPRADM+sjnuhmGIOJiAaT5TADQgyJUHbM8r0
         +wT9QD6FVdNNiLTc7tqMbZd8qDuJWhtwJJhO7XlFlJ7ZY1JpvPID4Z5IlrWIJQFkhnLM
         7qoZeQcEJzN6pNgd/H5yEDSYlccEw3jhXUwASWXeiPQis/F9J79XW8PQSDfKq09+9mh2
         TG6poVBo6rNWxlAncZSXx8cwL9Uw7vRHFz5acKNjUVcERCqmF2BV5lhsGfsX3bWYYFty
         UBSTT9fjf3wK597AVvkCZ3CDKqd+FaE/HIvZHmhw5gERLOQrbt6WyBCs5eJKPX7C08Vr
         NKIg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXfYbps8Gi5L8/+LmvQyxvmjzp9lFRVjzPAPNUKkgghKf3mj5Ll
	tGKda1DUJZUCZjMoYSDQqaLkN64FXvRZ8z0x0p9FiFL6jTJ9VYInrrOQ3yNn7SBkFM9b4XOke7X
	HFqg0mN9aXcp+vkgnGNZIg+lQj0TfFAfWvPHvLOHcmCcDNuHathQKiN4iMj0FQS4=
X-Received: by 2002:a63:7d49:: with SMTP id m9mr108749228pgn.161.1564625881168;
        Wed, 31 Jul 2019 19:18:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzsF3fsjuUHP8x/r2eG96jpjV7sX22dC2PLXePJvWxBBTpqtrN2BgdA5KYWAISDEPhhIDJN
X-Received: by 2002:a63:7d49:: with SMTP id m9mr108749172pgn.161.1564625880252;
        Wed, 31 Jul 2019 19:18:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564625880; cv=none;
        d=google.com; s=arc-20160816;
        b=NDT0LX4i8CMqHPk7owma8npyPug5Xt7TsrbzOBMLGYrVz5mF5YnL4s6K1AQx6iH8Lh
         lbZXEKTo0Dd8mES94aanCYCa2iW7XMUKb4+oiUcTJLv7vclpqjNf+QL+5Hz+IN+HZrEW
         pqhRZlIN99tkcu0u0ofheCWg8aEmH7fLKapd/9+ld8xLCc8w9jnCTSjCC7hjLaYJ+uoH
         RUDB52fbiQnvfKM2grKFmQ7m6q7zTOwx+IuTdB5pH0sewL4xNBp3xskOb8N9TQT6Z8+T
         DK3ioYMOFCiQDEkKn9Q9x4jj87afpKkE+L7YMPo7p9Reemc1M1hmtjDYoRqX5FB2Qd43
         aAVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=F++oM0IFb4Dzarbnf6aTsMjUhikuU7xqUEteruzc4xs=;
        b=h/wUREVS36Zzq/r0LWIIdM9PaqN2I8e5D4I9d39IrDX6Wcy9F+WnnF9ibU8uarpDQK
         Q+BFeO7KJiC3inuxQGZEOF2DgnOmcoE/INIry9v5NXQu48yDixNbWOR9OOM6Nfz40EUV
         YdI3SE0crtGccX/35+WLGgfYm4TgcCUu5I4wLlBRDnYLzljdOtb4DychVgwN8Yj2+8ZV
         D3B6U7HySqTTPWnCrWwMMpemGACC7Po7XAFKl42Z/lgUplpi78e36eGgGekFVJxgv3lc
         mY+tigxPeBJWdOT8YUzJvClPM+1xwT9S0G3klzOOIYnEc7gdmQZ24WSeScOtziZKDGCr
         rzKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id ay21si2657132pjb.34.2019.07.31.19.17.59
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 19:18:00 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-139-63.pa.nsw.optusnet.com.au [49.195.139.63])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id A28C443E4AA;
	Thu,  1 Aug 2019 12:17:58 +1000 (AEST)
Received: from discord.disaster.area ([192.168.253.110])
	by dread.disaster.area with esmtp (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0eB-0003b8-9B; Thu, 01 Aug 2019 12:16:51 +1000
Received: from dave by discord.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1ht0fH-0001lK-7I; Thu, 01 Aug 2019 12:17:59 +1000
From: Dave Chinner <david@fromorbit.com>
To: linux-xfs@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH 16/24] xfs: Lower CIL flush limit for large logs
Date: Thu,  1 Aug 2019 12:17:44 +1000
Message-Id: <20190801021752.4986-17-david@fromorbit.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801021752.4986-1-david@fromorbit.com>
References: <20190801021752.4986-1-david@fromorbit.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=fNT+DnnR6FjB+3sUuX8HHA==:117 a=fNT+DnnR6FjB+3sUuX8HHA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=FmdZ9Uzk2mMA:10 a=20KFwNOVAAAA:8
	a=y69QCnB_skpws7lHVjcA:9
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Dave Chinner <dchinner@redhat.com>

The current CIL size aggregation limit is 1/8th the log size. This
means for large logs we might be aggregating at least 250MB of dirty objects
in memory before the CIL is flushed to the journal. With CIL shadow
buffers sitting around, this means the CIL is often consuming >500MB
of temporary memory that is all allocated under GFP_NOFS conditions.

FLushing the CIL can take some time to do if there is other IO
ongoing, and can introduce substantial log force latency by itself.
It also pins the memory until the objects are in the AIL and can be
written back and reclaimed by shrinkers. Hence this threshold also
tends to determine the minimum amount of memory XFS can operate in
under heavy modification without triggering the OOM killer.

Modify the CIL space limit to prevent such huge amounts of pinned
metadata from aggregating. We can 2MB of log IO in flight at once,
so limit aggregation to 8x this size (arbitrary). This has some
impact on performance (5-10% decrease on 16-way fsmark) and
increases the amount of log traffic (~50% on same workload) but it
is necessary to prevent rampant OOM killing under iworkloads that
modify large amounts of metadata under heavy memory pressure.

This was found via trace analysis or AIL behaviour. e.g. insertion
from a single CIL flush:

xfs_ail_insert: old lsn 0/0 new lsn 1/3033090 type XFS_LI_INODE flags IN_AIL

$ grep xfs_ail_insert /mnt/scratch/s.t |grep "new lsn 1/3033090" |wc -l
1721823
$

So there were 1.7 million objects inserted into the AIL from this
CIL checkpoint, the first at 2323.392108, the last at 2325.667566 which
was the end of the trace (i.e. it hadn't finished). Clearly a major
problem.

XXX: Need to try bigger sizes to see where the performance/stability
boundary lies to see if some of the losses can be regained and log
bandwidth increases minimised.

XXX: Ideally this threshold should slide with memory pressure. We
can allow large amounts of metadata to build up when there is no
memory pressure, but then close the window as memory pressure builds
up to reduce the footprint of the CIL until memory pressure passes.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 fs/xfs/xfs_log_priv.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/xfs/xfs_log_priv.h b/fs/xfs/xfs_log_priv.h
index b880c23cb6e4..87c6191daef7 100644
--- a/fs/xfs/xfs_log_priv.h
+++ b/fs/xfs/xfs_log_priv.h
@@ -329,7 +329,8 @@ struct xfs_cil {
  * enforced to ensure we stay within our maximum checkpoint size bounds.
  * threshold, yet give us plenty of space for aggregation on large logs.
  */
-#define XLOG_CIL_SPACE_LIMIT(log)	(log->l_logsize >> 3)
+#define XLOG_CIL_SPACE_LIMIT(log)	\
+	min_t(int, (log)->l_logsize >> 3, XLOG_TOTAL_REC_SHIFT(log) << 3)
 
 /*
  * ticket grant locks, queues and accounting have their own cachlines
-- 
2.22.0

