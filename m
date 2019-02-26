Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8F44C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:36:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2043217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:36:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2043217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E3CF8E0004; Tue, 26 Feb 2019 07:36:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 394E78E0001; Tue, 26 Feb 2019 07:36:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2856F8E0004; Tue, 26 Feb 2019 07:36:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id F0E298E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:36:04 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so12038045qte.10
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:36:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=eX4S2efK7SowW8top3f6e556R1RXGUxZHUOcW1egL+s=;
        b=XpnQSKkGVMKS4NndtspIqg2Dp99m5ePdpGRQ9co8lTI7VFBGc9kchcNgF0rAYTHYcw
         VFhT1Z8L29/PDeCT0i2+Vmlp9SJjoubOW1YdAE6SqUWh3WvvYYtrbtveXP7IYjHQ2WzF
         vbZPAcRozTIZkR20GipWzjlwt3TBQ0Hhqt2vZifNtdon8MbKtdhEdtTVUeFif4xcfoNY
         TVz+Ws5sEIfkm4UWtEzFWO2P/r0sfWLZGwnm3eF3GHQ1hxCI5MbRsPoFZklPXwTpq+iW
         q607J4hXI1iCZkqvkwOsk+kO0bn7QIz9p3k11mGAp6Yee/s7m7kfg8Id4V3nx3hHbkXd
         ldEw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuazTYlndO5oGWuDPscsV4jeDD5lfrR03qeljFfMrViax9P0xMYY
	BWnGDmig5MhALiVNLvCBlfjvEkcZFMeCNIQIv+BRX32xDH4fVYA5P2b/A0E+mNEbAuDQOivgkaF
	vtMnxNck+9Q7Mz2UiWN/tZHTFs88jMIrrzWi2A9+90q1xyysF2j1Pe5phLlDyDF+Azg==
X-Received: by 2002:aed:384a:: with SMTP id j68mr17690700qte.171.1551184564731;
        Tue, 26 Feb 2019 04:36:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYDlVC3UoDPpH6ZraELuQTyj/ZWdE8AKhYFEM8qldCvmVqoqVE0hgnnRJvoZXXh9aICgm++
X-Received: by 2002:aed:384a:: with SMTP id j68mr17690650qte.171.1551184564004;
        Tue, 26 Feb 2019 04:36:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551184564; cv=none;
        d=google.com; s=arc-20160816;
        b=QIDAWEwlmy/p2wD84ofpursWfWCkAEv0caZ3FDg5bVMYM6PzKVDR5ZDJMgZUb4eewz
         SRdvZwXElL67+iFo+qYMDwpCaVvpw1kvzxZS5QK7MZpPelCOFF1+hSocugGO38lfY/4c
         YA7PaAFhq2qS997pfO5bHVDF+Qhog+7+xrv6cGj7xDWNu6p+NOJeekAneoamDZPXpeqC
         3Rla2shlmVXvlLgdkn9BuR8FixIBLfkX6ouGsz0RLuseuH4T62SjgRXInZ7M3//7WQaV
         4jdSDG+pBXuw9p7yE48JpGIjdMnuayTrDIGZqGwBDJpcL9wkgO1UQ/kn3IuiGeru0dFd
         sdlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=eX4S2efK7SowW8top3f6e556R1RXGUxZHUOcW1egL+s=;
        b=HFgfT3Hvg/5SozPd2fBytjCs1ZwL9eU+ja8T2eoQXHfC2oYEQlbh7UEQ/RBhajF2QY
         /+HEnxRdqi9gEbgSXIWQLde21yDc/Kuu8xv72GFIhH0b3JWbMoxo36FEde6pfBifyOxB
         HquyuqA47jR3gIvdFb9pqgPFToUwx6kQlXl4guW3rSGoQBsyuQduun98tAEdk3L5tT0n
         0ECjK5D1Wp5k9YUesVNLbdk9CXrkfbH+nhvZVd2R7ZBzH0I7j2mlLlqufFFHwDYfpIkw
         4oO8vwmB7RDtowNm864lIcIkfafLrXhgGq0scqjL1pXjag+YI5goyJfRqPzQrtYGBxI+
         aj2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h31si3526855qtc.165.2019.02.26.04.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:36:03 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0634870D90;
	Tue, 26 Feb 2019 12:36:03 +0000 (UTC)
Received: from ming.t460p (ovpn-8-17.pek2.redhat.com [10.72.8.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5CCD927BC0;
	Tue, 26 Feb 2019 12:35:50 +0000 (UTC)
Date: Tue, 26 Feb 2019 20:35:46 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ming Lei <tom.leiming@gmail.com>, Vlastimil Babka <vbabka@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	"open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	linux-block <linux-block@vger.kernel.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226123545.GA6163@ming.t460p>
References: <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
 <20190226121209.GC11592@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226121209.GC11592@bombadil.infradead.org>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 26 Feb 2019 12:36:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 04:12:09AM -0800, Matthew Wilcox wrote:
> On Tue, Feb 26, 2019 at 07:12:49PM +0800, Ming Lei wrote:
> > On Tue, Feb 26, 2019 at 6:07 PM Vlastimil Babka <vbabka@suse.cz> wrote:
> > > On 2/26/19 10:33 AM, Ming Lei wrote:
> > > > On Tue, Feb 26, 2019 at 03:58:26PM +1100, Dave Chinner wrote:
> > > >> On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
> > > >>> On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> > > >>>>> Or what is the exact size of sub-page IO in xfs most of time? For
> > > >>>>
> > > >>>> Determined by mkfs parameters. Any power of 2 between 512 bytes and
> > > >>>> 64kB needs to be supported. e.g:
> > > >>>>
> > > >>>> # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> > > >>>>
> > > >>>> will have metadata that is sector sized (512 bytes), filesystem
> > > >>>> block sized (1k), directory block sized (8k) and inode cluster sized
> > > >>>> (32k), and will use all of them in large quantities.
> > > >>>
> > > >>> If XFS is going to use each of these in large quantities, then it doesn't
> > > >>> seem unreasonable for XFS to create a slab for each type of metadata?
> > > >>
> > > >>
> > > >> Well, that is the question, isn't it? How many other filesystems
> > > >> will want to make similar "don't use entire pages just for 4k of
> > > >> metadata" optimisations as 64k page size machines become more
> > > >> common? There are others that have the same "use slab for sector
> > > >> aligned IO" which will fall foul of the same problem that has been
> > > >> reported for XFS....
> > > >>
> > > >> If nobody else cares/wants it, then it can be XFS only. But it's
> > > >> only fair we address the "will it be useful to others" question
> > > >> first.....
> > > >
> > > > This kind of slab cache should have been global, just like interface of
> > > > kmalloc(size).
> > > >
> > > > However, the alignment requirement depends on block device's block size,
> > > > then it becomes hard to implement as genera interface, for example:
> > > >
> > > >       block size: 512, 1024, 2048, 4096
> > > >       slab size: 512*N, 0 < N < PAGE_SIZE/512
> > > >
> > > > For 4k page size, 28(7*4) slabs need to be created, and 64k page size
> > > > needs to create 127*4 slabs.
> > > >
> > >
> > > Where does the '*4' multiplier come from?
> > 
> > The buffer needs to be device block size aligned for dio, and now the block
> > size can be 512, 1024, 2048 and 4096.
> 
> Why does the block size make a difference?  This requirement is due to
> some storage devices having shoddy DMA controllers.  Are you saying there
> are devices which can't even do 512-byte aligned I/O?

Direct IO requires that, see do_blockdev_direct_IO().

This issue can be triggered when running xfs over loop/dio. We could
fallback to buffered IO under this situation, but not sure it is the
only case.


Thanks,
Ming

