Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80E0FC04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:44:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B1BC20866
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:44:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B1BC20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CBD86B0277; Thu,  6 Jun 2019 10:44:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87CB66B027A; Thu,  6 Jun 2019 10:44:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 76C996B027B; Thu,  6 Jun 2019 10:44:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2BACD6B0277
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:44:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id i44so4107609eda.3
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:44:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J8FfACnsD6mOR5LZtSAhtTgqUeQWv0+Eb13GbfG1rdc=;
        b=IIVdK8lnpxrBC+1x7eeWyGzUpPsY/q2efmed6IJ8yNX1jhQHBHxe05vk4z9hFwGeEj
         CD0lmq4EuFXzSC3OCKfPsDyNBwkfpEDK1rjYixX5BuePHsqvy5CNnqS2YyOGliOPvVBR
         IIWgWHMPuV08dCnG1VN4KzIlx3Km6LI6SPuidJOUlnLmpmiQHmOHbklVCIfeNj0GYJ9L
         nP29ZTQU+U5t/1DJY42eRdHNFK/6MJOz9QrK5ai1WIDv3GBGgmoT1ZLxwDGAp23lnMYo
         3OcOH8cbOxiGgoer/2sHy9HF7QTOwS/r++U+CkpXcw7fEuS+vzjWkr4OwYks0zRGe/wc
         g7Tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.234 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVmrp98bIzaTTgyDl7B1XxIc37o6hKjnk6vjr4PPxF4ihyM4mtW
	d2NN6YXzN1JYorjRK2scQ/Dt9JI7mBaHZr96GSLqxp5VMSFIlc5Ob3DLdBDyC2pxr6NlZHpn8Mq
	yJ7+kxy2jyJ7/lIao7nWeTymrMmzP15UthaP49/6egeFIece/Gvi/ARgJaLCWbtqngA==
X-Received: by 2002:aa7:c2d0:: with SMTP id m16mr11931061edp.94.1559832269756;
        Thu, 06 Jun 2019 07:44:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjfZNuirbVN7zjsFcVxvWfv/1KVXdvDYDqmtx0qhmkloBusd73p5c1OrMYQRIq/7i5OMr2
X-Received: by 2002:aa7:c2d0:: with SMTP id m16mr11930980edp.94.1559832268973;
        Thu, 06 Jun 2019 07:44:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559832268; cv=none;
        d=google.com; s=arc-20160816;
        b=shA6Fm2mLqkUolJDcZ+fTFoWcraFGXHKuChLFVCii/+ao5tyjhleuhLveNVXCZjBlw
         qMJZrZMXGqp5hq7rJL6p30dHVCw8o6AL9sfWe6dxgWpDHvF0yaQyIn57sLSi+FrAdW4w
         VYnv9T/yoowKbYUA8ItDU5dF2cuAIC2ddYYDXo3yQ9ZLN9dP40OtRn6YHyuCqeBSwo+8
         ibJDsbFZ5AXUrdbVVaVGtXVJbzv2IPiQMScbuVJ/0wUvZyDkYOFLgvg4uQ/1WVi8CuuK
         odzWxJgSj0b8OIhi6mzocJnWMLd5hoAOEmk1GKK9qP48BBgqdadB46inumNb4husbUdK
         lH/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J8FfACnsD6mOR5LZtSAhtTgqUeQWv0+Eb13GbfG1rdc=;
        b=fUZc45z34NwBQE/JBOQtuFQmQDbreQZs0nV0tdgiDeRNC8DCWjQRgUe/sTmvdDa+cJ
         kAqRSf+BhgbG9f34cDj6/rheNgVKSL4537zcFnc+utHX2MhaHjaqjyExTip1rVea1+UM
         ZNJ2Q/Tm655E10IJFx7OM5j18tr7bc0IzVxMx3aBReL7d4n7WSIw3bP6vskh9IRBZvRw
         IQWYoXyXFVmG/JLMMMcsKv538IwiI26ACKa9EqcAI4dp+WsT7yI7dlzefsQvqSbig6Vs
         zgg+L68G5tkLPkvqiIKBEiY6HqP3gJQYCE6OPtM0lPNneXVdgM/cCDw70KT6ONLP8ZEA
         taUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.234 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp17.blacknight.com (outbound-smtp17.blacknight.com. [46.22.139.234])
        by mx.google.com with ESMTPS id p19si1655972ejj.62.2019.06.06.07.44.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 07:44:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.234 as permitted sender) client-ip=46.22.139.234;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.234 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp17.blacknight.com (Postfix) with ESMTPS id 89C741C18CB
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 15:44:28 +0100 (IST)
Received: (qmail 2793 invoked from network); 6 Jun 2019 14:44:28 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 6 Jun 2019 14:44:28 -0000
Date: Thu, 6 Jun 2019 15:44:24 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: balducci@units.it
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer
 dereference under stress (possibly related to
 https://lkml.org/lkml/2019/5/24/292 ?)
Message-ID: <20190606142600.GA2782@techsingularity.net>
References: <20190605172136.GC4626@techsingularity.net>
 <27679.1559827273@dschgrazlin2.units.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <27679.1559827273@dschgrazlin2.units.it>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:20:49PM +0200, balducci@units.it wrote:
> > Can you try the following compile-tested only patch please?
> >
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index 9e1b9acb116b..b3f18084866c 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -277,8 +277,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pf
> > n, bool check_source,
> >  	}
> >  
> >  	/* Ensure the end of the pageblock or zone is online and valid */
> > -	block_pfn += pageblock_nr_pages;
> > -	block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
> > +	block_pfn = min(pageblock_end_pfn(block_pfn), zone_end_pfn(zone) - 1);
> >  	end_page = pfn_to_online_page(block_pfn);
> >  	if (!end_page)
> >  		return false;
> >
> 
> Unfortunately it doesn't help: the test firefox build very soon crashed
> as before; this time the machine froze completely (had to hardware
> reboot) and I couldn't find any kernel log in the log files (however the
> screen of the frozen console looked pretty the same as the previous
> times)
> 

Thanks.

> (I applied the patch on top of e577c8b64d58fe307ea4d5149d31615df2d90861,
> right?)

Please try the following on top of 5.2-rc3

diff --git a/mm/compaction.c b/mm/compaction.c
index 9e1b9acb116b..69f4ddfddfa4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -277,8 +277,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 	}
 
 	/* Ensure the end of the pageblock or zone is online and valid */
-	block_pfn += pageblock_nr_pages;
-	block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
+	block_pfn = min(pageblock_end_pfn(block_pfn), zone_end_pfn(zone) - 1);
 	end_page = pfn_to_online_page(block_pfn);
 	if (!end_page)
 		return false;
@@ -289,7 +288,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
 	 * is necessary for the block to be a migration source/target.
 	 */
 	do {
-		if (pfn_valid_within(pfn)) {
+		if (pfn_valid(pfn)) {
 			if (check_source && PageLRU(page)) {
 				clear_pageblock_skip(page);
 				return true;

