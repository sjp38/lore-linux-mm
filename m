Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5260C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:52:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7332C2087C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:52:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7332C2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E97416B0006; Fri,  2 Aug 2019 10:52:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E472B6B0008; Fri,  2 Aug 2019 10:52:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D360C6B000A; Fri,  2 Aug 2019 10:52:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 850256B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:52:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so47058555ede.23
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:52:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GjasllrIC3Pnrz/9hYorEaiVodhbZPy+HxPX+i5Mb7U=;
        b=Q9y13sTpwCMJEbcGCfO8cJbSYsGPGYz3+Zx4b2TIKBXiFTmSRO2iXlzapL3V7KtnFB
         lnRA6iU0n31EJs0B2QZ7TdO7N+mwCtarjP64nRM9v/kvcyCL2WwW9ENccfkeTSn0JFNT
         JDPUKZQs03zBDBFI7BCiXdJIuNonK+hn03S9O4E+FxTtmQd+kZJPo/G9tWIzS0aBdXPE
         bRSBQuss5Fk0LmOtOhrcHpkNMTRB7zCnv4UhVu59s7h1jg7O9bBCOA9QELvAGjig3Q8p
         ga1UDtnuYQOsqggUGNHnSaZP+hKpTuHeaZX4N7IbpH+D1hEPTk85BZanwW7nqHRkm6qD
         D9MA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVkZtDhJDGLP36RqMdBZeYUaVQL5L125JOjy6uRdfqeJCGAgAGu
	Z1cemgAuriFnymuBxgI6xFuxDzEZZ2v9LiiFDDfIhGFm5TA5Hl/fh4Hx4yiDAAS6TpSWW3yGD+m
	55xygau1FdcSCxervSUZlpRPrkFNxyI7UqLT94YWpON1BdDgc+PqwUy35Q8s0qtJpww==
X-Received: by 2002:a50:ba28:: with SMTP id g37mr119546926edc.109.1564757560114;
        Fri, 02 Aug 2019 07:52:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw++ftToksiLkVxXJ1uXHaV4QqRpMaP7DYCf6gcTbHgxyzPUK1ri/S7yO6aOEFxtZtIRb4t
X-Received: by 2002:a50:ba28:: with SMTP id g37mr119546876edc.109.1564757559449;
        Fri, 02 Aug 2019 07:52:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564757559; cv=none;
        d=google.com; s=arc-20160816;
        b=Ncs8ywAxw5K9PkAYDEVSrkrlwEmoDBAVAAwJbconkB6OO6Z95AZBmGdM0Mm9kPvVcK
         YhD3yeUZIo7Z9iofwA7CT4r783Z1+LiqKKKW5aEys61dYFy1dkpTyIHqcv5KZYM/VBde
         D70MU0GpbtCMr47aLfwgxm4as/Jud92+eBZ4x6Sa0A/Sw9HLJbMVnVI2UCqUqOrQ723c
         SQj5VLdnaWIGeHOpb6dYC6E+F8R5HFa+UwVk1ny5wffQcTV5+XIHvFoJWHSma6bVt4+o
         YUIjAKSO8AZsFvPSsLGFKTdtnIjQQaKHWUKksoooKW4G3FcJNoUZ/t1ssQ8TsZmrKeTd
         dgpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GjasllrIC3Pnrz/9hYorEaiVodhbZPy+HxPX+i5Mb7U=;
        b=DDhp1Z/CodIgUJgEj2N6djDmtSP4wt/lGwWqTJgQCqIjDpcyxjFEjSrr3yfBpqSvq6
         WF8rv/VgF/iPUJ++t7eA8gy9XkMJMyIgin3XZNuDx/OfcJuE+/x6fC8gkm9uFUML4kg8
         vxoXuwQC1u9h6FCqQJ0JvRvCM3xO436y2ndkBmph0F/Ye2EEeVINWJ4kQChV2LFMXZwU
         yfS19LpVKpX7zwCURZZmhsmIzPs5SNEJ5f9bPxeOKLQ9kjymEUWw9Yk3xsU+3JAK8eLb
         jdcFuaMrMPKP6K0vWN5ALlYmbxRO474OvekVSIl1hNL1XbYY0t+SI2KKr9BwzdmGBRy2
         UDXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f53si24568477edf.85.2019.08.02.07.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 07:52:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 80E69AF3F;
	Fri,  2 Aug 2019 14:52:38 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 09FD71E433B; Fri,  2 Aug 2019 16:52:27 +0200 (CEST)
Date: Fri, 2 Aug 2019 16:52:27 +0200
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@kernel.org>,
	john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
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
Message-ID: <20190802145227.GQ25064@quack2.suse.cz>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
 <20190802142443.GB5597@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802142443.GB5597@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 02-08-19 07:24:43, Matthew Wilcox wrote:
> On Fri, Aug 02, 2019 at 02:41:46PM +0200, Jan Kara wrote:
> > On Fri 02-08-19 11:12:44, Michal Hocko wrote:
> > > On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
> > > [...]
> > > > 2) Convert all of the call sites for get_user_pages*(), to
> > > > invoke put_user_page*(), instead of put_page(). This involves dozens of
> > > > call sites, and will take some time.
> > > 
> > > How do we make sure this is the case and it will remain the case in the
> > > future? There must be some automagic to enforce/check that. It is simply
> > > not manageable to do it every now and then because then 3) will simply
> > > be never safe.
> > > 
> > > Have you considered coccinele or some other scripted way to do the
> > > transition? I have no idea how to deal with future changes that would
> > > break the balance though.
> > 
> > Yeah, that's why I've been suggesting at LSF/MM that we may need to create
> > a gup wrapper - say vaddr_pin_pages() - and track which sites dropping
> > references got converted by using this wrapper instead of gup. The
> > counterpart would then be more logically named as unpin_page() or whatever
> > instead of put_user_page().  Sure this is not completely foolproof (you can
> > create new callsite using vaddr_pin_pages() and then just drop refs using
> > put_page()) but I suppose it would be a high enough barrier for missed
> > conversions... Thoughts?
> 
> I think the API we really need is get_user_bvec() / put_user_bvec(),
> and I know Christoph has been putting some work into that.  That avoids
> doing refcount operations on hundreds of pages if the page in question is
> a huge page.  Once people are switched over to that, they won't be tempted
> to manually call put_page() on the individual constituent pages of a bvec.

Well, get_user_bvec() is certainly a good API for one class of users but
just looking at the above series, you'll see there are *many* places that
just don't work with bvecs at all and you need something for those.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

