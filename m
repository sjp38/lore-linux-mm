Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6144EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:26:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 290DD20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 20:26:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 290DD20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF24C8E0014; Mon, 25 Feb 2019 15:26:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA0448E000C; Mon, 25 Feb 2019 15:26:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98F7A8E0014; Mon, 25 Feb 2019 15:26:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB468E000C
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:26:37 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id 17so7824590pgw.12
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 12:26:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VMsyBcHItgRY2FgAMjIuw5zaUnGVohMGMAMl4BYxVk4=;
        b=hgKxI3uN2DBrnbLDNcLnigRSzALXzwBNILQTwmn8Rih27YNf+8ZrrLXN3kxS3fM2Ix
         vV52r89sisQJnVCIJasDCOAPDwcQIhn1+NWQq/KwNqFj8SOu2JVZyYbPy+Klr90hW2XV
         rEQXFbp905FBdnf4ThHtWkDv6qqeZ32PBrmcJmQp4IW2sNG56Tzi0cNL1Jwr18NzL3gD
         YE9Z3Ak4Q1NdGJVL7zfBP+WJVt6dY8UoodhAMG0+Cgmxmn2c+sZ099NJUJ7i1qhMb4r6
         OQO77AhMo9xom1kLUW2W3fJj7zfImR3lcJZAVJzqUL6rIoC7tkfbb5vfMCAvbaOZwXOI
         GFsQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuZ/RsSW0Rnz0qGw+i4BKhzXryEpyLEmUCY46gRVvELAdY6LKWyq
	SNbEPMOustZiurjBnsm1twYPFeWkZfPXj2gemk9+V1mVqfDo5rcsrnseWeY8zUvZHEexT/Awu3P
	UvSk099ZAg6UFkBrxgIKdGVmLxDyQ8Xb/G+mTupn/6nUqPomtnIaxIVdb50/u6dc=
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr21402435plb.226.1551126396954;
        Mon, 25 Feb 2019 12:26:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYwiEOdG6S/4wLTk3ofE2Z3G0isl2mjkDpbcj/ewinSTaTmkWkOEQlLQQijoGktZW+9Fayr
X-Received: by 2002:a17:902:2aa8:: with SMTP id j37mr21402356plb.226.1551126395705;
        Mon, 25 Feb 2019 12:26:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551126395; cv=none;
        d=google.com; s=arc-20160816;
        b=Ar4qopDu0fVvfRqTUQiybehh1lVmIkh2nQ2IWcsUhNy/iIYTtxbaXPmFi7ZmW1xjRO
         MhpGP1ixEAH1nY/aDPknXKNuKtaMO2bYm905QhUuYRJNrKjysjGXCys5V7v8YC08uDmY
         /+5hZY73sLbdJaAhbNC4/t04KFEiAImle/nXeRNf+nDO/3VVksfOxLhTypjfIh8I31ro
         I2TWOZ7+KzZ07NqhDvLfCBCUMr+1PyoBaCYkkRFb9wqqd2SfgQBD2z+gPqbqP2CNrC4N
         RK2BJFpEsDSNouuy43jQlIcyqxPeaAwWA41DJu8JYeFdNIZWH8dP+SJ8lmNQQCsQosGF
         VTvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VMsyBcHItgRY2FgAMjIuw5zaUnGVohMGMAMl4BYxVk4=;
        b=mlZ2Y9iQk6V2FKdGHaQbNPARvNjLjyRKLrhaQkwh5Gs6Yb0JE8ElHrvAkheq6plhb6
         xK82gm8eB3rrcOobuokEplGbz+th4VPxXL7owNdJjNgpkSO+DFnTi2mbKdnxmVSI9I2u
         FV6HhEgmJ0xv3VtvhpQzxPeITpEt4daEoPFbjSPPq2H+BK38DbvSez0zSBdqu0WgcpEB
         JxJ2HI2O9j3SLKWMpbDzL4F5BFKgEVTzI/jtI3MLUaxNWoTqSFwTd3MqVKnymbac+C6H
         ZQWvXTvq9QJiA4RM7iIgnipxE8ig3gd5q3m/G7TD2aHfnail+ZggyDPAtDyFn0A82i6D
         jO0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id f22si9631219pgv.578.2019.02.25.12.26.34
        for <linux-mm@kvack.org>;
        Mon, 25 Feb 2019 12:26:35 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.145;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.145 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl6.internode.on.net with ESMTP; 26 Feb 2019 06:56:34 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gyMpa-0005O6-Rn; Tue, 26 Feb 2019 07:26:30 +1100
Date: Tue, 26 Feb 2019 07:26:30 +1100
From: Dave Chinner <david@fromorbit.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ming Lei <ming.lei@redhat.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190225202630.GG23020@dastard>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 02:15:59PM +0100, Vlastimil Babka wrote:
> On 2/25/19 5:36 AM, Dave Chinner wrote:
> > On Mon, Feb 25, 2019 at 12:09:04PM +0800, Ming Lei wrote:
> >> XFS uses kmalloc() to allocate sector sized IO buffer.
> > ....
> >> Use page_frag_alloc() to allocate the sector sized buffer, then the
> >> above issue can be fixed because offset_in_page of allocated buffer
> >> is always sector aligned.
> > 
> > Didn't we already reject this approach because page frags cannot be
> > reused and that pages allocated to the frag pool are pinned in
> > memory until all fragments allocated on the page have been freed?
> 
> I don't know if you did, but it's certainly true., Also I don't think
> there's any specified alignment guarantee for page_frag_alloc().

We did, and the alignment guarantee would have come from all
fragments having an aligned size.

> What about kmem_cache_create() with align parameter? That *should* be
> guaranteed regardless of whatever debugging is enabled - if not, I would
> consider it a bug.

Yup, that's pretty much what was decided. The sticking point was
whether is should be block layer infrastructure (because the actual
memory buffer alignment is a block/device driver requirement not
visible to the filesystem) or whether "sector size alignement is
good enough for everyone".

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

