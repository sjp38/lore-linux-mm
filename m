Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 361C4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E59AC20863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 13:43:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E59AC20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8129B8E0003; Tue, 26 Feb 2019 08:43:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C25A8E0001; Tue, 26 Feb 2019 08:43:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68A848E0003; Tue, 26 Feb 2019 08:43:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 395268E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 08:43:18 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id f70so10286704qke.8
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 05:43:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=5mMzx/V+dR+di3hpAXkGPrfAlwNFownHeXp7yqIOXR0=;
        b=teyhtQlKLe6jjZgsz9R6S1KYCtlm1DPT5urBc1B9xFIKABwxWgwUBrX8A2xXiGJMDp
         WEvoyZi+dYyFDAAuJegZxrBIUror2//Lj0wfb/4jKjqShjdbqpLQRk2fun3EtmnagzId
         ewbEIE2Ucb+x7YXQoA+g9mML3pOxSuAyPhneH2O4zIBkpsTEvhixxNdQnAnzN+B8BPaR
         O8U907lT+jDCT7QdlnduIafez7xkDKxKs6a6QAe4B/epWp06EJQs6qGBsRgXml+r9nkS
         mzGtxwchzVVpSC70hbi6RNhrZHw5ebG2hRxhtJ0r9OQfVWFmfllrGMR/QutlaaeKG2Cq
         XbOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ3caUMnai9bt2nFPu9+T7TU+/AQsH6irwJOyCr9pSRx5Z6yMya
	NAv8xq05v0jsnzGFeMsdQBaYl67UI3O152lzWYtLcoYARW7UkNleqG92vs6cvg4SBsg7sBQ1e46
	snTUm7d4Yn/SG2iRltgX40kWzbovUBXMv2Wz3fJc/2u6Lz2KizzQ8CHtcdOaUsaUXTw==
X-Received: by 2002:a0c:93ab:: with SMTP id f40mr18223187qvf.59.1551188597930;
        Tue, 26 Feb 2019 05:43:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IawYQDhoHtC8vNCbwLq///aUvLDK/lk7mDL7jdwWntoYc3YPt3BDjeKLFyz3Hr6CNCrD4Wl
X-Received: by 2002:a0c:93ab:: with SMTP id f40mr18223142qvf.59.1551188597213;
        Tue, 26 Feb 2019 05:43:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551188597; cv=none;
        d=google.com; s=arc-20160816;
        b=Bf9D9wiGtZWwwgg2sMHEPYZ1+wetUMWb7FoBcE2/69yW6qb0q2ERyEtdP/lzmSxjVu
         8t86i4c9TqKfbczA3xCDilGTw0KOq61GQM67WAR2YF8hS00inOLNFEbMWEy7PX0l0tYN
         CgrHRJ9xYQK0EmPLcgloYi+ZkfGGn1p5QhbN7lVY1Zj0sbaNBz8VRXRtS7u0WtE6GPyj
         P688/4Dc4oOly77qY/TOix965eEoe5JNgQ8/OJug9WS98SD3/9cbirEEPY0BZoT4okvE
         e/ThF5J6crfJG0BAzFpjDc3qRTTM7GYcpTcOk46BaSx6SxdHfbZoNhUrbl1sqV3Qjwpq
         ZNQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=5mMzx/V+dR+di3hpAXkGPrfAlwNFownHeXp7yqIOXR0=;
        b=sDzB8QOQuHx44pVi4VReMfNzmWpXWnte96b5yXYQ23MgGvggOP0FHPlxq9rtgAk60F
         3mYo7KfUn2CHmYMlytKLI/XJLLCqT90E8WIPJtoXlDOaObaxmNUXwwj266sbrqg8LQVY
         oPuU6p+aIH2Y2CKGhNDvNsN4FD61gQcSraJPHX9YO0d0cwaQ8q+NSmmgDyvtOnABFePm
         WOhGmEUN4O3umBwBFhmVyEptia0imaDF4ovidUtTzISNRHyvBRhSSNJfdNHpi3psZuJN
         Xxt8nYOcbwm8Xd5xC7iIww8p/ULFMPbpVdWEKwvkTzVuoNU2hK+vT/SUfHLZug68sTXY
         kS2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m11si2825963qkk.267.2019.02.26.05.43.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 05:43:17 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D712F30BC133;
	Tue, 26 Feb 2019 13:43:15 +0000 (UTC)
Received: from ming.t460p (ovpn-8-17.pek2.redhat.com [10.72.8.17])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 09CFD5D9D2;
	Tue, 26 Feb 2019 13:42:53 +0000 (UTC)
Date: Tue, 26 Feb 2019 21:42:48 +0800
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
Message-ID: <20190226134247.GA30942@ming.t460p>
References: <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
 <20190226045826.GJ23020@dastard>
 <20190226093302.GA24879@ming.t460p>
 <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com>
 <20190226121209.GC11592@bombadil.infradead.org>
 <20190226123545.GA6163@ming.t460p>
 <20190226130230.GD11592@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226130230.GD11592@bombadil.infradead.org>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 26 Feb 2019 13:43:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 05:02:30AM -0800, Matthew Wilcox wrote:
> On Tue, Feb 26, 2019 at 08:35:46PM +0800, Ming Lei wrote:
> > On Tue, Feb 26, 2019 at 04:12:09AM -0800, Matthew Wilcox wrote:
> > > On Tue, Feb 26, 2019 at 07:12:49PM +0800, Ming Lei wrote:
> > > > The buffer needs to be device block size aligned for dio, and now the block
> > > > size can be 512, 1024, 2048 and 4096.
> > > 
> > > Why does the block size make a difference?  This requirement is due to
> > > some storage devices having shoddy DMA controllers.  Are you saying there
> > > are devices which can't even do 512-byte aligned I/O?
> > 
> > Direct IO requires that, see do_blockdev_direct_IO().
> > 
> > This issue can be triggered when running xfs over loop/dio. We could
> > fallback to buffered IO under this situation, but not sure it is the
> > only case.
> 
> Wait, we're imposing a ridiculous amount of complexity on XFS for no
> reason at all?  We should just change this to 512-byte alignment.  Tying
> it to the blocksize of the device never made any sense.

OK, that is fine since we can fallback to buffered IO for loop in case of
unaligned dio.

Then something like the following patch should work for all fs, could
anyone comment on this approach?

--

diff --git a/block/blk-lib.c b/block/blk-lib.c
index 5f2c429d4378..76f09f23a410 100644
--- a/block/blk-lib.c
+++ b/block/blk-lib.c
@@ -405,3 +405,44 @@ int blkdev_issue_zeroout(struct block_device *bdev, sector_t sector,
 	return ret;
 }
 EXPORT_SYMBOL(blkdev_issue_zeroout);
+
+static struct kmem_cache *sector_buf_slabs[(PAGE_SIZE >> 9) - 1];
+
+void *blk_alloc_sec_buf(unsigned size, gfp_t flags)
+{
+	int idx;
+
+	size = round_up(size, 512);
+	if (size >= PAGE_SIZE)
+		return NULL;
+
+	idx = (size >> 9) - 1;
+	if (!sector_buf_slabs[idx])
+		return NULL;
+	return kmem_cache_alloc(sector_buf_slabs[idx], flags);
+}
+EXPORT_SYMBOL_GPL(blk_alloc_sec_buf);
+
+void blk_free_sec_buf(void *buf, int size)
+{
+	size = round_up(size, 512);
+	if (size >= PAGE_SIZE)
+		return;
+
+	return kmem_cache_free(sector_buf_slabs[(size >> 9) - 1], buf);
+}
+EXPORT_SYMBOL_GPL(blk_free_sec_buf);
+
+void __init blk_sector_buf_init(void)
+{
+	unsigned size;
+
+	for (size = 512; size < PAGE_SIZE; size += 512) {
+		char name[16];
+		int idx = (size >> 9) - 1;
+
+		snprintf(name, 16, "blk_sec_buf-%u", size);
+		sector_buf_slabs[idx] = kmem_cache_create(name, size, 512,
+							  SLAB_PANIC, NULL);
+	}
+}
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index faed9d9eb84c..a4117e526715 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1657,6 +1657,9 @@ extern int bdev_read_page(struct block_device *, sector_t, struct page *);
 extern int bdev_write_page(struct block_device *, sector_t, struct page *,
 						struct writeback_control *);
 
+extern void *blk_alloc_sec_buf(unsigned size, gfp_t flags);
+extern void blk_free_sec_buf(void *buf, int size);
+
 #ifdef CONFIG_BLK_DEV_ZONED
 bool blk_req_needs_zone_write_lock(struct request *rq);
 void __blk_req_zone_write_lock(struct request *rq);
@@ -1755,6 +1758,15 @@ static inline int blkdev_issue_flush(struct block_device *bdev, gfp_t gfp_mask,
 	return 0;
 }
 
+static inline void *blk_alloc_sec_buf(unsigned size, gfp_t flags)
+{
+	return NULL;
+}
+
+static inline void blk_free_sec_buf(void *buf, int size)
+{
+}
+
 #endif /* CONFIG_BLOCK */
 
 static inline void blk_wake_io_task(struct task_struct *waiter)

Thanks,
Ming

