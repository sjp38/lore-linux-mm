Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCD8AC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:23:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 869432081B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:23:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 869432081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18C998E0008; Tue, 12 Feb 2019 03:23:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 111AB8E0007; Tue, 12 Feb 2019 03:23:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF5698E0008; Tue, 12 Feb 2019 03:23:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF4AA8E0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:23:29 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b187so15094263qkf.3
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:23:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8MPRQ0P6VsdbCnEYvAIdEtO1KUWzacGCZoVQJ+QEtsk=;
        b=c6JIAD/Ci7jGDqoiahk3mrLx3WiXS2NPggyb6VxBMhVy/A/EH4hCGhTimPk7PA4H1U
         o9K2EBNtG2wPJSnrOkuDYixjUzKvGhmSEvpTKUs3QpkNDGjiwGzg446Z8/yrYB9viROp
         AlpZV7P47EGN1ZHYhNIUepmYL0XwHNswrxN9CYlXRxGPw5AnpFFOEyPpZU8fdkRKyAJh
         5cFXyhp3Toub0A4QYz+Yg8pYNmZqDFa1YZ1rqqMSY1kC3x7mHDeEx8yeTVDcvcgIHIj6
         0QafCOiyCA/EYod1RxbxEuXb7ZBcEVYfNy69lRXBeHfZw9IlAkuKwkijB+V+GcnhZoCw
         6A+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua4kBVtGovXLPQDuJEyeMI8x70KL0KhcB/aUeArIKlMbc3kxAei
	a0MrKI7skXP8kQ7BadSu5L9ipESD+V+H3j6uO4JrqtMBOoguExCnEZx28ZVCpyrX5CJUgkq3dyp
	7YPRXB/fgr3rGzfRR0wu8mCe9UxKAP7NhoBbVBvx18xQlWptS7nUPGfO64bN1Ll/e+A==
X-Received: by 2002:aed:3ba9:: with SMTP id r38mr1865257qte.330.1549959809480;
        Tue, 12 Feb 2019 00:23:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYVCDUCvs7J9o7QDJBMpvUcT3DJKeCx3b535tpUG4xxPt1iy9MOIuyhtVuugV8UGkmtJzj6
X-Received: by 2002:aed:3ba9:: with SMTP id r38mr1865236qte.330.1549959808775;
        Tue, 12 Feb 2019 00:23:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549959808; cv=none;
        d=google.com; s=arc-20160816;
        b=fpapIytGF8wRpO4eaaL3QaimjFl7NTy2BMNDcJuaeZXkdyy9+HjMUxnKAFC8Mc+NpE
         KwJ98y584YyZHW7fOdg+nLi7lu8AFxheA8dhgwxKNRr5Ym6Nq+tEYWpsl+UmlBXDqBAi
         sEfTRlTOCAmUBwWRjJiMyhfaCSKrb7idDBlnrIwQtT/Cz6IzXPpzzpc5B7k6rwR0iKLO
         /+WCg7xtIMuWmlkZnrS8nshUyYwZ48gFgqpF0FDbCYHwXQHpm7Q73LYhaCp5jw1efvdR
         /sdqLpCx7T7oQqxUx2F0p/Fq2NXDy+JAgLIXi6PyF59DQgHNTBnIH8I4Ai7kY31v5Ujd
         TUqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=8MPRQ0P6VsdbCnEYvAIdEtO1KUWzacGCZoVQJ+QEtsk=;
        b=hVqAvNQcy2TCcAcDhPfVA7y6We55ZmN3OsN3KxFDGom5dyEYpk5vK4vMDQqJnlUmUb
         cW1RoftnXfxSUoaDpL2KbRYQTJqUV+i0oHC6c+EUvr8uZc8+Zc4JTIdf+3pRVWzk+CT4
         u8zGFEsn+q6/6Lpd3UL9I5iauXY9ZNKfM4hgol+dykwb2K69U7OleOGqjKFft9pxnwd6
         SFFC+RZ0cOQtnn+RDm/wJmMVrbCo9hStMYN+5gChz7HMZx7DJMr7YKdajrl3081WeVfc
         GoTODkNrF5q4mdA0k0+OnZu7hc0pLXMNYyIA9tVKdupS6MT3nZxc/tD8fjXrxxoqaRTj
         BC6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y128si3396979qke.259.2019.02.12.00.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:23:28 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8BD8886679;
	Tue, 12 Feb 2019 08:23:27 +0000 (UTC)
Received: from carbon (ovpn-200-42.brq.redhat.com [10.40.200.42])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5207F100164A;
	Tue, 12 Feb 2019 08:23:21 +0000 (UTC)
Date: Tue, 12 Feb 2019 09:23:19 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Toke
 =?UTF-8?B?SMO4aWxhbmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>, Ilias Apalodimas
 <ilias.apalodimas@linaro.org>, Matthew Wilcox <willy@infradead.org>, Saeed
 Mahameed <saeedm@mellanox.com>, Andrew Morton <akpm@linux-foundation.org>,
 Mel Gorman <mgorman@techsingularity.net>, "David S. Miller"
 <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>,
 brouer@redhat.com
Subject: Re: [net-next PATCH 2/2] net: page_pool: don't use page->private to
 store dma_addr_t
Message-ID: <20190212092319.2d2c6b4b@carbon>
In-Reply-To: <CAKgT0Ucw_HGaice7cjM7e_nYuvjU_TKVd54Yc_fHen1pZRkUJw@mail.gmail.com>
References: <154990116432.24530.10541030990995303432.stgit@firesoul>
	<154990121192.24530.11128024662816211563.stgit@firesoul>
	<CAKgT0Ucw_HGaice7cjM7e_nYuvjU_TKVd54Yc_fHen1pZRkUJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 12 Feb 2019 08:23:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 11:31:13 -0800
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On Mon, Feb 11, 2019 at 8:07 AM Jesper Dangaard Brouer
> <brouer@redhat.com> wrote:
> >
> > From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> >
> > As pointed out by David Miller the current page_pool implementation
> > stores dma_addr_t in page->private.
> > This won't work on 32-bit platforms with 64-bit DMA addresses since the
> > page->private is an unsigned long and the dma_addr_t a u64.
> >
> > A previous patch is adding dma_addr_t on struct page to accommodate this.
> > This patch adapts the page_pool related functions to use the newly added
> > struct for storing and retrieving DMA addresses from network drivers.
> >
> > Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> > ---
> >  net/core/page_pool.c |   13 +++++++++----
> >  1 file changed, 9 insertions(+), 4 deletions(-)
> >
> > diff --git a/net/core/page_pool.c b/net/core/page_pool.c
> > index 43a932cb609b..897a69a1477e 100644
> > --- a/net/core/page_pool.c
> > +++ b/net/core/page_pool.c
> > @@ -136,7 +136,9 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
> >         if (!(pool->p.flags & PP_FLAG_DMA_MAP))
> >                 goto skip_dma_map;
> >
> > -       /* Setup DMA mapping: use page->private for DMA-addr
> > +       /* Setup DMA mapping: use 'struct page' area for storing DMA-addr
> > +        * since dma_addr_t can be either 32 or 64 bits and does not always fit
> > +        * into page private data (i.e 32bit cpu with 64bit DMA caps)
> >          * This mapping is kept for lifetime of page, until leaving pool.
> >          */
> >         dma = dma_map_page(pool->p.dev, page, 0,
> > @@ -146,7 +148,7 @@ static struct page *__page_pool_alloc_pages_slow(struct page_pool *pool,
> >                 put_page(page);
> >                 return NULL;
> >         }
> > -       set_page_private(page, dma); /* page->private = dma; */
> > +       page->dma_addr = dma;
> >
> >  skip_dma_map:
> >         /* When page just alloc'ed is should/must have refcnt 1. */
> > @@ -175,13 +177,16 @@ EXPORT_SYMBOL(page_pool_alloc_pages);
> >  static void __page_pool_clean_page(struct page_pool *pool,
> >                                    struct page *page)
> >  {
> > +       dma_addr_t dma;
> > +
> >         if (!(pool->p.flags & PP_FLAG_DMA_MAP))
> >                 return;
> >
> > +       dma = page->dma_addr;
> >         /* DMA unmap */
> > -       dma_unmap_page(pool->p.dev, page_private(page),
> > +       dma_unmap_page(pool->p.dev, dma,
> >                        PAGE_SIZE << pool->p.order, pool->p.dma_dir);
> > -       set_page_private(page, 0);
> > +       page->dma_addr = 0;
> >  }
> >
> >  /* Return a page to the page allocator, cleaning up our state */  
> 
> This comment is unrelated to this patch specifically, but applies more
> generally to the page_pool use of dma_unmap_page.
> 
> So just looking at this I am pretty sure the use of just
> dma_unmap_page isn't correct here. You should probably be using
> dma_unmap_page_attrs and specifically be passing the attribute
> DMA_ATTR_SKIP_CPU_SYNC so that you can tear down the mapping without
> invalidating the contents of the page.

It is unrelated to this patch, but YES you are right.  I was aware of
this, but it slipped my mind.  You were the one that taught me the
principle page_pool is based on, that we keep the DMA mapping, but
instead let the driver perform the DMA-sync operations.

Thanks for catching this!  I actually think that the current small
ARM64 board we are playing with at the moment (Espressobin) will have a
performance benefit from doing this.


> This is something that will work for most cases but if you run into a
> case where this is used with SWIOTLB in bounce buffer mode you would
> end up potentially corrupting data on the unmap call.

I do have a board Machiattobin, that operate with SWIOTLB bounce
buffers, which it is not suppose to, and something that I'll hopefully
get a round to fix soon.  But we have not implemented use of page_pool
on that board yet. So, thanks for catching this.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

