Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95C1FC072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:27:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A7D020851
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:27:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="eGczKoO2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A7D020851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 953336B000A; Fri, 24 May 2019 12:27:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9029E6B000C; Fri, 24 May 2019 12:27:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7CB1C6B000E; Fri, 24 May 2019 12:27:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF5C6B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:27:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c26so14863353eda.15
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:27:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5uGnJY6+WIJldncn5/DuJlJfSiMsN3sDHc0cFO6evKw=;
        b=F2MXUcEIoZV4WTaiN+a8iQmUgTA9+rRnEwEzKb9Loph8zyuVX93vRPSG/lc0l62nKq
         SsC4lGCWPlISeK2Kib+Rd+hGis+gjK4NdRu455XyQkfRgO++Nha1ukTn9uMrPHxqUZ8T
         Si3KFrHsj9DrwzpC50h3tUbM0wtlqGB2+R2hT/GVIRpdqRW7UB84AArjp4uIBxAMPgxI
         OjQYZb0bIcqfnWASo05TrwKmaGMV0UoH5ExUv7qBTKvjAmgPXekRX6Lk/haX7pwZmDON
         1ic+rYOyn+3tnOYRmVt9fVd0D22L+WZBSmYDHZWbuREGOcrFBcMZXpceC+hlpXBXwDmd
         uYqw==
X-Gm-Message-State: APjAAAWl3tAp7hR/P/7/HPtiTNcYaiQlwZeIMtCshKybNmBMsctjgyl2
	m3xlxSiAu1GUoIz6JEaUcpSyzA1mnASsCXwZXZkWPcUeSc1ADZIPuvmY+BLQWME9o3QGYwEo4fm
	PKSwOwfgcdBHiAUqOlfDhqFEazmXDc9m9aLn2fJ73xmVDaoO6JjlIqz2n2EBwoPfxsQ==
X-Received: by 2002:a17:906:4599:: with SMTP id t25mr56976112ejq.197.1558715234636;
        Fri, 24 May 2019 09:27:14 -0700 (PDT)
X-Received: by 2002:a17:906:4599:: with SMTP id t25mr56976013ejq.197.1558715233514;
        Fri, 24 May 2019 09:27:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558715233; cv=none;
        d=google.com; s=arc-20160816;
        b=Z5m0vuAIqOEm0UgXC2/+pFSjEj6xGGPfB1LKYUqVT4dKqAnErPaUVfdrAnNLDtjxM2
         TrM01nsfOHix/acRTU3F1soArurALMTpF3K0B9hChq48NsYNSXCZePhhs2mo9ySXmGNo
         JklGBwWWNC+YOA6vwa3fyr6LdEwh9ILQt6ix2PpLMLIrVs4cfQKYfBNJPfwuDSqwR+ML
         qmFNkGcYk7t20kjIfWLzsVtWJpJAC5KgbpafViyPVjM3FJmgsKqWJbdxCmUbbPAgO764
         5ofGypqB6R6v5ltntbdMlxzb4uDCmuYIX9Llle507Kj+k6YvBgpWlL3tTpiv26XVXWd0
         3imA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date:sender
         :dkim-signature;
        bh=5uGnJY6+WIJldncn5/DuJlJfSiMsN3sDHc0cFO6evKw=;
        b=JHuhgCsaWj4iU9i8LfWJCvEET1YuYds4XZ5Qe2Zgcn1PiLgXIHU0E4R++QJG7Z2MFD
         XmdbrWWsZNmqEnzpjMASyX3u7DQcO5Ck8FJyU2B0YplYdm0l1P0JU2Y0VZCg1gZ4eg1i
         rGpj0aQrdRVfj4ASYsXNkZeyFEep6SEbGHeQvVmikiFEtHpdgLshtFONbmyYjwcSL/RN
         mWJSe+tVK+2MBYU21Ou1FLzDPA6EKSqsuXwHyZS9DsNLYCH/X9zcvQ15leR5VlcQmPTr
         dXZ3VZ6KlbFGueaIdGu+BzURzr3z1JkBYgjnbv9KAPZw/vOZz0KAL4u0vTZ1S+OvUQKN
         TgkA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=eGczKoO2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) smtp.mailfrom=daniel@ffwll.ch
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id os17sor962328ejb.14.2019.05.24.09.27.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 09:27:13 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ffwll.ch header.s=google header.b=eGczKoO2;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of daniel@ffwll.ch) smtp.mailfrom=daniel@ffwll.ch
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=5uGnJY6+WIJldncn5/DuJlJfSiMsN3sDHc0cFO6evKw=;
        b=eGczKoO2oK1LxqRDUeq+D7nDJHBIb4XMUraNpLr4yOcOAsFgoTd33a5I2wq/sPLj5m
         cv4CL9Pysa7bfIL+Jn+vSSY2Z0bldZYmz/9YA39+pTt/iA6nk2Z39gXEHUQfsENbPGDq
         9COrk8k8zvaBOZH4FfeULv1UGUcPpYkvd+miQ=
X-Google-Smtp-Source: APXvYqz+Z4CiuIPAkdi1mB6lLRW1WTeonKTLCscAeQw4ulK7kt9ebJAos6eSJA0Dpqv9o1VxaTHnkw==
X-Received: by 2002:a17:906:6a02:: with SMTP id o2mr57101777ejr.164.1558715233065;
        Fri, 24 May 2019 09:27:13 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id m16sm418816ejj.57.2019.05.24.09.27.11
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 09:27:12 -0700 (PDT)
Date: Fri, 24 May 2019 18:27:09 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
	Dave Airlie <airlied@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Jerome Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org, dri-devel <dri-devel@lists.freedesktop.org>
Subject: Re: RFC: Run a dedicated hmm.git for 5.3
Message-ID: <20190524162709.GD21222@phenom.ffwll.local>
Mail-Followup-To: Jason Gunthorpe <jgg@ziepe.ca>,
	Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
	Dave Airlie <airlied@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jerome Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org, dri-devel <dri-devel@lists.freedesktop.org>
References: <20190523150432.GA5104@redhat.com>
 <20190523154149.GB12159@ziepe.ca>
 <20190523155207.GC5104@redhat.com>
 <20190523163429.GC12159@ziepe.ca>
 <20190523173302.GD5104@redhat.com>
 <20190523175546.GE12159@ziepe.ca>
 <20190523182458.GA3571@redhat.com>
 <20190523191038.GG12159@ziepe.ca>
 <20190524064051.GA28855@infradead.org>
 <20190524124455.GB16845@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524124455.GB16845@ziepe.ca>
X-Operating-System: Linux phenom 4.14.0-3-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 09:44:55AM -0300, Jason Gunthorpe wrote:
> On Thu, May 23, 2019 at 11:40:51PM -0700, Christoph Hellwig wrote:
> > On Thu, May 23, 2019 at 04:10:38PM -0300, Jason Gunthorpe wrote:
> > > 
> > > On Thu, May 23, 2019 at 02:24:58PM -0400, Jerome Glisse wrote:
> > > > I can not take mmap_sem in range_register, the READ_ONCE is fine and
> > > > they are no race as we do take a reference on the hmm struct thus
> > > 
> > > Of course there are use after free races with a READ_ONCE scheme, I
> > > shouldn't have to explain this.
> > > 
> > > If you cannot take the read mmap sem (why not?), then please use my
> > > version and push the update to the driver through -mm..
> > 
> > I think it would really help if we queue up these changes in a git tree
> > that can be pulled into the driver trees.  Given that you've been
> > doing so much work to actually make it usable I'd nominate rdma for the
> > "lead" tree.
> 
> Sure, I'm willing to do that. RDMA has experience successfully running
> shared git trees with netdev. It can work very well, but requires
> discipline and understanding of the limitations.
> 
> I really want to see the complete HMM solution from Jerome (ie the
> kconfig fixes, arm64, api fixes, etc) in one cohesive view, not
> forced to be sprinkled across multiple kernel releases to work around
> a submission process/coordination problem.
> 
> Now that -mm merged the basic hmm API skeleton I think running like
> this would get us quickly to the place we all want: comprehensive in tree
> users of hmm.
> 
> Andrew, would this be acceptable to you?
> 
> Dave, would you be willing to merge a clean HMM tree into DRM if it is
> required for DRM driver work in 5.3?
> 
> I'm fine to merge a tree like this for RDMA, we already do this
> pattern with netdev.
> 
> Background: The issue that is motivating this is we want to make
> changes to some of the API's for hmm, which mean changes in existing
> DRM, changes in to-be-accepted RDMA code, and to-be-accepted DRM
> driver code. Coordintating the mm/hmm.c, RDMA and DRM changes is best
> done with the proven shared git tree pattern. As CH explains I would
> run a clean/minimal hmm tree that can be merged into driver trees as
> required, and I will commit to sending a PR to Linus for this tree
> very early in the merge window so that driver PR's are 'clean'.
> 
> The tree will only contain uncontroversial hmm related commits, bug
> fixes, etc.
> 
> Obviouisly I will also commit to providing review for patches flowing
> through this tree.

Sure topic branch sounds fine, we do that all the time with various
subsystems all over. We have ready made scripts for topic branches and
applying pulls from all over, so we can even soak test everything in our
integration tree. In case there's conflicts or just to make sure
everything works, before we bake the topic branch into permanent history
(the main drm.git repo just can't be rebased, too much going on and too
many people involvd).

If Jerome is ok with wrestling with our scripting we could even pull these
updates in while the hmm.git tree is evolving.

Cheers, Daniel
(drm co-maintainer fwiw)
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

