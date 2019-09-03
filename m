Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B814C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 20:13:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF2582339E
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 20:13:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="Cn915Kxo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF2582339E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 685896B0005; Tue,  3 Sep 2019 16:13:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 610AF6B0006; Tue,  3 Sep 2019 16:13:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D7706B0007; Tue,  3 Sep 2019 16:13:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0041.hostedemail.com [216.40.44.41])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3D76B0005
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 16:13:47 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id CA5AD824CA2E
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 20:13:46 +0000 (UTC)
X-FDA: 75894710052.17.ball98_5b2cf91b66207
X-HE-Tag: ball98_5b2cf91b66207
X-Filterd-Recvd-Size: 3718
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com [54.240.9.46])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 20:13:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1567541625;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=3CTlLgcwUNm+oBDTSqVhwT6v0ROJvSsfzOlbmJ233Hs=;
	b=Cn915KxoRAOo3PmJZOOm/ld4evNzr6pLGhw1L27Pj4A6Fs/aZr4YyJgWGbjjuYtj
	jeVgNkAMHrsCuy8IfzOPqbjM31SPPbl46ewrDDjxMgWc5IdaUb6qSn4OWC/M8d9fnKh
	6hQcvnAzb8uFmTKLv3L+pNjqUii1U+7KYP92y6TI=
Date: Tue, 3 Sep 2019 20:13:45 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Wilcox <willy@infradead.org>
cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, 
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
In-Reply-To: <20190901005205.GA2431@bombadil.infradead.org>
Message-ID: <0100016cf8c3033d-bbcc9ba3-2d59-4654-a7c2-8ba094f8a7de-000000@email.amazonses.com>
References: <20190826111627.7505-1-vbabka@suse.cz> <20190826111627.7505-3-vbabka@suse.cz> <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com> <20190828194607.GB6590@bombadil.infradead.org> <20190829073921.GA21880@dhcp22.suse.cz>
 <0100016ce39e6bb9-ad20e033-f3f4-4e6d-85d6-87e7d07823ae-000000@email.amazonses.com> <20190901005205.GA2431@bombadil.infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.09.03-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 31 Aug 2019, Matthew Wilcox wrote:

> > The current behavior without special alignment for these caches has been
> > in the wild for over a decade. And this is now coming up?
>
> In the wild ... and rarely enabled.  When it is enabled, it may or may
> not be noticed as data corruption, or tripping other debugging asserts.
> Users then turn off the rare debugging option.

Its enabled in all full debug session as far as I know. Fedora for
example has been running this for ages to find breakage in device drivers
etc etc.

> > If there is an exceptional alignment requirement then that needs to be
> > communicated to the allocator. A special flag or create a special
> > kmem_cache or something.
>
> The only way I'd agree to that is if we deliberately misalign every
> allocation that doesn't have this special flag set.  Because right now,
> breakage happens everywhere when these debug options are enabled, and
> the very people who need to be helped are being hurt by the debugging.

That is customarily occurring for testing by adding "slub_debug" to the
kernel commandline (or adding debug kernel options) and since my
information is that this is done frequently (and has been for over a
decade now) I am having a hard time believing the stories of great
breakage here. These drivers were not tested with debugging on before?
Never ran with a debug kernel?

