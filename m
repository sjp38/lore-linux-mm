Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEC3DC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:59:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 880F421880
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:59:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 880F421880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 219D06B0006; Thu,  8 Aug 2019 02:59:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C9D96B0007; Thu,  8 Aug 2019 02:59:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BA556B0008; Thu,  8 Aug 2019 02:59:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B3A956B0006
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:59:37 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id l24so44759059wrb.0
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:59:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4PGz37ROPIjgASVITDVN9LnvP6bYDz+C4QCRlM2A9h4=;
        b=YAEix+wqbfveaagQVrJ1Wa02j0fgeeOhpqrG6CiqaVB17nXGs6jpKsBjULasXdpa4n
         +5GzK0QLb4dly80LymcEQg+dAkxXWRlfLJ8qgqMJH9EKfCwRCjkr8Wlt2oqc3i9usq6F
         IpANDsmCJxiWTcL/eGFn9+ip4Zfrlt8Qz09nXYDfPRppnxFqRtI0e1cxi4xVz+O4CExe
         UAfqF+er52aYb2+AK4M++gxbGiY887oGzJxNqEVyf61AZaCuZgbNnIDXsX1uyA9EzaRv
         gktPfjkXpRYZx+FKBdYi5ZH+gfq+r8HZsqonT+fflsWKqp3A2ZpdBv0RcHLIqqQVyPFE
         1I9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVCkqbokyx4l9HqycYQfQqkvOnBDpeH0zjmx3nveSPFIUuTe36/
	qSgmubvWd8kniKG9DIslKm5E9yA2Z7hoyx5x4lG1L7p2kkXjqu4f/FReAxjYou00XoQPjyap8d6
	4uZzobqfNEzakGZkYMZCT87UEz6QbUx/9WehLBorbjFxep2UpWiZo8L+dXuvO0X2j3A==
X-Received: by 2002:a1c:2d8b:: with SMTP id t133mr2399177wmt.57.1565247577312;
        Wed, 07 Aug 2019 23:59:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvGh4kJnz66jIpy2jYPLBTSC8Onj0D+CCqqL5YB8fGUBMRG2CcHbPo2mJskDevtImzpcuv
X-Received: by 2002:a1c:2d8b:: with SMTP id t133mr2399110wmt.57.1565247576451;
        Wed, 07 Aug 2019 23:59:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565247576; cv=none;
        d=google.com; s=arc-20160816;
        b=Ev8jvFZM9xy+5LyA5j51V9C5LBrt7qDW8umVYzaQTO9A6dOMDUjPUI8yfL0BCD810U
         hpnfH1GnvBQJt+b3eJvogglB2BKBDLyZMvNZBBvvw3uXDxR1d9O3PO2p2q81tdn9p3yh
         QyRWQPHsWlbECBauMkUbUQQfCjA0sUGTWQVezxWFJtJvAj7M4RkEKXuEs1dPdMdf9biH
         v7f5bzooqOrmNM204VKGWFPhc9ni6o+wn/wP/xCEZfFMLKMhuh9wDfxhF/VlgPP1CtkF
         5v2Cm839kfTNshwfbOv0sgNMLGddpVUoCYt+CIty0zIJ6P2MNAAcUR1YivSvPUI3XAuF
         e+sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4PGz37ROPIjgASVITDVN9LnvP6bYDz+C4QCRlM2A9h4=;
        b=qSW9PDBv71cpg6ROel2z2/6A0T831P6XaqBAibtN33nHl6/KZPCscOzqjqpQ7P5Jnd
         e4bnlnea3FoKoc/2YX+1yJFdI7DGmymLkgTOJReUElg9ZijhvE4pTqo0mfqr7ZJVzLcx
         uTg72/IGoeEqdp8vvhmWt8sGArGX3sbC7+jUpdUliNFG86Q4Iav0pSCf8WA8IobVmCem
         lCBo+KfUWWpW0uwIOnawIVuyAeBvEodVvZL5bHaTEK/XNVhtsHxG2I1Ps7Q9Idcu4dUy
         GPTwsM+LIn/5C+QpyPKAZ+kjfKmPB0W54UdRyZrjG83wjMttrr8tQLjnd5muXwO+5lzq
         iflw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d8si2341962wrm.74.2019.08.07.23.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 23:59:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id D398268AEF; Thu,  8 Aug 2019 08:59:33 +0200 (CEST)
Date: Thu, 8 Aug 2019 08:59:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct
 hmm_vma_walk
Message-ID: <20190808065933.GA29382@lst.de>
References: <20190806160554.14046-1-hch@lst.de> <20190806160554.14046-5-hch@lst.de> <20190807174548.GJ1571@mellanox.com> <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hPCuHBLhSJgZZEh0CbuuJNPLFDA3f-79FX5uVOO0yubA@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 07, 2019 at 11:47:22AM -0700, Dan Williams wrote:
> > Unrelated to this patch, but what is the point of getting checking
> > that the pgmap exists for the page and then immediately releasing it?
> > This code has this pattern in several places.
> >
> > It feels racy
> 
> Agree, not sure what the intent is here. The only other reason call
> get_dev_pagemap() is to just check in general if the pfn is indeed
> owned by some ZONE_DEVICE instance, but if the intent is to make sure
> the device is still attached/enabled that check is invalidated at
> put_dev_pagemap().
> 
> If it's the former case, validating ZONE_DEVICE pfns, I imagine we can
> do something cheaper with a helper that is on the order of the same
> cost as pfn_valid(). I.e. replace PTE_DEVMAP with a mem_section flag
> or something similar.

The hmm literally never dereferences the pgmap, so validity checking is
the only explanation for it.

> > +               /*
> > +                * We do put_dev_pagemap() here so that we can leverage
> > +                * get_dev_pagemap() optimization which will not re-take a
> > +                * reference on a pgmap if we already have one.
> > +                */
> > +               if (hmm_vma_walk->pgmap)
> > +                       put_dev_pagemap(hmm_vma_walk->pgmap);
> > +
> 
> Seems ok, but only if the caller is guaranteeing that the range does
> not span outside of a single pagemap instance. If that guarantee is
> met why not just have the caller pass in a pinned pagemap? If that
> guarantee is not met, then I think we're back to your race concern.

It iterates over multiple ptes in a non-huge pmd.  Is there any kind of
limitations on different pgmap instances inside a pmd?  I can't think
of one, so this might actually be a bug.

