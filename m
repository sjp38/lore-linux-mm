Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54FF7C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 08:51:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E497321855
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 08:51:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E497321855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 918F46B0003; Fri, 19 Apr 2019 04:51:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FA8E6B0006; Fri, 19 Apr 2019 04:51:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B6E66B0007; Fri, 19 Apr 2019 04:51:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30C956B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 04:51:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id p26so2554711edy.19
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 01:51:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=BLs+ii2Yfom+p0uFP3vTacPxEBV52n3yxmZM6FMyfFw=;
        b=Jx8KmlYP8q7uJvP7WgtD5hX6kUPNxdHo8IlrUm2TzVBEr/lABStGXFZbCDDvMR7Asr
         moGr9vKCe6ccp3gn+RPUp7vHEKFqMZdt1YF2RSBPmTKZuOmhcr8WNLTVin3DCKeq3hqP
         xR/NnulYNXoGfXfNFsz2IX+G8SkC9WU4tdv6MTohXPp6UrKy0iFSzEsP70kmRIGG7BbU
         bqnqNNxotsyrWdVhuxrtBNiB6efEudtd+O4Ha8x9xMdpNwdlNN9Xw08lzvRIn3LVHv4i
         9dOCV+VS2PG0uwoFfqz8Qs4QN1M9aLnCISG2ZN9vftivItbtv4CkYOP+0Syka1d5MQ9m
         ffTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAU1m6tgFC3X/RLBgQuDwWp2sbR3IQ24TbPE8VMC7MH6xR9bBS/+
	1aXJUrr3Wm73uLIOizd49I357VAg4klEQLYLvhFgBVyf+D2UKyE69owjmK1A9R+DuR+rxdAyX/0
	eyJLh00xYpdWlhHTVJWXb7/XTDg8c89Bk2Krc/eJj0M5/RcCdrXCHP8YcCBDLihvxbw==
X-Received: by 2002:a50:a90d:: with SMTP id l13mr1740857edc.45.1555663896659;
        Fri, 19 Apr 2019 01:51:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDiZNBhUa2RjAnExkdHNfzF58mnWrY+yEGuSvG4QWG8snCdlgz/FFemRZDvtLbreVlFq3K
X-Received: by 2002:a50:a90d:: with SMTP id l13mr1740811edc.45.1555663895682;
        Fri, 19 Apr 2019 01:51:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555663895; cv=none;
        d=google.com; s=arc-20160816;
        b=AkGUZ832mMxKh57csgOxJFp2aF+x7zm8Tlc9l3Cb2cJ9D3aqYKxzNY3pKy9CrV+2Wb
         UvuBrl/dVIEsezRLb2kMszgiPnGZJU/NqVkKZ5sKCq50sJHzGVF2FeiRcJTvT3yhHtNp
         hG5/C62Z7Ke871dR2gLELDzFMXHAXnZrZjT8w8zh5ojj2RJ76FYRSQyP0bzO/rBIMupJ
         C2HfLt4aDftjUQvxvZHL0GN8eQYN/Ll6ex6NFBthDlmOzcFcIWronQLF4icO0ILjlt5s
         mbWIIu8tKkMykfWWIOdVIx2BbDhxzkJrjcYo5QBCV6Vos1djIeFdZJUCDlhR4Gmp93By
         anxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=BLs+ii2Yfom+p0uFP3vTacPxEBV52n3yxmZM6FMyfFw=;
        b=Nm0AsaT4D631acAu8jmkgMGepLD9rX23OX27X6HT107czTZ3Z5qJj6wI+YIynNuwhf
         kpQbndBJPciQGv1uZr9IqNPvHqNeX4RuHIOXjQSbJjM9n9qSe5VvAhIehUfW5wd2/sR2
         rhUnbZ0MaM+JA1Rpy7snvtl0Kcu/+iRBqG8Z+QJ0iDqT2R00kDzsRGAKXZje2/PBz9t3
         +us3Viu0cI1qwKkR101/U4XOuhTI+bgI01iYDrpgaX/RxnQo2pUpFetI+x4rlcCkz3Vj
         fPvTFLsuOfzIDOIo1XzzKr7Gy9kPXdMC2CpdIF0YSwy4bqbsDRQK2eVpjcf1tM6C478B
         e8DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id f7si2115148edi.148.2019.04.19.01.51.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 01:51:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) client-ip=81.17.249.194;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 5738AB90B8
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 09:51:35 +0100 (IST)
Received: (qmail 14374 invoked from network); 19 Apr 2019 08:51:35 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 19 Apr 2019 08:51:35 -0000
Date: Fri, 19 Apr 2019 09:51:33 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Li Wang <liwang@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
	linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Subject: [PATCH] mm, page_alloc: Always use a captured page regardless of
 compaction result
Message-ID: <20190419085133.GH18914@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

During the development of commit 5e1f0f098b46 ("mm, compaction: capture
a page under direct compaction"), a paranoid check was added to ensure
that if a captured page was available after compaction that it was
consistent with the final state of compaction. The intent was to catch
serious programming bugs such as using a stale page pointer and causing
corruption problems.

However, it is possible to get a captured page even if compaction was
unsuccessful if an interrupt triggered and happened to free pages in
interrupt context that got merged into a suitable high-order page. It's
highly unlikely but Li Wang did report the following warning on s390
occuring when testing OOM handling. Note that the warning is slightly
edited for clarity.

[ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_direct_compact+0x182/0x190
[ 1422.124065] Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfsv4 dns_resolver
 nfs lockd grace fscache sunrpc pkey ghash_s390 prng xts aes_s390 des_s390
 des_generic sha512_s390 zcrypt_cex4 zcrypt vmur binfmt_misc ip_tables xfs
 libcrc32c dasd_fba_mod qeth_l2 dasd_eckd_mod dasd_mod qeth qdio lcs ctcm
 ccwgroup fsm dm_mirror dm_region_hash dm_log dm_mod
[ 1422.124086] CPU: 0 PID: 9783 Comm: copy.sh Kdump: loaded Not tainted 5.1.0-rc 5 #1

This patch simply removes the check entirely instead of trying to be
clever about pages freed from interrupt context. If a serious programming
error was introduced, it is highly likely to be caught by prep_new_page()
instead.

Fixes: 5e1f0f098b46 ("mm, compaction: capture a page under direct compaction")
Reported-by: Li Wang <liwang@redhat.com>
Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d96ca5bc555b..cfaba3889fa2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3773,11 +3773,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	memalloc_noreclaim_restore(noreclaim_flag);
 	psi_memstall_leave(&pflags);
 
-	if (*compact_result <= COMPACT_INACTIVE) {
-		WARN_ON_ONCE(page);
-		return NULL;
-	}
-
 	/*
 	 * At least in one zone compaction wasn't deferred or skipped, so let's
 	 * count a compaction stall

