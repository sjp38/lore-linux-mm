Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65638C282E3
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 12:44:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17909217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 12:44:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="OwAdPYWw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17909217D7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ABED96B0003; Fri, 24 May 2019 08:44:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A96206B0006; Fri, 24 May 2019 08:44:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 984026B0007; Fri, 24 May 2019 08:44:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7836B0003
	for <linux-mm@kvack.org>; Fri, 24 May 2019 08:44:58 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id c2so2025714vsm.9
        for <linux-mm@kvack.org>; Fri, 24 May 2019 05:44:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=86zgAQfw8EJJS+UNpjxjOFPf8eRhOu/zVe65BnxqX6k=;
        b=GKhgDcKacvFphBy3t3jeNSUOlW5FJtcPuVHgcn6XkmGetWOnjVB4xBWXNhhekis0v6
         L6I2S7Lk8Yo8Fso/M2Qpazvhu5A79D4vsywxrX1pOViaAmGk4qIxDgVschm+pcOYY/5f
         AsQXYsAXCTLDc5gOyVZEgaQs8p9m3xGONlieKvak9kfJseGOVT/WBiv6oMmBD4MafSoD
         Ejmv0nMkX0dkz6beMjyxLnR/MtbTFLx1SaK0BSXTCAbiyiQPRBnupgdNTCE04sRyogIb
         mO8JCVgJzjdkbUfm3PUh9kbrdOg/4st2/c0trIbu61SVip9t9fcUMOPS+0vCOxuctTED
         CKTA==
X-Gm-Message-State: APjAAAUHdyE0g+4I8JycmGHbVct3n5eWhP6oWKFc7P3BszSG1v2K6K+h
	LGy/zoEEXZo+vL7SEstueFM2HZl1yBXCL3CTiq60hfCo6ATyLwzJX5YFDvRPmqXuRosXJckhi8M
	PurD1t9DGrdudqlLA4Z5dFifwoOTKTk3Dmdbawt1SxMyfZ8/RpGrnpbsSQkBXQMkQqg==
X-Received: by 2002:a67:fc88:: with SMTP id x8mr7954634vsp.94.1558701898103;
        Fri, 24 May 2019 05:44:58 -0700 (PDT)
X-Received: by 2002:a67:fc88:: with SMTP id x8mr7954548vsp.94.1558701897249;
        Fri, 24 May 2019 05:44:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558701897; cv=none;
        d=google.com; s=arc-20160816;
        b=SE4iUU6fd2hiyLqnuVb2+YkciV6j61zQ0nI6uQ1OiyPWNt/8Rwm5kmaWXZJVpp2zi2
         CIzWYfbKPqmSZtemrTtEh/VdijrKM7LqNzUYq3XnSDcAwBeTVstLnUhQwWUNSbM2CU6A
         acpgUvASLLnMYz9h7YLHUXYY67OAKdu0VPAmOXw03NjQSemEc8C3MFyuy7W1aLe7lAWN
         jB3s0VmZDD77xlutIragzq5bWSLYqeITHerul+Yswe9xYj+qZYdVvmKn/DGTDrzVqpaX
         F3xbFg3Zuavm1ZJL9pJPOrUjrvNgN2lsfiwJM5DpW1Nh28p2PfbWzD9yRsgqbNVk9Isk
         f31A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=86zgAQfw8EJJS+UNpjxjOFPf8eRhOu/zVe65BnxqX6k=;
        b=vldukpbreejz17YWoUbJ9aa2aNlxaSYn+iOB899uFegGuxdFojPUc1uN3wzcH9bdzn
         UD+mVML8t/sfgFw3wCkkLA4cCffg5iOFJmwWKyxleg77DqQChYb2iJH64oj2YYH2kfB3
         +JH/c0rUWxfWiwTwDLxUIHMnjG86ueI8xjSuys2/1v+TX+Fzs/N91qD7k7waT2+mHyUV
         82JQKWcb0TEHni/aGFZPMWpcj0eOVBg9HBtdVuZmqGHikOng07VHxcypB2mEF0lcN1dC
         pEgHgW4eRddoC0RuHUSdAiswQ6BjsVpo6ZNfjIwqb0H+62e7e4Bl2d2GDhMKcpO1wHb7
         fNsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=OwAdPYWw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b4sor1256185uam.5.2019.05.24.05.44.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 05:44:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=OwAdPYWw;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=86zgAQfw8EJJS+UNpjxjOFPf8eRhOu/zVe65BnxqX6k=;
        b=OwAdPYWwIIhzKIrP9zacmHWALt7WHScrXTSOiHZlMka+qhZn/6McmfKFyb+5mt72A8
         4yZy3bxx8SNsfV/ezDuz1DHppIcgD8780P3ujAMHW+4K+f5RPN2e/31pnlevfPC9Lp+c
         IN1fRiPPUJUb5X4snek7Tvn/JK+pQvE5V97Id1Jk2wzSHpDtKmilz9caWuJ8z3mWEy9q
         AOt6arDl+8e3Fikr/N4U9ap3kxtcaR49d3FGq/xJ5hMQ0ZX/MhCAK0F6obNBUpuZOBis
         qEUp9M8syRwmD9qj3C+L+koiFfG+W4r4XUmdJ49PyV4KvxBT7r7Hdnt9AYt3p/P2fLLt
         SrEg==
X-Google-Smtp-Source: APXvYqyEylmmdkAB6AaIhsy3vhee0zusZnFo+WYBZWM/18FEIODicL7EA9MIafCvZ0ZYEzrSfr1ouA==
X-Received: by 2002:ab0:23cd:: with SMTP id c13mr14715196uan.77.1558701896809;
        Fri, 24 May 2019 05:44:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id x19sm453316vsq.9.2019.05.24.05.44.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 05:44:56 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hU9Z9-0004qz-Fc; Fri, 24 May 2019 09:44:55 -0300
Date: Fri, 24 May 2019 09:44:55 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
	Dave Airlie <airlied@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org, dri-devel <dri-devel@lists.freedesktop.org>
Subject: RFC: Run a dedicated hmm.git for 5.3
Message-ID: <20190524124455.GB16845@ziepe.ca>
References: <20190522235737.GD15389@ziepe.ca>
 <20190523150432.GA5104@redhat.com>
 <20190523154149.GB12159@ziepe.ca>
 <20190523155207.GC5104@redhat.com>
 <20190523163429.GC12159@ziepe.ca>
 <20190523173302.GD5104@redhat.com>
 <20190523175546.GE12159@ziepe.ca>
 <20190523182458.GA3571@redhat.com>
 <20190523191038.GG12159@ziepe.ca>
 <20190524064051.GA28855@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524064051.GA28855@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 11:40:51PM -0700, Christoph Hellwig wrote:
> On Thu, May 23, 2019 at 04:10:38PM -0300, Jason Gunthorpe wrote:
> > 
> > On Thu, May 23, 2019 at 02:24:58PM -0400, Jerome Glisse wrote:
> > > I can not take mmap_sem in range_register, the READ_ONCE is fine and
> > > they are no race as we do take a reference on the hmm struct thus
> > 
> > Of course there are use after free races with a READ_ONCE scheme, I
> > shouldn't have to explain this.
> > 
> > If you cannot take the read mmap sem (why not?), then please use my
> > version and push the update to the driver through -mm..
> 
> I think it would really help if we queue up these changes in a git tree
> that can be pulled into the driver trees.  Given that you've been
> doing so much work to actually make it usable I'd nominate rdma for the
> "lead" tree.

Sure, I'm willing to do that. RDMA has experience successfully running
shared git trees with netdev. It can work very well, but requires
discipline and understanding of the limitations.

I really want to see the complete HMM solution from Jerome (ie the
kconfig fixes, arm64, api fixes, etc) in one cohesive view, not
forced to be sprinkled across multiple kernel releases to work around
a submission process/coordination problem.

Now that -mm merged the basic hmm API skeleton I think running like
this would get us quickly to the place we all want: comprehensive in tree
users of hmm.

Andrew, would this be acceptable to you?

Dave, would you be willing to merge a clean HMM tree into DRM if it is
required for DRM driver work in 5.3?

I'm fine to merge a tree like this for RDMA, we already do this
pattern with netdev.

Background: The issue that is motivating this is we want to make
changes to some of the API's for hmm, which mean changes in existing
DRM, changes in to-be-accepted RDMA code, and to-be-accepted DRM
driver code. Coordintating the mm/hmm.c, RDMA and DRM changes is best
done with the proven shared git tree pattern. As CH explains I would
run a clean/minimal hmm tree that can be merged into driver trees as
required, and I will commit to sending a PR to Linus for this tree
very early in the merge window so that driver PR's are 'clean'.

The tree will only contain uncontroversial hmm related commits, bug
fixes, etc.

Obviouisly I will also commit to providing review for patches flowing
through this tree.

Regards,
Jason
(rdma subsystem co-maintainer, FWIW)

