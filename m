Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B967C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:13:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 497CD218A4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:13:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 497CD218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEABD8E0004; Wed, 30 Jan 2019 13:13:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D986C8E0001; Wed, 30 Jan 2019 13:13:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C611E8E0004; Wed, 30 Jan 2019 13:13:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D0858E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:13:09 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id v11so290695ply.4
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:13:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Yr+PZvks0FVwLADAvQrpP2okUTdHEpAW8GPJty2x3dM=;
        b=iyxpZOttkE9/STSudZ6V5DTzzbEmIh+ciat6eTgMzKdcMwQIGdRnSRcvPh79HJvglj
         dV3RdJc7Sllua6BemA7/6jbmytMFycne5YhCQRdVhLId0Pj1/CaIbDH7NJWd/7d+EJAz
         qb8t78UgcU2ZmVqf0s/kQz528ipkGjSJ1ZHPStiFHlIOh0J544BdB7DXA0a786znoKQW
         QI5EuUb8FcvdAFSXHiuzTP7ujLLjXp8KIqGN8ZeLyknbP3LvqUPaTtdutBmZZSjwJJFk
         Crn7EjDqw3CDg74kfzToOndn1I3ngkZnhBNY5V6QySTeqRLtxJAbdDpApGlLHwYJKiXq
         RdDw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukduQuNng0GYjoUvBz1zIBNtSfetJQTl4e6JmtO7PaH8YtM79tFY
	Vp64iSUOZlLlArG8QTOFDgzqNPRsScFn1G0VLmdf0mr+/nWAtXIG06ef+qLDfwtMCwmRy3AKj+U
	HjK1Bj0bDVkxSsKClPW0qxuo/oCjTEynRDE4NzWTl0el30EwKU+W3+E0MX9yzFxrzVg==
X-Received: by 2002:a62:ca03:: with SMTP id n3mr32602186pfg.241.1548871989147;
        Wed, 30 Jan 2019 10:13:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5bgtWoy0ZvemYmc4k90UIvzSRbCDZKAazGh3BS0rX/Gi105922EWAJ8rR/L/a9HDBWNRAC
X-Received: by 2002:a62:ca03:: with SMTP id n3mr32602139pfg.241.1548871988406;
        Wed, 30 Jan 2019 10:13:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548871988; cv=none;
        d=google.com; s=arc-20160816;
        b=kXltmWBADXUrp3eBAnoY4jg2ajbRLfi3nSEe/SjhY6BsYrHuhAoqFpqAYDGdqhT81h
         2PAxJpTWXRRyCXwVgKgBYFgx+yB/A9hSEL3No5EbSWH0eUiPuwjUtryGalUVuNK3kDLl
         LydvSfs4zlFgHPGe+VLkY0YnCu4idLGy83VGdj3aIwp9rBez1nIWFJ81t50YvJp8oj9q
         FMxAiOdwCQOsH8mnUVcYgT1yBztYUGc4MUgjL/Pt17ia2VvPFrPKcw+uMex59M2U53ZK
         MoE6mHy5IXHR/IBe21s+EJ/gWK+LGaeVJ6PhZJExAg8L79hrFT+slPFIi6sGAcsFEvRO
         OtSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Yr+PZvks0FVwLADAvQrpP2okUTdHEpAW8GPJty2x3dM=;
        b=dzi2FImMXQOg3k97P1y04Ii+dx/9t7L8YczsqkgOFpNETPU/zAP3XS+V0RS+fZAaTX
         WP/0hy4VqvgXvVhWeEH05se7+oeAnCF4Zyc3TJiAbmcva+MXfgYMoRySVly4/zmCDf7M
         Wp9tWmA7OaLiw8HjDbKz9iAHqBgFTSd8Fjf1GylJ8ll9MSOSv+qF8o2jvTgGuoOkbKyY
         U9RfocKg+uoFyXA1Xi39aIsLibESSwhhWGJTmEDTlaXy3Rra55qpz20GhH/33aBAF4w9
         42GhYCB8+Nx9P36IZCKrwIIQBj0CjWJ2tt9X8UIG+8w569OXzjznMy+IFIFPXNcixwwI
         v07Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g12si1978732pgd.567.2019.01.30.10.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:13:08 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jan 2019 10:13:07 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,541,1539673200"; 
   d="scan'208";a="113978754"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga008.jf.intel.com with ESMTP; 30 Jan 2019 10:13:07 -0800
Date: Wed, 30 Jan 2019 11:12:22 -0700
From: Keith Busch <keith.busch@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, linux-nvme@lists.infradead.org
Subject: Re: [LSF/MM TOPIC] memory reclaim with NUMA rebalancing
Message-ID: <20190130181221.GA19525@localhost.localdomain>
References: <20190130174847.GD18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130174847.GD18811@dhcp22.suse.cz>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 06:48:47PM +0100, Michal Hocko wrote:
> Hi,
> I would like to propose the following topic for the MM track. Different
> group of people would like to use NVIDMMs as a low cost & slower memory
> which is presented to the system as a NUMA node. We do have a NUMA API
> but it doesn't really fit to "balance the memory between nodes" needs.
> People would like to have hot pages in the regular RAM while cold pages
> might be at lower speed NUMA nodes. We do have NUMA balancing for
> promotion path but there is notIhing for the other direction. Can we
> start considering memory reclaim to move pages to more distant and idle
> NUMA nodes rather than reclaim them? There are certainly details that
> will get quite complicated but I guess it is time to start discussing
> this at least.

Yes, thanks for the proposal. I would be very interested in this
discussion for MM. I think some of the details for determining such a
migration path are related to the heterogeneous memory attributes I'm
currently trying to export.

