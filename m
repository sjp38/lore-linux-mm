Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 008E6C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 12:55:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFEAC2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 12:55:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFEAC2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5685E6B0003; Thu,  2 May 2019 08:55:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F1426B0006; Thu,  2 May 2019 08:55:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36C4C6B0008; Thu,  2 May 2019 08:55:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DBAF26B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 08:55:19 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c1so9311edi.20
        for <linux-mm@kvack.org>; Thu, 02 May 2019 05:55:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cqXFoPYUbMBdIgtz4paGbMx4rhmEJsLkRsTQDM6QnC0=;
        b=gMSlfmpfedxXICN2uxAez2hMpTtFsj+DBfgXN1nBGNxNVK8z/7hdCbK+gukI9HiyA8
         Wkr9I8Y/15oWZr1ZWIh6subBBO0H0KxPrZoelBgDCFw/6kwac4RMmk5PQ4iu5/wly86Y
         DwaSs9P6hXhwOBXFVcp6yAOJEraxemL9qEEmt/UldcSpRHtC9SC5PkbGLW9RvIUPCkpD
         /X8W3Tg2I3h5vLXgMkIFKPZ7Gs7G4IsJ7IoxHu7CxLLEZqvkwONv6ib7EYAnjOgJrd49
         U3/dGrN/TUYOwYAU5143vSlkSNRGUYmg2gbSe2FAVj0m+jHPZ6cXP7FQZqj/ikl3VKYK
         G0/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAXWo45wS7uLcdpZH0MPtgbyPyaIr92i4tIEpYSxJdRlIoBN4dgh
	/TWkvZtAGbw+UR06u8SILJIskKpT89QQ9VWjc1XxiwmV2INQvoZjB+xRCdYTO98RlSZ/kon7wIs
	BZYyRddHB44S42gCmCHOkf88MFo4MKwKZ5VOMO0lixU7FoxyUY3NtXJQNnTCgwxSB8A==
X-Received: by 2002:a50:a951:: with SMTP id m17mr2337841edc.79.1556801719474;
        Thu, 02 May 2019 05:55:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/nb9XCNeZA9yc2fXKvpCRBRNW3/TFG1zZhdIUkHUm8ZdXM1uh/4b1BsjCNRAlcqRg0g/y
X-Received: by 2002:a50:a951:: with SMTP id m17mr2337813edc.79.1556801718709;
        Thu, 02 May 2019 05:55:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556801718; cv=none;
        d=google.com; s=arc-20160816;
        b=ksWFqXtfCBSYwOjpKZTyDQ8N3FxQ9GPBYNbdWg3s5amQxBrsIvKem5ZrUU7Q3QP6OJ
         s+xriVyiu7aM6XliylVjGX7xVrq/CjM+vEw5I+9x24GIfri2qUTxG6UGSBZz8XiAtRIy
         GTHrA04t8e0roZQWAEMpNxadm9CUVL+smepbnia30JuRuffxFhLuuq4fGBeU5L8znV2N
         YX+XtmcZ06UlqtjBpsIL9S1FJoH3300+AqbERMkgYOPuSP9mK78vQMpRo57qaCmDRdly
         6VrhU5nJvcobJasxPD2Lh3o594yH+ZRJxkngS5Csq4YskYMYs2Sg6ki3MkJneaIQRZy3
         HbCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cqXFoPYUbMBdIgtz4paGbMx4rhmEJsLkRsTQDM6QnC0=;
        b=rCMD+qJH8FiBwdTlYYNPKDz4/oCcJFeUPKcnzfh2A82MHqM2imc+PWNBDs14cuqdRx
         r4rSvWOg2/IRv92ibZoPYd4U0Cot2pOoD1HsqwLW3HzBEJjznPPMGUXC4WPlkSAgMXkt
         0+Kacg6Q4a1fzgTvZTIkH099/O2U6b5u/yC/7cw0mOaajVygahR0bay5hrGqUpYfQsF7
         lvHkIOj5jrzEe67Iu01hZOfk3esWIlMKBA4KBxf2VYC6h7/lwBEnw1rce6CGaf8ZJcCE
         e+kZQxMjkzTSd0TN5iJcYFprSym24Ip0uen7yojYrR5BG3Y1i1O0o8KTMhtJIVBxaWlM
         A+JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l10si71796edf.330.2019.05.02.05.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 05:55:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2E5D7AC0C;
	Thu,  2 May 2019 12:55:18 +0000 (UTC)
Date: Thu, 2 May 2019 08:55:14 -0400
From: Michal Hocko <mhocko@suse.com>
To: Dexuan Cui <decui@microsoft.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	Roman Gushchin <guro@fb.com>, Hugh Dickins <hughd@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	"dchinner@redhat.com" <dchinner@redhat.com>,
	Greg Thelen <gthelen@google.com>,
	Kuo-Hsin Yang <vovoy@chromium.org>
Subject: Re: isolate_lru_pages(): kernel BUG at mm/vmscan.c:1689!
Message-ID: <20190502125514.GB29835@dhcp22.suse.cz>
References: <PU1P153MB01693FF5EF3419ACA9A8E1FDBF3B0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <PU1P153MB01693FF5EF3419ACA9A8E1FDBF3B0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 01-05-19 23:49:10, Dexuan Cui wrote:
> Hi,
> Today I got the below BUG in isolate_lru_pages() when building the kernel.
> 
> My current running kernel, which exhibits the BUG, is based on the mainline kernel's commit 
> 262d6a9a63a3 ("Merge branch 'x86-urgent-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip").
> 
> Looks nobody else reported the issue recently.
> 
> So far I only hit the BUG once and I don't know how to reproduce it again, so this is just a FYI.

This is really unexpected. This BUG means that __isolate_lru_page must
have returned EINVAL which implies a non-LRU page on the LRU or an
unevictable page on an evictable LRU list. I am currently travelling so
I cannot have deeper look. There was a similar report which triggered a
different BUG_ON in the reclaim path also stumbling over but that was on
an really old kernel with out of tree patches so it is not clear what
happened there. Do you think it would be possible to setup a crash dump
or apply the following debugging patch in case it reproduces?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a5ad0b35ab8e..289493986f6c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1686,6 +1686,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			continue;
 
 		default:
+			dump_page(page);
 			BUG();
 		}
 	}

Thanks for the report.
-- 
Michal Hocko
SUSE Labs

