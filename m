Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6842C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:06:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CB31204EC
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 08:06:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Kn7zyiwF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CB31204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 088F66B0005; Fri,  2 Aug 2019 04:06:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 039846B0006; Fri,  2 Aug 2019 04:06:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E69DC6B0008; Fri,  2 Aug 2019 04:06:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id C89A56B0005
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 04:06:21 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id f22so82319621ioh.22
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 01:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=oQGkgX+xjP5mcvxvnZUNTJDjzsROZ8JGq6RAdmO4uPA=;
        b=t1lso6y9d2ljDdkFQHz51jEQj5xrkh8EBwpL5x+ytLyQ55/Uq6fAsucmTk1rN33DoA
         F+pGQfYpMhJ4T6NKWOlKTBDAMk/eemC+YXKh4QHJ3z2OenVtxlQw8qkEddNpdtKJggnV
         t0ATy1AYWC5FjlsY5hlbSy6i9/4SMTDJt4DTJrKTrnM54DEhDiCmx2SOs2rcw9FUUeZf
         dNpm6Z+s9W/jrHS4rUDm+RvhMsqgOHiAlbmPqb/zN2PPnaFOmVxhmsqU5kArBp4xfB0v
         eTvke3hs58Z9TzovCOT3+b8R4yDdcaaHfSxt7WBxRrfrAZNW7Ak9wkhT0mFBUw8zEFVW
         UzsQ==
X-Gm-Message-State: APjAAAX7vvAbiZe2j+GP1l1B0xqGNzxkiBMLsYVBrReZxkvM6B7RsHlJ
	W0i+aCNNImNoPyiBaBe/3aTUgB2ANcI6cFyKo1e6Ua/9UExDbiOh2kLXGFYO6fun4XLh+Si6MiO
	+/Po6XjO/vhDB0t0WW2JnPNhiK8RJoM+3HwqCizjqiNAfQYOnjG2KXV0+tpHFA/Or1A==
X-Received: by 2002:a6b:6310:: with SMTP id p16mr9639427iog.118.1564733181436;
        Fri, 02 Aug 2019 01:06:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypwPiMKuYSdF5YNRxStfTs0zjYkU5sXxwH9Ko/dqpFzOiIxZDAvH6k+ZwF32zRCHROtRxY
X-Received: by 2002:a6b:6310:: with SMTP id p16mr9639386iog.118.1564733180915;
        Fri, 02 Aug 2019 01:06:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564733180; cv=none;
        d=google.com; s=arc-20160816;
        b=wAebPxGLouUoqjSw6aD1g3gr4Wsx5nWbxOMSiLFP7N2DhioNhvfp1zX8M8NVf95PMc
         Ts8AxFp+S1T0jv09EFkULbqolvtGeIkCH2T3+tfNi++S3Stf+jxlp74bL+KikAY/TpXe
         8yjKps7j96TfegnoFVehEkWK4LkSnsZeASdoQdRi1/NF/HUaSjmrtKXNiPCktaEzJAnc
         C2FR4Hm1fXGelB2Ok/hWddIJ4wFqEyDZNHrRUzjtI1i8D85/huJw5sUAaoMq2ly9UmUK
         RWisUdczkcrcAAar2GBSw19pQCw9PfHMPmToIo5eeN+F4n7tnvxJhYuFIBQxRW4lGChS
         LP7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=oQGkgX+xjP5mcvxvnZUNTJDjzsROZ8JGq6RAdmO4uPA=;
        b=YMwg5p2Kande3YnpYryLQu+g3Jyq/nHzxh6t4uzypD2RNWD8E7OcDJS8qzZeTjrGv9
         1/nuaIahbRCDkPyafVd7lq9XxH1x6uRCuaCTHgzj7UYS5Pyv0U7XrXVtAo+nmg4R29we
         j1CX1q/Cx18NmUSAKc/afbHd/A+vRy1C70b/9Ycjtj/Yq+uxyITaRbfw9U6bCFBJFqms
         WeFm0hBY1kqyYEzHBkrKsAVi41GvDhnrmGymnjLfmjY5B8CFxzAY01ufk4TQHy0v4Wwp
         /sgq/DeQiDPG+or15Rd65mYwOYZvuL29UzTeAnWMierg8haruy8b9xyIKeEXL3mOvJ3s
         lH1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Kn7zyiwF;
       spf=temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org ([2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id e124si94974808jab.5.2019.08.02.01.06.20
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 02 Aug 2019 01:06:20 -0700 (PDT)
Received-SPF: temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Kn7zyiwF;
       spf=temperror (google.com: error in processing during lookup of peterz@infradead.org: DNS error) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=oQGkgX+xjP5mcvxvnZUNTJDjzsROZ8JGq6RAdmO4uPA=; b=Kn7zyiwFYY1w4GG19f5Z+fxXG
	rpdCjyayz/9gviyRYspgLpeSBWC2GfVoCY+63/ODQnmLa1Ss8JkqUpftu3V0chMAiw/KlU2kDYgEh
	oR5YKgy/zWb5/EAWdvNxCcTyybQ/h6IZloFk2u58KpdWjALZ6VxSlYgO9NyD6ORVH0k4+/SJs5gc5
	s9u9DnNkq+UczyxB+jcY/9wLHc7m1xooYunausG0HwlgSx5YAgAGjYk+/D776D8302Y3gySch17HH
	NqaNqFjlPIzia2+bWk3vao3mV6/a02u4eJ9MN9jE/yE1oy7yiEOCMpBpQIwm2mrZk60vD3Q8D3Ve6
	97+ImnTKw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1htSZZ-0007h0-0W; Fri, 02 Aug 2019 08:05:57 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 8B3D42029F4CB; Fri,  2 Aug 2019 10:05:54 +0200 (CEST)
Date: Fri, 2 Aug 2019 10:05:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: john.hubbard@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
	devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
	linux-mm@kvack.org, linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
	rds-devel@oss.oracle.com, sparclinux@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 00/34] put_user_pages(): miscellaneous call sites
Message-ID: <20190802080554.GD2332@hirez.programming.kicks-ass.net>
References: <20190802021653.4882-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190802021653.4882-1-jhubbard@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2019 at 07:16:19PM -0700, john.hubbard@gmail.com wrote:

> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions"). That commit
> has an extensive description of the problem and the planned steps to
> solve it, but the highlites are:

That is one horridly mangled Changelog there :-/ It looks like it's
partially duplicated.

Anyway; no objections to any of that, but I just wanted to mention that
there are other problems with long term pinning that haven't been
mentioned, notably they inhibit compaction.

A long time ago I proposed an interface to mark pages as pinned, such
that we could run compaction before we actually did the pinning.

