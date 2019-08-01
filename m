Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54274C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 04:22:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF170206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 04:22:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF170206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sina.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8705C8E0005; Thu,  1 Aug 2019 00:22:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 821D28E0001; Thu,  1 Aug 2019 00:22:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9978E0005; Thu,  1 Aug 2019 00:22:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38E278E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 00:22:54 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e20so44833659pfd.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 21:22:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-language:precedence:list-id:archived-at
         :list-archive:list-post:content-transfer-encoding;
        bh=YWQfKGIde2FQKMsI9cImY1CNyF8U748+3m93N97mArI=;
        b=orottsoukbnNw17hBZACpI0ikWu9vUVztRxLcRA1+DriSdemRZWH+g8y41k4G4Fnk0
         Xk4bHKcfEvvYYgw179fsVIYMa83BAy6L0LGs3s2emmql/vRPK/83ZodCnAzQB/LyLW+5
         gTyccDilQQeGUV+l9l4Q2AbfpyP7bYWl7pdAF+K94nnBImAhsTjpnyhMmAeCxo19YHTK
         BGt3YCLeyNnghCNYIIksmcYkmLc8vwBn2rjL9eofjIfymx86dgNz8Gj9m0qRNQO+G6Ia
         7Oz4kxwYVNfWiiwJQx8qZV9O7MsNhwOMza6Mf/OwhuagQ/7XuJ+KzAhE7PdhgTcKrrmH
         BZRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
X-Gm-Message-State: APjAAAVQbRu2Z6gnnWqhKa9reP8bs3G6Z1NBjIatljJa2JvwlCTkof0i
	uj2M6cOi0hfh2/cwxMqFrY66+a8vHrdA36QDDh19KHjlmBRQoOp4Sm9LelCJNIoMoQBggPVuA5T
	jlxoG/MA8xb2Oweh/fhHAlLahDXCvIzxaLIDXuwRtjZD9gfrodFWEAeLFFzDimXv8qw==
X-Received: by 2002:aa7:9786:: with SMTP id o6mr49880579pfp.222.1564633373887;
        Wed, 31 Jul 2019 21:22:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz4kF8B95CGj+s8zKYWKMjwufz+nop0rfmew2tp7hWM+CDFD5zMasIaO+65bFoarsL86vd3
X-Received: by 2002:aa7:9786:: with SMTP id o6mr49880542pfp.222.1564633373212;
        Wed, 31 Jul 2019 21:22:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564633373; cv=none;
        d=google.com; s=arc-20160816;
        b=tQi4hbVHG2e+iYHDqyQYxb4Ji64HqdIPIUpIZYi3LRiTdbXxLrmylbqk6tpfIivcec
         ye72s64Squz6Dj9NdSB2m0Yi1tFA3en+WSf43shidTb808K+qMqRVEUtPxX7vtgHzzAL
         EfeXBVSuT3+uiWqbYE32oRsHzeXiDJcZ24FCeX55RTL4Aiv8SMedeu2r9txAJHTf2Mgx
         bTjmgEWc6MhNoHs+Ejhxwz9ZnaUdNKKR0unk6LMOCVBT9v/3WaBgpp3cgC1KYd0jHcEo
         5aCmWLmAg3ZffO+6+tvJMGlloNp/jQF1PePXuHNkRbowikYv6KZixZAjYnL2AfGQ8IUT
         sbJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:list-post:list-archive:archived-at
         :list-id:precedence:content-language:mime-version:user-agent
         :references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=YWQfKGIde2FQKMsI9cImY1CNyF8U748+3m93N97mArI=;
        b=1Bolo/hiyWOdLzpQfGGn+1bN4M17SR9YMV4Q8zfqNp5upwk9kSXSXGSuX2qMG1pepH
         /OlVheEm286pvi2F0bs298wfXovxo2ZGyVzrhir9pQyEemMTL4TYNhbBrfecmXSNRXsm
         7VNI1LHXEblJJZV+MI3nUjOcWadqSKkBfOSGw6ue0buB5DyMM+wbRIaSr6AN3Br7L0SI
         vpQtoCi/JKOykYkc6FgPmxwm6AnV/oqwFDv+yEeuUE8fgizPz7tT7SsilhFDlVjw3GGN
         rDmN20QhrXE3h1TGO6a+XQoAg2wl3wHus8FE3H1/HKBYdfzsoCfPZRJ1wcQOQCrtcMMr
         zmjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from mail7-213.sinamail.sina.com.cn (mail7-213.sinamail.sina.com.cn. [202.108.7.213])
        by mx.google.com with SMTP id a19si37619504pgw.234.2019.07.31.21.22.52
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 21:22:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) client-ip=202.108.7.213;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hdanton@sina.com designates 202.108.7.213 as permitted sender) smtp.mailfrom=hdanton@sina.com
Received: from unknown (HELO localhost.localdomain)([222.131.77.31])
	by sina.com with ESMTP
	id 5D42691900004DEA; Thu, 1 Aug 2019 12:22:51 +0800 (CST)
X-Sender: hdanton@sina.com
X-Auth-ID: hdanton@sina.com
X-SMAIL-MID: 26952250201762
From: Hillf Danton <hdanton@sina.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Mel Gorman <mgorman@suse.de>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 1/3] mm, reclaim: make should_continue_reclaim perform dryrun detection
Date: Thu,  1 Aug 2019 12:22:40 +0800
Message-Id: <f6e25e52-bb02-6d79-b9fd-3acc8358ec45@oracle.com>
In-Reply-To: <295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz>
References: <20190724175014.9935-1-mike.kravetz@oracle.com> <20190724175014.9935-2-mike.kravetz@oracle.com> <20190725080551.GB2708@suse.de> <295a37b1-8257-9b4a-b586-9a4990cc9d35@suse.cz>
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
List-ID: <linux-kernel.vger.kernel.org>
X-Mailing-List: linux-kernel@vger.kernel.org
Archived-At: <https://lore.kernel.org/lkml/f6e25e52-bb02-6d79-b9fd-3acc8358ec45@oracle.com/>
List-Archive: <https://lore.kernel.org/lkml/>
List-Post: <mailto:linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000008, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190801042240.J5_QWR8RtBnRI3AikCWC67iK8-3xY6p246pjxX4Nqbg@z>


On Wed, 31 Jul 2019 14:11:02 -0700 Mike Kravetz wrote:
>
> On 7/31/19 4:08 AM, Vlastimil Babka wrote:
> > 
> > I agree this is an improvement overall, but perhaps the patch does too
> > many things at once. The reshuffle is one thing and makes sense. The
> > change of the last return condition could perhaps be separate. Also
> > AFAICS the ultimate result is that when nr_reclaimed == 0, the function
> > will now always return false. Which makes the initial test for
> > __GFP_RETRY_MAYFAIL and the comments there misleading. There will no
> > longer be a full LRU scan guaranteed - as long as the scanned LRU chunk
> > yields no reclaimed page, we abort.
> 
> Can someone help me understand why nr_scanned == 0 guarantees a full
> LRU scan?

AFAIC no pages reclaimed without pages scanned(no scanning no reclaiming).

Literally a reclaimer's KPI is usually gauged by its effeicency of
reclaiming pages, irrespective of factors like the proportion of dirty
pages, costly order, the online of a swap disk and lru size.

At the moment nr_scanned == 0 raises a red light and the reclaimer has
to take right actions accordingly. Currently there is no ruleout of a
full lru scan.

Feel free to correct me if anything missing.

Hillf

