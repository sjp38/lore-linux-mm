Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B06BC10F01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 07:27:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA3DC2147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 07:27:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA3DC2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D7608E0003; Wed, 20 Feb 2019 02:27:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 886F88E0002; Wed, 20 Feb 2019 02:27:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7518A8E0003; Wed, 20 Feb 2019 02:27:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30A9E8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 02:27:12 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so18181004pfe.10
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 23:27:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LCSqhH2jgdSOL2gxJUMoBVvfcReWprUg444wjdmt1R4=;
        b=At+SmhCz3goUW9PzQ5CUVVXWjvsuuGvncH+fKXcO5Q8HCwOijR+e1vkkMYPg30ODg5
         9f/BX0JQDjVzqkIossLSbJtnfhwCACW0rJYuuMeQO4Nm0SVJIw2ZB0t8VJrqfhUXCqkp
         sJlkb0NM8z1Jwy9u8XkOCs/ypdKj3tYuqqJxdnFZw6MR5c5o4ONJp0qLk+RlZwsYZ7Nc
         1s8QJ+VcSyh/0vq9Nct8yTNtzh6v/aPa4dcd6EYamVN2T9nnS5yuv/vbW8c98tRDd/ha
         A4OMVP8P1i9I6KcpI1U3Gk5fLM94+XZ7H/duer+I2+Zl8uw9dEvw/Wy4U+nQMR9ju/hJ
         8rSw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuYFVibM77n8rp41M9ZwwlN17HDkyYCpiiMjno1Vt8HNINPSB9eb
	FM9YEkDW0kr80IMVNyWfIEyyXasibobk9m4hYM98q/tbdH3JgPPb0BzqLJVqKPIiYs2e1LyuYwq
	EJFW2pPNbyzMurNSzYrIdN7LddKKCmb4NRcv1LZmejirPVqGIoUOxpp6A0F3B2AE=
X-Received: by 2002:a63:2c8c:: with SMTP id s134mr28179985pgs.269.1550647631672;
        Tue, 19 Feb 2019 23:27:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaORYqpKyw0XkeH8tzAkEbE0e8NIt7oZFfuOrMU5qL4Z4rs/5GF6Vl2I1l3mo5xIa1ZGxOz
X-Received: by 2002:a63:2c8c:: with SMTP id s134mr28179933pgs.269.1550647630717;
        Tue, 19 Feb 2019 23:27:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550647630; cv=none;
        d=google.com; s=arc-20160816;
        b=rMmvHv7xHIh6fvcio7RZ17YJriaQiZ6Eb8D39UWoHJ3S7JRCO2V5UI3vG9MR60XrWP
         nZVs+J7jJ+pA8RWgJEPfDqccZ2KvHSeGZP9iATBIMiVif1/JbI2OR5Ee4q/7OzPZfkR5
         bwwKpWLnU+mRaTDFAcQKNHqPKMr7VRKGvW+TYzUUm/zJ0C0XuYymdHNlNR4Y0xtjsxIz
         bVeGXm4JfnljX+7uO0BaQQ/gvGQQfVNldJd2dv+PZaAiErq+CHKolwfAl80Rci0alYVT
         5Qq7x0bvD1ut22HR1CFSyx7XWWFmR7TQ9UtO81iGYEb/TiDq3mWXRqTit5Jaf4PCJV++
         CkJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LCSqhH2jgdSOL2gxJUMoBVvfcReWprUg444wjdmt1R4=;
        b=JcBftwaKGaTapIZJiK88jUsXi1jYEVnWyARh5TPcmGAeAYtCwFu0sAMWDJ3GLOnCJa
         F1IZqLtWyB3Pptu7sSNHNxXsjNUdoHfF097Qfjxuq1BYg7n6JWV1gcDMws8NBCnxzl0n
         aoMCDzBuMgT9T0757gH1xdUFbE/KL8KYX5X6XM65uME2GUm7FwRWg2SCo6UumvIpkzst
         VcltS+oSMpBZh4cpUsdkFOf5H082a3iqjs8zPMn7tJNpRqHV5G1x9hfmzCubr0v0fBNc
         j53VrV5cgPVoXRyOVP8iz3soFj9kJvW6FbCw/87zRqkZH3Z9Jz0FEjy7CbtIPX1ZkXPc
         HSxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id a8si16523610pgw.380.2019.02.19.23.27.09
        for <linux-mm@kvack.org>;
        Tue, 19 Feb 2019 23:27:10 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 20 Feb 2019 17:57:08 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gwMHb-0006BJ-4U; Wed, 20 Feb 2019 18:27:07 +1100
Date: Wed, 20 Feb 2019 18:27:07 +1100
From: Dave Chinner <david@fromorbit.com>
To: Roman Gushchin <guro@fb.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"riel@surriel.com" <riel@surriel.com>,
	"dchinner@redhat.com" <dchinner@redhat.com>,
	"guroan@gmail.com" <guroan@gmail.com>,
	Kernel Team <Kernel-team@fb.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Message-ID: <20190220072707.GB23020@dastard>
References: <20190219071329.GA7827@castle.DHCP.thefacebook.com>
 <20190220024723.GA20682@dastard>
 <20190220055031.GA23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220055031.GA23020@dastard>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 04:50:31PM +1100, Dave Chinner wrote:
> I'm just going to fix the original regression in the shrinker
> algorithm by restoring the gradual accumulation behaviour, and this
> whole series of problems can be put to bed.

Something like this lightly smoke tested patch below. It may be
slightly more agressive than the original code for really small
freeable values (i.e. < 100) but otherwise should be roughly
equivalent to historic accumulation behaviour.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

mm: fix shrinker scan accumulation regression

From: Dave Chinner <dchinner@redhat.com>

Commit 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
in 4.16-rc1 broke the shrinker scan accumulation algorithm for small
freeable caches. This was active when there isn't enough work to run
a full batch scan -  the shrinker is supposed to defer that work
until a future shrinker call. That then is fed back into the work to
do on the next call, and if the work is larger than a batch it will
run the scan. This is an efficiency mechanism that prevents repeated
small scans of caches from consuming too much CPU.

It also has the effect of ensure that caches with small numbers of
freeable objects are slowly scanned. While an individual shrinker
scan may not result in work to do, if the cache is queried enough
times then the work will accumulate and the cache will be scanned
and freed. This protects small and otherwise in use caches from
excessive scanning under light memory pressure, but keeps cross
caceh reclaim amounts fairly balalnced over time.

The change in the above commit broke all this with the way it
calculates the delta value. Instead of it being calculated to keep
the freeable:scan shrinker count in the same ratio as the previous
page cache freeable:scanned pass, it calculates the delta from the
relcaim priority based on a logarithmic scale and applies this to
the freeable count before anything else is done.

This means that the resolution of the delta calculation is (1 <<
priority) and so for low pritority reclaim the cacluated delta does
not go above zero unless there are at least 4096 freeable objects.
This completely defeats the accumulation of work for caches with few
freeable objects.

Old code (ignoring seeks scaling)

	delta ~= (pages_scanned * freeable) / pages_freeable

	Accumulation resoution: pages_scanned / pages_freeable

4.16 code:

	delta ~= freeable >> priority

	Accumulation resolution: (1 << priority)

IOWs, the old code would almost always result in delta being
non-zero when freeable was non zero, and hence it would always
accumulate scan even on the smallest of freeable caches regardless
of the reclaim pressure being applied. The new code won't accumulate
or scan the smallest of freeable caches until it reaches  priority
1. This is extreme memory pressure, just before th OOM killer is to
be kicked.

We want to retain the priority mechanism to scale the work the
shrinker does, but we also want to ensure it accumulates
appropriately, too. In this case, offset the delta by
ilog2(freeable) so that there is a slow accumulation of work. Use
this regardless of the delta calculated so that we don't decrease
the amount of work as the priority increases past the point where
delta is non-zero.

New code:

	delta ~= ilog2(freeable) + (freeable >> priority)

	Accumulation resolution: ilog2(freeable)

Typical delta calculations from different code (ignoring seek
scaling), keeping in mind that batch size is 128 by default and 1024
for superblock shrinkers.

freeable = 1

ratio	4.15	priority	4.16	4.18		new
1:100	  1	   12		0	batch		1
1.32	  1	    9		0	batch		1
1:12	  1	    6		0	batch		1
1:6	  1	    3		0	batch		1
1:1	  1	    1		1	batch		1

freeable = 10

ratio	4.15	priority	4.16	4.18		new
1:100	  1	   12		0	batch		3
1.32	  1	    9		0	batch		3
1:12	  1	    6		0	batch		3
1:6	  2	    3		0	batch		3
1:1	 10	    1		10	batch		10

freeable = 100

ratio	4.15	priority	4.16	4.18		new
1:100	  1	   12		0	batch		6
1.32	  3	    9		0	batch		6
1:12	  6	    6		1	batch		7
1:6	 16	    3		12	batch		18
1:1	100	    1		100	batch		100

freeable = 1000

ratio	4.15	priority	4.16	4.18		new
1:100	 10	   12		0	batch		9
1.32	 32	    9		1	batch		10
1:12	 60	    6		16	batch		26
1:6	160	    3		120	batch		130
1:1	1000	    1		1000	max(1000,batch)	1000

freeable = 10000

ratio	4.15	priority	4.16	4.18		new
1:100	 100	   12		2	batch		16
1.32	 320	    9		19	batch		35
1:12	 600	    6		160	max(160,batch)	175
1:6	1600	    3		1250	1250		1265
1:1	10000	    1		10000	10000		10000

It's pretty clear why the 4.18 algorithm caused such a problem - it
massively changed the balance of reclaim when all that was actually
required was a small tweak to always accumulating a small delta for
caches with very small freeable counts.

Fixes: 9092c71bb724 ("mm: use sc->priority for slab shrink targets")
Signed-off-by: Dave Chinner <dchinner@redhat.com>
---
 mm/vmscan.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index e979705bbf32..9cc58e9f1f54 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -479,7 +479,16 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
 
 	total_scan = nr;
 	if (shrinker->seeks) {
-		delta = freeable >> priority;
+		/*
+		 * Use a small non-zero offset for delta so that if the scan
+		 * priority is low we always accumulate some pressure on caches
+		 * that have few freeable objects in them. This allows light
+		 * memory pressure to turn over caches with few freeable objects
+		 * slowly without the need for memory pressure priority to wind
+		 * up to the point where (freeable >> priority) is non-zero.
+		 */
+		delta = ilog2(freeable);
+		delta += freeable >> priority;
 		delta *= 4;
 		do_div(delta, shrinker->seeks);
 	} else {

