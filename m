Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B1BBC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:01:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6FB92173C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 08:01:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6FB92173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 568AD8E0004; Wed, 13 Mar 2019 04:01:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4EDA48E0002; Wed, 13 Mar 2019 04:01:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DEF88E0004; Wed, 13 Mar 2019 04:01:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA1548E0002
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 04:01:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p5so540229edh.2
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 01:01:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=x/tgta5x5um3W+6jeoD8NpqB5tEGh5dTeW/hr+RBHm8=;
        b=Z1nSVE9b1YsFgdfkQxIdxb1ZOcNUKsMbXS9jCNitmvEBtEqtV/WaIPYrRR/TJyDQg0
         /5Rn2OlGkuh24uz8FFO/FfNqhNrfccY4ZLHHqmnIuQOX/UFm2FEQE05pXnl0X0zsBxu5
         IJYyLHijoimOhSE7KQlfJEPy7Y84HofRTypGBrFEay8pFRzVH0OZ12RfG54cntrdeCYL
         HR6s2gkJ44JxsZkl7gV7/x0kwTEGXRtNLkMc2IJVhv9L/i+DdxuPfstpOZzzqGSNWx3W
         ZreknNv3yHyl6CFpsNVka72pVF3XDtLuB41Vn/Zu/Kyymwmi3ahUBLoUmY3YIlZJ8aTL
         wj9Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXFWe2vRaCblo22RZxWZaqMYHCfnY9pBrNjXYZaq72wgQt7d51u
	wGOzJTW/8F9Zz7dNt9YO7ZaowgIjJrT6La17eQIn98cwPCHZJuksyc6lFEtGzAg6uB3ayUm29rX
	IEoMuoT2HJzpcyeyQMfALzbMio35ueBXTXX1Lrn9n9mQ1EOP8fxCcJCCN2VXA5nA=
X-Received: by 2002:a17:906:3c3:: with SMTP id c3mr27732419eja.181.1552464067552;
        Wed, 13 Mar 2019 01:01:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzy/4mk6YrkDbbIxdNAnBIHBPqIaDwupc9x1rOUXzK28hEcSyM7lK+sXII0PNaZjMlpALtS
X-Received: by 2002:a17:906:3c3:: with SMTP id c3mr27732381eja.181.1552464066645;
        Wed, 13 Mar 2019 01:01:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552464066; cv=none;
        d=google.com; s=arc-20160816;
        b=jdMQq55AKNLdkZPp7G1pwqV1EsuKozO5F4aFBxbWrd28XRcwy0+3ATGyGkt2nrfOZ9
         MXTR+EIkpKnKQSl9YyENhOIl7wAjaERndqRHHgX9uGQo5sSVQ+Y3UHh2Nx97pJHByq4G
         ieorLbJs/96XVwgM97bz/A3y/xRUyKxG8cInoEgTUcjU5DoK5yUW/vHeu3iPhZ/eOOcO
         7oWv0aNfVd5P9gk+KNTNrq+G2dwXJg4kV4TBzRtdmaaDh0omg1QxRFiNeyClW7Cdhd3+
         bJVyNNYo8xRSrhgdX2E5gPZK+NB++6lWCbdwhtsWRPd0lNrnLR+9edd/ziqphYLAKx0s
         RABA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=x/tgta5x5um3W+6jeoD8NpqB5tEGh5dTeW/hr+RBHm8=;
        b=KqYYR3BBMKpCjRElLIdqiUPrvyG0h8LGA/vv6PljtREEeCqn1A/eSSn6djzkEU6kaI
         sKOLR/8mGCxHP7OSvfAuaWackviw1l4ImRxCjjN+tFTfhU/6B/jEtNGG2qObcdGcs6wg
         kl7ThZK2TI7nnhvMjOx9wAyNqz/6Fp3N2w/V+3y55Or7jKmvTNpDgeOmDWpTWzEVVMcz
         DVVT9RwwyeEzTQuwPxP3R1yFVTKLWmYFLNCwJZpKFW3qtmr8CqB/h/3P64VlpYE6cHlH
         cCvGAXg2lmtEiRuRg2R7Xcn29oRVeTqfnsD7tLmgWKTyUg92Qe/2Q0ivJSqUmermjTRU
         fKRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si448901edx.81.2019.03.13.01.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 01:01:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EE063AE84;
	Wed, 13 Mar 2019 08:01:05 +0000 (UTC)
Date: Wed, 13 Mar 2019 09:01:05 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, vbabka@suse.cz,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix offline undo_isolate_page_range()
Message-ID: <20190313080105.GG5721@dhcp22.suse.cz>
References: <20190313014216.36782-1-cai@lca.pw>
 <20190313075212.wc3pbwixx3ppwxua@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313075212.wc3pbwixx3ppwxua@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000295, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 13-03-19 08:52:16, Oscar Salvador wrote:
> On Tue, Mar 12, 2019 at 09:42:16PM -0400, Qian Cai wrote:
> > +
> > +	/*
> > +	 * Onlining will reset pagetype flags and makes migrate type
> > +	 * MOVABLE, so just need to decrease the number of isolated
> > +	 * pageblocks zone counter here.
> > +	 */
> > +	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
> > +		int i;
> > +
> > +		for (i = 0; i < pageblock_nr_pages; i++)
> > +			if (pfn_valid_within(pfn + i)) {
> > +				zone->nr_isolate_pageblock--;
> > +				break;
> > +			}
> > +	}
> > +
> 
> I do not really like this.
> 
> I first thought about saving the value before entering start_isolate_page_range,
> but that could race with alloc_contig_range for instance.

Yup. We need to take the zone lock.

> So, why not make start_isolate_page_range to return the actual number of isolated
> pageblocks?

That makes more sense indeed.

-- 
Michal Hocko
SUSE Labs

