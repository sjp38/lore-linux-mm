Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31F2CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:59:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA66A21A4C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:59:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="KMz4etZx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA66A21A4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 754CB8E0002; Fri, 15 Feb 2019 12:59:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DE4D8E0001; Fri, 15 Feb 2019 12:59:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 57F878E0002; Fri, 15 Feb 2019 12:59:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D14C8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:59:52 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id i18so7824958ite.1
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:59:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=5Bgr0zj2aRmsmq9cmq2G6DDeTRau1JwWNabZdtGLuU8=;
        b=l/SfS54tNr6UGwAr98QrSlc2M28V9qbnSXIZ9J0d3F0Utekdr4X/2dFwTEAy2pdf1D
         ifBvAvaGdKv4V+AslVu4wMXYQEDsh24k+nUva/WttEtL6vMoerO4gQgkugxYGvQVy9R/
         4v9F4HwAO7b4HSoPWNXdiuGy5eDLX1vzYZF+hJBvXzmcSp7Yu9G+0KPJPtbZc7vTIg1P
         KiYVZrmHRAtMjrylSSuwdGbrEwFe4QD1hw/sWyE8RZd1QJma7W5VM7hrXX+0dENCTdGf
         D10NLbHrRfYosO7yPKP8k82R1IetS7fIZ6+ybuYtdnSoxxsfQcaUNQU5GpGqHg3PyU5h
         87fQ==
X-Gm-Message-State: AHQUAuaMzhp1ZOwKh0zumi9u6ZJJ5Wdrrdsd6CKWIgaF0iERviKF8pnl
	mdAEJCRtsO9hNQ5H8x5PcsbQRBnZ+pwm7Z5BNIYhZEltfEqnjh5UBr9QRP6aCF2RByh8AkKD2sl
	xNYTrniCfnazVOLit/Xp8MD3W6IejOVO2FNNrlzvTwwGSCW++3jzqzMe5sA7NbnpSW87mqMg6P4
	/0CZG4bIL0qYsiZCkRnm06ZsYiBpJYvutxiPbBHp5pmrdwycVNLmYFaoaqnw/3kdtoWs67ZxOVc
	vdoAq9D6/qiyAnM20PMAW13ncblkFWInUMjRggj+kYdpY9BbTuumBSl3Ds6lfYKYib27UBid+P8
	Cp8R1mb8QQvg5nIwnVY+XFBVpzSdICaFXrI6K5oVewQrZRdyjCKIztmpZkf/3GM7gmDuzCxUGNR
	5
X-Received: by 2002:a24:de87:: with SMTP id d129mr5496791itg.110.1550253591814;
        Fri, 15 Feb 2019 09:59:51 -0800 (PST)
X-Received: by 2002:a24:de87:: with SMTP id d129mr5496758itg.110.1550253591044;
        Fri, 15 Feb 2019 09:59:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550253591; cv=none;
        d=google.com; s=arc-20160816;
        b=pcYmlO+upgPiZ3vKR24ZUsX8KdvN9jwX7JOAFbzt+Cn28kIOMWPKjc/6lJjGrAij6v
         lHf9PNwXEWlC7HErUC2DkZblF/vUNcr/RHBOOlmtSmLUxl2MKoEMVe6n85+hDhav11BC
         ai/pwmnvQ3zyCr6NuM6HPF8V7u9DKXPs8hjzCeiEx6BsN0r55cV0fRdvusHN6dAAQjiV
         O32EyL7G0VxsYa8IO/RuqUPnoz2DZpDtfLHtd4QRbyJDLR3zwN0xhDvOin+nVUUWuQA9
         5LoRLppV1VD7aqFtXP39YxIcZPsU8ra8wP0Xb9AnmPJ3jMVaAVMLRy0XplrMU3gEdRP8
         mE1A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=5Bgr0zj2aRmsmq9cmq2G6DDeTRau1JwWNabZdtGLuU8=;
        b=akT/gsp7uZ534kJdhu3YyYl0NM3hghjlUXypZ8Bu7+3DuhyfsXoR2jMHd8RDbrBt4u
         Voc7YkY4Bbowuwra4Fqvra2apoQJqCHvbY3L+yC9l8lph/lsUVhu/6S7Il41eRZFmvpN
         l32sIzlnUj6BZHwUaNt/hSomhmkOVjUsyF6+SivhNKM5IuHk44usrdoSenHyN6cJegtE
         ADDNXqyQcadf4IynvlKRpBNC1900wCvFDtl1NJQqyLuYk5oLiOO+KKLqpgla/N8Y9uG5
         wPVI58qScZmZzpKznMSsxQAAkq0oEOnRGEZUa/clRxmaud5kviZEZdTfKT1emlqbd7Ju
         CqgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=KMz4etZx;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p65sor6320864jap.11.2019.02.15.09.59.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 09:59:50 -0800 (PST)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=KMz4etZx;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=5Bgr0zj2aRmsmq9cmq2G6DDeTRau1JwWNabZdtGLuU8=;
        b=KMz4etZxSVwp6ToDNVHa3UQ5ONXpp2fqM+/uuzn5Ym9qarUAL9M/eUOGtuee4TIrTa
         ubCuGgOn1V8Py7fyrabLO5lRu7vcV+IDhbJ94eazYzeqeXYFWWDHttWOw+yQpiBOj1ir
         dcFjII7LU/kMVttYP0gIeH5c1KoQHRZrKYfh3ZHvud2ojLZ3cx1ncCmK+/ompP2Ucv3z
         RqAeHx62HuzzzrLZrkkC3mQbaifqXn7tG1FHgrYi/1RPiOdD9nLbTrDqGpbw/i6OLrR2
         qy9Sj6sSUC5Fsxp86Toe1OSuHZYp1wmedRsen41kvhaIENqfCxh04YY76/7HUgTRKfsH
         n3YQ==
X-Google-Smtp-Source: AHgI3IbXlmYdrlCKnom68rsNd9Jn36YbM8bNEMGoKtZXICr/hlZrCiz2ntRDeSi7ie71hr+8xcfK8A==
X-Received: by 2002:a02:c943:: with SMTP id u3mr5868722jao.96.1550253590448;
        Fri, 15 Feb 2019 09:59:50 -0800 (PST)
Received: from [192.168.1.158] ([216.160.245.98])
        by smtp.gmail.com with ESMTPSA id b25sm2440259iot.10.2019.02.15.09.59.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 09:59:49 -0800 (PST)
Subject: Re: [dm-devel] [PATCH V15 00/18] block: support multi-page bvec
To: Bart Van Assche <bvanassche@acm.org>, Ming Lei <ming.lei@redhat.com>
Cc: Mike Snitzer <snitzer@redhat.com>, linux-mm@kvack.org,
 dm-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
 Sagi Grimberg <sagi@grimberg.me>, "Darrick J . Wong"
 <darrick.wong@oracle.com>, Omar Sandoval <osandov@fb.com>,
 cluster-devel@redhat.com, linux-ext4@vger.kernel.org,
 Kent Overstreet <kent.overstreet@gmail.com>,
 Boaz Harrosh <ooo@electrozaur.com>, Gao Xiang <gaoxiang25@huawei.com>,
 Coly Li <colyli@suse.de>, linux-raid@vger.kernel.org,
 Bob Peterson <rpeterso@redhat.com>, linux-bcache@vger.kernel.org,
 Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner
 <dchinner@redhat.com>, David Sterba <dsterba@suse.com>,
 linux-block@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
 linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org
References: <20190215111324.30129-1-ming.lei@redhat.com>
 <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
 <1550250855.31902.102.camel@acm.org>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <18c711a9-ca13-885d-43cd-4d48e683a6a2@kernel.dk>
Date: Fri, 15 Feb 2019 10:59:47 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1550250855.31902.102.camel@acm.org>
Content-Type: text/plain; charset=UTF-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/15/19 10:14 AM, Bart Van Assche wrote:
> On Fri, 2019-02-15 at 08:49 -0700, Jens Axboe wrote:
>> On 2/15/19 4:13 AM, Ming Lei wrote:
>>> This patchset brings multi-page bvec into block layer:
>>
>> Applied, thanks Ming. Let's hope it sticks!
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

Just ran a few tests, and it also seems to cause about a 5% regression
in per-core IOPS throughput. Prior to this work, I could get 1620K 4k
rand read IOPS out of core, now I'm at ~1535K. The cycler stealer seems
to be blk_queue_split() and blk_rq_map_sg().

-- 
Jens Axboe

