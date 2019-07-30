Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E78CC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:46:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E9D9206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:46:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E9D9206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE8B98E0003; Tue, 30 Jul 2019 01:46:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B981B8E0002; Tue, 30 Jul 2019 01:46:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD5AE8E0003; Tue, 30 Jul 2019 01:46:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77F688E0002
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:46:37 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i2so31250798wrp.12
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:46:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=spsil+7VVo8vd21go/pFi3CKHWWLfFAPTsBOwVHoS8c=;
        b=cqF+zGhPgmoyhqBIldQp5VhgVnGPVQ57SWnoaxSEasCC7GFqfsi95sA38KqEuHcf0t
         7rSSOUebvGAaXp+V2bwCOClB23l1nNvyrz70FZWL50QelEiKTmuo1//UNfX8UVhQLYT8
         pbcTmi5LXyQMZnogwZYsJKqkTIQskbccVy7qx7LjkG21fK/w4PCSHJfdqRdlCkpLOUry
         9IDIGIqgvWKm7guhLoYsj4bVpYY3hK33dKv/6ztRi5b1QseVDAOM6mXid+8jxnjFVitN
         DKA9LLFSd+jAMlUJLJoQl+SWuMJHAdAV1tFQo+iINK1iJ/W7vgfQgOC288H28iLVhVJQ
         k6eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXJAjUgEkrhTFnB2vm7ZDvU0cDpycHbc8odc1rtTT1itPUY2p9I
	yYfxMZybSjvnPlR7UwoyOlp0ttDq0KUMbeX/tMUuPhgPkxvS46D17pFoyTtc0iAdv4DbGEAdlli
	DGapQYstLZyYJgnTbebts0acmBaNx41/saDqTJjBVqc/OZ7vpO65RSp2ThgBvCHMA7A==
X-Received: by 2002:adf:ea4c:: with SMTP id j12mr129692445wrn.75.1564465597016;
        Mon, 29 Jul 2019 22:46:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm7Px7ieH4ItHfM35fa0BZ6nGGmCgcfgEy0DnG1NegWiHsRZFNYw3SIzdj5I2/bwc3SwbQ
X-Received: by 2002:adf:ea4c:: with SMTP id j12mr129692348wrn.75.1564465596241;
        Mon, 29 Jul 2019 22:46:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465596; cv=none;
        d=google.com; s=arc-20160816;
        b=nvqYOEuauNm047LRLe6BH9JJtogZf8UFRr0qAoXyqVwha3nrOKH2gWr6TTYx2uNRce
         Pg48wDcRpK3Zk0zca1FAe+DOwhbjDGWowVwb8Va4C9PaYOXNHYkuWbm/13szx/UuShFA
         1q+AZQIOR5hihPtacwfHnv7ZFYp5rJimcGd6MjmRZmgwPFgujwQZOAxTrMITV6iJkS9T
         d+edPnF25YTNUb2SRtAA4dc6FfqPkLqhynQ/O7s8H7bR8asmg/AzlmPewV1bY/NPSENn
         +3qx32Hd+/otSqDHO9rJdGRI1OlENq+elMmgANf2zCJ1xttUEGgCMwhEPGHNltgC+jjT
         TSEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=spsil+7VVo8vd21go/pFi3CKHWWLfFAPTsBOwVHoS8c=;
        b=iYGA/gEL9KQJZilp7XydZvlmJ86KU7RGXSH3y01I1dZZjoapQsT/+6LhxvjqV/dTPE
         pauHixAOiyzp4DNcdGxQHx3C3PJcM8V6uodrB9g0mQ5khl2n32ruVFm0duGwh3KoJAmR
         D5vPJXtstX3QYnoecRk1EUtomdGJnnJTRjLAy/17ZrMkxRbxucMOl8UjvLQ0Xn3Ssj28
         ldclagP0OIZYPvdjY1D353sjhHEnTVPdImIdWrfziSYpAJDz1YtPvk9Pppmj2MAb7Al9
         RO9LAHBt8Usecdh8QGlkfoeavnbBRBeI3NMMGsFyudfLdRjJGQKhR30lniZkRC99ewcm
         knLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v17si59985301wrw.361.2019.07.29.22.46.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 22:46:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id ABD1D68AEF; Tue, 30 Jul 2019 07:46:33 +0200 (CEST)
Date: Tue, 30 Jul 2019 07:46:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 9/9] mm: remove the MIGRATE_PFN_WRITE flag
Message-ID: <20190730054633.GA28515@lst.de>
References: <20190729142843.22320-1-hch@lst.de> <20190729142843.22320-10-hch@lst.de> <20190729233044.GA7171@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190729233044.GA7171@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 07:30:44PM -0400, Jerome Glisse wrote:
> On Mon, Jul 29, 2019 at 05:28:43PM +0300, Christoph Hellwig wrote:
> > The MIGRATE_PFN_WRITE is only used locally in migrate_vma_collect_pmd,
> > where it can be replaced with a simple boolean local variable.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> NAK that flag is useful, for instance a anonymous vma might have
> some of its page read only even if the vma has write permission.
> 
> It seems that the code in nouveau is wrong (probably lost that
> in various rebase/rework) as this flag should be use to decide
> wether to map the device memory with write permission or not.
> 
> I am traveling right now, i will investigate what happened to
> nouveau code.

We can add it back when needed pretty easily.  Much of this has bitrotted
way to fast, and the pending ppc kvmhmm code doesn't need it either.

