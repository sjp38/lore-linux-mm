Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66596C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 01:41:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12D68218D0
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 01:41:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12D68218D0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61B8D8E0003; Tue, 26 Feb 2019 20:41:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F2D18E0001; Tue, 26 Feb 2019 20:41:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E1D48E0003; Tue, 26 Feb 2019 20:41:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 243818E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 20:41:55 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k1so14126460qta.2
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 17:41:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=p1KJy7oSpe1RDztelI4ho6n8KipN7a8DGxGvr3yBIk8=;
        b=qJPPvzXIVvZSOehYAvqiVYf1mkpWFA/jPRyGWXLZk+xMCAM5UJCYg/3CPcfDDmO0h7
         avo017B/BNOBn65s8U/wOEq9teCRUfoSxeTHGFRonL8ZPZza5dWJSJttBdyWPQxba4+B
         lVGLWUljTn4LyINYiW6rTwjrqzw/igHyS5nRzZVe37okWYkI7RIRlqk61cxqccdXVSgR
         bV+05UvBgCKzK3ddnRsX/MkvP+s5uy/fcMVauuiDm2QyrnRJbWi6oEwnbgG95z9Druw6
         9HxgXyHBFZihcNMsLhAXfSfK/CGWlYeAG+rkdep4wsyjwLcirjFDItZK0pgDbmhyMOFE
         d6Mw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubDZ/twHsZcqsAJcm1N0noC0EHXVuljnCHEL5FbrQSBKyhBd0QG
	s/7Few+AFi/n8KtRSOPSaGqiV3BRNpeTfpjzahwUsxBt9UAWJKgehrHECcIqfRZk1/2BrNY2mzF
	e82r4hTrxdBWAwq954wDUn2t05aDKCJPM/Hbz7rVAiIyscJybObzR4+ceOfsj5vrDew==
X-Received: by 2002:a37:2245:: with SMTP id i66mr365073qki.354.1551231714912;
        Tue, 26 Feb 2019 17:41:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+FS7UaYsZ9CLQ1eBvZkM3W72QyBVi7UUkcZIhweG8mhh+ZkEmEgO8OYDU1W2dvmN6PrBi
X-Received: by 2002:a37:2245:: with SMTP id i66mr365032qki.354.1551231714014;
        Tue, 26 Feb 2019 17:41:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551231714; cv=none;
        d=google.com; s=arc-20160816;
        b=RHFhFI0zmJhsNKnEJCreRok7QohLuFJZw674EV/7FAUKS3F+E4326O7zF6LMu5PJ/O
         9cI2t7MFTRSLL/RQCzgSEXyIALQDMCIPaRH+ZpxLQ4pMmV9XlFxvSA/h93RlUc1FX2jD
         plgB01MDcfYvr/GXzpLexgumFKdWA89CGG9nt5Z5PcCp75Z/NqSkdxwJ/iZsWYvRk+lu
         HiMmr+tYERPYJ82Tk/2xlL/D0dzNX2JtTberKvNd58TToEMkFQ6kVc8/26ZZXqHVNkBV
         MFuWjzF006JTI961eXEFl5JhmoaUiO4fBR8ocUBglUMqlWd5kJvXXf+eVp5Gw40eJmZ8
         wp8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=p1KJy7oSpe1RDztelI4ho6n8KipN7a8DGxGvr3yBIk8=;
        b=v8qANyE2lmtnndXjI9ww2e6Fn04Ej9/lQ7z7fC0FdtSdM7rSMT5Pw501DAvW83VJJw
         FLf8hURxS0wY94Dg23HcaUG3lKwC/L3CAwsj7V3KY/HSeuYREc4unP+QOsABzdHgD/lQ
         TOavbwEF9xkmwU6N0fhMOYVTc2hyyQ0+vQuKx/hGUp+XUy+Pgs3aqVc6FBPuLgUlKFil
         lp6Z2MYlE+YuaE1J8EiIeL7MPgQ+xOYAfl4l6sBunKBZKBToDlqxa6BOqJOVMDCP30sC
         V3LYzK/yQvto6PcVre8RRyJd2RdzK4CDAeurTwv89JK7Toxk0dqaDVF/r/kH7udn0O3S
         FmqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q38si577551qtq.172.2019.02.26.17.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 17:41:54 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 183E07E44B;
	Wed, 27 Feb 2019 01:41:52 +0000 (UTC)
Received: from ming.t460p (ovpn-8-21.pek2.redhat.com [10.72.8.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 649211001DEC;
	Wed, 27 Feb 2019 01:41:38 +0000 (UTC)
Date: Wed, 27 Feb 2019 09:41:34 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
	Ming Lei <tom.leiming@gmail.com>, Vlastimil Babka <vbabka@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
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
Message-ID: <20190227014133.GB16802@ming.t460p>
References: <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
 <20190226121209.GC11592@bombadil.infradead.org>
 <20190226123545.GA6163@ming.t460p>
 <20190226130230.GD11592@bombadil.infradead.org>
 <20190226134247.GA30942@ming.t460p>
 <20190226140440.GF11592@bombadil.infradead.org>
 <20190226161433.GH21626@magnolia>
 <20190226161912.GG11592@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226161912.GG11592@bombadil.infradead.org>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 27 Feb 2019 01:41:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 08:19:12AM -0800, Matthew Wilcox wrote:
> On Tue, Feb 26, 2019 at 08:14:33AM -0800, Darrick J. Wong wrote:
> > On Tue, Feb 26, 2019 at 06:04:40AM -0800, Matthew Wilcox wrote:
> > > On Tue, Feb 26, 2019 at 09:42:48PM +0800, Ming Lei wrote:
> > > > On Tue, Feb 26, 2019 at 05:02:30AM -0800, Matthew Wilcox wrote:
> > > > > Wait, we're imposing a ridiculous amount of complexity on XFS for no
> > > > > reason at all?  We should just change this to 512-byte alignment.  Tying
> > > > > it to the blocksize of the device never made any sense.
> > > > 
> > > > OK, that is fine since we can fallback to buffered IO for loop in case of
> > > > unaligned dio.
> > > > 
> > > > Then something like the following patch should work for all fs, could
> > > > anyone comment on this approach?
> > > 
> > > That's not even close to what I meant.
> > > 
> > > diff --git a/fs/direct-io.c b/fs/direct-io.c
> > > index ec2fb6fe6d37..dee1fc47a7fc 100644
> > > --- a/fs/direct-io.c
> > > +++ b/fs/direct-io.c
> > > @@ -1185,18 +1185,20 @@ do_blockdev_direct_IO(struct kiocb *iocb, struct inode *inode,
> > 
> > Wait a minute, are you all saying that /directio/ is broken on XFS too??
> > XFS doesn't use blockdev_direct_IO anymore.
> > 
> > I thought we were talking about alignment of XFS metadata buffers
> > (xfs_buf.c), which is a very different topic.
> > 
> > As I understand the problem, in non-debug mode the slab caches give
> > xfs_buf chunks of memory that are aligned well enough to work, but in
> > debug mode the slabs allocate slightly more bytes to carry debug
> > information which pushes the returned address up slightly, thus breaking
> > the alignment requirements.
> > 
> > So why can't we just move the debug info to the end of the object?  If
> > our 512 byte allocation turns into a (512 + a few more) bytes we'll end
> > up using 1024 bytes on the allocation regardless, so it shouldn't matter
> > to put the debug info at offset 512.  If the reason is fear that kernel
> > code will scribble off the end of the object, then return (*obj + 512).
> > Maybe you all have already covered this, though?
> 
> I don't know _what_ Ming Lei is saying.  I thought the problem was
> with slab redzones, which need to be before and after each object,
> but apparently the problem is with KASAN as well.

I have mentioned several times that it is triggered on xfs over
loop/dio, however it may be addressed by falling back to buffered IO
in case unaligned buffer.

Please see lo_rw_aio().

Thanks,
Ming

