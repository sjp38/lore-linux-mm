Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26E64C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 20:53:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA38F208E4
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 20:53:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="q6PKtm2q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA38F208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74FDA6B0005; Tue,  3 Sep 2019 16:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 700256B0006; Tue,  3 Sep 2019 16:53:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6165D6B0007; Tue,  3 Sep 2019 16:53:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0233.hostedemail.com [216.40.44.233])
	by kanga.kvack.org (Postfix) with ESMTP id 428936B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:53:19 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E2EE5180AD805
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 20:53:18 +0000 (UTC)
X-FDA: 75894809676.09.crate17_913a036ba4312
X-HE-Tag: crate17_913a036ba4312
X-Filterd-Recvd-Size: 4561
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 20:53:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=9j9Ys3SKrunuUdWnpddWrlF3hlzVX+dYskTpGsMVRdg=; b=q6PKtm2qHXC4ZxDd1oWAesGqt
	mkef31ksS0DE/m+V94xxk8mY4E4NK7/D6yceAd4IMOYEtng6UUMmitBiFDXkmyC3VsZShsSIDhDxA
	spbPZghZh0gaSPUEaq9m2Id0riRmEJzPcniu1pE5CxkkCA32WDRJ3NzR/05hgewKmdlszxQcADztH
	z19osbBcPHxeseNqIEdEFRXQ1AGIdZ5S6kJBEUtzqgvVeooolY2oxTjjKG+adYErsSQPK+86v+0qP
	AK7u61q/Rmd8W04N+VU/Ik4OalyMQ207Yu/0eA5EaNXbWRdvGCZGHdJNie5vvkiHaECkD4l0efUVb
	n2xH0iMQA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i5Fnc-0005w9-SY; Tue, 03 Sep 2019 20:53:12 +0000
Date: Tue, 3 Sep 2019 13:53:12 -0700
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
Message-ID: <20190903205312.GK29434@bombadil.infradead.org>
References: <20190826111627.7505-1-vbabka@suse.cz>
 <20190826111627.7505-3-vbabka@suse.cz>
 <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com>
 <20190828194607.GB6590@bombadil.infradead.org>
 <20190829073921.GA21880@dhcp22.suse.cz>
 <0100016ce39e6bb9-ad20e033-f3f4-4e6d-85d6-87e7d07823ae-000000@email.amazonses.com>
 <20190901005205.GA2431@bombadil.infradead.org>
 <0100016cf8c3033d-bbcc9ba3-2d59-4654-a7c2-8ba094f8a7de-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0100016cf8c3033d-bbcc9ba3-2d59-4654-a7c2-8ba094f8a7de-000000@email.amazonses.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 08:13:45PM +0000, Christopher Lameter wrote:
> On Sat, 31 Aug 2019, Matthew Wilcox wrote:
> 
> > > The current behavior without special alignment for these caches has been
> > > in the wild for over a decade. And this is now coming up?
> >
> > In the wild ... and rarely enabled.  When it is enabled, it may or may
> > not be noticed as data corruption, or tripping other debugging asserts.
> > Users then turn off the rare debugging option.
> 
> Its enabled in all full debug session as far as I know. Fedora for
> example has been running this for ages to find breakage in device drivers
> etc etc.

Are you telling me nobody uses the ramdisk driver on fedora?  Because
that's one of the affected drivers.

> > > If there is an exceptional alignment requirement then that needs to be
> > > communicated to the allocator. A special flag or create a special
> > > kmem_cache or something.
> >
> > The only way I'd agree to that is if we deliberately misalign every
> > allocation that doesn't have this special flag set.  Because right now,
> > breakage happens everywhere when these debug options are enabled, and
> > the very people who need to be helped are being hurt by the debugging.
> 
> That is customarily occurring for testing by adding "slub_debug" to the
> kernel commandline (or adding debug kernel options) and since my
> information is that this is done frequently (and has been for over a
> decade now) I am having a hard time believing the stories of great
> breakage here. These drivers were not tested with debugging on before?
> Never ran with a debug kernel?

Whatever is being done is clearly not enough to trigger the bug.  So how
about it?  Create an option to slab/slub to always return misaligned
memory.


