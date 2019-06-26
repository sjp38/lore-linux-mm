Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFC47C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:59:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B38F72086D
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:59:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B38F72086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 856E98E0005; Wed, 26 Jun 2019 02:59:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8075A8E0002; Wed, 26 Jun 2019 02:59:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F71D8E0005; Wed, 26 Jun 2019 02:59:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3BB8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:59:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a5so1705389edx.12
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:59:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9JZitHP6eJRgaj75NXXVVCbPBeJLVjtAlNYNgc56J5M=;
        b=ZJovR+nwExXG7dj6wnDNFNcmtUvcih7oWTTWcmzIt+WEx7rzZyxe0c/Pucm/F3+nkV
         kzrLwTkX0n638TrPXHVOh2sEOyeemyreaSVeTlBd0R7L/DDb3FmTyTVhJ2nVrlW+u1KD
         IZfq54tVVQM+Lk7xdAhSvzcAaOVQyUbE2OUHMZOt+5c4g0NdUdPslqkPBVP0XrFyCcft
         fyqA7XyWFtbji3z/SEsHkX8DqUfX+rtBsSvsOeFBJQfQHS6/cQl6VrRFLLDZaU8YSJvS
         jdurbpuYsWwwqI6Ggl5BUjW36Gl1uueWyu4Yak3p/hR3L0/5ue3ONKrqi5ZL4meFhZNh
         7aAQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWB3fkmaBe62bux7J+N9bR/bopUIAXSpP93hVqhAmvPOqXj08Dn
	6AiOS4SAkrWT8NSk+K1+Ys3yxUsB8owp6GAJAKxdebwyD6SYfk6uoNv7FKBWzUOJLdFgYJFZBFj
	LXDeD9+eA3BrXBx1BN6q1HJ+HrFlNHFeR3dd7gYUfxNZN5L8sam6/6/zNaiJu8SE=
X-Received: by 2002:a17:906:365a:: with SMTP id r26mr2504388ejb.128.1561532379702;
        Tue, 25 Jun 2019 23:59:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2Ktg6wviKckie1YZlPvw1+jItVFBVCtlSbCKq8N0I9Xj29JvtO34QvtD3yrqucr33ySZv
X-Received: by 2002:a17:906:365a:: with SMTP id r26mr2504346ejb.128.1561532378974;
        Tue, 25 Jun 2019 23:59:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561532378; cv=none;
        d=google.com; s=arc-20160816;
        b=lDFUqcT869b5h4qEcVi/sBPbkls7H+qV61sJ56Xl5BAaUeOOAQnf5aKP5WQoJD+PjG
         zBVY3ACtFW4Rtw8odpoxF1toBAbH5eKN7zj7aF7OTCexTLPW7XDE2h0oJzdVz7NnVefp
         4QXRCXSggYBhbBq6aGKz9N5YCqZIYRxVdM6dPN/j2sG9cSfhGU9ZQAd+sJAad8GSHyIH
         hiGoHKmLvkLWaD04GEJjVSHWxHW6Aetgr7EB/988hrIxjYMVzvdCI5O8XymFnHKWdBAs
         Z+D4BKM2v+qeQzgOrf37vF8tJPV0DuUPdC1vfB8mZGx7BBhIWDYeY3BZAcDMZZPsP62Z
         jjOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9JZitHP6eJRgaj75NXXVVCbPBeJLVjtAlNYNgc56J5M=;
        b=V68o31ZdWSNi9uBULgAjvGEw6uJoBpVhP1K5/BVaw0Be28EXKHrHXprirM3ffd2a5j
         coH4YipW97+QP+oBW1tlCICx7j/bpAASh9FFqJ8a9OqnZOR528vHuv2DrlPOIw21wwg8
         TTiSDTnpEviyaSVmDdBgdoO/gf8YGSXamzzBUSqCoOUHxx7oD7afnoPhPzBcSeEb2Dm/
         87T3XHJN0i6NZelNOjT7Sibtt3Wo7jqZQ8iH8LZK2YsWs0HcakjrPJcRG6ukm65p9pFH
         cIXLRcYlEPQcILwIiDqcC7BerYsnYtvVywMVlQreHfAy/8n88WC8D6IzgwuL9JOhz2dx
         zZpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id la8si2091353ejb.359.2019.06.25.23.59.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 23:59:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 94530AC83;
	Wed, 26 Jun 2019 06:59:38 +0000 (UTC)
Date: Wed, 26 Jun 2019 08:59:35 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alastair D'Silva <alastair@d-silva.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>,
	Mike Rapoport <rppt@linux.ibm.com>, Baoquan He <bhe@redhat.com>,
	Qian Cai <cai@lca.pw>, Logan Gunthorpe <logang@deltatee.com>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 2/3] mm: don't hide potentially null memmap pointer in
 sparse_remove_one_section
Message-ID: <20190626065935.GL17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
 <20190626061124.16013-3-alastair@au1.ibm.com>
 <20190626062344.GG17798@dhcp22.suse.cz>
 <edac179f0626a6e0bd91922d876934abf1b9bb19.camel@d-silva.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <edac179f0626a6e0bd91922d876934abf1b9bb19.camel@d-silva.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 16:30:55, Alastair D'Silva wrote:
> On Wed, 2019-06-26 at 08:23 +0200, Michal Hocko wrote:
> > On Wed 26-06-19 16:11:22, Alastair D'Silva wrote:
> > > From: Alastair D'Silva <alastair@d-silva.org>
> > > 
> > > By adding offset to memmap before passing it in to
> > > clear_hwpoisoned_pages,
> > > we hide a potentially null memmap from the null check inside
> > > clear_hwpoisoned_pages.
> > > 
> > > This patch passes the offset to clear_hwpoisoned_pages instead,
> > > allowing
> > > memmap to successfully peform it's null check.
> > 
> > Same issue with the changelog as the previous patch (missing WHY).
> > 
> 
> The first paragraph explains what the problem is with the existing code
> (same applies to 1/3 too).

Under what conditions that happens? Is this a theoretical problem or can
you hit this by a (buggy) code? Please be much more specific.

-- 
Michal Hocko
SUSE Labs

