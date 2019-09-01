Return-Path: <SRS0=4eAG=W4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C269C3A5A6
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 00:52:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF0082186A
	for <linux-mm@archiver.kernel.org>; Sun,  1 Sep 2019 00:52:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="eBz5M1QV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF0082186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 624E16B0006; Sat, 31 Aug 2019 20:52:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D50E6B0008; Sat, 31 Aug 2019 20:52:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EBBA6B000A; Sat, 31 Aug 2019 20:52:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0044.hostedemail.com [216.40.44.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2D9956B0006
	for <linux-mm@kvack.org>; Sat, 31 Aug 2019 20:52:19 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B19B2180AD7C1
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 00:52:18 +0000 (UTC)
X-FDA: 75884525556.18.salt91_1410d02ac5148
X-HE-Tag: salt91_1410d02ac5148
X-Filterd-Recvd-Size: 4471
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun,  1 Sep 2019 00:52:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=jXXM66EKtvmEAYvb1Llji9/A136eINaxlL5uqBe0OBY=; b=eBz5M1QVpKJZMQDzXUQ9MXhMT
	rIK2EkzUbSraojFclMxJ7OU+sf7tbq9mwzo0REl3yaDUt2YpbGdUBXr1PBULu2aic9sZuNzSPwoCp
	owngjkSk9HrwVrtscNCYj+aZ/17/cGG88hXmrwj3PKy0BJCvg4ElKAVolJU/MnnAZSwlpMqAmc62e
	AMUhgpKdATQQ056Kf77qv58BUxrXE6ktixwa0beiRV9gpk+ZAtbCCa1VAH88gCyyf5jTc6PxLSazv
	wV7o8Fq43JPBfe5nZRIUcQcvYRvRzMraHjUnFk9kNgyg6rLAwcalK0UgYckSGwX3KhjlxftyTplES
	EIwb3V+yg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i4E69-0007JD-OE; Sun, 01 Sep 2019 00:52:05 +0000
Date: Sat, 31 Aug 2019 17:52:05 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Ming Lei <ming.lei@redhat.com>, Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-btrfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] mm, sl[aou]b: guarantee natural alignment for
 kmalloc(power-of-two)
Message-ID: <20190901005205.GA2431@bombadil.infradead.org>
References: <20190826111627.7505-1-vbabka@suse.cz>
 <20190826111627.7505-3-vbabka@suse.cz>
 <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com>
 <20190828194607.GB6590@bombadil.infradead.org>
 <20190829073921.GA21880@dhcp22.suse.cz>
 <0100016ce39e6bb9-ad20e033-f3f4-4e6d-85d6-87e7d07823ae-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016ce39e6bb9-ad20e033-f3f4-4e6d-85d6-87e7d07823ae-000000@email.amazonses.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2019 at 05:41:46PM +0000, Christopher Lameter wrote:
> On Thu, 29 Aug 2019, Michal Hocko wrote:
> > > There are many places in the kernel which assume alignment.  They break
> > > when it's not supplied.  I believe we have a better overall system if
> > > the MM developers provide stronger guarantees than the MM consumers have
> > > to work around only weak guarantees.
> >
> > I absolutely agree. A hypothetical benefit of a new implementation
> > doesn't outweigh the complexity the existing code has to jump over or
> > worse is not aware of and it is broken silently. My general experience
> > is that the later is more likely with a large variety of drivers we have
> > in the tree and odd things they do in general.
> 
> The current behavior without special alignment for these caches has been
> in the wild for over a decade. And this is now coming up?

In the wild ... and rarely enabled.  When it is enabled, it may or may
not be noticed as data corruption, or tripping other debugging asserts.
Users then turn off the rare debugging option.

> There is one case now it seems with a broken hardware that has issues and
> we now move to an alignment requirement from the slabs with exceptions and
> this and that?

Perhaps you could try reading what hasa been written instead of sticking
to a strawman of your own invention?

> If there is an exceptional alignment requirement then that needs to be
> communicated to the allocator. A special flag or create a special
> kmem_cache or something.

The only way I'd agree to that is if we deliberately misalign every
allocation that doesn't have this special flag set.  Because right now,
breakage happens everywhere when these debug options are enabled, and
the very people who need to be helped are being hurt by the debugging.

