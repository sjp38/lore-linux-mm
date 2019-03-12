Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFEF8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:52:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BA7B214AF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:52:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BA7B214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 09D3F8E0003; Mon, 11 Mar 2019 23:52:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 04C648E0002; Mon, 11 Mar 2019 23:52:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7CAB8E0003; Mon, 11 Mar 2019 23:52:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB67F8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:52:45 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 35so1083377qty.12
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:52:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=E/UyB+xWk/xehLCQmoblfGNsmlWELdfSb6B+opPtGT0=;
        b=t2tXG1FUoj/rEdZbd+6amNqsu0zrrBvbIFkoc/g4yiE1epVHWq6DxqYNNfA/X9CCX2
         6xMqUE9b8eAOlBF5M8Zno7uhRnOYM3pTclDVRgCHXi7UjfMUuUtdfugSPf5+hLAz58Hh
         ODFyf7ZHeL/lu2+n6+XIIbL//oJPgNnrDuUTXkbfgn677DLX5gx9L1wdm6Q/uCdpM0+q
         i65N9VCt05egSOZ9mRHfpnElSWA4+MuMyJwUvWiRLCG+l50xo0StYwHRuDFoUaEbu2Ge
         5yMcTnz7Leh6kxb04h9yfRGOMu2XuHn7eFgrZKLtudGm/J0RGtcxG7SUNxcMb5KKlAvL
         SC5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXsWbQMd/iLN+WawchJXgtnVI9lD51vb+/aB3UogZDpaTNwcKmw
	XmyHPJWSP3F0gydf8Q68S2GXOo6Ynm6KTkN7ZUGDB++pqp8TP+NQPLu14YkUB/gu+1Ma99bcfhe
	FFmoa4ZIn72xYOCUBiCa3TUQe3n4+j3BV9/qPT5cK3ExnPZhzYtGh1lT2JOnoe98vhlhN+p2loF
	HYm6YKyzdU9MPXQTr699K6EzlyFrN3N5HnzaBEmD4EKaMHE+i4pUgt5dtNgu1F0m4dtcBMbayck
	h9+MmV4gF41nUpgfQSqoY73nywF+AAY3nKmZVd7x4s7gpPv14XB3z+tKwniQKfUV9WtA6whtOv0
	NtJdJAiujQCEOVE+OIKnKNFKMUeQ5CZjQ3xGZHr36AS+ikqHvbtdPrZoede3cjHmIwHvgDg4M4F
	i
X-Received: by 2002:ac8:554d:: with SMTP id o13mr28734893qtr.105.1552362765580;
        Mon, 11 Mar 2019 20:52:45 -0700 (PDT)
X-Received: by 2002:ac8:554d:: with SMTP id o13mr28734873qtr.105.1552362764946;
        Mon, 11 Mar 2019 20:52:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552362764; cv=none;
        d=google.com; s=arc-20160816;
        b=VYqVxAwLF5WKey1b2GPOuqZd+V5qJZddFhvnWQKhmKHeF0Gy70pVmkqkc9qwfI+qK9
         j7Cw868vTinTvBa8Y1iU4SrMtE/+Gpgcn6Xm4C/kUDCiSG1M4vm64i3d9vNZkSqb9AJC
         qRALHW+5HPHtoBmNn9lHzWSqH+hOdaYnkNp9mbnebpbIuIUwbuW1nJThNUE9U7v5X5PA
         Qv3Tq6gy1X6e6W5kaUsEMb0jDwANTomDvTx/jRtXegUt0L6tSs59D1waGqQme/O99MKA
         KkPtzWi53baxGw+cs1QLbl3YsvdpuasGq/mLI4OCOvpVL/BCYqN9MEWfC0w+U8TdZkQY
         2Lzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=E/UyB+xWk/xehLCQmoblfGNsmlWELdfSb6B+opPtGT0=;
        b=Mdt5sd8ZHazki/KfewU59kZSRG2QNgH8jtwB/RLjXxD8olTirYxu7VCs6F4rhDHnr3
         IYnwUPA2Hyqu77ysp4IEK9LVfHQX8e2cG1PURUc4Jk6kUJ+N3F/1FMRjeStkoreSAFLz
         sGvMkL+YKsRo+0FdHJnRTuXywvoTkUdbLI2FDhtgdHTkiGQBxMu1FZsOCXZcvrPLyc3r
         AO2lrHRH0LhxDMQBjv7TYmkH8cFlzXuakeq6f/CIOj7icL2eVVxoT3N5mJWrEnh8MBVT
         XpztTga3jdCCy8cSKINBeRb5kMRCJ+wdam3kZlvAxBLv0oU+SLg0W7TnSm8TCeyEtS6V
         je1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v185sor3255607qki.67.2019.03.11.20.52.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 20:52:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw6vWNjN7roQr24NYlwA5iXQwWdK6cI38JZZ7g3cWXw6ntcj/yHKj2a9lBFrAD0H1GF5Tax7A==
X-Received: by 2002:ae9:c30f:: with SMTP id n15mr4412813qkg.227.1552362764721;
        Mon, 11 Mar 2019 20:52:44 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id o188sm4099469qkd.30.2019.03.11.20.52.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 20:52:43 -0700 (PDT)
Date: Mon, 11 Mar 2019 23:52:41 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: David Miller <davem@davemloft.net>, hch@infradead.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org, aarcange@redhat.com,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190311235140-mutt-send-email-mst@kernel.org>
References: <20190308141220.GA21082@infradead.org>
 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
 <20190311095405-mutt-send-email-mst@kernel.org>
 <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 10:59:09AM +0800, Jason Wang wrote:
> 
> On 2019/3/12 上午2:14, David Miller wrote:
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> > Date: Mon, 11 Mar 2019 09:59:28 -0400
> > 
> > > On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
> > > > On 2019/3/8 下午10:12, Christoph Hellwig wrote:
> > > > > On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
> > > > > > This series tries to access virtqueue metadata through kernel virtual
> > > > > > address instead of copy_user() friends since they had too much
> > > > > > overheads like checks, spec barriers or even hardware feature
> > > > > > toggling. This is done through setup kernel address through vmap() and
> > > > > > resigter MMU notifier for invalidation.
> > > > > > 
> > > > > > Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
> > > > > > obvious improvement.
> > > > > How is this going to work for CPUs with virtually tagged caches?
> > > > 
> > > > Anything different that you worry?
> > > If caches have virtual tags then kernel and userspace view of memory
> > > might not be automatically in sync if they access memory
> > > through different virtual addresses. You need to do things like
> > > flush_cache_page, probably multiple times.
> > "flush_dcache_page()"
> 
> 
> I get this. Then I think the current set_bit_to_user() is suspicious, we
> probably miss a flush_dcache_page() there:
> 
> 
> static int set_bit_to_user(int nr, void __user *addr)
> {
>         unsigned long log = (unsigned long)addr;
>         struct page *page;
>         void *base;
>         int bit = nr + (log % PAGE_SIZE) * 8;
>         int r;
> 
>         r = get_user_pages_fast(log, 1, 1, &page);
>         if (r < 0)
>                 return r;
>         BUG_ON(r != 1);
>         base = kmap_atomic(page);
>         set_bit(bit, base);
>         kunmap_atomic(base);
>         set_page_dirty_lock(page);
>         put_page(page);
>         return 0;
> }
> 
> Thanks

I think you are right. The correct fix though is to re-implement
it using asm and handling pagefault, not gup.
Three atomic ops per bit is way to expensive.

-- 
MST

