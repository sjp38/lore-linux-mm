Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7534C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 09:57:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 85639206A3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 09:57:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 85639206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C434C6B0003; Thu,  9 May 2019 05:57:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF3BB6B0006; Thu,  9 May 2019 05:57:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B311C6B0007; Thu,  9 May 2019 05:57:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 67F506B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 05:57:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r20so1084221edp.17
        for <linux-mm@kvack.org>; Thu, 09 May 2019 02:57:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ytdoicVPJcmrbdhJNzAyrGzNk0Z/0QzZ+RLmMTI0ffs=;
        b=rtU3j5/CYL02dMBccwuxeKQE7t6kiR0V7HvI9m+oeg+B364rpNubN91j8rFS0v5a/s
         YkMo+5jfzwk4JYb66w5AMI0jvlIvlulU6lZiAgmk3TSP7SdT+QZl9OHd2U6ClxzPfkgY
         y0lmIQkDtSUOozk3qufnPTraEsvbSxethvuNtLtlNzUqcoiJGo0kVpzhcQ5L5N0/+xdN
         sgFmaQ5KXyM4Ai1k1oi9bYqdeiulUhlfQipcN1FZXJUsr1iLPUtX0SCcToRiirV9SxYH
         RORcZ/kJYVdaFilsDBfQBXapHepUtzP6+h7DYfRPYqnlY9jsFB9v6OfD5qViJU1GjziC
         QG5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVR+KyVETaetyQXC5mG2VGwrfXRISe3GdFhFpbyvGXAQp8NNvCY
	j9+d9FTgY/uDJC8VZDG/rExsUkDZO7zzzmEPNoxUnFH6HcNoL/RlBr4hJRpEiG0gwpE+TLyZOs9
	yyBuiM4QKKig/Z5zvCWHvA+2EYFKXhdMz0hRyjKzI0TjyQpt0dbR2cfGgc3th1exN6Q==
X-Received: by 2002:a50:bb24:: with SMTP id y33mr2816632ede.116.1557395847920;
        Thu, 09 May 2019 02:57:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOO1bTMUiMz0tb8QSXtgRJRp2TPt161bSfIRANQYh4TTAPs7FqRNE1uwQ82HJeFtcAZ+ZW
X-Received: by 2002:a50:bb24:: with SMTP id y33mr2816563ede.116.1557395846810;
        Thu, 09 May 2019 02:57:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557395846; cv=none;
        d=google.com; s=arc-20160816;
        b=qXZC1NiKsHZlITbPQsXJZOIHS+H6rscqRSwhH3WCOP0mO9o+3J5jZkWOSd06znnlXy
         vfe8o/7pjhefHRME70Q7TpRkZJMGRL9S8+t+viZBnd9VgImnaeKYAqK6ibWrqvWFpqNI
         mXlLpkVjU4xEqMIV/olDm80GOis5pdk2CJ6jLjZ6g16+6XGSD8NE9L1uR1QogmSlsb1C
         9Zm2daxMMhQEKFJ+A4w+U5i59WJnQMhkRHKGOY5Ruwqzy2yMevI1DM0SK2qJNYaS6n9T
         6e6IpE92kvYQ2c4hAuN/NN0KIGTdJS5fsBzT7WzHFUBM89LiPAX7gycZVK6iFl41sAQm
         60OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ytdoicVPJcmrbdhJNzAyrGzNk0Z/0QzZ+RLmMTI0ffs=;
        b=xOVJ88yoJRZsaJ1a+zkKePaJBxCIn+c34yEj8eKYEBRTaEXyYlzKKTOimzon9BBbod
         TpN3X282IpaX3Mo6muejckWbQCg0HGIQ1yJp5qnTPGjaOxfMX1A4A9UB1FZbMWDerO2c
         TA2RNxm9+OfY4WhcqsutYns4XcmikEwF3WOfYPNNQvu/Jw2TRQ8SyQbTfECV2HDNjbyL
         D7Vt1GqhKvUaxhMu55W9rV7B/f6ofHR11ITTjeuru3U6pGioU4HKRIWWKNX3fivvVGCK
         gCZ+jITKW6oYVuFtn7VPqLBYD03FMCv33N156eA39Oi76Bvezdpi23ByIx7aQE2KhOaL
         NMCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id y46si1031844edc.298.2019.05.09.02.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 02:57:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 60DA61C299F
	for <linux-mm@kvack.org>; Thu,  9 May 2019 10:57:26 +0100 (IST)
Received: (qmail 28448 invoked from network); 9 May 2019 09:57:26 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 9 May 2019 09:57:26 -0000
Date: Thu, 9 May 2019 10:57:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: syzbot <syzbot+d84c80f9fe26a0f7a734@syzkaller.appspotmail.com>
Cc: akpm@linux-foundation.org, aryabinin@virtuozzo.com, cai@lca.pw,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com,
	syzkaller-bugs@googlegroups.com, vbabka@suse.cz
Subject: Re: BUG: unable to handle kernel paging request in
 isolate_freepages_block
Message-ID: <20190509095724.GG18914@techsingularity.net>
References: <0000000000003beebd0588492456@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <0000000000003beebd0588492456@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 02:50:05AM -0700, syzbot wrote:
> Hello,
> 
> syzbot found the following crash on:
> 
> HEAD commit:    baf76f0c slip: make slhc_free() silently accept an error p..
> git tree:       upstream
> console output: https://syzkaller.appspot.com/x/log.txt?x=16dbe6cca00000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=a42d110b47dd6b36
> dashboard link: https://syzkaller.appspot.com/bug?extid=d84c80f9fe26a0f7a734
> compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> 
> Unfortunately, I don't have any reproducer for this crash yet.
> 

How reproducible is it and can the following (compile tested only) patch
be tested please? I'm thinking it's a similar class of bug to 6b0868c820ff
("mm/compaction.c: correct zone boundary handling when resetting pageblock
skip hints")

diff --git a/mm/compaction.c b/mm/compaction.c
index 3319e0872d01..ae4d99d31b61 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1228,7 +1228,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 
 	/* Pageblock boundaries */
 	start_pfn = pageblock_start_pfn(pfn);
-	end_pfn = min(start_pfn + pageblock_nr_pages, zone_end_pfn(cc->zone));
+	end_pfn = min(start_pfn + pageblock_nr_pages, zone_end_pfn(cc->zone) - 1);
 
 	/* Scan before */
 	if (start_pfn != pfn) {
@@ -1239,7 +1239,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
 
 	/* Scan after */
 	start_pfn = pfn + nr_isolated;
-	if (start_pfn != end_pfn)
+	if (start_pfn < end_pfn)
 		isolate_freepages_block(cc, &start_pfn, end_pfn, &cc->freepages, 1, false);
 
 	/* Skip this pageblock in the future as it's full or nearly full */

