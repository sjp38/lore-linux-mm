Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D67A9C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 09:13:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 279A9206DD
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 09:13:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 279A9206DD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C21F8E0003; Wed,  6 Mar 2019 04:13:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96F358E0002; Wed,  6 Mar 2019 04:13:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8611E8E0003; Wed,  6 Mar 2019 04:13:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 284408E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 04:13:25 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id j5so5964699edt.17
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 01:13:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rAfjh4wn8vAHmGZywffeERW4e2x5OmrorKNgu268+FM=;
        b=RaVPyOlVXAyONd+J9cqeqA8CThknbxyKwyoevj5FojkCOEyqzI7Xb7MDjxOuL5YFkL
         4pbnFxqx0r9jJcQjYPcWfTX6boofUgWryjrdYt6aXUGN4Y8GnIibyWvbmcPVEcpP4OsM
         YrNvbHioC8RGMdMecbhItXFjKbHrmW33qN2EX+tMfSBbDyqSCQo6D3Eva94+dSW8HnNC
         Wc24OSe6jnYjg+mduYXEjrnXmp6W8AWViu+Br3znA094FEWBU0aCcNleWbcOn4pLT6Lp
         en2DBDMyaN/+q5yjTNUa/FgbC+I4JBWCEADY0sbRaOFDDINM5zHrsuir4vwtFYQJeLCa
         +/Rg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAW0WvAI49sL3h0Oni8jSnhnB+dI+EnmlCymuE6p2NrSAs5x5V8C
	2jWZgYoNDBQVSFEQW0WNLT9GC2Vl2cJ8u3N+RcOj6nn40gHp7Dq2jQxo9LAU2FIhcRieeG41tdE
	zB8VyRjQLm97FDq9DPtqDS4xLCD2Rjwmed+rWfnh1j+SgxLo3pedF6503MnPJxPp2dw==
X-Received: by 2002:a50:ae63:: with SMTP id c90mr22408524edd.285.1551863604762;
        Wed, 06 Mar 2019 01:13:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqzrNa2JLHr2jCDBpY9u+dsTPA4o9WbWnEr5mrJCVYcgM2if+LNfrBow2tHxA/IxAR2XRfZm
X-Received: by 2002:a50:ae63:: with SMTP id c90mr22408488edd.285.1551863603993;
        Wed, 06 Mar 2019 01:13:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551863603; cv=none;
        d=google.com; s=arc-20160816;
        b=IuKICJ5+2NuNpmwIbxs8ezhqwpQcpevG9vZmuyeGuqYxTW2hQya+Og01P6qSRCMpiG
         1AOwVUg8dadWEXtJ/bVIkC8XZlGMXa/Iq5Yj/EJwUJeQK15xyOe9m2WR0/lbbDOR34aJ
         vFpSuXFi5VoYTrLDjyN84PCn00IHkJmiAFAevewn5WjU1Zi3h4ytcSRH9jp1+BwgaLKq
         AcBL1JciFYofEPysc+vizWmwWlcwhySOCA5+AkDqz3soOb2TafajYQtF3B5URBCCb5TM
         bEvdS+Jd/5irVKDRgOkqt+oBlnLZSDufUGSJXMaJxAX8jdQz6Ubt084qjQWKLk+YeFnb
         3vWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rAfjh4wn8vAHmGZywffeERW4e2x5OmrorKNgu268+FM=;
        b=q8RU+4Rbu2mkzguNkITgvC5Kd3fkizNGxiCxTvqcVZjThM1V3E78Y/9JXiKrp58Afi
         6CGbWnjxi+Zbyurc3a/PCCdhlE7p12ENNFSBN/Tr9QkvvfmMNhup3dyYKG1LKc1454wm
         Yz72+8UlKv7BKGCvIMh/0NHOYRE14EyDTXEjGc9+ntja90R4PnByki/t3o/lz5C+NS4W
         G7dOFL1kmeJEVISh7uFVl5iG7smjs/zpQKgpANHcj+mE/l7MYPjcNps7S+HORR2l35K6
         vyZzaqkIjyodYM78LxuCvYN00EQRy6zFZT6lgnG0XvMMfgr6Nfzj2OIav24chdJvFbIJ
         +HcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp10.blacknight.com (outbound-smtp10.blacknight.com. [46.22.139.15])
        by mx.google.com with ESMTPS id d50si400693edb.246.2019.03.06.01.13.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 01:13:23 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) client-ip=46.22.139.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.15 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp10.blacknight.com (Postfix) with ESMTPS id 2E7EC1C239E
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 09:13:21 +0000 (GMT)
Received: (qmail 19130 invoked from network); 6 Mar 2019 09:13:21 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 6 Mar 2019 09:13:20 -0000
Date: Wed, 6 Mar 2019 09:13:19 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Qian Cai <cai@lca.pw>
Cc: vbabka@suse.cz, Linux-MM <linux-mm@kvack.org>
Subject: Re: low-memory crash with patch "capture a page under direct
 compaction"
Message-ID: <20190306091319.GJ9565@techsingularity.net>
References: <604a92ae-cbbb-7c34-f9aa-f7c08925bedf@lca.pw>
 <20190305144234.GH9565@techsingularity.net>
 <1551798804.7087.7.camel@lca.pw>
 <20190305152759.GI9565@techsingularity.net>
 <1d3a13fc-72b4-005a-7d73-2203b1ff25e4@lca.pw>
 <5eecbceb-2522-c880-7d6a-af20cf548500@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5eecbceb-2522-c880-7d6a-af20cf548500@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 05, 2019 at 10:14:29PM -0500, Qian Cai wrote:
> I don't understand this part.
> 
> @@ -2279,14 +2286,24 @@ static enum compact_result compact_zone_order(struct
> zone *zone, int order,
>                 .ignore_skip_hint = (prio == MIN_COMPACT_PRIORITY),
>                 .ignore_block_suitable = (prio == MIN_COMPACT_PRIORITY)
>         };
> +       struct capture_control capc = {
> +               .cc = &cc,
> +               .page = NULL,
> +       };
> +
> +       if (capture)
> +               current->capture_control = &capc;
> 
> 
> That check will always be true as it is,
> 

It's a defensive check allowing for the possibility that
try_to_compact_pages() is passed NULL. Originally the structure was
different but I preserved the NULL check to avoid potential surprises.
It could be changed but I don't think it'll help. I aim to setup a machine
with your config today, try again to reproduce the problem and look at
the patch again to see can I spot how it could corrupt anything.

-- 
Mel Gorman
SUSE Labs

