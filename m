Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C86FC3A5A6
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 22:22:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3633D2064A
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 22:22:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="S5udK1mC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3633D2064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2DE16B0006; Tue, 27 Aug 2019 18:22:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DF856B0008; Tue, 27 Aug 2019 18:22:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CE8A6B000A; Tue, 27 Aug 2019 18:22:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0153.hostedemail.com [216.40.44.153])
	by kanga.kvack.org (Postfix) with ESMTP id 6ED806B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:22:22 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1EE1362CE
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 22:22:22 +0000 (UTC)
X-FDA: 75869632524.27.cloth48_4ed7fd909cd3c
X-HE-Tag: cloth48_4ed7fd909cd3c
X-Filterd-Recvd-Size: 4792
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 22:22:21 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id b11so709401qtp.10
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 15:22:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=O/Eb9Yv9aHdMVq7eZpOlz+xzQGez6PZaf9uMsvKFVSk=;
        b=S5udK1mCM17tEnM8qe/Euf0h6hUrQ+FsIrJswR0TUa9fPCRYoUQo2Bj0vFq0Fv5x7W
         brf7rtaaLWpCWBBcKPEArqo55P7LK9Y+3eaAJqaKFm9q2TqOIryQNcOTxeO43ahRyXMz
         +78BCiCK8tOS1KfOCv/vOzajMjclnKu+sqNB45ittMbYMfVVgnS3nM2+4LsDNk/3U5wE
         KGi8UiI7+GqWkinARDlIKI/eUAIOW3lDoAfSJWFqbiG0llZz8rTszgW14HlsyNgX7pzb
         W7N9EDComqNskKX+zkqao8RVYlPByzJ2Rr93KmNG9Ioy0A2C6bMSUxiivkfsaaJUAjXo
         HBtw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=O/Eb9Yv9aHdMVq7eZpOlz+xzQGez6PZaf9uMsvKFVSk=;
        b=gjFxI78UVAmMd8crXrX/vsC8LRR8fk+j3MHWZ0OewFeTm2VpMnNQIl6B60EgzmMaIE
         Vwnq1XlkZziFxUyVyy9nfLP1TyfbQnVxAOHy60m6gGZUE6fbnYvEsUcfSrsfHTpLXYY5
         OdhVv41S3eP8PixZ3t0cTHmeesFh4ucsU+AP6MRrpCahGZf9nOmgcw74CqKQdp1laL7g
         mSvhl2te/Tgb9I0jN7PIUGotUbEdO8dVhI0cDpP5HzOj+iN6TKqyUtfrcDpKM5CA7aoS
         fawOS83RiHR13KCy3s6+FbbaBb2SDGa1VSSqVSCJJ5+fk2peo7UOrk5Oop+REkcNl5pF
         KqBg==
X-Gm-Message-State: APjAAAWghdvs0r8oiRi0PCxSpG//yOszWy7N6DtNtbEWxDZM2bv7oxdM
	j5zjl8Gt74pENK2+QtLqVUXx5A==
X-Google-Smtp-Source: APXvYqyjufzPEUsNxQkLMwFYT3vRSJjpNbEwwYE37k3KlJ9jZ4hz+iVzDJ0578B4zjHZuy1e3Jd+Ag==
X-Received: by 2002:ad4:47c3:: with SMTP id p3mr808533qvw.120.1566944540997;
        Tue, 27 Aug 2019 15:22:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-142-167-216-168.dhcp-dynamic.fibreop.ns.bellaliant.net. [142.167.216.168])
        by smtp.gmail.com with ESMTPSA id y25sm408767qkj.35.2019.08.27.15.22.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Aug 2019 15:22:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i2jr1-00080x-Hu; Tue, 27 Aug 2019 19:22:19 -0300
Date: Tue, 27 Aug 2019 19:22:19 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	nouveau@lists.freedesktop.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/2] mm/hmm: hmm_range_fault() infinite loop
Message-ID: <20190827222219.GA30700@ziepe.ca>
References: <20190823221753.2514-1-rcampbell@nvidia.com>
 <20190823221753.2514-3-rcampbell@nvidia.com>
 <20190827184157.GA24929@ziepe.ca>
 <f5c1f198-4bdd-3c23-428f-764f894b9997@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f5c1f198-4bdd-3c23-428f-764f894b9997@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 01:16:13PM -0700, Ralph Campbell wrote:
> 
> On 8/27/19 11:41 AM, Jason Gunthorpe wrote:
> > On Fri, Aug 23, 2019 at 03:17:53PM -0700, Ralph Campbell wrote:
> > 
> > > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > >   mm/hmm.c | 3 +++
> > >   1 file changed, 3 insertions(+)
> > > 
> > > diff --git a/mm/hmm.c b/mm/hmm.c
> > > index 29371485fe94..4882b83aeccb 100644
> > > +++ b/mm/hmm.c
> > > @@ -292,6 +292,9 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
> > >   	hmm_vma_walk->last = addr;
> > >   	i = (addr - range->start) >> PAGE_SHIFT;
> > > +	if (write_fault && walk->vma && !(walk->vma->vm_flags & VM_WRITE))
> > > +		return -EPERM;
> > 
> > Can walk->vma be NULL here? hmm_vma_do_fault() touches it
> > unconditionally.
> > 
> > Jason
> > 
> walk->vma can be NULL. hmm_vma_do_fault() no longer touches it
> unconditionally, that is what the preceding patch fixes.
> I suppose I could change hmm_vma_walk_hole_() to check for NULL
> and fill in the pfns[] array, I just chose to handle it in
> hmm_vma_do_fault().

Okay, yes maybe long term it would be clearer to do the vma null check
closer to the start of the callback, but this is a good enough bug fix

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

