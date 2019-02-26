Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AEC8C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 03:02:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D662321848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 03:02:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D662321848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BDBF8E0003; Mon, 25 Feb 2019 22:02:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66B8A8E0002; Mon, 25 Feb 2019 22:02:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55A498E0003; Mon, 25 Feb 2019 22:02:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 106668E0002
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:02:20 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 202so8556478pgb.6
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 19:02:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=D0hbpNV9TNJ54bvZJ9hz7IwWoYayd/Vx+bDcG2Q6Kwo=;
        b=uf8wtpw6GrgtyPXw66b29p08UX5ZWSOK23ZPni2uIOdfWTQzqGZ6e5z45M+0MYzN6t
         L7+HhbfIw8HWKyCrTQ7Sb3rPqtNgNC8EwOzCWBh4KTuQuuk8vvDU6gW2yABEiEAHAI/M
         nWSqasGunde3MqcP3a8zh9n/v/mvpz4vXoiEXGWjKJl/B7unDCNIv4apbaWRROdA+WJ7
         yrW+a+XTby+UQ6kSWmR2QhHH5kkJWVdSNr7X9ogTjyU/gMejXVqphTtn+t3FlGY+cCOy
         pafwrfUp0zNWAlUV9F+AslDlyBMSf5eiD6sNyHR5hCHXNK/qL8tEI5KXz5uXQ6+FVv1f
         BnNg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuaiQlWkHchRl1tInFg/Zrg66YA2BE2YWz5xOn7mK8Urlaph5hjP
	KsA3BnDYAVZnQNKAASKmuV2P+Ll5pBt+PlPc7U1hzzGHK7bi4oDW/bCzfpy7QwsSfQ5UZJSMiOZ
	RhHlc/66/SKPRev+GRQI4CVq+SfeW91j0QLJNgCw5ZJQAnUOgWeanX/K4DFmDPHw=
X-Received: by 2002:a62:64c6:: with SMTP id y189mr23956848pfb.103.1551150139673;
        Mon, 25 Feb 2019 19:02:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYT0SAxTNHCWKVFTSwkMj6f/TbjJOt+2jGCmIPquTVsG8K3E6RoGDnx5PXIl+oGDkh+lyAN
X-Received: by 2002:a62:64c6:: with SMTP id y189mr23956697pfb.103.1551150137710;
        Mon, 25 Feb 2019 19:02:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551150137; cv=none;
        d=google.com; s=arc-20160816;
        b=hra1FZYq3Km4tOym3ouyl9WspScCp5R4wCP1A2DaOJmaufyFId+dMUQTkwlIDZhOaA
         LM9V/9cMmXdLo1FERm62VVqbMFmYe2FmuhJM85Y6H+/9ZmA1+r9JPia3G1z95RCCzQi+
         wzNdT4x2XbMSpuQafeYkOWmnveCuKG5jTniVzxMJ49U+EBcukV4eEJZa/7VsGCDcJhRq
         JtnHI6MjeUFU5URcHJ+AqAwjBSYisKBqeUlzZHYZnkyl/+iXHt3NVdIByNSx2/USB3DX
         KyHEWH2rKEavUiuPXMIkKJAgm5Qt30iIE457UtU8/DjHbGrW3xT1HzOTJGB2/11bfmTR
         actQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=D0hbpNV9TNJ54bvZJ9hz7IwWoYayd/Vx+bDcG2Q6Kwo=;
        b=P0wAtAmCAyheNTr0zCaPCPWTZ41zOLDqY9iTr2abY+UFTX5RhikR4VbFZEv+NR1x7h
         VKHUUnfD84chWehvxJJ+qCe1fRXgpqZSVRogy2d/Y1iATpBaAs8WosXYYOM103Y88H7+
         o68h96Sy18OQPR3IWHjE6Qs+jC+QQPCMu3XG3UM4FAjWJLLhlxBGVqLvsiSmn69q66U4
         UHo8nJV/BMb5NwoMozMhx79jF36E7rX1ID0h6OWcQJCVAJEwhSM8ZEjj8XsHZcD6AX1d
         nJsdD8V7pBEv9CbUDQsuFaXCGrKhzyeUIlzLBwCUY1XCVT3/LaTHDcx1CJM+4Fjq1M6p
         eoTg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id a73si10847178pge.5.2019.02.25.19.02.16
        for <linux-mm@kvack.org>;
        Mon, 25 Feb 2019 19:02:17 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 26 Feb 2019 13:32:16 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gyT0Y-0005qQ-5X; Tue, 26 Feb 2019 14:02:14 +1100
Date: Tue, 26 Feb 2019 14:02:14 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ming Lei <ming.lei@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226030214.GI23020@dastard>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226022249.GA17747@ming.t460p>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 10:22:50AM +0800, Ming Lei wrote:
> On Tue, Feb 26, 2019 at 07:26:30AM +1100, Dave Chinner wrote:
> > On Mon, Feb 25, 2019 at 02:15:59PM +0100, Vlastimil Babka wrote:
> > > On 2/25/19 5:36 AM, Dave Chinner wrote:
> > > > On Mon, Feb 25, 2019 at 12:09:04PM +0800, Ming Lei wrote:
> > > >> XFS uses kmalloc() to allocate sector sized IO buffer.
> > > > ....
> > > >> Use page_frag_alloc() to allocate the sector sized buffer, then the
> > > >> above issue can be fixed because offset_in_page of allocated buffer
> > > >> is always sector aligned.
> > > > 
> > > > Didn't we already reject this approach because page frags cannot be
> > > > reused and that pages allocated to the frag pool are pinned in
> > > > memory until all fragments allocated on the page have been freed?
> > > 
> > > I don't know if you did, but it's certainly true., Also I don't think
> > > there's any specified alignment guarantee for page_frag_alloc().
> > 
> > We did, and the alignment guarantee would have come from all
> > fragments having an aligned size.
> > 
> > > What about kmem_cache_create() with align parameter? That *should* be
> > > guaranteed regardless of whatever debugging is enabled - if not, I would
> > > consider it a bug.
> > 
> > Yup, that's pretty much what was decided. The sticking point was
> > whether is should be block layer infrastructure (because the actual
> > memory buffer alignment is a block/device driver requirement not
> > visible to the filesystem) or whether "sector size alignement is
> > good enough for everyone".
> 
> OK, looks I miss the long life time of meta data caching, then let's
> discuss the slab approach.
> 
> Looks one single slab cache doesn't work, given the size may be 512 * N
> (1 <= N < PAGE_SIZE/512), that is basically what I posted the first
> time.
> 
> https://marc.info/?t=153986884900007&r=1&w=2
> https://marc.info/?t=153986885100001&r=1&w=2
> 
> Or what is the exact size of sub-page IO in xfs most of time? For

Determined by mkfs parameters. Any power of 2 between 512 bytes and
64kB needs to be supported. e.g:

# mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....

will have metadata that is sector sized (512 bytes), filesystem
block sized (1k), directory block sized (8k) and inode cluster sized
(32k), and will use all of them in large quantities.

> example, if 99% times falls in 512 byte allocation, maybe it is enough
> to just maintain one 512byte slab.

It is not. On a 64k page size machine, we use sub page slabs for
metadata blocks of 2^N bytes where 9 <= N <= 15..

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

