Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0AD0C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 11:54:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49C2E20657
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 11:54:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49C2E20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7AFA8E0003; Tue, 12 Mar 2019 07:54:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2A4F8E0002; Tue, 12 Mar 2019 07:54:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C183B8E0003; Tue, 12 Mar 2019 07:54:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98A808E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:54:07 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 207so1903029qkf.9
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:54:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=2kYB1p/b/VSU9SsB3LoLb0aZfIgS7NS7Z3NfTbSHKls=;
        b=l7UlPQ4bhXAMtX6SGZO8P5VFjvAEqRW/xy92NQ64SomWyWUZ4RS3tM0RZAzyi697O8
         GPMAEnK5nCcx2R214/+WF6uKeJt2dee3mZzxwXOhACZn9K7pHz5Ubi/7zM3Kes7wnFms
         BCV0Bw4ecLzyFEBRqOsLVbJPr1CcCimIDgCwanuCT7ztS4xPbnmizkUTQd5wESUhc8v/
         FfluBojr6xYBwwqdMFZzlJqSIBhFgucZ35Q0KILyGofQ985/opdAr+ad2NfwbPCBWvxr
         6C3AJDd35LoKBnqEgYN94edY0dOQmKQ8zSQBKcozh89l/NtwaPi9XLv9CF2rkTbJ6oA4
         GlIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWe3JHUzxWXy9AoKvSSZb24v3oLi59gOQr5nHMxjVs69e9tFaRb
	X7F9aEY2i6/n/aoEXKv6k735ar7SC3zUgV5DYsl3IbmG/oFY5FMXoX5SH5L3YvIOFJHbfUCrszR
	wVTPS0f2tohp00QyCNaZVcTcJfQYUyhea8NncU9U3H0F+b4GhsYZ+/CqeHOrZtiQOeVucnnCS0E
	xSNgJRqGzcEzAi96pfaYEOl12UMcst7EvkmTgt6+ynngrnqrsnukyG2Xxl+c5fAzNUuFQaRcdCm
	VoBocw67+9FykjIdyF4CC7pupdKLcktmqq+BrkCly0antMmxR3RFmnh+HyIVcNPT6sK3UoovBkq
	xqXTIK4nBUqvoVZo/C4Lkrd8Snuwdaf+PQdHTV/cVRe0U0FvRef3cqxyjTqoFxxDkoxFfUMr9zt
	x
X-Received: by 2002:a0c:b7a1:: with SMTP id l33mr29940849qve.160.1552391647392;
        Tue, 12 Mar 2019 04:54:07 -0700 (PDT)
X-Received: by 2002:a0c:b7a1:: with SMTP id l33mr29940807qve.160.1552391646443;
        Tue, 12 Mar 2019 04:54:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552391646; cv=none;
        d=google.com; s=arc-20160816;
        b=O+8tzteGlxK6GqgCZXa8dC6IRg+uDcwPmsumvZp0zO9zI/YzzvtYtctluNXAHpWbN6
         F2CqPUZ6a48YwjgIBtWABjYU+v+K6zhyFgvLwYtcbTd70yBDhRv2BDvwOm5jJxwR1o01
         wLiMh+R5qaqzHZSVY33fglqN6g3IDwJktPpEX7unC/VDInXZ1FR9wmFJZh7eHOdfPfQh
         ObaSAuKIDaKD6xJuf5gh7RsjGPQkgBm1tInETELOhgXutIiT9Yw08YNOpJY6OhwPE+cL
         VDkzUlqwyXglgx5RT7A2rQwdlyirm4++y2AvsramQ6pftozgaWY15/snYZnLQcT2O+1Q
         Verg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=2kYB1p/b/VSU9SsB3LoLb0aZfIgS7NS7Z3NfTbSHKls=;
        b=XSZRGuqBqiLw26+Lf9OMSTbHnNRu89xTXoN/hrk9I9aJ+Kpp5SI6CO5zJEm2RK1kJY
         MX2raMXz7u5UiFxlMFn1MkvokgGwqVdpCgIuq1iQGxIR8wh1n9Vxli9q3N/PCL0VhkT1
         T/FsqJawT4QnBwyoJqLAZTP+m+ZVdCuKLhqDuq5m/kwKRU7OGrjrY9Cu5WN1ss5mJ2/p
         cOeUIR0RTtcTdysMaGsdKUarxkuohAHJS/n+dDfal+tEx7ZOI9OxqiLj7WXcSwMoYxWP
         3k8L3qBajgjTwBsUdNYcl4/Nm6Ndu/eG9KtOc4AxXHpa9GVwfs1MvI+VMk3I4ad3OqHl
         i7pA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u21sor4516270qkk.33.2019.03.12.04.54.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 04:54:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxlYyfklOn1Ixv2yLTKmxFig1ic497FcTleSgokOtZQtp/NrlhMzHsNN0QtF+AybUzOKVjxPQ==
X-Received: by 2002:ae9:ec13:: with SMTP id h19mr17835707qkg.345.1552391646180;
        Tue, 12 Mar 2019 04:54:06 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id s186sm2889766qkb.57.2019.03.12.04.54.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 04:54:04 -0700 (PDT)
Date: Tue, 12 Mar 2019 07:54:02 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: David Miller <davem@davemloft.net>, hch@infradead.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org, aarcange@redhat.com,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190312075033-mutt-send-email-mst@kernel.org>
References: <20190308141220.GA21082@infradead.org>
 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
 <20190311095405-mutt-send-email-mst@kernel.org>
 <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 03:17:00PM +0800, Jason Wang wrote:
> 
> On 2019/3/12 上午11:52, Michael S. Tsirkin wrote:
> > On Tue, Mar 12, 2019 at 10:59:09AM +0800, Jason Wang wrote:
> > > On 2019/3/12 上午2:14, David Miller wrote:
> > > > From: "Michael S. Tsirkin" <mst@redhat.com>
> > > > Date: Mon, 11 Mar 2019 09:59:28 -0400
> > > > 
> > > > > On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
> > > > > > On 2019/3/8 下午10:12, Christoph Hellwig wrote:
> > > > > > > On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
> > > > > > > > This series tries to access virtqueue metadata through kernel virtual
> > > > > > > > address instead of copy_user() friends since they had too much
> > > > > > > > overheads like checks, spec barriers or even hardware feature
> > > > > > > > toggling. This is done through setup kernel address through vmap() and
> > > > > > > > resigter MMU notifier for invalidation.
> > > > > > > > 
> > > > > > > > Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
> > > > > > > > obvious improvement.
> > > > > > > How is this going to work for CPUs with virtually tagged caches?
> > > > > > Anything different that you worry?
> > > > > If caches have virtual tags then kernel and userspace view of memory
> > > > > might not be automatically in sync if they access memory
> > > > > through different virtual addresses. You need to do things like
> > > > > flush_cache_page, probably multiple times.
> > > > "flush_dcache_page()"
> > > 
> > > I get this. Then I think the current set_bit_to_user() is suspicious, we
> > > probably miss a flush_dcache_page() there:
> > > 
> > > 
> > > static int set_bit_to_user(int nr, void __user *addr)
> > > {
> > >          unsigned long log = (unsigned long)addr;
> > >          struct page *page;
> > >          void *base;
> > >          int bit = nr + (log % PAGE_SIZE) * 8;
> > >          int r;
> > > 
> > >          r = get_user_pages_fast(log, 1, 1, &page);
> > >          if (r < 0)
> > >                  return r;
> > >          BUG_ON(r != 1);
> > >          base = kmap_atomic(page);
> > >          set_bit(bit, base);
> > >          kunmap_atomic(base);
> > >          set_page_dirty_lock(page);
> > >          put_page(page);
> > >          return 0;
> > > }
> > > 
> > > Thanks
> > I think you are right. The correct fix though is to re-implement
> > it using asm and handling pagefault, not gup.
> 
> 
> I agree but it needs to introduce new helpers in asm  for all archs which is
> not trivial.

We can have a generic implementation using kmap.

> At least for -stable, we need the flush?
> 
> 
> > Three atomic ops per bit is way to expensive.
> 
> 
> Yes.
> 
> Thanks

See James's reply - I stand corrected we do kunmap so no need to flush.

-- 
MST

