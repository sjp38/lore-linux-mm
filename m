Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 36E2EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:40:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E79A521850
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 09:40:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="agGczCTy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E79A521850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A9776B0006; Wed, 20 Mar 2019 05:40:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 959E76B0007; Wed, 20 Mar 2019 05:40:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8497D6B0008; Wed, 20 Mar 2019 05:40:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 459DE6B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 05:40:36 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a72so2003922pfj.19
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 02:40:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2ilZdXEgKQl8eu/If6oZwzfIDgI9nzN5u6h3xxR7k4I=;
        b=XLBqDhOt6NYJWWK2a9LtP0XrAQ/dgd70UvPAG8gOj918asiHj34WSuJFyfBtmvkjOa
         sUT13TPBcZ4zM4wiydFkGsLtyKoGx2ypgNVA53cgH7y2timp66+gzQIgSXrB4WFag1b2
         9/CpD2fNlKDTMDeqzJxTkNO2T262joD9o2QehfCMDY0IcP6OK0FJ7ua7d8v5uc1o9l4L
         813fy/tZl8Urz0T7VKpEg5WA8Je5m5VKkOoGgVzvcFnutsDoUVPbuov659IkAl1hGeKW
         vLYYqjevtnvovvOTCNqq4qLo7LZOmq8d16BuSUV6TXmOfpM8462mIqJrlAqUMs3YiavI
         HlOA==
X-Gm-Message-State: APjAAAWcqAyRKLw6iPYXFIL+XdhhXHpfQAbuTLNqYlNcIzEab98yMGt6
	2a8PnQVwWwuNUnXhhOCtwKFgDAgchEW4CcxITVIt6JpsL8ydfUMgsYhSej6Zchp3vfpdx3KSjOl
	wXpGVmisM+EqERN3Q93t/11jorzCsa2vRM3fp4p5mrZRL6ok4PTHOgW7NBjaBtvBb0g==
X-Received: by 2002:a62:69c3:: with SMTP id e186mr6520309pfc.169.1553074835890;
        Wed, 20 Mar 2019 02:40:35 -0700 (PDT)
X-Received: by 2002:a62:69c3:: with SMTP id e186mr6520255pfc.169.1553074835052;
        Wed, 20 Mar 2019 02:40:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553074835; cv=none;
        d=google.com; s=arc-20160816;
        b=0zdvEqj/zEK5DFWNn+TK7ELu2Vu+JVDuOgmwK+Yckphl+g3+ACP9xNzIyGzkA6aW/o
         YOnSgPGp/FkcPvMowstE+2VfAahPeepOEeAulUKGdahcm9ByBEYGiYyy0zjqZi2cZscE
         mIT0fzPXaQJDtdFoUCsYL0BdtWUSczlHM3XeuEJuOk3e8Ev/e+rKf2IdB0HjnDIWCdI2
         n8d/MkpTyWR/BOO/iirTK6pdleoa1xO97BPmrZJgqrjVZZzeCJKrSnBQKR/jM/mQlwXy
         01/7MHnJ2FODBiO8PqK//lH+4JE3qpdGJQugc6Dr6Fi1D4+JTMZ7dBFHpvh5ZkWu1MFk
         zgsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=2ilZdXEgKQl8eu/If6oZwzfIDgI9nzN5u6h3xxR7k4I=;
        b=d7myxeRK8x1eRd2nT15M5VgBT4fYVi6lHgkNIO9q2yzy+G0w3oZLJllow6Q+RH04MF
         slsmkrrEAtrxv20j+22sf8ldBPDYT3JNZb+8yW5Ij9vyn/KREsSAIe9P2/NUZYvCBZoA
         BBi06yROm1iV0++aKa2ZfD05584o/lerYpvUctnOKQ1VvW1wy6axkUL4w99cFhDJctn5
         jvIkzKtjZAZeJLswsDjF4BsNOk0Qfe0h6uyuHpNrVpFT+Vu/c1pVHVoboKS+lzR17pVi
         PnVR3dVVEBOXbLnq19RhDE5rBr/OmBP/bI7CcwTivdGrdAUhW9tAt4mGxg6Xu6b9jVkr
         KJ+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=agGczCTy;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e15sor1586834pgh.79.2019.03.20.02.40.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 02:40:35 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=agGczCTy;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2ilZdXEgKQl8eu/If6oZwzfIDgI9nzN5u6h3xxR7k4I=;
        b=agGczCTyVX3YbxtbNXvXDU8mq3XwNWH9k0ijzWdCgnWmZ24E6MXUuKm4fIV2Q58fjO
         rOmnT42x6IFqOMRyniVzVvrcvEdFZuh29FVdN73buc2fLd6c9XSGSU4ekUwdIRP9w0jI
         TnG1CjqVJaKfsNBHua+/pXoacxpFw/skgnhdL+ii6OjDFsLZhdTCVeT8jAXx0g6s32ff
         uOpFM8zsMkWdQ3UMLwxog6cqiiP4a9Wn8JCr/Sm942GLxVQsp/kAULxiT5dKNnnH46Xj
         PRBqmL8qznxMJI3VqLWDQ45wB8rzfg+CagDnTAavLEuE4SvWjzHy/VzxJQpLMF3zACQ4
         92wA==
X-Google-Smtp-Source: APXvYqyRZpQfbFJVEpRMID17XPrBgMkhW+bQ+/Tdq95pUIU9dvdMgO/DYyin4FL9ZRNXRc0CEIUHAw==
X-Received: by 2002:a63:5515:: with SMTP id j21mr6551236pgb.244.1553074834713;
        Wed, 20 Mar 2019 02:40:34 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([134.134.139.82])
        by smtp.gmail.com with ESMTPSA id 10sm2608365pft.83.2019.03.20.02.40.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 02:40:34 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 47B4C3011DB; Wed, 20 Mar 2019 12:40:29 +0300 (+03)
Date: Wed, 20 Mar 2019 12:40:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190320094029.ifweqx4wowyyr3wi@kshutemo-mobl1>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <bf443287-2461-ea2d-5a15-251190782ab7@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bf443287-2461-ea2d-5a15-251190782ab7@nvidia.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 12:24:00PM -0700, John Hubbard wrote:
> So, I could be persuaded either way. But given the lack of an visible perf
> effects, and given that this could will get removed anyway because we'll
> likely end up with set_page_dirty() called at GUP time instead...it seems
> like it's probably OK to just leave it as is.

Apart from ugly code generated, other argument might be Spectre-like
attacks on these call. I would rather avoid indirect function calls
whenever possible. And I don't think opencodded versions of these
functions would look much worse.

-- 
 Kirill A. Shutemov

