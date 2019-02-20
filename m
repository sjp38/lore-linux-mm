Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB276C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 01:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D9DE21738
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 01:17:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D9DE21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6E0A8E0003; Tue, 19 Feb 2019 20:17:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D45158E0002; Tue, 19 Feb 2019 20:17:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0C288E0003; Tue, 19 Feb 2019 20:17:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 94CE08E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 20:17:51 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so21666433qte.16
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 17:17:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cxz8PSCizWLyu3nFHbrT9aZjAmozVtiHFlv4/k/JLV8=;
        b=IQKwvcxL8E/y0Tann9GkrB5hyYpni+XjIM+JZ8fKbUOF0aDeToWd/cC2Mu6ex6vslG
         xzhJuMIC7KJXPtzC5o+Fhj8CUaucpXCjsjAVo+7gtDgYcILblbKf6WaO1x7dBpFnnjIt
         s2obwGrVXFhnilKbY2+GU7OUYw5xyGClP6vAVP5xd3z0AwUt3uwNrb5pat2MlOIyERgj
         rMxtfverIKF7iCpo5vjLZP/vSOC8PR+A0AiaoKpc6Wuo9LCw7z8YulY7tUiXCljew/WI
         WLwiCwN6+Gl6FuP1ZMP/7HM2/d4dco2ILPA8IMG0v/gEadOEcVBiOODcVKCGMf/C7W78
         59Jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub4nfrlO6Dr675+2YNpl3UNMZYCiXvpHfnXDiPRE6NJ8W9VN4Yk
	VVeb4OZDJSxQSqKkS5LH5euNt57xpm8wpDtMLxyZ6mhFAsmkFWyna3MQ/TQ3wK/ae2kZB9nXEwz
	9ApZ91OyBAfsbuARgsJN9IkAMlvZ7UiwTUmrmOkPq0OoKFujmZCO0PTlZrJhch6Q1oA==
X-Received: by 2002:a0c:b6d2:: with SMTP id h18mr10477700qve.216.1550625471298;
        Tue, 19 Feb 2019 17:17:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZxakTMXVo4N7Xcb9XuJOhSJm/7jLb7UaXkviI50DO6zkR/mbl0+QggPC1COHIbPArOpQ6i
X-Received: by 2002:a0c:b6d2:: with SMTP id h18mr10477657qve.216.1550625470309;
        Tue, 19 Feb 2019 17:17:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550625470; cv=none;
        d=google.com; s=arc-20160816;
        b=C/YEFXatJZ9Ncvr77XX/dBC/cYBB4+OS1op5dQ4soEQCiUh4YKsCTnShrqX/A0pU8o
         prqe9WCuKg1OI6W4DXC9VFQTlKCja7yCILrxrejL5UStb8QZn52fGpUNC9Kmib/zKWuS
         03MRMBv0WsIueb/UL+r24ajAu/vnNOpKUQLOAg7DAWu4bIahI62sMHqQ5/wKnU9jzN9j
         zhn8WhS7IiKUlldTS68M7Hx9YKFPliKcR1hTdjzyF5hcjnRmS+I1wTenNSz0aT4n/nES
         R5ARclb6qmuMskJYi7HvDr+w7V3iDrO52w57q6kKZe99ujWNpd9DIkXIl7Cr3Lwsg/s7
         zFrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cxz8PSCizWLyu3nFHbrT9aZjAmozVtiHFlv4/k/JLV8=;
        b=OgtEbCotFZPEf6K0Zv7TO4m5AuL/7W5aUa0enrce/XOE2jauIhSgBIw9HsQohgG4tD
         LZh0FMieoEdBW6S+rgt6V5THk8rWvRZzgPW3+Zbaxj4rf7pGCRB6yncKN2eAGnAnH0qv
         R1me7AhIy4aBAchZ6Y+qasBsnMNuGFAsrkYEieyN4gwdfnlajh89vtyBm0XhHe9AIQ2w
         EoO3P8coCRh5EAnWWTRHI9ahgkEmtzhiLu7s6fyH+tkE78isJtP03RZrtQ8ceL99OWzc
         ZqDbuO9Z79ROCl4Utjfv6qXwbA3OvCK+SqBzsJTQ42WMG+UkTVqTHqPHGULz9lFV9vys
         JRSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t18si3057317qvc.110.2019.02.19.17.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 17:17:50 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 14EB83D978;
	Wed, 20 Feb 2019 01:17:48 +0000 (UTC)
Received: from ming.t460p (ovpn-8-26.pek2.redhat.com [10.72.8.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 86BC461B93;
	Wed, 20 Feb 2019 01:17:25 +0000 (UTC)
Date: Wed, 20 Feb 2019 09:17:20 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Bart Van Assche <bvanassche@acm.org>
Cc: Jens Axboe <axboe@kernel.dk>, Mike Snitzer <snitzer@redhat.com>,
	linux-mm@kvack.org, dm-devel@redhat.com,
	Christoph Hellwig <hch@lst.de>, Sagi Grimberg <sagi@grimberg.me>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Omar Sandoval <osandov@fb.com>, cluster-devel@redhat.com,
	linux-ext4@vger.kernel.org,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Boaz Harrosh <ooo@electrozaur.com>,
	Gao Xiang <gaoxiang25@huawei.com>, Coly Li <colyli@suse.de>,
	linux-raid@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>,
	linux-bcache@vger.kernel.org,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Dave Chinner <dchinner@redhat.com>, David Sterba <dsterba@suse.com>,
	linux-block@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
	linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org
Subject: Re: [dm-devel] [PATCH V15 00/18] block: support multi-page bvec
Message-ID: <20190220011719.GA13035@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
 <1550250855.31902.102.camel@acm.org>
 <20190217131128.GB7296@ming.t460p>
 <1550593699.31902.115.camel@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550593699.31902.115.camel@acm.org>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 20 Feb 2019 01:17:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 08:28:19AM -0800, Bart Van Assche wrote:
> On Sun, 2019-02-17 at 21:11 +0800, Ming Lei wrote:
> > The following patch should fix this issue:
> > 
> > 
> > diff --git a/block/blk-merge.c b/block/blk-merge.c
> > index bed065904677..066b66430523 100644
> > --- a/block/blk-merge.c
> > +++ b/block/blk-merge.c
> > @@ -363,13 +363,15 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
> >  	struct bio_vec bv, bvprv = { NULL };
> >  	int prev = 0;
> >  	unsigned int seg_size, nr_phys_segs;
> > -	unsigned front_seg_size = bio->bi_seg_front_size;
> > +	unsigned front_seg_size;
> >  	struct bio *fbio, *bbio;
> >  	struct bvec_iter iter;
> >  
> >  	if (!bio)
> >  		return 0;
> >  
> > +	front_seg_size = bio->bi_seg_front_size;
> > +
> >  	switch (bio_op(bio)) {
> >  	case REQ_OP_DISCARD:
> >  	case REQ_OP_SECURE_ERASE:
> 
> Hi Ming,
> 
> With this patch applied test nvmeof-mp/002 fails as follows:
> 
> [  694.700400] kernel BUG at lib/sg_pool.c:103!
> [  694.705932] invalid opcode: 0000 [#1] PREEMPT SMP KASAN
> [  694.708297] CPU: 2 PID: 349 Comm: kworker/2:1H Tainted: G    B             5.0.0-rc6-dbg+ #2
> [  694.711730] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [  694.715113] Workqueue: kblockd blk_mq_run_work_fn
> [  694.716894] RIP: 0010:sg_alloc_table_chained+0xe5/0xf0
> [  694.758222] Call Trace:
> [  694.759645]  nvme_rdma_queue_rq+0x2aa/0xcc0 [nvme_rdma]
> [  694.764915]  blk_mq_try_issue_directly+0x2a5/0x4b0
> [  694.771779]  blk_insert_cloned_request+0x11e/0x1c0
> [  694.778417]  dm_mq_queue_rq+0x3d1/0x770
> [  694.793400]  blk_mq_dispatch_rq_list+0x5fc/0xb10
> [  694.798386]  blk_mq_sched_dispatch_requests+0x2f7/0x300
> [  694.803180]  __blk_mq_run_hw_queue+0xd6/0x180
> [  694.808933]  blk_mq_run_work_fn+0x27/0x30
> [  694.810315]  process_one_work+0x4f1/0xa40
> [  694.813178]  worker_thread+0x67/0x5b0
> [  694.814487]  kthread+0x1cf/0x1f0
> [  694.819134]  ret_from_fork+0x24/0x30
> 
> The code in sg_pool.c that triggers the BUG() statement is as follows:
> 
> int sg_alloc_table_chained(struct sg_table *table, int nents,
> 		struct scatterlist *first_chunk)
> {
> 	int ret;
> 
> 	BUG_ON(!nents);
> [ ... ]
> 
> Bart.

I can reproduce this issue("kernel BUG at lib/sg_pool.c:103") without mp-bvec patches,
so looks it isn't the fault of this patchset.

Thanks,
Ming

