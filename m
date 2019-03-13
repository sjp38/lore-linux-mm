Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4803C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:03:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64D17206DF
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:03:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="HAIUAFIb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64D17206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECE358E0005; Wed, 13 Mar 2019 12:03:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7D0C8E0001; Wed, 13 Mar 2019 12:03:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D1DF28E0005; Wed, 13 Mar 2019 12:03:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCE38E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:03:27 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v15so1172027pga.22
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:03:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uNI5X/3NiZwWGw9ll+SGYgUYDbq0/M8f6aJJzFdlRg8=;
        b=F6YECM4JLXtM1pxAqHfaGvB91O4lm1Xro9I4NcEkfeYtZUFk9FACF3BBc/0zQkWkGJ
         MhH8EY8LBZEuTcPxU4msLRua1hTivG/iC9bkxaoTV1BEfKS/vNRiaW49Xi4EAoDpQN1S
         Ug1+Hkw94X2wrVLFRGtrIedYW9Eh4Q0sWjPEG4uv1f2a2BePqSLNdOFWr6FqK7X6/G0+
         w8UJpUvnzGdX8ZuhtEYMsM9PxFV8P8z5GrOhI6okXYzpEBLeGwR/dZC2V2K53PvZ9w2h
         zZXiIigSBySemv88zTgHStjQKVa18WMs4Zmp5FYyFZtnwGhQ0TSmnoz7zKjMgxXHp8Yu
         Cl7w==
X-Gm-Message-State: APjAAAUF/6PcjgDY7KWXFaDZ2Ix+oS7n3/szdLREIjxi0ndEuCf328nL
	LTHEzz4A6Xd7Lk6BY+T7jVMYVRva/XKMbFoiDTytWF+1WFwbOveFY3e3lZI1jS4u3Wf/uOI35Z4
	ukr7x8o2Uqv80mx4fkV4PwU/2Bo/KVnaPX42kQKhWgU32NiIJn0OqIFiDCTbuDF1p+Q==
X-Received: by 2002:a62:2b88:: with SMTP id r130mr44559520pfr.93.1552493007075;
        Wed, 13 Mar 2019 09:03:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgmbGJ4v+/xASp/y2sx9IksjCrT+OJzi+Meork0D7iKP5Q6MRgnEiE/S45sfESAqa+sGL7
X-Received: by 2002:a62:2b88:: with SMTP id r130mr44559383pfr.93.1552493005244;
        Wed, 13 Mar 2019 09:03:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552493005; cv=none;
        d=google.com; s=arc-20160816;
        b=vg95oBqhLRNGjk9bY0fJwVJcBvPjIRm3Wh2PmPLS2CsQdCiYvEb8XRpJuQ8bS3YiAA
         rgeLVBVcQxP9RF7CGJz6CO7VimpOvVBMytU0qzKdJZ1M3ecjxwLg6tSNjb2ZaoD/1pou
         6aqW20hCBZjq1I1oKcrHbdKPb2tPAffA/NfxXQsyUApZ8T2adg23mUSMEYnw6zAVZ7qO
         vg9xf1s+l+2hkepcu2hUkrdxQZdJq5kuFFqgQWb9S6tNbeOEHFfeISbjufb+A94hD10n
         lvBMm4cxM3cy6LohkhjCxGILTS8PKI9XEmby0stnJxU/p8+KrXib0GstxPmO5IIH6Au+
         Yn5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=uNI5X/3NiZwWGw9ll+SGYgUYDbq0/M8f6aJJzFdlRg8=;
        b=NLSDC7q3cs/h99FCDKJ4USHoDjMlruP5t8+EXKNImBfDp+YQidSJbl0qNiTHwKqEUx
         qhyuijSj5HfXke7EmiosZ/HyU0JafgXfyGIqra0otMTcTfuCMtB1k6piJnES+O+yj91V
         5ZfrIyxsjzzL5ufW6wxnIRCTxJv+tebPDRjGR2vFSLrHSzj9cjfKImcZKwIZKFJ3+P4r
         wNCCfucJSxnUqYpPU16dr7eUqN7CDIUL449NzWf2Y+5cpX6SyVFv+JmTcqo18RMGssCJ
         GuLipi69uw/J4n+YtwZ/1YjxaObfGhbcwEgPjrxTPaT3yxArvDXmZPdjjSkKu2KZB8Gw
         PU9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HAIUAFIb;
       spf=pass (google.com: best guess record for domain of batv+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g2si3714118plo.354.2019.03.13.09.03.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 09:03:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=HAIUAFIb;
       spf=pass (google.com: best guess record for domain of batv+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=uNI5X/3NiZwWGw9ll+SGYgUYDbq0/M8f6aJJzFdlRg8=; b=HAIUAFIbqsW3BMxa/FP5NX1sG
	yw88chlyXN2ibo/Qu5d+gI4KxTZuL7AbNlHF0jJlGUzB21qP16G260680a2VUZLeipWU05Mn99LAu
	PpqWc6IqgqhyIMLkJEcfN72nGVnUjHbzkIcfuVkd6VEn+tXvqAXZavNAS5s0lksDJ73gRqY7kPQ1l
	JBqGDM9SN+rIsNP5uhBsIKXyqajBBvmyhH7qgWPZReT9+cYuPLpQDXyYo0hYgy6iZxpT1IxQlRJiI
	3WWBkZ6SbAAmf4MBUw1zyzXRfAEkSmW5eamvKicLBu/pT0jDDL1fpCBp+a72ig51Y279e15azLyL7
	29XFmWulA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h46Lf-0004Jg-Kg; Wed, 13 Mar 2019 16:03:19 +0000
Date: Wed, 13 Mar 2019 09:03:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Christopher Lameter <cl@linux.com>,
	john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190313160319.GA15134@infradead.org>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190310224742.GK26298@dastard>
 <01000169705aecf0-76f2b83d-ac18-4872-9421-b4b6efe19fc7-000000@email.amazonses.com>
 <20190312103932.GD1119@iweiny-DESK2.sc.intel.com>
 <20190312221113.GF23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312221113.GF23020@dastard>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:11:13AM +1100, Dave Chinner wrote:
> On Tue, Mar 12, 2019 at 03:39:33AM -0700, Ira Weiny wrote:
> > IMHO I don't think that the copy_file_range() is going to carry us through the
> > next wave of user performance requirements.  RDMA, while the first, is not the
> > only technology which is looking to have direct access to files.  XDP is
> > another.[1]
> 
> Sure, all I doing here was demonstrating that people have been
> trying to get local direct access to file mappings to DMA directly
> into them for a long time. Direct Io games like these are now
> largely unnecessary because we now have much better APIs to do
> zero-copy data transfer between files (which can do hardware offload
> if it is available!).

And that is just the file to file case.  There are tons of other
users of get_user_pages, including various drivers that do large
amounts of I/O like video capture.  For them it makes tons of sense
to transfer directly to/from a mmap()ed file.

