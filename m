Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 665C8C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:24:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2997720679
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:24:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="G2sxycFA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2997720679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B78B26B000A; Fri,  2 Aug 2019 10:24:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28336B000C; Fri,  2 Aug 2019 10:24:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C8596B000D; Fri,  2 Aug 2019 10:24:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 660326B000A
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:24:52 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s21so41680429plr.2
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:24:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jvuzp+6FCROkRR+waxcd/xSBD2jk0LdlEwwlmE/QRVo=;
        b=CbabUivdnOQXSFk4CFD+D0qPy7MpgZ9HAPGA0P4nbOCDXO3Vj/N8nkb2MM35Kys4QW
         LCxsNEIpxW9uRu0pjQtRMMzcr40wbTPa+9AKolUjwgqZ36kKt6l4j4Y0cAy1T57luviB
         E6xzPAjlnUvyFYdaT3R8Wn9M24HfndapRYUHHSld8ovrwSv0SdiybqS2xyXoEQmBL27w
         uamHjiZDTXEtG582TQaM1LxSc4FE6HJJ86rexypuDEyEFsfOdXPCadxcNSDNa91m7uR7
         IKNyUjQSsxlf65duC29TBVpZurfi3QvXH+xNx4r1umUzpg+QpuhyvvCDkB00oE5hK9zV
         kLDA==
X-Gm-Message-State: APjAAAUtIGeR8IQYpuD18z9LIzeYS65WACTDg3dG2mdpi+5fjU03zKf/
	v2l6X4qXjyrlXBRUrbhS+q609nI5f3K+KcUxuqz/mGDuLu2D9J7X0fM4jfbArnUBtXonb8IBP3v
	eJSxaaDJPLMs2LhDIqKHWas4eUUQr/svuzRW3utUY5nPA/Th1lm28nqrquWwYtzP3tw==
X-Received: by 2002:a17:902:bc83:: with SMTP id bb3mr134914733plb.56.1564755891924;
        Fri, 02 Aug 2019 07:24:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTbcs3kvBcm1Qf9DRacc1OBiwTeU5ENpaIhfyOugYqgH3OLA4U6e3ssEyWdrdhOu4snyex
X-Received: by 2002:a17:902:bc83:: with SMTP id bb3mr134914672plb.56.1564755891247;
        Fri, 02 Aug 2019 07:24:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564755891; cv=none;
        d=google.com; s=arc-20160816;
        b=BOY5G9D4H154Ezm5XyCNGL5Mj/4dbxK2yrubDxaEDawZM2obNCppuMbWKDIWrx3zS7
         /ixThv7XGGWF4fGgMkBtR58Ldt5xLgIy2PdV3nmNiodkdt7f6SwU4Vxa0bFVuY5Vk5Fv
         wUIbWVH+LMQ2voowvoTTT3QZrdsq52iFwTlHGW5k2cxLIxpYnGvVsPNpS220v05LdQgS
         VJZOquDc+io2ee9+BVdpMhb/NlwGFxERxKJsOhABoLgrdjixq7IltIKxV3yYBeFi0Cue
         9shg60v3zOlP937wNyczKgySyNm9eJUQj07lmwbTztdJv6gomiUHYkRa6+1Fl+JqfW2L
         sw3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jvuzp+6FCROkRR+waxcd/xSBD2jk0LdlEwwlmE/QRVo=;
        b=numLcspWyBaSm9UVljHLmw+twWfqjtLfAEfE95Y5WpOYIaKJS+H6MGfyagTbaOZjDX
         6WXhaz7qE6Q0nn/ApJ343D+CtPkAQTckCtstFsjOmtV5JYmjGVKHTCurtjy5nhX+g2WV
         /X4aSkQe4EmjfdljHgdTBqH6X6SB6nh4OgFOmj5m2rvJj12O4e3HYi9uI7OBE4in/Cry
         XbkJIkc/gzfEpEQI4FhQ3zHM1SqSrf7/N+MbxkmJzQMYJ4RNUGxvl1TfVacooMgUsZ1M
         qXRSL1P+u8pV3KV51irHmyyH+h6bRG34mjFVZIJUzFEF6UII+vLWqfiwvQ4EfJIdbn+h
         oEjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=G2sxycFA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j36si34514137plb.77.2019.08.02.07.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 07:24:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=G2sxycFA;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=jvuzp+6FCROkRR+waxcd/xSBD2jk0LdlEwwlmE/QRVo=; b=G2sxycFAx+YSXemaZWFj5rBoO
	L5W+suRd87Fzi03i9UbUkz+K/l4OLA7u4vdCzpFKd8kbKkpNT5POJKTjl3Y9NgF+IfuEQiw+Ya9sZ
	Uz98GhfWAglGYt98RBvfBnca/15T9G/n1hhy4hthNjlrIrfsKUlfX1Lr9suoRAYQ/pICfFJo13kmR
	L+hbvfVY5BZygvFEilaamnzYAdT/2P4dTNkPPWEPWi3WZyJpk4mE3pZYxvO4hCe5QB9xougEB5c3g
	IV0U5HMFOk+fqAqk6ui4QqQV5LiDqQxBtFq8kG3bamWa6AZ5dtGBvDFf6uxZiiuQmelcNvOe6qNsg
	wQg03COuw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1htYU7-0007La-VU; Fri, 02 Aug 2019 14:24:43 +0000
Date: Fri, 2 Aug 2019 07:24:43 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>,
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
Message-ID: <20190802142443.GB5597@bombadil.infradead.org>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802091244.GD6461@dhcp22.suse.cz>
 <20190802124146.GL25064@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802124146.GL25064@quack2.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 02, 2019 at 02:41:46PM +0200, Jan Kara wrote:
> On Fri 02-08-19 11:12:44, Michal Hocko wrote:
> > On Thu 01-08-19 19:19:31, john.hubbard@gmail.com wrote:
> > [...]
> > > 2) Convert all of the call sites for get_user_pages*(), to
> > > invoke put_user_page*(), instead of put_page(). This involves dozens of
> > > call sites, and will take some time.
> > 
> > How do we make sure this is the case and it will remain the case in the
> > future? There must be some automagic to enforce/check that. It is simply
> > not manageable to do it every now and then because then 3) will simply
> > be never safe.
> > 
> > Have you considered coccinele or some other scripted way to do the
> > transition? I have no idea how to deal with future changes that would
> > break the balance though.
> 
> Yeah, that's why I've been suggesting at LSF/MM that we may need to create
> a gup wrapper - say vaddr_pin_pages() - and track which sites dropping
> references got converted by using this wrapper instead of gup. The
> counterpart would then be more logically named as unpin_page() or whatever
> instead of put_user_page().  Sure this is not completely foolproof (you can
> create new callsite using vaddr_pin_pages() and then just drop refs using
> put_page()) but I suppose it would be a high enough barrier for missed
> conversions... Thoughts?

I think the API we really need is get_user_bvec() / put_user_bvec(),
and I know Christoph has been putting some work into that.  That avoids
doing refcount operations on hundreds of pages if the page in question is
a huge page.  Once people are switched over to that, they won't be tempted
to manually call put_page() on the individual constituent pages of a bvec.

