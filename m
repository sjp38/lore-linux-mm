Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB9F1C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:12:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73869218A3
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:12:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="gB0ndMav"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73869218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0F6A8E017A; Mon, 11 Feb 2019 17:12:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E96EA8E0176; Mon, 11 Feb 2019 17:12:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D380B8E017A; Mon, 11 Feb 2019 17:12:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8E4418E0176
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:12:50 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 143so401044pgc.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:12:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=83DmjUWQh+S2vLB7v2POyWHbLsByc2zkoGWWNU6YAPM=;
        b=CxVYz61gEUILfgfdUd+YblUbZyNktd7Uwt2DC+VHmgm460xPSeYUa3ZdFvgEDS2G98
         hY1CJK52VojoIIshrj57FPB0MxnSLgdO8S+/+65z8Fwak2AqSgZRVpwl+6bhl5osuKii
         GG/NqA0Bl7Jq+F/UYlYnHfGl4ujSZijmOa3xp3bm0OaMG5qJ8QiZsfLT/UfS32LKjxQ6
         3vR5JMmI9DBKIOQTCMnIWoYqxi6lFRNgkKvR9RrvQzFUSZBlh9rCYId+Hyq19kE3ruim
         2PlCQaGQvMGiRtps5j89Mfc6a1Sf4N2a2iPt0lKS4eMrC0L7Bx1CVHLAQ6JLryDfd+XP
         Pyyw==
X-Gm-Message-State: AHQUAuZ7pQMyMaoquwP3OGI9e95deSat70LfhLqGpRsYYtTC0F6oQEcE
	FlcQVKdQvNtPzv+UdxIHxSuAfIw06Lh+Xno0CslpsPkFkIi2Sbqre0RW2Ty378GXLZ1Qn+JiXrP
	k4rAOoPrkfHqYV+s25TVffRQqHl8M/0xAJRYC3jK4UWuxo8cvGrkQgjZO41FNBBSZn8bh9gDloT
	2hiEPykDGOF41nvrW9HNpkHVpCyVZ2pYA/cHYg3ynzNflpTg6Hsf/CdrcxVPYmTI/FR1oTbcl4c
	faNZmDZuAm+DWjOuNmXk1RhUk46qJ1KQr7iMZYfYGi9CqbxcgFDY5twVR32sT+AdYLsNfvbnvCE
	UgEd/M0WwCEvoH8E9zEzc5oqAxTFu/YpECzIVVPz1u/UwSn2dBE0q8HzCESHXKM8euZ56BmPMK/
	T
X-Received: by 2002:a63:f201:: with SMTP id v1mr443775pgh.232.1549923170259;
        Mon, 11 Feb 2019 14:12:50 -0800 (PST)
X-Received: by 2002:a63:f201:: with SMTP id v1mr443722pgh.232.1549923169413;
        Mon, 11 Feb 2019 14:12:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549923169; cv=none;
        d=google.com; s=arc-20160816;
        b=mzWUiuSWJhSUN/DQmuu+6sKIf3fs16GgjcfcMiuAASkXMl24zMQV2bxQwt4BNEmcQU
         osY+nPYjZTzZH5RtDBkMxtzwG6NcUTNaX6JkjD21ybDs2iLqBaVPBsNCRJWis6nFuFjV
         YTBF9380uJjzM6pjOkVmmt6+E/7gNrQPg4j4p4smLisSBNjZzaQPG0OeybPjUnc77WJI
         GQKZ9HL8mF7Ni5Or8uVX1PH49o1r36d+pK2tXb1vQF9hrox//iJT1BeBLOHgn9zlJKKA
         TSTqDActrvGvvuGDVlkx8EgbvhtM1gChh32cJZlU/2GH3CIQaixSo+on5Lr6zXjb4udl
         XqEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=83DmjUWQh+S2vLB7v2POyWHbLsByc2zkoGWWNU6YAPM=;
        b=C/qIAVlmra08wm/Cd9TqkYUgQWE0c6FyWwMIhiHlKjgSbSe6+cPOL1DRXwW1MNm5CF
         L0iO2wMvAeeIimLkk8igP9Kqbwd3z2Oo7cWCZhoN1kzRUjeSMGgaIq1IQMGjwsc/bDCz
         24w/6ifK9vuf5tL0GNhmg/l/kwg8FL8DVJ/Cle6oCuL4qvVj8X2MkCNuGEemSIAdkiQp
         /MGT0Lscs4d4gWd+KpkDpazyH1Tw1IiJvY10eYCVBzUaBIqZHZm51IO98qHPSOoODL0d
         OZ2qg/ZYWYp8UTvdxJDj4TGTWPnWx083r1l/C5jY09nRQk2pvJk2SHX7dOoK1eBFDLsb
         Yegg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gB0ndMav;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 133sor15888825pga.67.2019.02.11.14.12.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:12:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=gB0ndMav;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.41 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=83DmjUWQh+S2vLB7v2POyWHbLsByc2zkoGWWNU6YAPM=;
        b=gB0ndMavIkmtshRqaMuUYA0IV/ApBgqnYbPjyksRq1BBJjKyeq3LdC/xG1McWcTeQX
         nrlUPXmoL33R57gJEqBcQ4NdMD34w4y3m0yMDrQGlSDTfgbKsfOmEqMasbZ+GUNniIGP
         iPHtdLQYITnYXmpZcYXwRjZHui/AFax+dob2kX9rjeHUXFLz6ZXwBcUQO/4e5aDvyKV0
         LwgEtSKK0gNgz29rEg+wZWEfCWyQJznN1+yRyy9VQ/zcmEefHlbtKLk1W98S+MCgHIAS
         dIvqSYf9XtGOoU5AasRE9cVN+saFPAc8XtMbQ8iNWY8Xe9lZj6ekrIQf/wSl1hBOx1YO
         0iNw==
X-Google-Smtp-Source: AHgI3IYuL3gkNFhcl4a2Z2bh9sUoL6/TO+kjHmUXHSIyVoNduGP/oKTcakRSgEJRoQjAbch4RqeuxA==
X-Received: by 2002:a63:1544:: with SMTP id 4mr475924pgv.290.1549923169126;
        Mon, 11 Feb 2019 14:12:49 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id m67sm19284132pfb.25.2019.02.11.14.12.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 14:12:48 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtJol-0003Sa-Rp; Mon, 11 Feb 2019 15:12:47 -0700
Date: Mon, 11 Feb 2019 15:12:47 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190211221247.GI24692@ziepe.ca>
References: <bfe0fdd5400d41d223d8d30142f56a9c8efc033d.camel@redhat.com>
 <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <fb507b56-7f8f-cf2c-285c-bae3b2d72c4f@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fb507b56-7f8f-cf2c-285c-bae3b2d72c4f@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 01:22:11PM -0800, John Hubbard wrote:

> The only way that breaks is if longterm pins imply an irreversible action, such
> as blocking and waiting in a way that you can't back out of or get interrupted
> out of. And the design doesn't seem to be going in that direction, right?

RDMA, vfio, etc will always have 'long term' pins that are
irreversible on demand. It is part of the HW capability.

I think the flag is badly named, it is really more of a
GUP_LOCK_PHYSICAL_ADDRESSES flag.

ie indicate to the FS that is should not attempt to remap physical
memory addresses backing this VMA. If the FS can't do that it must
fail.

Short term GUP doesn't need that kind of lock.

Jason

