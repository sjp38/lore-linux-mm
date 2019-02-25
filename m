Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B3ECC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:46:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D208620989
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:46:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D208620989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ACF88E0177; Mon, 25 Feb 2019 03:46:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5351B8E0167; Mon, 25 Feb 2019 03:46:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D8DE8E0177; Mon, 25 Feb 2019 03:46:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6378E0167
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 03:46:42 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id z198so7260784qkb.15
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 00:46:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WGLzd0HcWwWMDCkJHBPCS9/1f3PaeJ2MUMQT5IoYtBQ=;
        b=ucnCFV9L/XMj15/t/7YZ8NrORaJ3xWH4DGpmvccDPAsOTK3Iq7HYcsDWhuDtYGtvzK
         WPK40y8GbYl6lFHvDvW40L73fbdpoD0WgvMYYhqowufSjeNDe3aOdk1B9J4a+G7IUgCm
         XEgafS/Hr9kmnmZZ34J2QewTFrUYY3kFkuVd2J/pxxOPcY4GZCUBJ6RX1L4Bh1aT0fRc
         8Wsw8wEXTwJyEOMzh2cES3ysF05D/wMJxFiwIAan/HMFCMQfxWdhFwAYP9O1PTLJAtEx
         t/cGtkHNQBuxagEYaBEO3Yy4nDjotCPM86osbAOrpPBt1mflnjiWkuJW/WPxyZ4R7ZcY
         TRAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYTZUFvz4Ai6x3vR5lj0ZP6GcO62b9FVh+oBn5rxxyqYnG8W+7J
	32PZsTuoKvMqNZXm5CP6zv23PXD2NMPZcgWYd+bTB1fb1aab2gGt2O+qjSdm6OtkmIVsvQwjLO6
	/+HIxjPYt8v/vvvF3o/SqA4wH22k7w/hDNRycS+nponHzIRByJyRLloatBlb7nHnj3g==
X-Received: by 2002:a0c:d121:: with SMTP id a30mr13294156qvh.0.1551084401778;
        Mon, 25 Feb 2019 00:46:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbHMynbDnCzfASpuamqu0hNOimGmLqS7FYaS2eFy9xp0Fuzb23IvvLc0C6lqBgKoNRRRGY7
X-Received: by 2002:a0c:d121:: with SMTP id a30mr13294128qvh.0.1551084401097;
        Mon, 25 Feb 2019 00:46:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551084401; cv=none;
        d=google.com; s=arc-20160816;
        b=N06PFzkhunRYjk833+jSWUisZkMqyYo9fj5gOlny82RQLoT90Rv4OlsXg6F/GhVSSe
         hX2UXJsmHa4WszywMsj1xKdHsmgvBGEla5XEs33kY7x+QmNMMjs8BfMfZgVJiRRg6+Xf
         rn6NSKWjhz9i+X1HfiLV5Q2vh9jnsT6RjMrdmbZxViLXgGlA+QYt/z8utacLOQB6/czW
         sJN0jZfwI7yqMpgBdJd6e1KzhdsEUelQvOHVSLXM3fwF4zUurzMQKbFwi8M7hBIgohkz
         m4EQG/WuKmB5Z/+BP++82JbPVyVziM0XvywzxDKy022n8vNY9mfbJNhHJTmoM4B+uQMr
         Ql9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WGLzd0HcWwWMDCkJHBPCS9/1f3PaeJ2MUMQT5IoYtBQ=;
        b=Pfq5aCdv+tAwa4zYh7I3Rl3y518FfcaKw4GY5RzLmgf0r0nNw1uqJCPH7Ahr0GRpLZ
         eTi1fZh2nzQprzUB/RkrVpfJn4WavDaD3l0GkmO/d2PTphLwmwspM7Tc05nZBrXLrnIg
         kMmuCeU8jirV5iGdZA66bvN/F0bHPbFgLBEUg5Je67aXNv8Ww4f1xKuXdfDHtSFCILHH
         1d+/S2i7Hl43Erurh3PPyxPu34SPtMnBk273EhCoE7yJbLs6FWHl6+iksfExMAuJHaGN
         VbppsBzwjWVPdPlx0sH/RVEwJBcNmzoj7v3Smhl5XFcvPt5yR7Es3p5dgG4QCnYXbyGf
         cG4A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t20si360374qtq.144.2019.02.25.00.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 00:46:41 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E84A783F3F;
	Mon, 25 Feb 2019 08:46:39 +0000 (UTC)
Received: from ming.t460p (ovpn-8-31.pek2.redhat.com [10.72.8.31])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 838E5600C4;
	Mon, 25 Feb 2019 08:46:30 +0000 (UTC)
Date: Mon, 25 Feb 2019 16:46:25 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Dave Chinner <david@fromorbit.com>
Cc: "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190225084623.GA8397@ming.t460p>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190225043648.GE23020@dastard>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Mon, 25 Feb 2019 08:46:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 03:36:48PM +1100, Dave Chinner wrote:
> On Mon, Feb 25, 2019 at 12:09:04PM +0800, Ming Lei wrote:
> > XFS uses kmalloc() to allocate sector sized IO buffer.
> ....
> > Use page_frag_alloc() to allocate the sector sized buffer, then the
> > above issue can be fixed because offset_in_page of allocated buffer
> > is always sector aligned.
> 
> Didn't we already reject this approach because page frags cannot be

I remembered there is this kind of issue mentioned, but just not found
the details, so post out the patch for restarting the discussion.

> reused and that pages allocated to the frag pool are pinned in
> memory until all fragments allocated on the page have been freed?

Yes, that is one problem. But if one page is consumed, sooner or later,
all fragments will be freed, then the page becomes available again.

> 
> i.e. when we consider 64k page machines and 4k block sizes (i.e.
> default config), every single metadata allocation is a sub-page
> allocation and so will use this new page frag mechanism. IOWs, it
> will result in fragmenting memory severely and typical memory
> reclaim not being able to fix it because the metadata that pins each
> page is largely unreclaimable...

It can be an issue in case of IO timeout & retry.


Thanks,
Ming

