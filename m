Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 378A3C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:41:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D02DC206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:41:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D02DC206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D1638E0006; Thu,  1 Aug 2019 02:41:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 681678E0001; Thu,  1 Aug 2019 02:41:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 571428E0006; Thu,  1 Aug 2019 02:41:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0667F8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:41:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so44136896edb.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:41:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=05E7owaURs/QvOBlmoldDfeb6/WPR73PlpUQezznL0o=;
        b=L/R/MABo92VMoDwaaixz8ZBf+LzSJFlIMmOsylYOUY+OSvutmffUTWZhWDSqUn1yEm
         l1voGO17yQOEeQ/T0MsWqXWeAjGLqbOJwBx7GZ4EzR/iMnw5tzNslpepWLGNw1aacUru
         j6tGNcYpwvJdd/pBmBahSm7XNKYaz6tWC99hgvvg2DN2X/noYIQKNDq3MohFWCKvXhJI
         FlDIQGZ+A0pe/N5PvCQ4WiFuRYbydAAXvgLxZvIRa0ZYu20HilvSa9xw9ufhPaZWKZYk
         hx32CHBkzrSw/IZ6equOsOfMFKMjFC1AATUtU9Ptq/aT4QWru/FOQeUegXZ0tZifUGnw
         ougQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVsRh5bsGZe3Ls8f+uQ8E0OyIK46+Bdn/tey+yE9B2td/2uCkyF
	MymlPyuou9AaFtsSukovOKtjG5p9Nyu16s+ZIMiadjSOcQTgflQHJuQ+N2seYwZEcrhPaU2Zk0B
	wTx5hzCeAYrY694dXGo5X2Q6VSnnoOSkrU00gDaV6+7uSeqAC+GCPRzCUq7mWxsk=
X-Received: by 2002:a17:906:90cf:: with SMTP id v15mr95207724ejw.77.1564641716594;
        Wed, 31 Jul 2019 23:41:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjuBcol1QsWSIF7iFt0BKC45hQrfIxnlxH3+nSuw2xa5YeiKIpD5JfDy30A31ymYZt/HhE
X-Received: by 2002:a17:906:90cf:: with SMTP id v15mr95207701ejw.77.1564641715906;
        Wed, 31 Jul 2019 23:41:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564641715; cv=none;
        d=google.com; s=arc-20160816;
        b=Ipn+sdDOHTQ699mG3uc89Hr/qH8yh0NW2s20MvB6k4uhB3NoJV/qRX5D32xa3GHI+D
         aFR3pFlhFYnxbBtVN2Z0rBpf+uOFWqnJuSJ0P9eJ2OxuXSJ7JGEIATOKzZIw2GFAPbeq
         Ghs5XVMAqIv98xlj+KwmleGjIx8zdOcEc4+w96r9rXMV7GEH7+GY4eZ+x/6eO4fEaY40
         YKIh5psy5ltVuszAMGrcsQ5JeVkYFvkyeUaYpGWR7X2Fq/j1pH+Dt1v13SG8Z2IZVaQs
         M5r+llPHkd1zo2I1EJ8ViRjEOrf2M3To+iuWvIhVbNDmrI9C3bUCaWaOpu7tUCTTyvyX
         OAUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=05E7owaURs/QvOBlmoldDfeb6/WPR73PlpUQezznL0o=;
        b=tFc7WL8tD4VrAqAH6V9ap7wsozHe4D89NWkIhFbDf5YHUc375aVXfcl8SgMYfb/QrX
         ODXwNhy2tKLYUSunJwCTrCQJAGH26Wr86OElqdxWV3MzqMKyeON/uOJN8dGBuylu+5R+
         2fHEWilKWJDr7uZ9Z+5P+bc6zUGwMpIADSVNo9L3vD9Fo9ZcAiylpHzmHEeK+4NgbRZP
         oXW4U8MEZ6GyCmWXIgIdsSeVaM/tSmcnjo94Tw2xg4p2JP0naspuVdrT38/CsgUj3+cU
         scMVcgO3hTkNBu3dCxbBtULJYgpaxgy2sOaW0qEh/LASPta25Fik+YIixlgwhdDm2FB7
         4C+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l53si23985086edd.293.2019.07.31.23.41.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 23:41:55 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8003FAD1E;
	Thu,  1 Aug 2019 06:41:55 +0000 (UTC)
Date: Thu, 1 Aug 2019 08:41:53 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>,
	Qian Cai <cai@lca.pw>
Subject: Re: [PATCH v2] mm: kmemleak: Use mempool allocations for kmemleak
 objects
Message-ID: <20190801064153.GD11627@dhcp22.suse.cz>
References: <20190727132334.9184-1-catalin.marinas@arm.com>
 <20190730130215.919b31c19df935cc5f1483e6@linux-foundation.org>
 <20190731154450.GB17773@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731154450.GB17773@arrakis.emea.arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 31-07-19 16:44:50, Catalin Marinas wrote:
> On Tue, Jul 30, 2019 at 01:02:15PM -0700, Andrew Morton wrote:
> > On Sat, 27 Jul 2019 14:23:33 +0100 Catalin Marinas <catalin.marinas@arm.com> wrote:
> > 
> > > Add mempool allocations for struct kmemleak_object and
> > > kmemleak_scan_area as slightly more resilient than kmem_cache_alloc()
> > > under memory pressure. Additionally, mask out all the gfp flags passed
> > > to kmemleak other than GFP_KERNEL|GFP_ATOMIC.
> > > 
> > > A boot-time tuning parameter (kmemleak.mempool) is added to allow a
> > > different minimum pool size (defaulting to NR_CPUS * 4).
> > 
> > btw, the checkpatch warnings are valid:
> > 
> > WARNING: usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc
> > #70: FILE: mm/kmemleak.c:197:
> > +static int min_object_pool = NR_CPUS * 4;
> > 
> > WARNING: usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc
> > #71: FILE: mm/kmemleak.c:198:
> > +static int min_scan_area_pool = NR_CPUS * 1;
> > 
> > There can be situations where NR_CPUS is much larger than
> > num_possible_cpus().  Can we initialize these tunables within
> > kmemleak_init()?
> 
> We could and, at least on arm64, cpu_possible_mask is already
> initialised at that point. However, that's a totally made up number. I
> think we would better go for a Kconfig option (defaulting to, say, 1024)
> similar to the CONFIG_DEBUG_KMEMLEAK_EARLY_LOG_SIZE and we grow it if
> people report better values in the future.

If you really want/need to make this configurable then the command line
parameter makes more sense - think of distribution kernel users for
example. But I am still not sure why this is really needed. The initial
size is a "made up" number of course. There is no good estimation to
make (without a crystal ball). The value might be increased based on
real life usage.
-- 
Michal Hocko
SUSE Labs

