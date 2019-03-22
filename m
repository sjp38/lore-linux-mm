Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76E20C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:33:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D29021916
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 16:33:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D29021916
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEAA76B0003; Fri, 22 Mar 2019 12:33:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B70196B0006; Fri, 22 Mar 2019 12:33:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A12DD6B0007; Fri, 22 Mar 2019 12:33:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B14C6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 12:33:41 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f1so2626019pgv.12
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 09:33:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=y1kranFGlBl8Y4Icc+/VnJOTsxFjXo9NxNnnER27N4o=;
        b=alQYdXlLbPiPbi1xjTvAR9ifWBQdARVxU38A6k5rRalZ5ENGHIj/L8+D1fGQf5q+pU
         6AXGJU4ELEgBX4DhwfJo49QT8gnRSW0lS0VaFEJxgLrEwP7/NOa5YEg6wA4b8EPO8OJt
         fzlCdHDioc950B1aOWiEbybYw79BuT9Br3TGPLMKjKyL95ns/xmAdJ4NxAWpX8AHuuK3
         AFaDBAlU9Kfh9ECQnIwYWyrQuIX2eQxyPkhn5CcYm5UvpLlavXBfFv5zmYXV9YkT9LAR
         197nwIUWH71de0Z/RrJIJvJ4MwVLNfXUVys6Bq6FsgU/xHXHbV2jnOhWT16+TBLS76hu
         0pAg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.136 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXl/yM4Yr1XoECShq2hp3T94ZHFozENZYWkTKaaGpK1is7fYBv/
	HbnL4oM5i7z8rC15kWp+xjbuvcnx2wTi3bKhgonvI4F3Kn+OwPJUKcM4V+k3YUQRYJcPu1klMMa
	pgEF3nl9M9Y6Utb9/Kd7Yt8i5g+tyCbaiZyYPgeBMnimNWjTj1XRuVYqp6LtZg88=
X-Received: by 2002:a17:902:822:: with SMTP id 31mr10501492plk.290.1553272421003;
        Fri, 22 Mar 2019 09:33:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoAfAUmd2FlMuWat25Edvz3kFeQj4xyrC7IPE0hI+GbuLJVhi4C6inXyU6Z6cEYoOUI4Ko
X-Received: by 2002:a17:902:822:: with SMTP id 31mr10501433plk.290.1553272420238;
        Fri, 22 Mar 2019 09:33:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553272420; cv=none;
        d=google.com; s=arc-20160816;
        b=eswWpnqesV4iJI1uKkd1axMLBmn64vwdasEdRSyHCF3jiFHf2VknbNs0dJjtB9/bbz
         MJVner8pM/T8T4KMIkpCgq+LcEecC7m+EzA2QGLEMvcPzfVpbxrUT1NRg5Ru7q56y+mb
         n7qUnHjy9IAfRflnos/Q0GIptYG6Pj0JJWDboN985p6/vtuWdzIa/Mas3d2QrBljq1ua
         vBgTKojjn/Dhe5m+IOgIIkBkO0xXfI+RqhK2FuLTjeKNMRkFS15V9lK6aJSC2rjHQRnz
         Uz5bl6AaU35e67nL7Jscl/N0GAR1QBUtz9LDkKHHz0f6vHyCI7cT8tj6Icvz9AfE3yx/
         8jTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=y1kranFGlBl8Y4Icc+/VnJOTsxFjXo9NxNnnER27N4o=;
        b=uThaEiY81KJg2i6POTlVTeoyDgLN9KzvfYVTkhi4BUdu4pFElxmOI/ZjQCud9tV6fa
         8IbD3GowOcnF9krClb11RO00txt1nS92seG4IQg74AJUPoKnKxoOfMfMj8pDbp68T2/0
         7h6+proxJROL5qq11hg3Il6VCiSrBQXFhVlZ1ByNt58HRycIQa9UPSJWmvZtmHxQZxPb
         sYo/i67w3tz9aDhy7cOwvSaV1uIGuChK2vo6tVOEXcpp20obU0Zo7AOsF0GV5ISmK6gP
         Bqqasc0O315n6w3cvVgkPSw/UI473DO3Y0Tvozd1Fi591ygONn6GEpjjm0YfBY5CSoI3
         sV0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.136 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 138si6206972pfa.199.2019.03.22.09.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 09:33:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 192.55.52.136 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 09:33:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="142975999"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 22 Mar 2019 09:33:39 -0700
Date: Fri, 22 Mar 2019 10:34:41 -0600
From: Keith Busch <kbusch@kernel.org>
To: Yang Shi <shy828301@gmail.com>
Cc: Keith Busch <keith.busch@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>, linux-nvdimm@lists.01.org,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 3/5] mm: Attempt to migrate page in lieu of discard
Message-ID: <20190322163440.GB31194@localhost.localdomain>
References: <20190321200157.29678-1-keith.busch@intel.com>
 <20190321200157.29678-4-keith.busch@intel.com>
 <CAHbLzkqGGJ7dFiZkR-=yvGEF0AM4JbBe6pxGFbSe9tSnC7wgzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHbLzkqGGJ7dFiZkR-=yvGEF0AM4JbBe6pxGFbSe9tSnC7wgzQ@mail.gmail.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 04:58:16PM -0700, Yang Shi wrote:
> On Thu, Mar 21, 2019 at 1:03 PM Keith Busch <keith.busch@intel.com> wrote:
> > +               if (!PageCompound(page)) {
> > +                       if (migrate_demote_mapping(page)) {
> > +                                unlock_page(page);
> > +                                if (likely(put_page_testzero(page)))
> > +                                        goto free_it;
> > +
> > +                                /*
> > +                                * Speculative reference will free this page,
> > +                                * so leave it off the LRU.
> > +                                */
> > +                                nr_reclaimed++;
> > +                                continue;
> > +                        }
> > +               }
> 
> It looks the reclaim path would fall through if the migration is
> failed. But, it looks, with patch #4, you may end up trying reclaim an
> anon page on swapless system if migration is failed?

Right, and add_to_swap() will fail and the page jumps to activate_locked
label, placing it back where it was before.

> And, actually I have the same question with Yan Zi. Why not just put
> the demote candidate into a separate list, then migrate all the
> candidates in bulk with migrate_pages()?

The page is already locked at the point we know we want to migrate it.

