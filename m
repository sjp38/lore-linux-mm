Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51614C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 16:28:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8200217D9
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 16:28:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8200217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=acm.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D30E8E0003; Tue, 19 Feb 2019 11:28:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5839C8E0002; Tue, 19 Feb 2019 11:28:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47E5D8E0003; Tue, 19 Feb 2019 11:28:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 094498E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 11:28:24 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f125so14637408pgc.20
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 08:28:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZhUEzJ11ce3cQzbjIxeMP4LPtiXWa6qX61ZXbLMs8l0=;
        b=ujlIcEOzskgryVajoNps3KgiQ+TSyMPLaBWVXUL/QHn/xEBDiyGTQfwG35PpqZn6fv
         rtH4p/rwJACAJCiJxCdewLi7F2Q/0hik23erWzX4krTJmbGXMAVaRWrwIlkdFqSOliQn
         aSSUZBxSOKw8Op6M0acbnVhybu/c3FJG14EhcrlDouEt3qGdrgrFuG/g+FGLSeJjxCVp
         W7DBK7uSJU1gqOR19noo68ebrnB8nO/SGNZ/MX97bp2MnQWwpaUNSetoEV+WKqE7Tg/h
         0a4fgYx5ff3HnuPBs4RmsDkffoI1pbzEKJBmpgtkoxDr5BVx4X2TNq5bmyfmY590tXwg
         zarQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Gm-Message-State: AHQUAua5vodXzbZ2Wza4oQeE9aDcxIWccYvm/K239Kzata3CvDs14LFN
	3woas3YjlzV+S2UfHhnfRjyjzqfwZVKx087CBEUSxVZ3rC34lQI5rckh3o1JpfIq73LwZzNRzYe
	mi5RKiwAMMLOyYoNBYnPdsFr9fjloE+MXrxPMb4DIufQ6+Ed+HMVAnsJASlyM3XOtRrHOS2zzNG
	BJZkJypr8Z4Jv3d31EXPOpjGXUZ60BU6n1VSFr/zfwIbR98GHba1keutXr99eXVLGKPEUMWTXy7
	rMxGIfnd6ik+qAFSEQJTvmU3nB90HucEDMCa8pxudfDYKacKcImo1Lw3g2V12CkXvprJ/QM06Rl
	E9A07LK/stfl+veGJno92z+cp8t6JcGt/QuI+LzM4kJHSczBZIhpVTrvagq5E6D2Yxh+8q8zjw=
	=
X-Received: by 2002:a17:902:12e:: with SMTP id 43mr31988118plb.31.1550593703643;
        Tue, 19 Feb 2019 08:28:23 -0800 (PST)
X-Received: by 2002:a17:902:12e:: with SMTP id 43mr31988061plb.31.1550593702812;
        Tue, 19 Feb 2019 08:28:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550593702; cv=none;
        d=google.com; s=arc-20160816;
        b=zVGYToBL+BBPIVn8nZv2umGIzOe6TmABmJfa/W8CfroSt/uxlPASYpNlvOuydA50bs
         fBwb+9lmUVCtqhjQNOFy1cXPIliskrtRCdYEOuECJg+phb87bB8kM2LB6G65oLBlYwmO
         RcQSxNRigogMGSFu6NBji1gtT5HHy46q4xMjRkjkbNHYXKNNa33CH1Ce4lOiRnZ+lDuY
         pkOeIPyBM5VSvPwOtrRxPYcjFPHEBEZz89/rdpwIlzt4t2n1xLsTtHoPv+rDh1dTLHXb
         e8LMoMlOjg4DH8cIO8CQ1DldRROz3Ci+WRunJOL5NEjkjN/2YVUyWMZqQ/A+oU6E7+J3
         L/EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=ZhUEzJ11ce3cQzbjIxeMP4LPtiXWa6qX61ZXbLMs8l0=;
        b=dtJ8m8aL1/sER5n8scyC1bH7/bXJdYx9AV+UNk/s7JmYN9yvRLg70lEF/lvmAGEOq+
         YqJzdTykXSKoDtzAKL6D5nwoMN2KpLrmeUrZ2ekufWdLpS6IQZzKxvb0wqulOWB9K3K8
         K7buZOki+munDQ9yI2G8xHORAmMPqbNJa0TpLxZuUliS5kyIAnSyByrLcShhoOaBdnl3
         2w9t3olvk1nzVxuwbSjZwHeSKYJncHGCmw+2OZviYORFbD8aXd+fGwswIY63C08CX3aM
         i/YuqFUqcHDlczUVOmrMGnpwylSUMrU2sZawg3fluRR5gSIKOFJPpPQ5+VU0RXE44n+x
         1f0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f98sor2667070plb.66.2019.02.19.08.28.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 08:28:22 -0800 (PST)
Received-SPF: pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bart.vanassche@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bart.vanassche@gmail.com
X-Google-Smtp-Source: AHgI3IYcr+ifN0s1shU8ycdfyzx2FN9lPp8b9RER92vD0tlqUpLtYLgg6ra1ovZN7NoPo2lKtLSG0Q==
X-Received: by 2002:a17:902:147:: with SMTP id 65mr31872306plb.116.1550593702320;
        Tue, 19 Feb 2019 08:28:22 -0800 (PST)
Received: from ?IPv6:2620:15c:2cd:203:5cdc:422c:7b28:ebb5? ([2620:15c:2cd:203:5cdc:422c:7b28:ebb5])
        by smtp.gmail.com with ESMTPSA id u186sm24387204pfu.51.2019.02.19.08.28.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 08:28:20 -0800 (PST)
Message-ID: <1550593699.31902.115.camel@acm.org>
Subject: Re: [dm-devel] [PATCH V15 00/18] block: support multi-page bvec
From: Bart Van Assche <bvanassche@acm.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, Mike Snitzer <snitzer@redhat.com>, 
 linux-mm@kvack.org, dm-devel@redhat.com, Christoph Hellwig <hch@lst.de>,
 Sagi Grimberg <sagi@grimberg.me>, "Darrick J . Wong"
 <darrick.wong@oracle.com>, Omar Sandoval <osandov@fb.com>,
 cluster-devel@redhat.com, linux-ext4@vger.kernel.org, Kent Overstreet
 <kent.overstreet@gmail.com>, Boaz Harrosh <ooo@electrozaur.com>, Gao Xiang
 <gaoxiang25@huawei.com>, Coly Li <colyli@suse.de>,
 linux-raid@vger.kernel.org,  Bob Peterson <rpeterso@redhat.com>,
 linux-bcache@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Dave Chinner <dchinner@redhat.com>, David Sterba <dsterba@suse.com>,
 linux-block@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>,
 linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, 
 linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org
Date: Tue, 19 Feb 2019 08:28:19 -0800
In-Reply-To: <20190217131128.GB7296@ming.t460p>
References: <20190215111324.30129-1-ming.lei@redhat.com>
	 <c52b6a8b-d1d4-67ff-f81c-371d09cc6d5b@kernel.dk>
	 <1550250855.31902.102.camel@acm.org> <20190217131128.GB7296@ming.t460p>
Content-Type: text/plain; charset="UTF-7"
X-Mailer: Evolution 3.26.2-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2019-02-17 at 21:11 +-0800, Ming Lei wrote:
+AD4 The following patch should fix this issue:
+AD4 
+AD4 
+AD4 diff --git a/block/blk-merge.c b/block/blk-merge.c
+AD4 index bed065904677..066b66430523 100644
+AD4 --- a/block/blk-merge.c
+AD4 +-+-+- b/block/blk-merge.c
+AD4 +AEAAQA -363,13 +-363,15 +AEAAQA static unsigned int +AF8AXw-blk+AF8-recalc+AF8-rq+AF8-segments(struct request+AF8-queue +ACo-q,
+AD4  	struct bio+AF8-vec bv, bvprv +AD0 +AHs NULL +AH0AOw
+AD4  	int prev +AD0 0+ADs
+AD4  	unsigned int seg+AF8-size, nr+AF8-phys+AF8-segs+ADs
+AD4 -	unsigned front+AF8-seg+AF8-size +AD0 bio-+AD4-bi+AF8-seg+AF8-front+AF8-size+ADs
+AD4 +-	unsigned front+AF8-seg+AF8-size+ADs
+AD4  	struct bio +ACo-fbio, +ACo-bbio+ADs
+AD4  	struct bvec+AF8-iter iter+ADs
+AD4  
+AD4  	if (+ACE-bio)
+AD4  		return 0+ADs
+AD4  
+AD4 +-	front+AF8-seg+AF8-size +AD0 bio-+AD4-bi+AF8-seg+AF8-front+AF8-size+ADs
+AD4 +-
+AD4  	switch (bio+AF8-op(bio)) +AHs
+AD4  	case REQ+AF8-OP+AF8-DISCARD:
+AD4  	case REQ+AF8-OP+AF8-SECURE+AF8-ERASE:

Hi Ming,

With this patch applied test nvmeof-mp/002 fails as follows:

+AFs  694.700400+AF0 kernel BUG at lib/sg+AF8-pool.c:103+ACE
+AFs  694.705932+AF0 invalid opcode: 0000 +AFsAIw-1+AF0 PREEMPT SMP KASAN
+AFs  694.708297+AF0 CPU: 2 PID: 349 Comm: kworker/2:1H Tainted: G    B             5.0.0-rc6-dbg+- +ACM-2
+AFs  694.711730+AF0 Hardware name: QEMU Standard PC (i440FX +- PIIX, 1996), BIOS 1.10.2-1 04/01/2014
+AFs  694.715113+AF0 Workqueue: kblockd blk+AF8-mq+AF8-run+AF8-work+AF8-fn
+AFs  694.716894+AF0 RIP: 0010:sg+AF8-alloc+AF8-table+AF8-chained+-0xe5/0xf0
+AFs  694.758222+AF0 Call Trace:
+AFs  694.759645+AF0  nvme+AF8-rdma+AF8-queue+AF8-rq+-0x2aa/0xcc0 +AFs-nvme+AF8-rdma+AF0
+AFs  694.764915+AF0  blk+AF8-mq+AF8-try+AF8-issue+AF8-directly+-0x2a5/0x4b0
+AFs  694.771779+AF0  blk+AF8-insert+AF8-cloned+AF8-request+-0x11e/0x1c0
+AFs  694.778417+AF0  dm+AF8-mq+AF8-queue+AF8-rq+-0x3d1/0x770
+AFs  694.793400+AF0  blk+AF8-mq+AF8-dispatch+AF8-rq+AF8-list+-0x5fc/0xb10
+AFs  694.798386+AF0  blk+AF8-mq+AF8-sched+AF8-dispatch+AF8-requests+-0x2f7/0x300
+AFs  694.803180+AF0  +AF8AXw-blk+AF8-mq+AF8-run+AF8-hw+AF8-queue+-0xd6/0x180
+AFs  694.808933+AF0  blk+AF8-mq+AF8-run+AF8-work+AF8-fn+-0x27/0x30
+AFs  694.810315+AF0  process+AF8-one+AF8-work+-0x4f1/0xa40
+AFs  694.813178+AF0  worker+AF8-thread+-0x67/0x5b0
+AFs  694.814487+AF0  kthread+-0x1cf/0x1f0
+AFs  694.819134+AF0  ret+AF8-from+AF8-fork+-0x24/0x30

The code in sg+AF8-pool.c that triggers the BUG() statement is as follows:

int sg+AF8-alloc+AF8-table+AF8-chained(struct sg+AF8-table +ACo-table, int nents,
		struct scatterlist +ACo-first+AF8-chunk)
+AHs
	int ret+ADs

	BUG+AF8-ON(+ACE-nents)+ADs
+AFs ... +AF0

Bart.

