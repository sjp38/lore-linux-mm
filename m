Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ED75C3A59B
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 17:41:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2707F23426
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 17:41:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="jOwxuN0/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2707F23426
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B9F9A6B0006; Fri, 30 Aug 2019 13:41:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B50366B0008; Fri, 30 Aug 2019 13:41:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A660F6B000A; Fri, 30 Aug 2019 13:41:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0079.hostedemail.com [216.40.44.79])
	by kanga.kvack.org (Postfix) with ESMTP id 857DF6B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 13:41:47 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1EF00180AD7C1
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 17:41:47 +0000 (UTC)
X-FDA: 75879811854.01.rings33_83f507e0b7c45
X-HE-Tag: rings33_83f507e0b7c45
X-Filterd-Recvd-Size: 3315
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com [54.240.9.99])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 17:41:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1567186906;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=O4l8bfyB+VvL+95TNWx4FpZqRMWRe8LWpmXp151rZPQ=;
	b=jOwxuN0/GsY64oKXgfJmdwBB+AXtX2WpGHqJuhQjx2ptbH8DVIIqkqyXxRD8yOn8
	GV8ejswyFu4wYPPvC5trc2TJ+u/8YK8DHJOysSHUEOvy5EY/yEQJyv85OgQB3tVrNRO
	oEjKdNcHWMyjIds//broy3iaTxgNIeqHLNuDl3dY=
Date: Fri, 30 Aug 2019 17:41:46 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Michal Hocko <mhocko@kernel.org>
cc: Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>, 
    David Rientjes <rientjes@google.com>, Ming Lei <ming.lei@redhat.com>, 
    Dave Chinner <david@fromorbit.com>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, 
    Christoph Hellwig <hch@lst.de>, linux-xfs@vger.kernel.org, 
    linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, 
    James Bottomley <James.Bottomley@hansenpartnership.com>, 
    linux-btrfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] mm, sl[aou]b: guarantee natural alignment for
 kmalloc(power-of-two)
In-Reply-To: <20190829073921.GA21880@dhcp22.suse.cz>
Message-ID: <0100016ce39e6bb9-ad20e033-f3f4-4e6d-85d6-87e7d07823ae-000000@email.amazonses.com>
References: <20190826111627.7505-1-vbabka@suse.cz> <20190826111627.7505-3-vbabka@suse.cz> <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com> <20190828194607.GB6590@bombadil.infradead.org>
 <20190829073921.GA21880@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.08.30-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Aug 2019, Michal Hocko wrote:

> > There are many places in the kernel which assume alignment.  They break
> > when it's not supplied.  I believe we have a better overall system if
> > the MM developers provide stronger guarantees than the MM consumers have
> > to work around only weak guarantees.
>
> I absolutely agree. A hypothetical benefit of a new implementation
> doesn't outweigh the complexity the existing code has to jump over or
> worse is not aware of and it is broken silently. My general experience
> is that the later is more likely with a large variety of drivers we have
> in the tree and odd things they do in general.


The current behavior without special alignment for these caches has been
in the wild for over a decade. And this is now coming up?

There is one case now it seems with a broken hardware that has issues and
we now move to an alignment requirement from the slabs with exceptions and
this and that?

If there is an exceptional alignment requirement then that needs to be
communicated to the allocator. A special flag or create a special
kmem_cache or something.

