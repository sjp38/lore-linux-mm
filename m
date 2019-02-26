Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F46CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 02:23:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 153DC21841
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 02:23:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 153DC21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B92B68E0004; Mon, 25 Feb 2019 21:23:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1D278E0002; Mon, 25 Feb 2019 21:23:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0C178E0004; Mon, 25 Feb 2019 21:23:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70E668E0002
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 21:23:08 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id e31so10878820qtb.22
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 18:23:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lZwfhl3IJ81M8OJk7/f91oxQCwh8KuL+7WSn+UTtHzc=;
        b=cjSyft2IAwzVHkQJvMSIxiMIyqleTiJ+eo8urN/8IQOk/OjPuhV6lwfqGID7Vie8sU
         uUzBiRNI7jkKTPmtmiFJSEDmy6YKzNYICdZXFkDZxEQe6t8PNpUEoBcXTbUoZGmgUA4z
         wuI8DXJrdILUvFFQ4SrR1lf29OR0FPYzOt1Bx6jQOLD4hmQTxUQdaUnxMGLUM5PMId5s
         rZTBlMXF2NENSK9OQe5dkLc3DdxbglmBP8WTQNJFRm/xGzrqVHdC4ZMmaOXnwRlQRGyx
         02qu0km2OkLBDlFtPIWUUklP35CrsIVYSETgOfkApfh7Ku27cAcCWIqy2VE0KXLZMIXk
         +rbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZO+iinIPGXag1POwjpzDOk5BzupDtMoS02bkQIjtH7SfRjAhFN
	DgMsMwlaUun4bQu0+3xHR9va9w5h/cY1YR86ZKITfINiAF5XibcsK1bxKXK8rjPMZb5ZQeFfD20
	xrA/sz8tNBX1P4y2u7oKLJMGL2nAMpmP0vA30pAAKvCpapN2VpCMysg74x/kLJXzOIA==
X-Received: by 2002:a0c:ae27:: with SMTP id y36mr16545941qvc.185.1551147788233;
        Mon, 25 Feb 2019 18:23:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2/Y2sbD4YaTZ8nLXTVzx2kgh2UFTRU/gSqW6zFH83UJnsTQ5Rv32/hAS9mQOm+UErURo+
X-Received: by 2002:a0c:ae27:: with SMTP id y36mr16545910qvc.185.1551147787557;
        Mon, 25 Feb 2019 18:23:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551147787; cv=none;
        d=google.com; s=arc-20160816;
        b=GYCSMXLAm48rNW2f+DUJnLXXxM3Dy5KdWzwZkl2qOL/j0FJhxV70XzZAZUNZ/fXIxX
         NFf7sJk1I3Cn1JcaaHUYubXS9mRrCu7AEEVKgC6PI5BOQYEiuh+mk/c1XJbFgffuFhnF
         8tyaofmVpebrg4an/kr6keesrJDXrice+Dxk4eOm8aNj3Aiz/NNjYZhfLDCEBBb100CC
         kqIAQXofy4FLUbCHF4yIEhUsyqs26tLFOQYM4fGa9UaXO3sa80dI3QVJmhJf3iykKt79
         x0KyRY8myQD4DedNxwWlcIaLoof47v22hgUt0M+jus40I92GvN14+LgpokdCTCQhbzI7
         +fng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lZwfhl3IJ81M8OJk7/f91oxQCwh8KuL+7WSn+UTtHzc=;
        b=P3bDP7/S+kiCZ7JlJQmNeTmK7vdCv4+cBuJXgqLLAFsz1xEo0S7a4Ma3iPH5r7uXAT
         Hb/rnBBhjaT/zNQtzD8nlO0aZ/Gs8kVeLPtfw/8emnP12dRj8oKKLKt8kJJiycaz7BXX
         /tQB6nvOc5eAC8P2o5paNRrBIQc5htU/XnkA355WTKwm/X561hUHt2oRB33JXBbuk+bZ
         dWY+NR3IT1HUn6zwnAlSQy4zZozgXrzrKujDiCGG/tPRkTQ2BXhF5rGOMy87O9BtVQGx
         62rAWhBwUSNJnH+o0nigFT7kwakL3P1P9HDYgEgS1/d+lLRpzVE9xV3b3CcUILSGsx/A
         ceXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s21si1878798qkg.175.2019.02.25.18.23.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 18:23:07 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 906FC30842B1;
	Tue, 26 Feb 2019 02:23:06 +0000 (UTC)
Received: from ming.t460p (ovpn-8-25.pek2.redhat.com [10.72.8.25])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 11F3460BE7;
	Tue, 26 Feb 2019 02:22:55 +0000 (UTC)
Date: Tue, 26 Feb 2019 10:22:50 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Dave Chinner <david@fromorbit.com>
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
Message-ID: <20190226022249.GA17747@ming.t460p>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190225202630.GG23020@dastard>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Tue, 26 Feb 2019 02:23:06 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 07:26:30AM +1100, Dave Chinner wrote:
> On Mon, Feb 25, 2019 at 02:15:59PM +0100, Vlastimil Babka wrote:
> > On 2/25/19 5:36 AM, Dave Chinner wrote:
> > > On Mon, Feb 25, 2019 at 12:09:04PM +0800, Ming Lei wrote:
> > >> XFS uses kmalloc() to allocate sector sized IO buffer.
> > > ....
> > >> Use page_frag_alloc() to allocate the sector sized buffer, then the
> > >> above issue can be fixed because offset_in_page of allocated buffer
> > >> is always sector aligned.
> > > 
> > > Didn't we already reject this approach because page frags cannot be
> > > reused and that pages allocated to the frag pool are pinned in
> > > memory until all fragments allocated on the page have been freed?
> > 
> > I don't know if you did, but it's certainly true., Also I don't think
> > there's any specified alignment guarantee for page_frag_alloc().
> 
> We did, and the alignment guarantee would have come from all
> fragments having an aligned size.
> 
> > What about kmem_cache_create() with align parameter? That *should* be
> > guaranteed regardless of whatever debugging is enabled - if not, I would
> > consider it a bug.
> 
> Yup, that's pretty much what was decided. The sticking point was
> whether is should be block layer infrastructure (because the actual
> memory buffer alignment is a block/device driver requirement not
> visible to the filesystem) or whether "sector size alignement is
> good enough for everyone".

OK, looks I miss the long life time of meta data caching, then let's
discuss the slab approach.

Looks one single slab cache doesn't work, given the size may be 512 * N
(1 <= N < PAGE_SIZE/512), that is basically what I posted the first
time.

https://marc.info/?t=153986884900007&r=1&w=2
https://marc.info/?t=153986885100001&r=1&w=2

Or what is the exact size of sub-page IO in xfs most of time? For
example, if 99% times falls in 512 byte allocation, maybe it is enough
to just maintain one 512byte slab.

Thanks,
Ming

