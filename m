Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 340A6C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 01:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1927218D3
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 01:51:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1927218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85F358E0003; Tue, 26 Feb 2019 20:51:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80D398E0001; Tue, 26 Feb 2019 20:51:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D5D08E0003; Tue, 26 Feb 2019 20:51:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41D078E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 20:51:15 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 43so13885420qtz.8
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 17:51:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=q8XqxL4PqPU0hQgcOyjnn1B7yeQB9/rIidcTQno47QI=;
        b=S4VapMymW4t56Bso/vg8tEZX23q9ZNyWKW0UN9eygoihkdamL+BQoaaw9gFqN7Pbfk
         i4TrQgGLcyCv5075kQ5TcCxXMbcMFlB75bKDlS7j5JK2mTvfGMpVk0JfdiWSgQsx26WG
         /+Hfa3U8YAfq6ybIihpk3VtcnLhSsC1thEyIHvNXiIx8EuYrwu+JBuW8NpRPbvpNROSi
         kD0C2mysMQn2DPyzmzTU+7r7714ScF6OBvMiTUzwtdyIdXniDSxgzEpj5mVS/0NYYbds
         vzA0GiCt+7Jwrs3cm7hHWRztqt6YRd1sXNaW++voqPrNP0MaxuW/cYSBrTiHmisWWrKM
         wYug==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZL6fkqiq6Po45fFgrawEnpPAocwCynMC3O/yONxCYxuPnjGOm6
	RsGBjnNj5FhvaKVsaHFH8zIGHY9GhN4W8XCnEw4f23c7nsVD81WOQQ2DGHDR/ivTiGrwMIiZVli
	mVH8u2CPjiJgEEbYjplDYUh5afyp1cB0AmawSYx8O0XlzG0XVn1q4+zR5Q2klgLnjWw==
X-Received: by 2002:a37:a704:: with SMTP id q4mr391668qke.245.1551232275001;
        Tue, 26 Feb 2019 17:51:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY1NcreflujqjM1b93xxh2Ao/QXvZuTU5brz+K8kXHES1pbYsqKSfxP3IJmMVzccMe25dND
X-Received: by 2002:a37:a704:: with SMTP id q4mr391637qke.245.1551232274320;
        Tue, 26 Feb 2019 17:51:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551232274; cv=none;
        d=google.com; s=arc-20160816;
        b=i+ZLhbCYar7tU5hpmUvHvOAN+w0o3SWSbPIHZJ/Vl3BiIscZd6HjN5tPcKIyR001KG
         k89VRbEesexUlE+EAHJyeIdrZN1tfB4FQVoD+eKC9KR2I0Jp6g/zAcIf/+VFasfWw58T
         ejsgNizRHAeEv4/2l3cYTHDVKeP/YM1yOT8DEozjzpJq/PF/GU+zRYnHyqpdalYy4v2z
         2TMNdp7NfOqH/eMvXFhN9s4fgpsxATzDmgWzI5A3i/1nLDEaUmIse6L5o4b/Uoj/M/kN
         5pNapxQmuKEQF/crM8fvo7Q/MDHGEVu8GOR0d4kUhPlu9Ovq0TowEpvnGo6Zm9Udy4xm
         cbKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=q8XqxL4PqPU0hQgcOyjnn1B7yeQB9/rIidcTQno47QI=;
        b=lglSwOJf8qoql6xA7Ocg02Lq1nM6np8KJhxg/Qfi7CcYUQzy8D/RILqwRRihpFxsdy
         UTgfVJZMKgRuLCtV4fAdS1JXPu+Qnt+rmGnMRwDMrGrt789YSqiJtENrHPgsFw9sFLM2
         SdPdp+Elm5c74iCfEG5xGTCX0q6PjEQ7CEaGIQG4ACUDqdvVA2zrAuu9dH8xoZdQdlU0
         OE44X4or+e5AXh/pyUDQzXI5bILIf+pJclowx4gnu3G4f16oHDCe9wtMtm99UIXOaikV
         regZVgTKsb+fFBEy3osYcuIUZu4w2DRtit6G/O+JGwOEGtEfjH/Q8vfs0pF+Ip89xGcj
         qpxA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w6si3021854qkf.82.2019.02.26.17.51.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 17:51:14 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 679512FFC30;
	Wed, 27 Feb 2019 01:51:13 +0000 (UTC)
Received: from ming.t460p (ovpn-8-21.pek2.redhat.com [10.72.8.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 45E3D5D9D3;
	Wed, 27 Feb 2019 01:51:00 +0000 (UTC)
Date: Wed, 27 Feb 2019 09:50:55 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190227015054.GC16802@ming.t460p>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <20190226204550.GK23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226204550.GK23020@dastard>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 27 Feb 2019 01:51:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 27, 2019 at 07:45:50AM +1100, Dave Chinner wrote:
> On Tue, Feb 26, 2019 at 05:33:04PM +0800, Ming Lei wrote:
> > On Tue, Feb 26, 2019 at 03:58:26PM +1100, Dave Chinner wrote:
> > > On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
> > > > On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> > > > > > Or what is the exact size of sub-page IO in xfs most of time? For
> > > > > 
> > > > > Determined by mkfs parameters. Any power of 2 between 512 bytes and
> > > > > 64kB needs to be supported. e.g:
> > > > > 
> > > > > # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> > > > > 
> > > > > will have metadata that is sector sized (512 bytes), filesystem
> > > > > block sized (1k), directory block sized (8k) and inode cluster sized
> > > > > (32k), and will use all of them in large quantities.
> > > > 
> > > > If XFS is going to use each of these in large quantities, then it doesn't
> > > > seem unreasonable for XFS to create a slab for each type of metadata?
> > > 
> > > 
> > > Well, that is the question, isn't it? How many other filesystems
> > > will want to make similar "don't use entire pages just for 4k of
> > > metadata" optimisations as 64k page size machines become more
> > > common? There are others that have the same "use slab for sector
> > > aligned IO" which will fall foul of the same problem that has been
> > > reported for XFS....
> > > 
> > > If nobody else cares/wants it, then it can be XFS only. But it's
> > > only fair we address the "will it be useful to others" question
> > > first.....
> > 
> > This kind of slab cache should have been global, just like interface of
> > kmalloc(size).
> > 
> > However, the alignment requirement depends on block device's block size,
> > then it becomes hard to implement as genera interface, for example:
> > 
> > 	block size: 512, 1024, 2048, 4096
> > 	slab size: 512*N, 0 < N < PAGE_SIZE/512
> > 
> > For 4k page size, 28(7*4) slabs need to be created, and 64k page size
> > needs to create 127*4 slabs.
> 
> IDGI. Where's the 7/127 come from?
> 
> We only require sector alignment at most, so as long as each slab
> object is aligned to it's size, we only need one slab for each block
> size.

Each slab has fixed size, I remembered that you mentioned that the meta
data size can be 512 * N (1 <= N <= PAGE_SIZE / 512).

https://marc.info/?l=linux-fsdevel&m=155115014513355&w=2


Thanks, 
Ming

