Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BE4CC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:53:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C9DA21743
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 17:53:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C9DA21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFA356B0010; Wed, 17 Jul 2019 13:53:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA89C8E0005; Wed, 17 Jul 2019 13:53:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72188E0003; Wed, 17 Jul 2019 13:53:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9C06B0010
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 13:53:36 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id m25so6492258wml.6
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:53:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WUCjLMoN5o2u3t2fcrnU61WAaQ6YGEYzfke7MP1QkZ0=;
        b=DvJBOJobWaASGR7HhOdemmn2Jxs0qc2ArJ2yFFc+xwVCmTwBxtVfTVqvgZuV7eXI9d
         giwi+WS2gCgAHyVuxxq1j46gUACPr9Kxmsg8TtgezyPv0Zr2y2TtWTtqvRT09dBt4GK4
         NRONE/MyyErS9CtWcNJGJ4/KV5xwCaPkSlWIxCY0UKa0H91syGUyHzhsO0c7Awy/uDcV
         NvYPqOYoAhjkLR9ROcatsQvNqTf1wyfu+UxMT8UsiftcbYxS+sU/tc+TCwSEZqzb6UfB
         4rAZHqmT7w5R9jG9IxPYyuJK5q4sf6tK5wKoAoHMCGae9KmKTIkBeZaPJRAlVXn0TOyA
         YcBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVAtFeyiCY1CpECz8luGGyaVVHQERbmRUvho3zT8hbj3om4gmDi
	Av19mECd9WfxiOu8xWsg4FA5EZG3eH9gMm7AV9WWmrfUbGfibx48iDj38W54YA5qjTxgYSKIT0W
	8PTDit2QkajdH9X/WHHIzgcs3WcxPICQxFM5xJEQWGzhj4GyBC4Q07VuyfiGCNv7Asw==
X-Received: by 2002:a5d:6583:: with SMTP id q3mr47199003wru.184.1563386015901;
        Wed, 17 Jul 2019 10:53:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmsdnHc9u0k9DLbW/bY3hS4xvnqD/7GXr9LNI7r0sQAsd1a1xom9+Dny0VD6cVeThm5Zh4
X-Received: by 2002:a5d:6583:: with SMTP id q3mr47198947wru.184.1563386015017;
        Wed, 17 Jul 2019 10:53:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563386015; cv=none;
        d=google.com; s=arc-20160816;
        b=xNaWliw8PJC/1/uPmfZXuEBA3H5HmWd93HJmMw009HAq/T3DwD7Dx2p0sIIL4A0Z5G
         NkckobIlTfQouaFiGH2Cfb/t+8ALydghG/ZK8i+/R7K9fD2cekCQxZSVmWGjAZO/MVHv
         YRR/PnCCz2m0wyLOLJChdL6aMkgQail7yBksiVIRXUIIotGuobrlrA2lX5XI+91WhWKm
         M1VovjQxp1chsG76KyxPP8oj2kDjWm7VZercRGthHQSm50ocVO5UMMfwmD4IERpyTLgU
         Du387sj4bRfNYS151LOxAQWD1vsMOGBVn8rABbFJOW0eNzay970OfqI38p+9+ALl0d09
         zmIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WUCjLMoN5o2u3t2fcrnU61WAaQ6YGEYzfke7MP1QkZ0=;
        b=og+IOKF4mqxapDn/q/zjNMkLkywe6TVt4bEtpJXCSxvfRrq99J1vLaq2j1L8kKZwNL
         H8hiApk1tGm90neF8hKeSPlKUw+aY+vXGdlrXPKSuB2oQw3jw6giYNopKyNccdrgXR0q
         TIQZRFkvw15C2ZMCePu+HiFQfOdoABfv6ZCbklldqgAMSkhAtQmjvO+NljjWfqlS8UVd
         hSTs8HVai7uocytgwB4zSxL8q1/NK4kfaL5RumGceeNMK89ce+YlGdfTfruJ86Txv07r
         fysn9cdL12gt4VmteSQpEBFowKH1TBr5U0P8PwnSTKv6ZGYGM8cGA4cx66w82gd1UJw9
         1eOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp21.blacknight.com (outbound-smtp21.blacknight.com. [81.17.249.41])
        by mx.google.com with ESMTPS id q17si21824256wrp.0.2019.07.17.10.53.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 10:53:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) client-ip=81.17.249.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.41 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp21.blacknight.com (Postfix) with ESMTPS id A7D60B871E
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 18:53:34 +0100 (IST)
Received: (qmail 2611 invoked from network); 17 Jul 2019 17:53:34 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[84.203.21.36])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 17 Jul 2019 17:53:34 -0000
Date: Wed, 17 Jul 2019 18:53:32 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: howaboutsynergy@protonmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [Bug 204165] New: 100% CPU usage in compact_zone_order
Message-ID: <20190717175332.GC24383@techsingularity.net>
References: <bug-204165-27@https.bugzilla.kernel.org/>
 <20190715142524.e0df173a9d7f81a384abf28f@linux-foundation.org>
 <pLm2kTLklcV9AmHLFjB1oi04nZf9UTLlvnvQZoq44_ouTn3LhqcDD8Vi7xjr9qaTbrHfY5rKdwD6yVr43YCycpzm7MDLcbTcrYmGA4O0weU=@protonmail.com>
 <GX2mE2MIJ0H5o4mejfgRsT-Ng_bb19MXio4XzPWFjRzVb4cNpvDC1JXNqtX3k44MpbKg4IEg3amOh5V2Qt0AfMev1FZJoAWNh_CdfYIqxJ0=@protonmail.com>
 <WGYVD8PH-EVhj8iJluAiR5TqOinKtx6BbqdNr2RjFO6kOM_FP2UaLy4-1mXhlpt50wEWAfLFyYTa4p6Ie1xBOuCdguPmrLOW1wJEzxDhcuU=@protonmail.com>
 <EDGpMqBME0-wqL8JuVQeCbXEy1lZkvqS0XMvMj6Z_OFhzyK5J6qXWAgNUCxrcgVLmZVlqMH-eRJrqOCxb1pct39mDyFMcWhIw1ZUTAVXr2o=@protonmail.com>
 <20190716071121.GA24383@techsingularity.net>
 <xZGQeie9gbbIEm7ZciNh3PrdV8kTu-SE7KtUYV3cloMCUEdzB7taS5BcTzSUSaThu5_ftcRjr3sYcQB1c9dVPX3i1kQ2eP-xjKvFIpT7wZs=@protonmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <xZGQeie9gbbIEm7ZciNh3PrdV8kTu-SE7KtUYV3cloMCUEdzB7taS5BcTzSUSaThu5_ftcRjr3sYcQB1c9dVPX3i1kQ2eP-xjKvFIpT7wZs=@protonmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 07:15:08PM +0000, howaboutsynergy@protonmail.com wrote:
> On Tuesday, July 16, 2019 12:03 PM, Mel Gorman <mgorman@techsingularity.net> wrote:
> > I tried reproducing this but after 300 attempts with various parameters
> > and adding other workloads in the background, I was unable to reproduce
> > the problem.
> > 
> 
> 
> The third time I ran this command `$ time stress -m 220 --vm-bytes 10000000000 --timeout 10`, got 10+ hung:
> 
>   PID  %CPU COMMAND                                                                            PR  NI    VIRT    RES S USER     
>  3785  94.5 stress                                                                             20   0 9769416      4 R user     
>  3777  87.3 stress                                                                             20   0 9769416      4 R user     
>  3923  85.5 stress                                                                             20   0 9769416      4 R user     
>  3937  85.5 stress                                                                             20   0 9769416      4 R user     
>  3943  81.8 stress                                                                             20   0 9769416      4 R user     
>  3885  80.0 stress                                                                             20   0 9769416      4 R user     
>  3970  80.0 stress                                                                             20   0 9769416      4 R user     
>
> <SNIP>
>
> trace.dat is 1.3G
> -rw-r--r--  1 root root 1326219264 16.07.2019 20:45 trace.dat
> 

Ok, great. From the trace, it was obvious that the scanner is making no
progress. I don't think zswap is involved as such but it *may* be making
it easier to trigger due to altering timing. At least, I see no reason
why zswap would materially affect the termination conditions.

From the path and your trace, I think what *might* be happening is that
a fatal signal is pending which does not advance the scanner or look like
a proper abort. I think it ends up looping in compaction instead of dying
without either aborting or progressing the scanner.  It might explain why
stress-ng is hitting is as it is probably sending fatal signals on timeout
(I didn't check the source).

Can you try this (compile tested only) patch please? Note that the stress
test might still take time to exit normally if it's stuck in a swap
storm of some sort but I'm hoping the 100% compaction CPU usage goes away
at least.

diff --git a/mm/compaction.c b/mm/compaction.c
index 9e1b9acb116b..952dc2fb24e5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -842,13 +842,15 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 
 		/*
 		 * Periodically drop the lock (if held) regardless of its
-		 * contention, to give chance to IRQs. Abort async compaction
-		 * if contended.
+		 * contention, to give chance to IRQs. Abort completely if
+		 * a fatal signal is pending.
 		 */
 		if (!(low_pfn % SWAP_CLUSTER_MAX)
 		    && compact_unlock_should_abort(&pgdat->lru_lock,
-					    flags, &locked, cc))
-			break;
+					    flags, &locked, cc)) {
+			low_pfn = 0;
+			goto fatal_pending;
+		}
 
 		if (!pfn_valid_within(low_pfn))
 			goto isolate_fail;
@@ -1060,6 +1062,7 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 	trace_mm_compaction_isolate_migratepages(start_pfn, low_pfn,
 						nr_scanned, nr_isolated);
 
+fatal_pending:
 	cc->total_migrate_scanned += nr_scanned;
 	if (nr_isolated)
 		count_compact_events(COMPACTISOLATED, nr_isolated);

-- 
Mel Gorman
SUSE Labs

