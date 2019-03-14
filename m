Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF2FDC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 10:42:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8B8D12184E
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 10:42:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8B8D12184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0BCC8E0003; Thu, 14 Mar 2019 06:42:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBAD58E0001; Thu, 14 Mar 2019 06:42:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAA968E0003; Thu, 14 Mar 2019 06:42:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB3F28E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 06:42:25 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id l87so4284284qki.10
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 03:42:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=DKfElOakWQ9jAytxopIGDRsc9fgHNgyH9+OuJWYXtqQ=;
        b=nmlNOLkLStKk4mNJI+7rTZtRrvgO/RA5he+Z0wpYrFX1XRMiKIIEQ5sIUYLWnBs55A
         l8z5L+Vg+dAm5HXKU/TASez72SNVAwWnJRXpBFC4qTiCVyexo0dq9c58WeivvcIjknMr
         ADd4KqSUTlfTUI/NQ6AHhhUzRqsbwd5SVXPrqL+rVQZX3fONx0JNbw/cTlQAAve0CBKK
         XNQwyuoEGCJWE5fSDusaC8xxpnjga+8TkDx9Fxb/ZBpzIXXs04YVkZ3HwOu0UjPkUHA/
         boARZmUU/gWkjr2xhzZ0NGwJivtJF3W4S8sdDwcKYvpIn7I5g8vvCdEEW+/hIAfawzK0
         Tvdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVXmlh/CLT9QcULudkcWPBPjevQrZsaETHtRWf8uGVCwzQ5oU41
	B/+aRbTIZDg0Uc+Xv42q3RBTNUCFMO5Nk+BX5Uy1IfynOF/1cqcZAhogsGsCi1gEdzcVd+ImdF1
	rOjaKrepBC/UMMxdAjjcbLmfVVFkgYxFldxakkFnk3/hEDR8gAX9tNsR3O4JK4J2ChVKfBpquRn
	RAPcfZ2LwxtcYltLuZo5UUNM4GnbP5ymF+umrh1yiSYTcUS/36ec+GCEqlgx9GbAUdwofNeV11Y
	m87GUCAXw+k4Jm9/GVEQdxItYXkZ5JGhuG1VQHZYzYLWsBDwRbw1QmAmZVu4dEGXiSwA3ILp0Fh
	vzwOXcAryLueGRyyD+AjvJwmqU8gX8yf4i1pemCG/q9rsiYj2ki+d5z0RVXZFtrfWCNqdZHbtuX
	p
X-Received: by 2002:a37:6882:: with SMTP id d124mr35617291qkc.225.1552560145534;
        Thu, 14 Mar 2019 03:42:25 -0700 (PDT)
X-Received: by 2002:a37:6882:: with SMTP id d124mr35617247qkc.225.1552560144649;
        Thu, 14 Mar 2019 03:42:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552560144; cv=none;
        d=google.com; s=arc-20160816;
        b=P7/jqDnNsB+0ufiak4TnQTRvnwIGF1nvCioHn0LqlNLCerPHqH47VyDCXqbnAH8ed7
         IUrvkg9fAjJLS8mf2WWAJo3R7rIQIB2ECuuVS3rsqMG6EDVuyc87iUPLfuBA7Ncuvnw7
         KC0mGNi1+rRwHOVQt5GwycebryUuZ+IN2DYqbVNU7V7XLnwRonnsE9JNV5xOUh8MVkVf
         bLdOUwxPdI4N9BrbOHW+Ey/rVRDh/qVEOnmmLD1GpJ68iqaKhKjBzbLmS31rgaT/qeZ+
         czxudXIeMfKx0OMosbfrX5NWnQN3Sx5PBzAXuUUc9AImfG3fYxtiMg973pkABbIGJO1z
         FN4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=DKfElOakWQ9jAytxopIGDRsc9fgHNgyH9+OuJWYXtqQ=;
        b=SJCzaxMdQxyp96AylfxXYSbPAQ6LBJI2B099+BKXTH6IHxr2d8gnC6SNGr0ef1+Pht
         XwD9SSy3UNDnlWJFK7JTI3Ne4W+ga0BAhiIXLNdWTkwzoN/A9JA7bcqNmhiRcJUGWAmq
         sDBB3GV2+p1tGW3La6DnxnLN2WDl1YVryJCx/KjX44jpJJnz77mQSz7cq/lCUJlj708c
         hOrN1ylzlVj+/iRWjvxczwlJGih3uhtg4VVfUYmZQpWNkH//i6A3lHAQrP9ITASe+mVj
         c+SuB7bxZSfuX5wtsrlsHdxMArJvdFQPOHmSxs1Of7evHAfBzVGsiAjUX+o4szNdP+M4
         xYPg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w19sor15648201qvf.30.2019.03.14.03.42.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 03:42:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzuTvhcTxdCy53aCMd03OXLipoCFuWa4Hom4hJY3Wk5ndn5Kuk15zvRYVXjblKQ47jdYUY9BA==
X-Received: by 2002:ad4:4304:: with SMTP id c4mr3312316qvs.41.1552560144409;
        Thu, 14 Mar 2019 03:42:24 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id i8sm4095314qtr.19.2019.03.14.03.42.22
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Mar 2019 03:42:23 -0700 (PDT)
Date: Thu, 14 Mar 2019 06:42:21 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190314064004-mutt-send-email-mst@kernel.org>
References: <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
 <20190312075033-mutt-send-email-mst@kernel.org>
 <1552405610.3083.17.camel@HansenPartnership.com>
 <20190312200450.GA25147@redhat.com>
 <1552424017.14432.11.camel@HansenPartnership.com>
 <20190313160529.GB15134@infradead.org>
 <1552495028.3022.37.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552495028.3022.37.camel@HansenPartnership.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:37:08AM -0700, James Bottomley wrote:
> On Wed, 2019-03-13 at 09:05 -0700, Christoph Hellwig wrote:
> > On Tue, Mar 12, 2019 at 01:53:37PM -0700, James Bottomley wrote:
> > > I've got to say: optimize what?  What code do we ever have in the
> > > kernel that kmap's a page and then doesn't do anything with it? You
> > > can
> > > guarantee that on kunmap the page is either referenced (needs
> > > invalidating) or updated (needs flushing). The in-kernel use of
> > > kmap is
> > > always
> > > 
> > > kmap
> > > do something with the mapped page
> > > kunmap
> > > 
> > > In a very short interval.  It seems just a simplification to make
> > > kunmap do the flush if needed rather than try to have the users
> > > remember.  The thing which makes this really simple is that on most
> > > architectures flush and invalidate is the same operation.  If you
> > > really want to optimize you can use the referenced and dirty bits
> > > on the kmapped pte to tell you what operation to do, but if your
> > > flush is your invalidate, you simply assume the data needs flushing
> > > on kunmap without checking anything.
> > 
> > I agree that this would be a good way to simplify the API.   Now
> > we'd just need volunteers to implement this for all architectures
> > that need cache flushing and then remove the explicit flushing in
> > the callers..
> 
> Well, it's already done on parisc ...  I can help with this if we agree
> it's the best way forward.  It's really only architectures that
> implement flush_dcache_page that would need modifying.
> 
> It may also improve performance because some kmap/use/flush/kunmap
> sequences have flush_dcache_page() instead of
> flush_kernel_dcache_page() and the former is hugely expensive and
> usually unnecessary because GUP already flushed all the user aliases.
> 
> In the interests of full disclosure the reason we do it for parisc is
> because our later machines have problems even with clean aliases.  So
> on most VIPT systems, doing kmap/read/kunmap creates a fairly harmless
> clean alias.  Technically it should be invalidated, because if you
> remap the same page to the same colour you get cached stale data, but
> in practice the data is expired from the cache long before that
> happens, so the problem is almost never seen if the flush is forgotten.
>  Our problem is on the P9xxx processor: they have a L1/L2 VIPT L3 PIPT
> cache.  As the L1/L2 caches expire clean data, they place the expiring
> contents into L3, but because L3 is PIPT, the stale alias suddenly
> becomes the default for any read of they physical page because any
> update which dirtied the cache line often gets written to main memory
> and placed into the L3 as clean *before* the clean alias in L1/L2 gets
> expired, so the older clean alias replaces it.
> 
> Our only recourse is to kill all aliases with prejudice before the
> kernel loses ownership.
> 
> > > > Which means after we fix vhost to add the flush_dcache_page after
> > > > kunmap, Parisc will get a double hit (but it also means Parisc
> > > > was the only one of those archs needed explicit cache flushes,
> > > > where vhost worked correctly so far.. so it kinds of proofs your
> > > > point of giving up being the safe choice).
> > > 
> > > What double hit?  If there's no cache to flush then cache flush is
> > > a no-op.  It's also a highly piplineable no-op because the CPU has
> > > the L1 cache within easy reach.  The only event when flush takes a
> > > large amount time is if we actually have dirty data to write back
> > > to main memory.
> > 
> > I've heard people complaining that on some microarchitectures even
> > no-op cache flushes are relatively expensive.  Don't ask me why,
> > but if we can easily avoid double flushes we should do that.
> 
> It's still not entirely free for us.  Our internal cache line is around
> 32 bytes (some have 16 and some have 64) but that means we need 128
> flushes for a page ... we definitely can't pipeline them all.  So I
> agree duplicate flush elimination would be a small improvement.
> 
> James

I suspect we'll keep the copyXuser path around for 32 bit anyway -
right Jason?
So we can also keep using that on parisc...

-- 
MST

