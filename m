Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 228D4C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 23:00:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC859206A2
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 23:00:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="clZMOrgp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC859206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7975E6B0003; Mon, 12 Aug 2019 19:00:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 747546B0005; Mon, 12 Aug 2019 19:00:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 636476B0006; Mon, 12 Aug 2019 19:00:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id 41EB46B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 19:00:48 -0400 (EDT)
Received: from smtpin20.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id EF8963CF8
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:00:47 +0000 (UTC)
X-FDA: 75815297334.20.tooth61_7b4d456b69238
X-HE-Tag: tooth61_7b4d456b69238
X-Filterd-Recvd-Size: 5356
Received: from mail-pf1-f193.google.com (mail-pf1-f193.google.com [209.85.210.193])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 23:00:47 +0000 (UTC)
Received: by mail-pf1-f193.google.com with SMTP id i30so1739828pfk.9
        for <linux-mm@kvack.org>; Mon, 12 Aug 2019 16:00:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2ksXWqG62EfbmUuHI0nKd4a7rlKac00A3mrtP5kn5Ls=;
        b=clZMOrgpPeiUsSiOQGc7xPtSCJ1+tYlCEalNf0FrCYLJfEA+0uy4k2IMsGT3jc2cFu
         QPuYWIpFCQhxAals/OKuaPNf8mppQVTkf6D4zIbGyKu4gOrWVhA2o9ZKUIPwXfJVrcoG
         avMIYarRQn3GMlD+OUwXFSElhTGkglyd3QZD1GJQSaZP8jC6QiZ2xLFtEuUdnjR3mnni
         sRQtw5csmi7PfDU+Ql+QaQ1NKyhCIKJ3a40cFUmsKMpgHBOzlU8Y+4Tu8Q9zJCvCmZsb
         tOC9AwuoxVLSsc9XXteA5o+ppMTBTFjDr7sDywYo3lo2UATZPZ7kYu0zrGDtAc9pwsi5
         IbpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=2ksXWqG62EfbmUuHI0nKd4a7rlKac00A3mrtP5kn5Ls=;
        b=OOaXaPmguTlVPlrDvKcjIP7cStCwW2sf6iK4/ejAVvPo2V1j4ZCcRqin2fbiZGsHhA
         o0p6omWIowZL4k9WhqdIXjpucCW761HUeHV0NUuT0q8I9lo83VmQSj/t34dPAPFRtmIr
         O6F5UV6gtfpQaUX2eJeL6usVo+AqLKwl7ZA3L5p2KSHJdvzxNFtUTMCI2XAx8A+D75Mj
         UHRkx52ezUUSvvqtLNIBert0rjBFnwkTx0YHVTJd+oYVwJdncDH47XRNBxFiaQJRchVB
         6KihnhLa77vJqDpNtYEO3GstgGlutbJ0XNBob8p7qiPFPzAeCg9qYCDarGyZiwy0U+qh
         7txA==
X-Gm-Message-State: APjAAAXsfrh2XrDgtUCeBZTPICwwjLj/HZngyIU4N8mwxOiWDLRXOETG
	TdIayzTMNmclt1Y/N5krDJzlkg==
X-Google-Smtp-Source: APXvYqyb883Z7rrcgcBtXgV+QnSSy8ZT99o+mRBxe/N1CFP0iCEGlwsPbuGd5lBVkMaokl9X9DPeAA==
X-Received: by 2002:a62:6083:: with SMTP id u125mr37305269pfb.208.1565650845803;
        Mon, 12 Aug 2019 16:00:45 -0700 (PDT)
Received: from localhost ([2620:10d:c091:500::2:f08])
        by smtp.gmail.com with ESMTPSA id z13sm110232784pfa.94.2019.08.12.16.00.44
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 12 Aug 2019 16:00:45 -0700 (PDT)
Date: Mon, 12 Aug 2019 19:00:43 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>
Subject: Re: [PATCH] mm: vmscan: do not share cgroup iteration between
 reclaimers
Message-ID: <20190812230043.GA18948@cmpxchg.org>
References: <20190812192316.13615-1-hannes@cmpxchg.org>
 <20190812210723.GA9423@tower.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190812210723.GA9423@tower.dhcp.thefacebook.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 12, 2019 at 09:07:27PM +0000, Roman Gushchin wrote:
> On Mon, Aug 12, 2019 at 03:23:16PM -0400, Johannes Weiner wrote:
> > @@ -2679,7 +2675,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >  		nr_reclaimed = sc->nr_reclaimed;
> >  		nr_scanned = sc->nr_scanned;
> >  
> > -		memcg = mem_cgroup_iter(root, NULL, &reclaim);
> > +		memcg = mem_cgroup_iter(root, NULL, NULL);
> 
> I wonder if we can remove the shared memcg tree walking at all? It seems that
> the only use case left is the soft limit, and the same logic can be applied
> to it. The we potentially can remove a lot of code in mem_cgroup_iter().
> Just an idea...

It's so tempting! But soft limit reclaim starts at priority 0 right
out of the gate, so overreclaim is an actual concern there. We could
try to rework it, but it'll be hard to avoid regressions given how
awkward the semantics and behavior around the soft limit already are.

> >  		do {
> >  			unsigned long lru_pages;
> >  			unsigned long reclaimed;
> > @@ -2724,21 +2720,7 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
> >  				   sc->nr_scanned - scanned,
> >  				   sc->nr_reclaimed - reclaimed);
> >  
> > -			/*
> > -			 * Kswapd have to scan all memory cgroups to fulfill
> > -			 * the overall scan target for the node.
> > -			 *
> > -			 * Limit reclaim, on the other hand, only cares about
> > -			 * nr_to_reclaim pages to be reclaimed and it will
> > -			 * retry with decreasing priority if one round over the
> > -			 * whole hierarchy is not sufficient.
> > -			 */
> > -			if (!current_is_kswapd() &&
> > -					sc->nr_reclaimed >= sc->nr_to_reclaim) {
> > -				mem_cgroup_iter_break(root, memcg);
> > -				break;
> > -			}
> > -		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
> > +		} while ((memcg = mem_cgroup_iter(root, memcg, NULL)));
> >  
> >  		if (reclaim_state) {
> >  			sc->nr_reclaimed += reclaim_state->reclaimed_slab;
> > -- 
> > 2.22.0
> >
> 
> Otherwise looks good to me!
> 
> Reviewed-by: Roman Gushchin <guro@fb.com>

Thanks!

