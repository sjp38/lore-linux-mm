Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90829C06511
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 12:46:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 370DE2053B
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 12:46:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 370DE2053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A55D96B0003; Mon,  1 Jul 2019 08:46:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A06858E0003; Mon,  1 Jul 2019 08:46:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CE7C8E0002; Mon,  1 Jul 2019 08:46:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f79.google.com (mail-ed1-f79.google.com [209.85.208.79])
	by kanga.kvack.org (Postfix) with ESMTP id 3E3A66B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 08:46:31 -0400 (EDT)
Received: by mail-ed1-f79.google.com with SMTP id l26so16819007eda.2
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 05:46:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=R4XVBQgIOSu7swuRG4xbBWrK6TxZBP3ZKgDOfbSeafs=;
        b=TuihZ71PtZ76+fOoTElT+A9zSDHorDLhCabPIvdgaTc5mbY7cbaG373shaMthLNkWR
         OKahKoK+n0Nfr3UmU4WHdAlTgxTgw29mBTlH1m7sozeQT2AMbPs71ZoXOYpLFeG7EwVK
         cb8kPxYIrvVFjhFp2a0ZtUkV1lUe+jlEmKWvcyAG1CpqDSgNw4gki1zrvr+Kb49g89wl
         Nd0R20tlY5lQnqytvT+rtiHYToPNUcwM3mdVIsX5JL0K8fzU7BELjYL6NY2CxCWAQrjb
         iIKa+qmdtkMKu3d7SFO3PTkvIO7qEdhl4NPgGkQgp+UJzkYRt0cNoLnZ1Tf1iyLq5KDX
         4TEw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXcNz6kkJofbKh8olWlpkMUnU25O6+C3lHi9b2VtYkETaOBeLgY
	x+3k+wIr8H3l2qiIZJ0ZFIPe9fMTKUl4JedcTkilvVd2csKRO+hTLQWZ2ZLeex7FfSNAL/p8L39
	vJu2CUudX11N7dMSIW2TuzlGlmtWAy7SxxEDEjVIr+SQ8q6KtvAOEHYc+iPiLrv4=
X-Received: by 2002:a50:9846:: with SMTP id h6mr28083803edb.263.1561985190752;
        Mon, 01 Jul 2019 05:46:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgHib82M8dscaza//AMhKljVp0LJVoaPcTd4zawL3RSSRSAIc+HI7gO/OgJQ7DeA1SGDNj
X-Received: by 2002:a50:9846:: with SMTP id h6mr28083715edb.263.1561985189528;
        Mon, 01 Jul 2019 05:46:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561985189; cv=none;
        d=google.com; s=arc-20160816;
        b=vJRLb1BdiSpi/Ft66bd4a8zz1y4whkpz7zGGfKhmpryd+8oY9aNkpjHn70/P+8yHlH
         9Vv0U6SIhAs3cgpdMpSduj+RpYBv18R0MhF/roGOLH9sJRnkp1y9wvPz/MuOAi1taW87
         xt9rdjrdX4i1ivGhUAsOy/E5pyj3wAl4L/96cy5BbtySY7OMfX/a50ovMkyDyqa7q7TJ
         ViYmcav89rtfWGIiA6JUla5u3HK7vLkuatKv3mdgB72lCjbZSjs1gQrHZ485iT892eYX
         udAq+g3eB+f413LdDevw4o2xlB7meqhHrhbIzoBjhCO4fKW5FJdSPdFkDPpe5Pi1Hgo/
         uGLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=R4XVBQgIOSu7swuRG4xbBWrK6TxZBP3ZKgDOfbSeafs=;
        b=vuHgeSvn4xh44/GJmOHamk94VJ7loIHvMXbQL4oTllkesl74AsI9DDbYcPkSDfrbVL
         QiWsIKp4GEizKypMmXuP+oN8uUsBmj9wLiLENBL4fxLJ7sEqMGhPaGMVBc76QUSzIrs5
         NXWkB12CoHKjT6cBpeLcwu+e/YQLYyeTjwShdfjNu5sVX3JfpRAIStvTfGRCyp+I64u2
         dlKtLTzqMJfeI4dVGwQGQvfloTzFossPF1crfUn5uHWTJcKTZZrdyDrbxksvIPjJGUXS
         7SPrOnGrJ6sfBceUobWKXjvY0CsiBEYYqEqNE0pXjeCOZb5aCwnf6SDrV0oUOMzmOICu
         HjlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e20si7264244ejb.77.2019.07.01.05.46.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 05:46:29 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B4AF5AEF5;
	Mon,  1 Jul 2019 12:46:28 +0000 (UTC)
Date: Mon, 1 Jul 2019 14:46:28 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.com>
Subject: Re: [PATCH v3 02/11] s390x/mm: Fail when an altmap is used for
 arch_add_memory()
Message-ID: <20190701124628.GT6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-3-david@redhat.com>
 <20190701074306.GC6376@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701074306.GC6376@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 01-07-19 09:43:06, Michal Hocko wrote:
> On Mon 27-05-19 13:11:43, David Hildenbrand wrote:
> > ZONE_DEVICE is not yet supported, fail if an altmap is passed, so we
> > don't forget arch_add_memory()/arch_remove_memory() when unlocking
> > support.
> 
> Why do we need this? Sure ZONE_DEVICE is not supported for s390 and so
> might be the case for other arches which support hotplug. I do not see
> much point in adding warning to each of them.

I would drop this one. If there is a strong reason to have something
like that it should come with a better explanation and it can be done on
top.
-- 
Michal Hocko
SUSE Labs

