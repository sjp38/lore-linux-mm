Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 685D5C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 07:49:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EEDC217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 07:49:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EEDC217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACEB98E0002; Mon, 18 Feb 2019 02:49:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7C988E0001; Mon, 18 Feb 2019 02:49:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 992F78E0002; Mon, 18 Feb 2019 02:49:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7328E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 02:49:42 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 35so15926206qty.12
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 23:49:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=drkJz+TDHq8btJFEo03IIxszTU6UhEPx3LnkIUBJSlg=;
        b=harHx9aacJXu6hTInTYZUeseXCUWhrDYX4uCa1RLVB+cUwe/UyXMcHV0sXERDHjyJq
         5sW+TRN9IGl44hI/RJzFJ7Eg9tggfwQQhaHYMBlb0KvdaPQQdlzA5udDeoWBkoqRDDHm
         n9b1vNu/osOMVI0QT5+7rxDDEBn4FWjY5MaWonyFzf1ROQYQacoZWt74ps/trPDbj7u2
         hZdD15l7PIMVZsP+6O1r+1xfoYab9EeZUtsusAy83d323FUbX8yEA6Mj1FjotLkYVOX8
         0rvyFog3chxk6byChDrW8SCxsIB/lf4sj9wQw0+vlwW+kx45USpahBPqw2zgTw1r/VJY
         8Aeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubej8+5PpaVgKzXOevts8W48gRJptSOPbIBDL/C+PxtJIjAYfwH
	ypd9QF5OKfpxg8ySPaVMfIkesF8ZyXIUTaOE9SkZW2qqTd/kn+FM+mM8sBkebQvy9dOFqw8gpRr
	V+7uzEeMrjQtKn/v0HQO1Tkj57hmsbSdbKQaKg7kMSpk1PJww9M4gM8wXvgTBlQQPEA==
X-Received: by 2002:a37:2f86:: with SMTP id v128mr2562482qkh.305.1550476182174;
        Sun, 17 Feb 2019 23:49:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iba03iWOOiV5l4rHuEs5FCzcZuDc9Cc6kKnAgo6KsK5KsJb5t0027rHKlCqm8Lp9sEYdDvn
X-Received: by 2002:a37:2f86:: with SMTP id v128mr2562450qkh.305.1550476181090;
        Sun, 17 Feb 2019 23:49:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550476181; cv=none;
        d=google.com; s=arc-20160816;
        b=tPSBCtmLty3UIjAEx3zVZBvCU3hr29C1lX4GueX/zvAQyR2566n4nRj5KWQEZ2xYEQ
         y641Fmem2HXEkHa0PqVgNFWn2KmFHlw0SJL2hClIV1y0HpKk2EScvwqh2p1OyOXM2cCw
         cz3IONsPiKOejZyOo3BoeOzcQAmH4Gb2q+VHB/zSSLF34X7lsrY7axJJjWYjd5ZY3HRf
         JLnVfk/H4tc8ON9l18J44WwawNT2lpqzX11pZMXj+0+AFWEEGy1k3dH8lnO4zqnBKqRP
         LfNv4vKN1QXyNeYZSxYk+jtTLZlqUi62cEOl7OksCxYtkIxj4lwz8rdsR3XWp06XEduT
         tYuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=drkJz+TDHq8btJFEo03IIxszTU6UhEPx3LnkIUBJSlg=;
        b=hwzo5Aln6Z4AT0XXzpAXLhRob3NdQHbFvQmCBldvBsZ4lVVIIX+QqFtK9AiXOjH8zn
         wV/aGg1ufbRkDc/CBxcOUxh8ocKBkYPv/l+br3geEA6TiUStflnXIwvC19Cm6+DZDlTc
         DObfA+J2Wk2JldQ6DZtLQ9idxD/lW/q9Fd9Zbnwpc0yiT8v+Thkg/7OnYYBse8himKuy
         UvxAp/4p+tWhEh34l0VxTJxEN9fMLs6fp3kjbMFebxUtvsjWivzHFvCTt4ka2Lt7BFfD
         D2v1+BCDv2BZEmG9rXc3FY7WRWm7NKOH1iKRyrXjN2DxlJEpmImJBAIfcJqZg9dZp+Gv
         iluw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r20si3561300qvl.44.2019.02.17.23.49.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Feb 2019 23:49:41 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 50FDE36887;
	Mon, 18 Feb 2019 07:49:39 +0000 (UTC)
Received: from ming.t460p (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 01D95608C7;
	Mon, 18 Feb 2019 07:49:12 +0000 (UTC)
Date: Mon, 18 Feb 2019 15:49:08 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Jens Axboe <axboe@kernel.dk>
Cc: Bart Van Assche <bvanassche@acm.org>, Mike Snitzer <snitzer@redhat.com>,
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
Message-ID: <20190218074907.GA806@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
 <1550250855.31902.102.camel@acm.org>
 <18c711a9-ca13-885d-43cd-4d48e683a6a2@kernel.dk>
 <20190217131332.GC7296@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190217131332.GC7296@ming.t460p>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Mon, 18 Feb 2019 07:49:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 17, 2019 at 09:13:32PM +0800, Ming Lei wrote:
> On Fri, Feb 15, 2019 at 10:59:47AM -0700, Jens Axboe wrote:
> > On 2/15/19 10:14 AM, Bart Van Assche wrote:
> > > On Fri, 2019-02-15 at 08:49 -0700, Jens Axboe wrote:
> > >> On 2/15/19 4:13 AM, Ming Lei wrote:
> > >>> This patchset brings multi-page bvec into block layer:
> > >>
> > >> Applied, thanks Ming. Let's hope it sticks!
> > > 
> > > Hi Jens and Ming,
> > > 
> > > Test nvmeof-mp/002 fails with Jens' for-next branch from this morning.
> > > I have not yet tried to figure out which patch introduced the failure.
> > > Anyway, this is what I see in the kernel log for test nvmeof-mp/002:
> > > 
> > > [  475.611363] BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
> > > [  475.621188] #PF error: [normal kernel read fault]
> > > [  475.623148] PGD 0 P4D 0  
> > > [  475.624737] Oops: 0000 [#1] PREEMPT SMP KASAN
> > > [  475.626628] CPU: 1 PID: 277 Comm: kworker/1:1H Tainted: G    B             5.0.0-rc6-dbg+ #1
> > > [  475.630232] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> > > [  475.633855] Workqueue: kblockd blk_mq_requeue_work
> > > [  475.635777] RIP: 0010:__blk_recalc_rq_segments+0xbe/0x590
> > > [  475.670948] Call Trace:
> > > [  475.693515]  blk_recalc_rq_segments+0x2f/0x50
> > > [  475.695081]  blk_insert_cloned_request+0xbb/0x1c0
> > > [  475.701142]  dm_mq_queue_rq+0x3d1/0x770
> > > [  475.707225]  blk_mq_dispatch_rq_list+0x5fc/0xb10
> > > [  475.717137]  blk_mq_sched_dispatch_requests+0x256/0x300
> > > [  475.721767]  __blk_mq_run_hw_queue+0xd6/0x180
> > > [  475.725920]  __blk_mq_delay_run_hw_queue+0x25c/0x290
> > > [  475.727480]  blk_mq_run_hw_queue+0x119/0x1b0
> > > [  475.732019]  blk_mq_run_hw_queues+0x7b/0xa0
> > > [  475.733468]  blk_mq_requeue_work+0x2cb/0x300
> > > [  475.736473]  process_one_work+0x4f1/0xa40
> > > [  475.739424]  worker_thread+0x67/0x5b0
> > > [  475.741751]  kthread+0x1cf/0x1f0
> > > [  475.746034]  ret_from_fork+0x24/0x30
> > > 
> > > (gdb) list *(__blk_recalc_rq_segments+0xbe)
> > > 0xffffffff816a152e is in __blk_recalc_rq_segments (block/blk-merge.c:366).
> > > 361                                                  struct bio *bio)
> > > 362     {
> > > 363             struct bio_vec bv, bvprv = { NULL };
> > > 364             int prev = 0;
> > > 365             unsigned int seg_size, nr_phys_segs;
> > > 366             unsigned front_seg_size = bio->bi_seg_front_size;
> > > 367             struct bio *fbio, *bbio;
> > > 368             struct bvec_iter iter;
> > > 369
> > > 370             if (!bio)
> > 
> > Just ran a few tests, and it also seems to cause about a 5% regression
> > in per-core IOPS throughput. Prior to this work, I could get 1620K 4k
> > rand read IOPS out of core, now I'm at ~1535K. The cycler stealer seems
> > to be blk_queue_split() and blk_rq_map_sg().
> 
> Could you share us your test setting?
> 
> I will run null_blk first and see if it can be reproduced.

Looks this performance drop isn't reproduced on null_blk with the following
setting by me:

- modprobe null_blk nr_devices=4 submit_queues=48
- test machine : dual socket, two NUMA nodes, 24cores/socket
- fio script:
fio --direct=1 --size=128G --bsrange=4k-4k --runtime=40 --numjobs=48 --ioengine=libaio --iodepth=64 --group_reporting=1 --filename=/dev/nullb0 --name=randread --rw=randread

result: 10.7M IOPS(base kernel), 10.6M IOPS(patched kernel)

And if 'bs' is increased to 256k, 512k, 1024k, IOPS improvement can be ~8%
with multi-page bvec patches in above test.

BTW, there isn't cost added to bio_for_each_bvec(), so blk_queue_split() and
blk_rq_map_sg() should be fine. However, bio_for_each_segment_all()
may not be quick as before.


Thanks,
Ming

