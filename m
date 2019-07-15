Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 612D1C76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:37:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C92A2081C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 19:37:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ouMD/x07"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C92A2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C047C6B0003; Mon, 15 Jul 2019 15:37:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB4E46B0005; Mon, 15 Jul 2019 15:37:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A7ED16B0006; Mon, 15 Jul 2019 15:37:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 734456B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:37:00 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 30so11058376pgk.16
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 12:37:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ZMZFpCm9N/xOShc4hGeJhjqpU1dBVFQxn4gJ5Yr8VYU=;
        b=Fey7f8ILTEsRtAjF9OxQmlaqo/uGV8wCmCX2den9qrq4S+p+UjzlPUaiGzUm6ov3eZ
         Lw+W92LlU1CQyyWvxAHGWJViiS0c6E60XFEtdeRZuTdW8cqCmr7oxhrBt8hmq3fLIIQ1
         5w76gz3is7NwXe3uv//rtnErYBi/O2LvhnP9kG94B71WMyIej0zTqZriDpkpDO/9egRF
         lzlloF7vhZTIQ04Up+TFMFKceoJv7ZCEtOykJIv/LQRiEWv+RsyPKHcCMK9OlDLcZ3Vn
         To+EgZ1xjXjGsm8aiUhPA5Hq/+maCuu8moYUwvtvcm1PYpelY0wygoQ9ColGBu334KsQ
         bxtQ==
X-Gm-Message-State: APjAAAUwXDbmf6fjXx0FCn/MUMlU9qaJ5sWT274X+0Nn8/bp8bcgn7p0
	p2zsbPP5Ed7q3SvK3M86tNE61PCf13/7zwmzJjWV0agY9CyuiFQKGdcs9+cX6w4vroyAElGCryc
	79i1arVNkAusYuy+ybKfnzxRSyka5qRYYq9jmiXh5yL4QrDOpi31ROYw6VEW/sECKgw==
X-Received: by 2002:a63:fc09:: with SMTP id j9mr13103246pgi.377.1563219419342;
        Mon, 15 Jul 2019 12:36:59 -0700 (PDT)
X-Received: by 2002:a63:fc09:: with SMTP id j9mr13103192pgi.377.1563219418580;
        Mon, 15 Jul 2019 12:36:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563219418; cv=none;
        d=google.com; s=arc-20160816;
        b=Y1WCVMo3VhTxsFsWr3iEe+eT0ja0ktdQoK48MMpjZCGOFOz6xz2Oc3ZG4wcI/RqWGJ
         GKURDYVgbNfOYwLNY+SgxdbtU2cxRLvY4ST9DjjeThou5M5RQ8/GGvTCQX0YdlVNPcn8
         bxP1DmlT1A4VTsdOmaANBfpL5pOLtO8vB+waIMijfxaHbDqDja7UOZU3+dS9BD+pteS3
         qu48tN7uTB+HkgxCo4BxUlOVqMOed/LYkbgD3u35yQ/FXytqcn5JR5dOQjzrUhK1AU4O
         W3XeTPnzzVMcU1btmsBhJqJYtnw/WvlFxbHTYTzlqFsADmg7VIT56PVNrSIMHW0NhgIc
         EhWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ZMZFpCm9N/xOShc4hGeJhjqpU1dBVFQxn4gJ5Yr8VYU=;
        b=J8Xndq7P+Sl6JK6W7mSXGRshQGEQagqGXvu0WOgQ8bLj/bn1ia8IVH/7gp1XXgSqOE
         Sg0t9FdcNTOUDMGLXQB3klH4mJirExavHvE0mtMqwzbFaNGlh0PIQe24jOkdhF4dhMpO
         U1Qlxh3ZUmFsYtuU3IjSG+BiKsbFujq1pr5mNNgRfl89+UeoAeSosLEMvfwiTv8s76KT
         KdXhrjsf/fQafldPPzifxJvZtT47pNfUjAG51iB03aTnjA7nHOs9GUkcZKVSljAeK/Pq
         tsdoMIMf6JizSxJqd02+agUlap/PsBUeQqzufa+9revhsLor2+3iVMvLhWKRbfDiurK6
         3iJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ouMD/x07";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 101sor22200234plf.70.2019.07.15.12.36.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 12:36:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="ouMD/x07";
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ZMZFpCm9N/xOShc4hGeJhjqpU1dBVFQxn4gJ5Yr8VYU=;
        b=ouMD/x07ooCJnj+NYt5TApE5G94vM5KbLQmbdXlQVy+akuMZEEpCrtND7YKQG5YUeA
         SwDKVhCmMNrLmoEdYnhOUJT7p2Js7T5gKnlL5psag4uSjc/eacvG09R20QX9ob1r4KGQ
         JPUttDZsH8R58YIqWxPGf4pAOehWEDqdzpRPAvVxKz6f5hK1dym19x1TE2jRz8hHVpx0
         UqQueUQ86Wq4EhgMr8yelYxObVmxnTeT2kl+gzYOROR0JeUAJOE9lJYDracn4NTfoh3G
         4sWnaSWux8Tb332IFGX3aPQu0kyiBn2izgQl68gsJm9ydw4yE3c+5dgMn2bBWXbyvUpu
         ia4g==
X-Google-Smtp-Source: APXvYqxiXiuWWcy55kFQPdkmhXEuhD4sgNJY5WWi5qbrL1Ybmgv+FOQ8bkjHLfFA1omJ8iRmDA1Qtg==
X-Received: by 2002:a17:902:4aa3:: with SMTP id x32mr28971983pld.119.1563219418289;
        Mon, 15 Jul 2019 12:36:58 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id n19sm18786840pfa.11.2019.07.15.12.36.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 12:36:57 -0700 (PDT)
Date: Tue, 16 Jul 2019 01:06:38 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: akpm@linux-foundation.org, ira.weiny@intel.com,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Dimitri Sivanich <sivanich@sgi.com>, Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Cornelia Huck <cohuck@redhat.com>, Jens Axboe <axboe@kernel.dk>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	=?iso-8859-1?Q?Bj=F6rn_T=F6pel?= <bjorn.topel@intel.com>,
	Magnus Karlsson <magnus.karlsson@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Jesper Dangaard Brouer <hawk@kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Enrico Weigelt <info@metux.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Alexios Zavras <alexios.zavras@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Max Filippov <jcmvbkbc@gmail.com>,
	Matt Sickler <Matt.Sickler@daktronics.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Keith Busch <keith.busch@intel.com>,
	YueHaibing <yuehaibing@huawei.com>, linux-media@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org,
	kvm@vger.kernel.org, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, bpf@vger.kernel.org,
	xdp-newbies@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH] mm/gup: Use put_user_page*() instead of put_page*()
Message-ID: <20190715193638.GC21161@bharath12345-Inspiron-5559>
References: <1563131456-11488-1-git-send-email-linux.bhar@gmail.com>
 <deea584f-2da2-8e1f-5a07-e97bf32c63bb@nvidia.com>
 <20190715065654.GA3716@bharath12345-Inspiron-5559>
 <1aeb21d9-6dc6-c7d2-58b6-279b1dfc523b@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1aeb21d9-6dc6-c7d2-58b6-279b1dfc523b@nvidia.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2019 at 11:10:20AM -0700, John Hubbard wrote:
> On 7/14/19 11:56 PM, Bharath Vedartham wrote:
> > On Sun, Jul 14, 2019 at 04:33:42PM -0700, John Hubbard wrote:
> >> On 7/14/19 12:08 PM, Bharath Vedartham wrote:
> [...]
> >> 1. Pull down https://github.com/johnhubbard/linux/commits/gup_dma_core
> >> and find missing conversions: look for any additional missing 
> >> get_user_pages/put_page conversions. You've already found a couple missing 
> >> ones. I haven't re-run a search in a long time, so there's probably even more.
> >> 	a) And find more, after I rebase to 5.3-rc1: people probably are adding
> >> 	get_user_pages() calls as we speak. :)
> > Shouldn't this be documented then? I don't see any docs for using
> > put_user_page*() in v5.2.1 in the memory management API section?
> 
> Yes, it needs documentation. My first try (which is still in the above git
> repo) was reviewed and found badly wanting, so I'm going to rewrite it. Meanwhile,
> I agree that an interim note would be helpful, let me put something together.
> 
> [...]
> >>     https://github.com/johnhubbard/linux/commits/gup_dma_core
> >>
> >>     a) gets rebased often, and
> >>
> >>     b) has a bunch of commits (iov_iter and related) that conflict
> >>        with the latest linux.git,
> >>
> >>     c) has some bugs in the bio area, that I'm fixing, so I don't trust
> >>        that's it's safely runnable, for a few more days.
> > I assume your repo contains only work related to fixing gup issues and
> > not the main repo for gup development? i.e where gup changes are merged?
> 
> Correct, this is just a private tree, not a maintainer tree. But I'll try to
> keep the gup_dma_core branch something that is usable by others, during the
> transition over to put_user_page(), because the page-tracking patches are the
> main way to test any put_user_page() conversions.
> 
> As Ira said, we're using linux-mm as the real (maintainer) tree.
Thanks for the info! 
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA

