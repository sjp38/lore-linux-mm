Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 941B0C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:23:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E15B2086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 23:23:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E15B2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CB2DE6B0008; Fri,  9 Aug 2019 19:23:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C62686B000A; Fri,  9 Aug 2019 19:23:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B2A306B000C; Fri,  9 Aug 2019 19:23:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 794EB6B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 19:23:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h5so60600212pgq.23
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 16:23:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=f9D/JEw7FTKyvjuHVi8UGqysW10nXJZAlR4Lf2Pks/k=;
        b=HMPfVm7XI1AtrSFXSOEqxkEJCe7GEsXbRE2McguQvH3RxmLSKBV5S87BEJD9+6YWGz
         Ct6NJyli7zgvbW7tVLlDW2w6v89IvOOUE42UsY3wLLndt8idyF4OiF1wpkQ7tkJN8h+f
         GxLfRqyYSMFv5Ef3v4cVgxHW87eiv0I362OAHMnaUkQV20l9cf6A6yy5K11YUOBxN2B6
         wZMo21A6VmZP5ftHZeZwCyIHmxDYnI3YSIVMxuKY3fiJ3HSsI8+bXs8T4/xPJLLzpBu4
         saLT+RTAcym/FUnP3TAQxdoAPLE38xQzYNiUbsE+LKoUOc0IQMgr77zIpv9EwMKhONdF
         phGw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAWzEBxsDW2C3gylPwaDqzIhjSSiagiUyFj7olq/fJHa7Y0QJCyM
	oGJ3l8LV5fARY+BlLIFcR+AsaPjZcVECLHErVt5mKMSTFbl0tZ36xEtldl9cNfuUQZ9Ou4kMt7/
	T1B6zkVdnaqgl1+nEgz53glfHIiAbxPGg3FY6/yneMrk8CfQxzt+dK9P91NG7Zvo=
X-Received: by 2002:a17:90a:ff17:: with SMTP id ce23mr11771945pjb.47.1565393004109;
        Fri, 09 Aug 2019 16:23:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXoNORJGDJ9HGtNIvRc7G9YH9Lc+smcDMkPvqdpG4vfz79SFPzGGfysaHkq0RRr5sg4O87
X-Received: by 2002:a17:90a:ff17:: with SMTP id ce23mr11771907pjb.47.1565393003424;
        Fri, 09 Aug 2019 16:23:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565393003; cv=none;
        d=google.com; s=arc-20160816;
        b=Zoq2UiiOHn7UAwlHpn8gOVJjMfPjjYBi1N5BtRKC1rBj1DrH9EB+nIKkVUN911THKE
         zG91ICnFSlumSRKcCIJ0d1FP2Q+8/h/xpJHTE91uC9FJwjp1NkWKWk4xszv72D7XGBnM
         JT7Z2VNSbzHfozdc4yDYZxJXGkXLmmi/Oyyt3/aayuLa1p21e2a6ZryxRrLY3kMl8hPi
         yzwhSaQTv8dNsaTcEzM0UcRQNuRlZ+69PZ39tbJ+idZBmagCFFTBaiAOFiawlE0WTJTS
         kYJUYqtaOY/6TLXFaSQvAU/5dk/TL5XlZ0dNAYxRYhPSphjEfF1OX3B1dw6cwF7wB9/F
         7qTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=f9D/JEw7FTKyvjuHVi8UGqysW10nXJZAlR4Lf2Pks/k=;
        b=N4+ovr1QcF55TCW0ztosrtGrVXUizEmy73Loco4Vqpble8eRoWSpCkRtjAoOJOE1j5
         AnHyOLlFL7OGXPEk2g2Cgtf1T+MHUgrZktyjwNRjmlmsvQJ9fPsiAlUxflGB87rD3zHj
         RNw9QvRpS6r85IILjKDijzjlBFF2ftfNAiQBIfTyESsFaek/ikQ8kdp4i4ZGP9ZeaUue
         rM5zetHbEZRztPk/DKYSdrUHUNr38Mq7fKEp8Z5SC6o0lZ5j6sE/DXUJ7md8ppqdbJNQ
         EVaWAVsfMir944DJ0jwhB3E80bWAypxOk1TyzAKOSRqXMHGQkCCr5eyHm2iA1/17MJJL
         eaaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id 71si51001501plf.156.2019.08.09.16.23.23
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 16:23:23 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 59581364BCE;
	Sat, 10 Aug 2019 09:23:17 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hwED3-0001Oj-SN; Sat, 10 Aug 2019 09:22:09 +1000
Date: Sat, 10 Aug 2019 09:22:09 +1000
From: Dave Chinner <david@fromorbit.com>
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>, linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [RFC PATCH v2 08/19] fs/xfs: Fail truncate if page lease can't
 be broken
Message-ID: <20190809232209.GA7777@dread.disaster.area>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-9-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190809225833.6657-9-ira.weiny@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=QyXUC8HyAAAA:8 a=7-415B0cAAAA:8 a=0k3dsaUolkUxXiJpVawA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 09, 2019 at 03:58:22PM -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> If pages are under a lease fail the truncate operation.  We change the order of
> lease breaks to directly fail the operation if the lease exists.
> 
> Select EXPORT_BLOCK_OPS for FS_DAX to ensure that xfs_break_lease_layouts() is
> defined for FS_DAX as well as pNFS.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  fs/Kconfig        | 1 +
>  fs/xfs/xfs_file.c | 5 +++--
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/Kconfig b/fs/Kconfig
> index 14cd4abdc143..c10b91f92528 100644
> --- a/fs/Kconfig
> +++ b/fs/Kconfig
> @@ -48,6 +48,7 @@ config FS_DAX
>  	select DEV_PAGEMAP_OPS if (ZONE_DEVICE && !FS_DAX_LIMITED)
>  	select FS_IOMAP
>  	select DAX
> +	select EXPORTFS_BLOCK_OPS
>  	help
>  	  Direct Access (DAX) can be used on memory-backed block devices.
>  	  If the block device supports DAX and the filesystem supports DAX,

That looks wrong. If you require xfs_break_lease_layouts() outside
of pnfs context, then move the function in the XFS code base to a
file that is built in. It's only external dependency is on the
break_layout() function, and XFS already has other unconditional
direct calls to break_layout()...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

