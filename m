Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A626CC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:12:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30EF52229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 20:12:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="hA9VncW7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30EF52229F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 757F78E0002; Thu, 14 Feb 2019 15:12:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 707428E0001; Thu, 14 Feb 2019 15:12:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F5B18E0002; Thu, 14 Feb 2019 15:12:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC158E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 15:12:35 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id x14so5115192pln.5
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:12:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ccxzyt/RMKZ2OOmgM+tFIm3eRFm02Zizg0pcCDEvEpA=;
        b=eXrTnKfRCyjgMT2iMd8cxhiN0EsQxkjYK2HuoFXCyrd582PZxdpVn6XNlPHyE3bm9w
         h5PqLYMk+OfjplZoua1cPvZtjn1UwBayVgpv1Fy+jmHq1S53orGCCqkx4BjcnIq4J/op
         qFABQHYAZ8kV+cibMKuSUEKALMKUBdGsBCY3iLkxutwvcdyq83RblJ+1Cm6TcHJCG8WG
         hgRmV1bJZEE+Ksk5FIaWsTQUieKL6BeQrtlLZ/tz312CckIL430W38TAcwdVvPDK1Lb6
         024TENFYfxF9CqGwWnxIABoMD3S8ymt0tA/W+PB5s+OwU1rKlnp9R6RhFc3mf07dBHa/
         wqqQ==
X-Gm-Message-State: AHQUAuZc0moWdgcKoKuOnvX4+WQojXAfyHSOJ5qjJ7IomkxZ9dGwdofC
	TJ2qARD+lboVCZi5DXZ4zhbj9zubFf0fSu99eQqVdmk/5J+IvHHUicq5koTZRBe8iTu8XCSc05P
	pN09kucsisS8dKbsBUnj3CeiKaeWgHTdB9c0yY3jns2DLqESfF4DovMpDoICYX713SUXTMUeQNS
	UGCj8r9pmo0ycBTgFKh/T58MXTWQHeQfkS2KF0rc9CizM5lY8Z08Du5o2vyZi6keZczVAuapHpE
	q6KKYnBy0AZ+yQZQbGuJtTFC1taJVI4gci2CdBp/ECmkEQkyabd6lOODzCJq56a9WmlH0iYNVyl
	W9zecqNla99FPrejtUyDI78p9ZgnX6FgIW/QUPspialXuWBqq17JKbgQY2oPihLvgxzjyNEM3Dd
	3
X-Received: by 2002:a17:902:2ae8:: with SMTP id j95mr6047277plb.292.1550175154618;
        Thu, 14 Feb 2019 12:12:34 -0800 (PST)
X-Received: by 2002:a17:902:2ae8:: with SMTP id j95mr6047222plb.292.1550175153886;
        Thu, 14 Feb 2019 12:12:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550175153; cv=none;
        d=google.com; s=arc-20160816;
        b=BFE8YNCV6ceZu8NAdw9LtGlZCKfisQ/VPJcqA9UAF8GR/fySAjQ0gvDOUKzfnQKN8Q
         ZpZca9zEw6GbzG1Tu9yuZRIc8ZYy13jszatihASjHhN+hTKwSLDQZdZB7e2G3WgPsvH5
         K9wXq3yAd2vnUd4T/ffZhTtNwvkSAchp+Dla2TU//B/Ww6ogpD9kVnLnm4DbanrWhjsl
         jcwbFWKie+Jt4IZb7wOGwOwRsqra5xgoMDd903RXDLYkqs/NM8shAdjVUQAtAzw2waCq
         +wzq9mW46frYI7DbmMzZVRJmUu5AnpJcN2828RrwLhF9OQB/fRb6BOYNI5BC6HxvlL19
         pDsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ccxzyt/RMKZ2OOmgM+tFIm3eRFm02Zizg0pcCDEvEpA=;
        b=vWEJC5rYD1iFyW5ckvISIinIFmX6nvCrEADY02JP2ztR4z3uPXgJLmYf/Cxk3QnSff
         VE/3bW3SXsLYWEGnfVOuFFi0/JIlvCRKhMXcPlN1xMMwEV105OmxUi4+n+2l4MvQxM1J
         NkddnYvS53AesLq+K6p/5bJiFDOgOb0nBED9QU+bpx2u9ohraxlI0DJkTAyMQmY6sqjy
         gDZoqWs2rHxBB6pzMyHz5suqEk9PPn+e0aI9L0ZmWYJVP2TcXQDTNAsr5VZu8vlb3g4h
         /yLwuP8mMAxhsVzlGIjZp7pEIguFinyjZpTSvluU3QQUXTWpl36wwRUyqLnqcv8mieCG
         RTaA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=hA9VncW7;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x11sor5721125pfn.58.2019.02.14.12.12.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Feb 2019 12:12:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=hA9VncW7;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ccxzyt/RMKZ2OOmgM+tFIm3eRFm02Zizg0pcCDEvEpA=;
        b=hA9VncW7abr9v+2utX/VkY1ZMwjjXa+hwVTodjREfjCiB0K7/Kc1hdBbZP6VIclrft
         XOlV/kBSodmvMnJmU6S+VCif2RbCUEwe4jiK021/ptlayI1p9QvtTplnf6hXcgW17wb+
         QnehE0OatJE+W6+9FVvKXjsQS9WlMlC81CJMTIZkDJ4RfuKrLjfzhp/2YUPNRFY/w0Lc
         aUTkEhbENTvNIWFJCqAuRCY2ROYZ4dZzB+xqdPWBbhLmA24jTl0pTqeeCY5bZatXCoQw
         abmHXi9B7hQUHXsFEubY8QrdE6yffwStU9kEa6Ykk1vfsXxhwe1xCEIBVbJx8CT9RHfQ
         tu1g==
X-Google-Smtp-Source: AHgI3IZWZ0MGPLsLn4wrH2r78+5Tb6L2fudxI7tZh+KJRQfM13M8w4S/vvhozZ+3+r9nH+nNGegkWw==
X-Received: by 2002:a62:a1a:: with SMTP id s26mr5944270pfi.31.1550175153085;
        Thu, 14 Feb 2019 12:12:33 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id q21sm8921770pfq.138.2019.02.14.12.12.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 12:12:32 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1guNN1-0007Ay-MB; Thu, 14 Feb 2019 13:12:31 -0700
Date: Thu, 14 Feb 2019 13:12:31 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
	dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
	kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
	hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
Message-ID: <20190214201231.GC1739@ziepe.ca>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211225447.GN24692@ziepe.ca>
 <20190214015314.GB1151@iweiny-DESK2.sc.intel.com>
 <20190214060006.GE24692@ziepe.ca>
 <20190214193352.GA7512@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214193352.GA7512@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 11:33:53AM -0800, Ira Weiny wrote:

> > I think it had to do with double accounting pinned and mlocked pages
> > and thus delivering a lower than expected limit to userspace.
> > 
> > vfio has this bug, RDMA does not. RDMA has a bug where it can
> > overallocate locked memory, vfio doesn't.
> 
> Wouldn't vfio also be able to overallocate if the user had RDMA pinned pages?

Yes
 
> I think the problem is that if the user calls mlock on a large range then both
> vfio and RDMA could potentially overallocate even with this fix.  This was your
> initial email to Daniel, I think...  And Alex's concern.

Here are the possibilities
- mlock and pin on the same pages - RDMA respects the limit, VFIO halfs it.
- mlock and pin on different pages - RDMA doubles the limit, VFIO
  respects it
- VFIO and RDMA in the same process, the limit is halfed or doubled, depending.

IHMO we should make VFIO & RDMA the same, and then decide what to do
about case #2.

> > Really unclear how to fix this. The pinned/locked split with two
> > buckets may be the right way.
> 
> Are you suggesting that we have 2 user limits?

This is what RDMA has done since CL's patch.

It is very hard to fix as you need to track how many pages are mlocked
*AND* pinned.

Jason

