Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 289BFC0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:29:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB2FF218A0
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 20:29:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB2FF218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F32828E001F; Wed,  3 Jul 2019 16:28:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE4E68E0019; Wed,  3 Jul 2019 16:28:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DABE68E001F; Wed,  3 Jul 2019 16:28:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id A16A98E0019
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 16:28:59 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id w11so1532297wrl.7
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 13:28:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xvSpZaxrbuLgtXnsH8gFg6oFV5rbwqCymBrMWW16Xz4=;
        b=d/ChjYopy+28lf1xJ6aJRGSN9Px2+wqzBq5/0q7eJ18L/WdMsfU+xVWPsEVLod0x6L
         1a/YVCUGQyc6zatOPzt4uQwYIuXiht1hu3BTfkzPoEO4ctyxw2ZCAgvPpbq4w62fTWHZ
         xbfd4tBdqmaYkiR+qbtTc6QzvsxFZED2D2HpWd7Q2rvDfHn+G9mmwge9fqA+dWdZpQ/q
         kHSct/vZCmyLpKo4u7qLnnYSKCLY+oBITJpP+pvwYE5FQ25+9kHKp6pd/sru39xwsCaH
         z8kIL4JXYWGsEfI7ACoxNUi2h7jEUx6mJTzo44wSxEjyDBcdHbiySTVPwLPB27Ezm2Yc
         jVdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAW+n9yBGiEC6xNOGfl1BuF9XmAO2mOO/7fm0om/OriE6ApWxC9H
	3mMY0vHHM+Oi9b4c5G6FV8zQbVRuQfytjlagIMCI9TJtbwOPGI10vDapGsy49SwxkcOG6kXL1Cl
	G9le8Nb+Qda48WvM7khFVpE/GoAw0thdClu7HcaKAcJNA1xEPZef6YDHsNHT80jnCFA==
X-Received: by 2002:a1c:a483:: with SMTP id n125mr8943186wme.3.1562185739262;
        Wed, 03 Jul 2019 13:28:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwWuUb10DxHthYZTPmz28gCJTQAD8BS4ha5FHlrlMuFPKnjDsbsClKICghpWUoWpoBFFZN
X-Received: by 2002:a1c:a483:: with SMTP id n125mr8943161wme.3.1562185738631;
        Wed, 03 Jul 2019 13:28:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562185738; cv=none;
        d=google.com; s=arc-20160816;
        b=Y1r/D9RKL3X3vDJ6by1OqQ0kpZRne2rIYysIRptJr32k7yFU4Cz38nXweAXeRFGrvJ
         UleUxzDgz6s9erw4ojSnuot/pP2eulm6QsBhGVNm63yjPoPEMljCSjaAadLzGR+0dRij
         xE77swbCuvXkkV2Iw2rtJiuIL6wUk6RC/tSAXA/ssmYQlp0nZwvn+/wNmY2WciFjZPAz
         zhlltwyhXeJ4PL9tr9GExcYir6/Vx4m+Id/B5sSf1Dchud6pRxJ+gKwNwtUlHfnZKZJX
         qoDalTHqgk44oE7L+57e/b9waHvM0amgSJTKVTBbiH5zioILWlMf3GZjeqMe1BTBMHks
         IMEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xvSpZaxrbuLgtXnsH8gFg6oFV5rbwqCymBrMWW16Xz4=;
        b=DRYqYvUAX0eD51nalK/0kJU0LcztAFvUTCL+os62b4nDwtdXr8couHza4E5divYk2R
         7vhT7O1zqRZ5zFgwNZc2ktCto6W9TMoHRHE6zv6p9RxEj8+TDLQLbfkOzGa+j2zSieVM
         pjqWJW/IDEcCDvWnFMvXxKRHOnbf9XqiAic4cQBPC4/4fCt1xnzwYXEazjbXaI0pekYH
         FO4VGb11umwoSz53eTVyUUrtstYhXOsghxxBgRi2ifFm5XTtlXn009e13lF7uPVM4L1i
         VKHJy6huJLaW8t44biJnSs/2OwPQEWx+S/rrNHfsE5PQbg/V2S4+9D+LScMfwmJu5hsn
         ZhIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id e14si2611907wro.156.2019.07.03.13.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 13:28:58 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id BA28168B05; Wed,  3 Jul 2019 22:28:57 +0200 (CEST)
Date: Wed, 3 Jul 2019 22:28:57 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH 1/5] mm: return valid info from hmm_range_unregister
Message-ID: <20190703202857.GA15690@lst.de>
References: <20190703184502.16234-1-hch@lst.de> <20190703184502.16234-2-hch@lst.de> <20190703190045.GN18688@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190703190045.GN18688@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 03, 2019 at 07:00:50PM +0000, Jason Gunthorpe wrote:
> I don't think the API should be encouraging some shortcut here..
> 
> We can't do the above pattern because the old hmm_vma API didn't allow
> it, which is presumably a reason why it is obsolete.
> 
> I'd rather see drivers move to a consistent pattern so we can then
> easily hoist the seqcount lock scheme into some common mmu notifier
> code, as discussed.

So you don't like the version in amdgpu_ttm_tt_get_user_pages_done in
linux-next either?

I can remove this and just move hmm_vma_range_done to nouveau instead.
Let me know if you have other comments before I resend.  Note that
I'll probably be offline Thu-Sun this week.

