Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A09B7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63FBD218A5
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:18:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63FBD218A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA4EC8E0006; Wed, 27 Feb 2019 21:18:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C517C8E0001; Wed, 27 Feb 2019 21:18:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46848E0006; Wed, 27 Feb 2019 21:18:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDE88E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:18:47 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id o56so15826358qto.9
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:18:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Vx2VZtOceXx/muNOFvOTUbvq8L4C1gUYQ/k1Qg6oF3M=;
        b=ilLpnEZKKCEGgxW/kt2AJVU3UBDhM4KqIeMzU86HP4FZfGPw179WB2UErcDH2u/Pfi
         ygR95G4fbPKMS0DQS9RiindYZ1vYyoHsa+7qf9sHInHX4u5MRiZ9s5x5GMyBALkKjoeZ
         99D9mVNyrhO63jeAAk2VfgrNe94dsgFCKk2XZAxI19zID8YGp6PBxAM1qvwJ/s2GpIH2
         NpXuYf0/goET0X64CLoqA2soXUUHnQ0QkFM38wxV+8lTBFfZAFOkqnxq3JfgcNuDxYcH
         N2SfdqYKUyQsMOFdZpLwcJRMk6e9wCS5XPx34euS+V5cDpR2MbqqAMNswxuEFVvGEpwY
         J3eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZ0ONPm0u2m5UDQSZrnVCqRDYz2No0gA5lBGW2pfAZpOlrCprBY
	oB83duvxFuK2uZUg7X6bOi4bh+D7UNcp7CWKmgJyBUtCep2zUs6i7tfTKUDVadp8wimhOxGu/Ti
	bQpsT+gEbS/M44QQKMXNkPUCddy9SyhKWKPBqkwZ3AtluonhnVSESb6I+f4qQijY/aH0jh2Afir
	0Mnusw89XMl7FCkScUmeuke7tyhHMFJNBqMUDLKzvU1NXz8ng9XbxY2O4cQ/LRefNcDHcL5xg+/
	mGv+dZcuoDTIiQHCYuhkBqdWtF0rQtwgizZXRTWJ3wWQmDkz+GmikjzxYO9pHyXkmTuaiI3tEJG
	Xxq6TEc1GgKF1DeYdi0d7S6QyFJ/W678uikMxPM+4oJFNdtdfAg9/qxvWXn99dsN/Uats2GV8A=
	=
X-Received: by 2002:ac8:803:: with SMTP id u3mr4323047qth.108.1551320327296;
        Wed, 27 Feb 2019 18:18:47 -0800 (PST)
X-Received: by 2002:ac8:803:: with SMTP id u3mr4323026qth.108.1551320326657;
        Wed, 27 Feb 2019 18:18:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551320326; cv=none;
        d=google.com; s=arc-20160816;
        b=kKk7g4/SLk2O9tBHGeUBnxDF0HIbdAAxQJSeIA+0tlxCpN9lPeEsPJMttJH3HkcDVV
         1jRX5GuT5DcuAdcSeHiJY3URmdf9yz+nwnoEUyXjsYrSyvOuxRphmne3zoJ3ssrmWVaf
         Effny2/6lbIjk2KJzCidpa18wG5FVcr3DnCSbeHLjWgLjZXwqK1DRAZ7tMQKxQi68R1e
         ddZl/NSAE7ITW0pKRTtWGWVIdUnYFwUnwl33frsJnXf5l94uVUH1ctMdDmcGby06AvDP
         yMmtzR0Jk/d5GVTpH1CJPawDk6tp+uy7v/6jqys9bGyYOLKCl34dxoE+k0MMXSrDRAc4
         +Y7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Vx2VZtOceXx/muNOFvOTUbvq8L4C1gUYQ/k1Qg6oF3M=;
        b=HmSw/Z2wuiquOZ4VouYY34RgboISwLm36mxXV7B/hixaRsXTI/gPXqbkCv8bK7lPF+
         soumVBH/TlZdU9wPsjYXTyurTFg/c2ileJZwLrgECcdv6hjmKL2U/rEEktK6S0UlfyVP
         TJaMnfOdFqWJNsZcz//SFJ2ehfFBhdZ9UFf9ifOB/iT9XOrJkr2B51tUkuT8b8ObSMV6
         7LmEKnxl87r9UISg5roZe4RAnnawrXwdVm6vI5jFh+TpsdXef7TII8vwI1xHRGtU7WV9
         r3hDMfVIuO/QV10OJDwcSRCbC8Kavr3BWsz8n1DBl2wRD2D+i4nAhBK0JCZMIfOtmetC
         aydw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x27sor20016451qvf.7.2019.02.27.18.18.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Feb 2019 18:18:46 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxT0Zazm3tmjv5xoUKZeesy8YEfKuPUZhr6x6oWUxafL1uMoGMXcNEnHEANX5YFiSEYe6MK5A==
X-Received: by 2002:a0c:b311:: with SMTP id s17mr4441198qve.69.1551320326433;
        Wed, 27 Feb 2019 18:18:46 -0800 (PST)
Received: from localhost.localdomain (cpe-98-13-254-243.nyc.res.rr.com. [98.13.254.243])
        by smtp.gmail.com with ESMTPSA id y21sm12048357qth.90.2019.02.27.18.18.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 27 Feb 2019 18:18:45 -0800 (PST)
From: Dennis Zhou <dennis@kernel.org>
To: Dennis Zhou <dennis@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Christoph Lameter <cl@linux.com>
Cc: Vlad Buslov <vladbu@mellanox.com>,
	kernel-team@fb.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 02/12] percpu: do not search past bitmap when allocating an area
Date: Wed, 27 Feb 2019 21:18:29 -0500
Message-Id: <20190228021839.55779-3-dennis@kernel.org>
X-Mailer: git-send-email 2.13.5
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
References: <20190228021839.55779-1-dennis@kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

pcpu_find_block_fit() guarantees that a fit is found within
PCPU_BITMAP_BLOCK_BITS. Iteration is used to determine the first fit as
it compares against the block's contig_hint. This can lead to
incorrectly scanning past the end of the bitmap. The behavior was okay
given the check after for bit_off >= end and the correctness of the
hints from pcpu_find_block_fit().

This patch fixes this by bounding the end offset by the number of bits
in a chunk.

Signed-off-by: Dennis Zhou <dennis@kernel.org>
---
 mm/percpu.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index 53bd79a617b1..69ca51d238b5 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -988,7 +988,8 @@ static int pcpu_alloc_area(struct pcpu_chunk *chunk, int alloc_bits,
 	/*
 	 * Search to find a fit.
 	 */
-	end = start + alloc_bits + PCPU_BITMAP_BLOCK_BITS;
+	end = min_t(int, start + alloc_bits + PCPU_BITMAP_BLOCK_BITS,
+		    pcpu_chunk_map_bits(chunk));
 	bit_off = bitmap_find_next_zero_area(chunk->alloc_map, end, start,
 					     alloc_bits, align_mask);
 	if (bit_off >= end)
-- 
2.17.1

