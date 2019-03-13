Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55F9FC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:05:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05FC9206DF
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:05:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WBmrDOFd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05FC9206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B1448E0003; Wed, 13 Mar 2019 12:05:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8607F8E0001; Wed, 13 Mar 2019 12:05:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74EFE8E0003; Wed, 13 Mar 2019 12:05:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 340A18E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:05:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e1so2693424pgs.9
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:05:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Baj+lWDXGPt27lshCwJLP8POnzrLswu3QVB5Jfd4sTc=;
        b=W9jvKE8T3MAUBhiieo5nBUSMHJ9JFQyoETn6ocbOgjm8dhBpu9Ezk89TbuK96atPKe
         rMyvy8IXtnf9XXhWec4h9neTXK2sBaIL0GlYvyk5sJLDw9xKkEg2w0wC8uveIdKzNcLM
         j+FI8Se5utZJt4D23n1DWXelxJGZC1KJHrVkDFtG3CkyQOh4yohIhh4Yec3wK1Zg9Obu
         cFIYf8aZ5cQg0VYcyxT4M9p42dkQXLLR7AtRR7SOWXwvRPmYgqL5Cs0Vnsdh3wKK+Mp4
         zv1J6trBrrT1K7XPukqZa5q/kDN72uqpMx2Gl4xD5HytatbKNmFeq1rtzB4G3VXcnOXy
         6PUQ==
X-Gm-Message-State: APjAAAUPdjAaDavuVVJDJxgqAzN9nOQgnkgUwEF8Vu6yYnnhqrw8ShJe
	ZDdZkK7ax6oX14STsZ7b/h3k0b5NpLs8mshecADajoW1o+mBUDHhegRSSeKkwR434bTez6GN/Ek
	zrfJW5RegUJ9f/mZR/5r+sLVWb+oaWU126HyrMQvJnu+FTegNTfyB1eLvjwJcaDs0/g==
X-Received: by 2002:a63:e641:: with SMTP id p1mr7980067pgj.325.1552493133812;
        Wed, 13 Mar 2019 09:05:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzvIcaoi1IkVhYrOzHJk7F94Ul1SbN2O8AJvS77IRpBrYCKipamoHOnWJwiGoQ3W1NL4vm+
X-Received: by 2002:a63:e641:: with SMTP id p1mr7979982pgj.325.1552493132715;
        Wed, 13 Mar 2019 09:05:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552493132; cv=none;
        d=google.com; s=arc-20160816;
        b=t+59U9H7SBo9SwqnxnmSHlLyduLUcdPPiTimXldOQnK7Bovp0pLzhXq3P3zHjZmIQG
         ZTd+Nbl988WUHvLUVGcEUBN5lel9R/66U11UJBoV9pDLLlk8wuGHOfH66P3piMcH+xtV
         7oQXdWbhlMB/YTPgjDNY93fky4B1ZvNJFLEbzCRm8+uuVoojDohV6LrAfYoKcUF6e0Wf
         WpXq9VjXs4wgtATy9tb/fJPXQM5viBZ50/9hetZuDZEU6d1RkzczsRbOZcDLQaMJEtvL
         csOS5NwWiAPr+nMO7md7/W3FA+xFLbfBTLTfkyBJh8RzA5B8RMP3n6ne+pp3+NGdgSKd
         9ghg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Baj+lWDXGPt27lshCwJLP8POnzrLswu3QVB5Jfd4sTc=;
        b=QaAvNMlH/vFVP/dqvTAlAkQX3q76bTMYyX+iRxxnbQfIb29KrGQ1cXUILJsAlP0HX8
         eExK1xfJrMI3h7w5L2OxuTeElvFd8DfYJ1i4Ys4pL0k4BamWNQX20DuxqAhOmZBzeFYs
         2KiJpDq2arTnaS0GoL20jb91jj9MRIiItvB30hJ4pOVgJbsXuekBuGF6vRQj+UXWPExZ
         7ZYk4JyVc50Y+f3+U5WqdQIL+g8jOPXyYP9Trw4b50UGsomO+vyht++q/qEOlenM5Z/1
         sJpgiw9XOPCVRqSvpmJ0qr3ZcJ5zh8WeGBJcINj6IQcz/SjATZw4sny/R2dm9Ayc3m1c
         8aMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WBmrDOFd;
       spf=pass (google.com: best guess record for domain of batv+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g18si10773144pfg.99.2019.03.13.09.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 09:05:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WBmrDOFd;
       spf=pass (google.com: best guess record for domain of batv+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+cb812337220b2e68da92+5680+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Baj+lWDXGPt27lshCwJLP8POnzrLswu3QVB5Jfd4sTc=; b=WBmrDOFdeqXIspuqZdFAcMVYT
	YzewMY/wBRq50wT4qf5pW+61boYgJjwEtUWHYvuvAA+t/hQpnyd7+NFHdTQMl1UnvjZgUfrXVpzNS
	VrSoqYQZLfdfSVN/E1wKu4mZy/4WJkG47nre5T0lR2Bm5nsnv6H0D/R1O7247uk1zW/zRIEv9ysUv
	TlxDpIA1dtVJYOVQ9eR2vQmUEA0xhxpFLYhzYZYd1mlG/jrPspUZFkFWxtON496QO+uRSS//+lYbz
	gu5x6yBnZsyJnKKOOAuDSYTZmPmkd93XFQAjDD/yUixFfT7S6wWLCpD8KlcWUgBNqemS+Hubgfnzg
	lYhikX1Sw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h46Nl-0005jS-AC; Wed, 13 Mar 2019 16:05:29 +0000
Date: Wed, 13 Mar 2019 09:05:29 -0700
From: Christoph Hellwig <hch@infradead.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, hch@infradead.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190313160529.GB15134@infradead.org>
References: <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
 <20190311095405-mutt-send-email-mst@kernel.org>
 <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
 <20190312075033-mutt-send-email-mst@kernel.org>
 <1552405610.3083.17.camel@HansenPartnership.com>
 <20190312200450.GA25147@redhat.com>
 <1552424017.14432.11.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1552424017.14432.11.camel@HansenPartnership.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 01:53:37PM -0700, James Bottomley wrote:
> I've got to say: optimize what?  What code do we ever have in the
> kernel that kmap's a page and then doesn't do anything with it? You can
> guarantee that on kunmap the page is either referenced (needs
> invalidating) or updated (needs flushing). The in-kernel use of kmap is
> always
> 
> kmap
> do something with the mapped page
> kunmap
> 
> In a very short interval.  It seems just a simplification to make
> kunmap do the flush if needed rather than try to have the users
> remember.  The thing which makes this really simple is that on most
> architectures flush and invalidate is the same operation.  If you
> really want to optimize you can use the referenced and dirty bits on
> the kmapped pte to tell you what operation to do, but if your flush is
> your invalidate, you simply assume the data needs flushing on kunmap
> without checking anything.

I agree that this would be a good way to simplify the API.   Now
we'd just need volunteers to implement this for all architectures
that need cache flushing and then remove the explicit flushing in
the callers..

> > Which means after we fix vhost to add the flush_dcache_page after
> > kunmap, Parisc will get a double hit (but it also means Parisc was
> > the only one of those archs needed explicit cache flushes, where
> > vhost worked correctly so far.. so it kinds of proofs your point of
> > giving up being the safe choice).
> 
> What double hit?  If there's no cache to flush then cache flush is a
> no-op.  It's also a highly piplineable no-op because the CPU has the L1
> cache within easy reach.  The only event when flush takes a large
> amount time is if we actually have dirty data to write back to main
> memory.

I've heard people complaining that on some microarchitectures even
no-op cache flushes are relatively expensive.  Don't ask me why,
but if we can easily avoid double flushes we should do that.

