Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91C67C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 12:41:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D6D62087E
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 12:41:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D6D62087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E81546B0003; Fri,  2 Aug 2019 08:41:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E31AA6B0005; Fri,  2 Aug 2019 08:41:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFA5A6B0006; Fri,  2 Aug 2019 08:41:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 835B06B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 08:41:50 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m23so46819327edr.7
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 05:41:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=x52DYLGmZZhSN1I9fLLuFXxzfr7EieKOPFnmz7fYOfc=;
        b=E8ZzHwiqxd+DRhTeCOMRbIaQlkdOoz2sq6eYVeWhzR9eLougmQXmFStiBPVg/GKWty
         9SYwv5Qo/M3l7plIUn/v+77+gmxWPrtVqRjmBdeHBim9EdyELR2JooJFH2cUyaM2VDPT
         HsFGQcbiidTINFrNlsJorcBh0dSEcN8A/HcZvWSPlmerqS9Hp7OXLWJVywetMfGSAEZ8
         MWn47vdXhFEjcV+seveSZFbFSs7iFR8PaH1kZK0+ySvvMwx3l1OwwDCv2yap0zbmmmSX
         Agfu2shMobziYph3PVZLUrVo4vG905GIaWGGH4dnMBFVtgIjP5Nl10cUd8cIJJe/Btk/
         jaKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUDg97OagqLX5p3E8DieKs27EsxTgQbXM+WiVZmWZa0K/R1yY3z
	h41hM34T6IW6BNRu6XQr/vGXZ7v0kfxLc1iOUlzVqBkEvyDlw/+clwqNs5Cs+Z871gK6+6Xwk60
	H6Zp1ldGFDV/lS6hCOCgQgHhsvx+LkYyrDH1RYYWIrNDlny3bHJA6kxfHJLSs+yWixg==
X-Received: by 2002:a50:94a2:: with SMTP id s31mr120090191eda.290.1564749710101;
        Fri, 02 Aug 2019 05:41:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9rJFLpSqHigy2muCvBDBaB3KwfS9EjQb4VFkzltI4c3B+Ok/ZVwc40tyMF4Ttt8sHqeS2
X-Received: by 2002:a50:94a2:: with SMTP id s31mr120090130eda.290.1564749709231;
        Fri, 02 Aug 2019 05:41:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564749709; cv=none;
        d=google.com; s=arc-20160816;
        b=mSeC9rq9MyUCxf2yNebnvDZLhTlle/0H2MLFeO8U6p/LIj9kL845ydFehN5YjzQuQr
         nV8Qt2uCn3olnR2efbdZ8TTAvZBLxVYSpnEUNG724nwOtYdM9N6cmkKf6sGw+sPT5vMe
         UxijGPt4BO8SSMqdJLHSpZJap+4T5arPlbkt3L2LFK/x45Cs0S3jeu4dpraFGzH5oJzC
         hzB4g8OBg/vHxgOsLhzeQTkwF7fCAm6czJkY4TRA2Sg39W4RavFsTGTJVNmm5+1wRcxi
         v/S4twXXrbx0ZCNaKXN+FGQ3BYWkY/pbYgygQgUJ3xdLCE0ytFaZuY4vICZ2fB4fYEoD
         6TRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=x52DYLGmZZhSN1I9fLLuFXxzfr7EieKOPFnmz7fYOfc=;
        b=yTm1VH55dANBDL23T52zrWbsjC1srH4wA0aW11BIXjcOVyAbyqn34rUSji5JyGcDS/
         4iMDaUujF/jilC3hrkyK0tznM9+tejpXMOEyeFVg/mLmWY3+hlms5ls8ZMba+S3qicYn
         b440FMEhe8NPjpI45FdLVBxiE/DjwuMNxoy36CmFpIyOSdZ3GAji1mLcSOw1bVX57GOt
         IhsU1H+ejtDozoHi8Shal4ArPqSdq54NwhjQxqKlwO0sLhyYRYjM21coL0eYPHieJ2sN
         f0DUVRIAg7CcqFpOHeldZw7+A7ZwPuFH+pHCLZjXZTwOdekrrqM2oK/KZo7clDHyo1ko
         y4lg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x32si23812415edx.397.2019.08.02.05.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 05:41:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 20E6FAF94;
	Fri,  2 Aug 2019 12:41:48 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id F40A51E3F4D; Fri,  2 Aug 2019 14:41:46 +0200 (CEST)
Date: Fri, 2 Aug 2019 14:41:46 +0200
From: Jan Kara <jack@suse.cz>
To: Michal Hocko <mhocko@kernel.org>
Cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Message-ID: <20190802124146.GL25064@quack2.suse.cz>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802091244.GD6461@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 11:12:44, Michal Hocko wrote:
> On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
> [...]
> > 2) Convert all of the call sites for get_user_pages*(), to
> > invoke put_user_page*(), instead of put_page(). This involves dozens of
> > call sites, and will take some time.
> 
> How do we make sure this is the case and it will remain the case in the
> future? There must be some automagic to enforce/check that. It is simply
> not manageable to do it every now and then because then 3) will simply
> be never safe.
> 
> Have you considered coccinele or some other scripted way to do the
> transition? I have no idea how to deal with future changes that would
> break the balance though.

Yeah, that's why I've been suggesting at LSF/MM that we may need to create
a gup wrapper - say vaddr_pin_pages() - and track which sites dropping
references got converted by using this wrapper instead of gup. The
counterpart would then be more logically named as unpin_page() or whatever
instead of put_user_page().  Sure this is not completely foolproof (you can
create new callsite using vaddr_pin_pages() and then just drop refs using
put_page()) but I suppose it would be a high enough barrier for missed
conversions... Thoughts?

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

