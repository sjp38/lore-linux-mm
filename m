Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F8E9C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 13:12:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E4521A4A
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 13:12:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E4521A4A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07B6C8E0003; Sun, 17 Feb 2019 08:12:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02AD68E0001; Sun, 17 Feb 2019 08:12:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5B678E0003; Sun, 17 Feb 2019 08:12:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B97948E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 08:12:00 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id n95so14151918qte.16
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 05:12:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dWsk+dOzRWmE/biPAbqtO6LSTtbTd0rgx3kkwsXDSEQ=;
        b=M2lE0P5+1PDWI3Re9EOeZyNVdBnfuujNF21NhkgXgp7ZgJ90oHfVfy15tTwUNMErek
         YliBoFGGynvxrz74VGw64sP7js+lf2DAxleGbDC1iEF/TgIs0umWHQmTqIvPpBLVKP79
         5Gga9V4YawMAYfBrncIdEHZi0fxV99RU/SKEUG4ACM0gMHqxqW05QidumgcvFCInGpoP
         GbFl5uGZEjsTpfstsAABi2sexl9V02Mf79BrBH2qwnSHBWkE1Jsvx9Djzjq14g3aqr2W
         IhR8ygsDztXJqYdzCVyp3Qoo7LMtaMyg8l9AEHGjGKBbdmjeC9bXQcKMqgpviAUd80kS
         7hXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubROzoFnnoyX4Fm12028oB6HbOdtYwYtBmMKH5vJuBBz8UvpcXK
	811yoO2vwO2mYjINEKR20tXVn7NZA31tFrz7kee2sxNiwwsWf4XjAe+AgdMiUIuzeKITgi37FGg
	AEHaM4P1fDEw0LDkQcLr1/HHv3YqnMWyYuSGvc+bXeKLeu4iE6l/y9Vv/tqkfCntJGw==
X-Received: by 2002:a37:32c7:: with SMTP id y190mr13557497qky.345.1550409120526;
        Sun, 17 Feb 2019 05:12:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYbyvuAthkcZDDbJCorK/7Jr3Yv7NfONXlBbtZgK1QtLmlRZGEeu3S0kUZRe2h+3YAwLB4u
X-Received: by 2002:a37:32c7:: with SMTP id y190mr13557452qky.345.1550409119754;
        Sun, 17 Feb 2019 05:11:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550409119; cv=none;
        d=google.com; s=arc-20160816;
        b=OpMYHoOFPrG66Xug4rV3BfUGmsXzR1TCCQ9L3+4v33Hp5sKsCyymk6UZovFaemDfJI
         eYWrnfvxwv6fERjxxiZFKYU/n/VCnp3RWxsySiWo18NEwVJ7dqWm2WpiOsMV7StJrbSF
         WmtfSBPtufUcCKh+e5FhySpJpnep32k+CGp9W1xcLD+OuZfam4TBQhxvRoXgqjWaKO9J
         ev7t7xBlJ2gqDUrdlORt1ChIuRp74N9BAqVhCSnsE7stwsUXCBVRXmjr/jq7ZhcOvAjs
         C3WqV/4hUoVu0Y7PuoTQHAPj5tXfV4DOPLjUrfOvUcFYfgw7Iq/jhJHl+gkvFqA39ovt
         GgRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dWsk+dOzRWmE/biPAbqtO6LSTtbTd0rgx3kkwsXDSEQ=;
        b=UdiqDYP7zBrrGLtG4htuv0eI0qJCnf66SDS1nuQsSzNFbJKzyHXtyNuYrKdZvFdaw9
         MRfW4UaZ2cFPefSr5hJQTzgfVve/Vs5WRY7OtuQyGJ92RY7QqWUT/rFLZju7ILPvvBQW
         kd50UWiJHhL5jQBEZ1ykxdFk5Znr9MQsUlhoyImNGrUK2w7qrcINu7tPsvfPxYF5glYr
         3ya5pS4uMxXrAD5mrXU7VPcCG/8jFsXuWSLruCbg8UdDRaWF5Cp61/ebT9Yvj3UzqwRR
         KvdNU5/StxvWzr9FRIWyHkfSVJS55IBa06SFAZqq4edaOWNapfERZBvVYEjl+1RcCYX1
         amoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g13si1628508qkg.240.2019.02.17.05.11.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Feb 2019 05:11:59 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 931F17AEAE;
	Sun, 17 Feb 2019 13:11:58 +0000 (UTC)
Received: from ming.t460p (ovpn-8-16.pek2.redhat.com [10.72.8.16])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 544DB60BF7;
	Sun, 17 Feb 2019 13:11:33 +0000 (UTC)
Date: Sun, 17 Feb 2019 21:11:29 +0800
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
Message-ID: <20190217131128.GB7296@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
 <1550250855.31902.102.camel@acm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550250855.31902.102.camel@acm.org>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Sun, 17 Feb 2019 13:11:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 09:14:15AM -0800, Bart Van Assche wrote:
> On Fri, 2019-02-15 at 08:49 -0700, Jens Axboe wrote:
> > On 2/15/19 4:13 AM, Ming Lei wrote:
> > > This patchset brings multi-page bvec into block layer:
> > 
> > Applied, thanks Ming. Let's hope it sticks!
> 
> Hi Jens and Ming,
> 
> Test nvmeof-mp/002 fails with Jens' for-next branch from this morning.
> I have not yet tried to figure out which patch introduced the failure.
> Anyway, this is what I see in the kernel log for test nvmeof-mp/002:
> 
> [  475.611363] BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
> [  475.621188] #PF error: [normal kernel read fault]
> [  475.623148] PGD 0 P4D 0  
> [  475.624737] Oops: 0000 [#1] PREEMPT SMP KASAN
> [  475.626628] CPU: 1 PID: 277 Comm: kworker/1:1H Tainted: G    B             5.0.0-rc6-dbg+ #1
> [  475.630232] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [  475.633855] Workqueue: kblockd blk_mq_requeue_work
> [  475.635777] RIP: 0010:__blk_recalc_rq_segments+0xbe/0x590
> [  475.670948] Call Trace:
> [  475.693515]  blk_recalc_rq_segments+0x2f/0x50
> [  475.695081]  blk_insert_cloned_request+0xbb/0x1c0
> [  475.701142]  dm_mq_queue_rq+0x3d1/0x770
> [  475.707225]  blk_mq_dispatch_rq_list+0x5fc/0xb10
> [  475.717137]  blk_mq_sched_dispatch_requests+0x256/0x300
> [  475.721767]  __blk_mq_run_hw_queue+0xd6/0x180
> [  475.725920]  __blk_mq_delay_run_hw_queue+0x25c/0x290
> [  475.727480]  blk_mq_run_hw_queue+0x119/0x1b0
> [  475.732019]  blk_mq_run_hw_queues+0x7b/0xa0
> [  475.733468]  blk_mq_requeue_work+0x2cb/0x300
> [  475.736473]  process_one_work+0x4f1/0xa40
> [  475.739424]  worker_thread+0x67/0x5b0
> [  475.741751]  kthread+0x1cf/0x1f0
> [  475.746034]  ret_from_fork+0x24/0x30
> 
> (gdb) list *(__blk_recalc_rq_segments+0xbe)
> 0xffffffff816a152e is in __blk_recalc_rq_segments (block/blk-merge.c:366).
> 361                                                  struct bio *bio)
> 362     {
> 363             struct bio_vec bv, bvprv = { NULL };
> 364             int prev = 0;
> 365             unsigned int seg_size, nr_phys_segs;
> 366             unsigned front_seg_size = bio->bi_seg_front_size;
> 367             struct bio *fbio, *bbio;
> 368             struct bvec_iter iter;
> 369
> 370             if (!bio)
> 
> Bart.

Thanks for your test!

The following patch should fix this issue:


diff --git a/block/blk-merge.c b/block/blk-merge.c
index bed065904677..066b66430523 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -363,13 +363,15 @@ static unsigned int __blk_recalc_rq_segments(struct request_queue *q,
 	struct bio_vec bv, bvprv = { NULL };
 	int prev = 0;
 	unsigned int seg_size, nr_phys_segs;
-	unsigned front_seg_size = bio->bi_seg_front_size;
+	unsigned front_seg_size;
 	struct bio *fbio, *bbio;
 	struct bvec_iter iter;
 
 	if (!bio)
 		return 0;
 
+	front_seg_size = bio->bi_seg_front_size;
+
 	switch (bio_op(bio)) {
 	case REQ_OP_DISCARD:
 	case REQ_OP_SECURE_ERASE:

Thanks,
Ming

