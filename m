Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77FD3C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:27:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2CB182171F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 01:27:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RWdnpec1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CB182171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A35628E0003; Tue, 12 Mar 2019 21:27:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B9A48E0002; Tue, 12 Mar 2019 21:27:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 864CA8E0003; Tue, 12 Mar 2019 21:27:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2DC8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 21:27:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id y1so411615pgo.0
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 18:27:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=DcQ2WocT+J2kTJpFnS9iX9mF0/3egjHnKwIWN+woEMI=;
        b=HMeAH1zLGGYIhXNW3z+QRLtTOZbJcrH+YAwAu1DsIU9DM7a3uXuLle0UxLEUPHoPnT
         foc+K2c0aNsgLWvZHJ3hljLM2pyxKhNdunT2EdwMcczLB70XUwGznN+zlnoIKH+huX1e
         8xmZcPW5tcKrFUQOPq4IBzGvBNOCS+LmoZfMRiaEogaEXjNvS+bi9i4fNfGr3Hb6FKWO
         m96dKo1KtE02LY4cud9vtoVgoNk6a0Sub5AUTjnzEDsH7IwEigIJHvWHlqyp/aJUVaJi
         oNhUvKajjGMwuJ6sGmaoJkZneq0Dr5zd5NQocuww7m4HtXOETTZ3uGAip9gt/FX71v4b
         Akcg==
X-Gm-Message-State: APjAAAUUpT/Jwv5z7k6R3T4vr7VyNiF+ArbkrBVFpFb/tMfDR63aSwSY
	yH/3ku8EfXIQq8D3AT/BtiORX1MBN+ap1//XIYyLvD/vAz7VPjiOR55pykRyOV3w88oXoBdYYus
	w8VVNCE6xxFFhiMIxrEfcue5hoe2iUxc8oSEaLD7o/M+f+c3VBzD0CSKaNpe/uBMj9/udWpXhlw
	e6Hd/4iYKaAGsQvO5lq9qsKorDrQeRN/0FC0OCPEaBB5yG2Hq+kABX26RSXrRQfZbifVgRnU6hY
	Q4ZhE9Xw9ofpK265TWkF0U2Z7ZHhtJbhg1HofhXv81t6aVPFeSDCQp8RVjpmTsbX4ErMQRW9XRY
	2QA8JkFQzOe9bwNOipnBJiXrzo/CxrV9rsEjUJt1HQuqgGtpjwHtsBU0NClTZRAh3GSHYSGSrEe
	j
X-Received: by 2002:a62:6d81:: with SMTP id i123mr41224550pfc.235.1552440422673;
        Tue, 12 Mar 2019 18:27:02 -0700 (PDT)
X-Received: by 2002:a62:6d81:: with SMTP id i123mr41224495pfc.235.1552440421652;
        Tue, 12 Mar 2019 18:27:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552440421; cv=none;
        d=google.com; s=arc-20160816;
        b=ZViH/qks15iv5jZvJ35CKPh9g25E3+jirz0hkyPzcumszemcRyBcVtls0LUKdoZ/bx
         pG7y8/d0fJgOCYAGz5TICBEm1I8t98tFkYCZi/3ij5NJLWQISTEsTdM4JOKyXfKjzi8R
         7USncfSjH3jpH43RPbOzIIZqx5Ro+of+ulREbmEyO4ay2LysGhAWyWXPTzc1qMzql3rd
         +DEAkon76GsmwxSiMtBxTG91FkCxR3nj58MpOAHi0ndK0MjeZr2z2/sSE/dibt98b6P4
         8pPdv7nqBwbukcAfRYEUnkhYLoFDeBdBO+PVPfxkb8biDMLN1pdLlCQqiohWJnGifChU
         58Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=DcQ2WocT+J2kTJpFnS9iX9mF0/3egjHnKwIWN+woEMI=;
        b=fieXKdmzqNE96dGBY/csd/qsXmiu3aQR8poADC9wjyYUspenzI3w4EjPsa2AOLIp8l
         AHi+RkoVJXTBwIB9ue25ipU4Rvp5PtE14BoqSj/QdeLHJah6pEsE6POjxLnpA2qPY9MK
         s0G5+h1Fa7Z9Bj7FvTmxRuyczxeXzil6CYl7LqSrKFZszi29rla0g/fNEa2Ni0iAjgfD
         8c03XpR07rIopbOzRhVC1sgX12AmskEU3HnUMBmu8hRADDuBGUms/t+GtAHAYToMezLx
         N5qwYTZkSJ7MyYRQ5ZhNsK2L9AMr+0b2Bq7ZnfM7scVr+JpOspsW9olylMXVv9zKHuiH
         ok9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RWdnpec1;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y67sor15758053pgy.46.2019.03.12.18.27.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 18:27:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RWdnpec1;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=DcQ2WocT+J2kTJpFnS9iX9mF0/3egjHnKwIWN+woEMI=;
        b=RWdnpec1bY1T5V836zaR6TgkI1WeiFH0PKCrCAZA81LICH6qrojkvo5ailcHkjppKa
         EbrgRn6hLo2I0Ct7Rz1icyXHB30ql+RvPS0ZRHWMQU3KqjVtaEvYXkNLgqptlGyT8Xp1
         PmjZdXOh8L70FrqRHskqFgqnnrs1pw7UJ4VrKaP0h2VSL2fEmqUGsHniBk0/mK6mQ7lp
         52ohzP1cnC5q7+x2HhYteeymEEF+JQ8zMpf7PiC5EBZBAnL1+aJeTHfNhFRO7fvCOs/d
         7ZsBGLfKsZjk8HoNMNwewTbiEUTLrWjsK1AczpPKxxyBwivq7nBDUoSS8c+A73Oakv4h
         W8KQ==
X-Google-Smtp-Source: APXvYqxUzSFC6XYHDs2GtK2JSRs06AFphXvchGSeeCQb540evYiOQyr3e+S+H13eBU3IDoMf/2c+jQ==
X-Received: by 2002:a63:5317:: with SMTP id h23mr13303091pgb.437.1552440421102;
        Tue, 12 Mar 2019 18:27:01 -0700 (PDT)
Received: from localhost.localdomain ([203.100.54.194])
        by smtp.gmail.com with ESMTPSA id c13sm27539995pfm.34.2019.03.12.18.26.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 18:27:00 -0700 (PDT)
From: Yafang Shao <laoar.shao@gmail.com>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org,
	linux-mm@kvack.org,
	shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: [PATCH v2] mm: compaction: some tracepoints should be defined only when CONFIG_COMPACTION is set
Date: Wed, 13 Mar 2019 09:26:43 +0800
Message-Id: <1552440403-11780-1-git-send-email-laoar.shao@gmail.com>
X-Mailer: git-send-email 1.8.3.1
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Only mm_compaction_isolate_{free, migrate}pages may be used when
CONFIG_COMPACTION is not set.
All others are used only when CONFIG_COMPACTION is set.

After this change, if CONFIG_COMPACTION is not set, the tracepoints
that only work when CONFIG_COMPACTION is set will not be exposed to
the usespace.
Without this change, they will always be expose in debugfs no matter
CONFIG_COMPACTION is set or not.
That is an improvement.

Signed-off-by: Yafang Shao <laoar.shao@gmail.com>
---
 include/trace/events/compaction.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index 6074eff..3e42078 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -64,6 +64,7 @@
 	TP_ARGS(start_pfn, end_pfn, nr_scanned, nr_taken)
 );
 
+#ifdef CONFIG_COMPACTION
 TRACE_EVENT(mm_compaction_migratepages,
 
 	TP_PROTO(unsigned long nr_all,
@@ -132,7 +133,6 @@
 		__entry->sync ? "sync" : "async")
 );
 
-#ifdef CONFIG_COMPACTION
 TRACE_EVENT(mm_compaction_end,
 	TP_PROTO(unsigned long zone_start, unsigned long migrate_pfn,
 		unsigned long free_pfn, unsigned long zone_end, bool sync,
@@ -166,7 +166,6 @@
 		__entry->sync ? "sync" : "async",
 		__print_symbolic(__entry->status, COMPACTION_STATUS))
 );
-#endif
 
 TRACE_EVENT(mm_compaction_try_to_compact_pages,
 
@@ -195,7 +194,6 @@
 		__entry->prio)
 );
 
-#ifdef CONFIG_COMPACTION
 DECLARE_EVENT_CLASS(mm_compaction_suitable_template,
 
 	TP_PROTO(struct zone *zone,
@@ -296,7 +294,6 @@
 
 	TP_ARGS(zone, order)
 );
-#endif
 
 TRACE_EVENT(mm_compaction_kcompactd_sleep,
 
@@ -352,6 +349,7 @@
 
 	TP_ARGS(nid, order, classzone_idx)
 );
+#endif
 
 #endif /* _TRACE_COMPACTION_H */
 
-- 
1.8.3.1

