Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24346C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:46:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E24952087E
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:46:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E24952087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 827538E0005; Thu,  1 Aug 2019 03:46:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D7BD8E0001; Thu,  1 Aug 2019 03:46:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69F668E0005; Thu,  1 Aug 2019 03:46:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 356888E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:46:19 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id v7so35090028wrt.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:46:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sTc0E3ysbgmn+npdW46ezm0Yr8ZyVN2zGAo5+I1SwMk=;
        b=JdqXjl4bXHj+g08X3/3x3ztXyqQ6FoPVzxhkUyAGmqHA51CKLP6ozwS2I6bpWFLYPg
         kvwl7diyiSD4uAUNnUMyRQi0wFS99BP/3nRF+n5Fxs5YA1RoPdqWWUiC0tftGsuyuYSh
         +imKkOe/M6pXPgmM3IuqXpJyYiSjnUDmM+TXQM08P7n0MGaOSGjCjibpXKCYRkfzTg2M
         +SR5k7aCJngn7BOhI6V7law0zIbQl7dRwteBHm3NBjkbfDGlffELtX3GwEAD2um0zdES
         vhN6co/xUnaSnoE/Ow+yKz6ML8m0HNxrATV95KMdZpni0Anc1KmoHrIXM+Zuz0BfRCjv
         gLnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAV0d6bfzPxe8DRNi3UH/Z2LztolaRgCwrAsa8HM5AXJcQaGqa9w
	QfY83WOQvQbECOmoWa6vezrLj7A+HfCO9mcj3zVsiNQuuyI2zNAN/A7d41TTG8bk9di6nQXO/1V
	ern8TQs9Orp81uOuPndCqzEh8I4VvMx2LPCRPg28dKoCQ3r7e3+GIQvex8QdKlIHzdA==
X-Received: by 2002:adf:e843:: with SMTP id d3mr91915066wrn.249.1564645578804;
        Thu, 01 Aug 2019 00:46:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCcrbvvzJVe8+NSLurgyzQTJvjxwKPgRlI3OEZus3dHNgroFh41eVfMVZzbrbthy7F2Kss
X-Received: by 2002:adf:e843:: with SMTP id d3mr91914975wrn.249.1564645578078;
        Thu, 01 Aug 2019 00:46:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564645578; cv=none;
        d=google.com; s=arc-20160816;
        b=ReRdoydHonAyBSHw+HODHCw+L0a+fQ0tk7hpDy6W6Ccu2V+zfkuRdYZetLsT78H+R1
         yUitIVHqPel64XyCBkX8NKt/+79+fMcPy7Zlxkh0tGs0I3TeMkuPE3sqAumQ0FgBOZIi
         4ThpJyTvCU1fYwdVlCc0Gh6+0tCUdqLZzjfhchz8zP2095EY7R34RzixpkdQYZ88mkuh
         D786caIy6+kSV264au3vx6yfXdYQZczRCP9WnWpCj0kXAOPvTpg+pBXiVfLIyySkySra
         FyvKiZkhQgPfBVPwrb7Gnw/lqH3d/13y5FpDk6JUVYLaeGkikLmE4qA0Eej+u0hbzpI3
         /WAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sTc0E3ysbgmn+npdW46ezm0Yr8ZyVN2zGAo5+I1SwMk=;
        b=mh+iLSp6+kUi7pns+JrAQ3NKZtGI0EMVQyPajhZsNq7+TrdiTQhcExFEcDAdVGkNfx
         fANSGqabpRknEzab4zjFm4Xk7QcX10e5wolrFbla1DpYqwADgnEbWrH9H4kyclB5JqSI
         NSm1ePdwXrrV18dovB6gEM7TBAdTo4pHTlEbuMS2xREubHaKbERzkHgsm4J9yyBkRIIk
         QF9YjaPM1s+rqyIRJOiaC9oDokON9JWX6HGG4nESi2s3B8ALcxdnT6Pd2RBlriwGxoZ0
         0+uRnvnPK83cvpjg4pNeQtFJZ5qhkBqASKkmNyW71Soeg8G937PPN8D9SiUxHNUbe0BP
         jG8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o2si53393816wmo.175.2019.08.01.00.46.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:46:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2CC4D227A81; Thu,  1 Aug 2019 09:46:15 +0200 (CEST)
Date: Thu, 1 Aug 2019 09:46:14 +0200
From: Christoph Hellwig <hch@lst.de>
To: Bharata B Rao <bharata@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 5/9] nouveau: simplify nouveau_dmem_migrate_to_ram
Message-ID: <20190801074614.GC16178@lst.de>
References: <20190729142843.22320-1-hch@lst.de> <20190729142843.22320-6-hch@lst.de> <20190731095735.GB18807@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731095735.GB18807@in.ibm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 03:27:35PM +0530, Bharata B Rao wrote:
> > -	kfree(fault->dma);
> > +	return VM_FAULT_SIGBUS;

> Looks like nouveau_dmem_fault_copy_one() is now returning VM_FAULT_SIGBUS
> for success case. Is this expected?

No, fixed.

