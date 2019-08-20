Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6635BC3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:30:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B78422CE8
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 02:30:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="mH0VY+ov"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B78422CE8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B51536B0007; Mon, 19 Aug 2019 22:30:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B28856B0008; Mon, 19 Aug 2019 22:30:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A17FD6B000A; Mon, 19 Aug 2019 22:30:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0197.hostedemail.com [216.40.44.197])
	by kanga.kvack.org (Postfix) with ESMTP id 813776B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 22:30:53 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 31FAD180AD801
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:30:53 +0000 (UTC)
X-FDA: 75841228386.08.point38_24c6d9bd3a048
X-HE-Tag: point38_24c6d9bd3a048
X-Filterd-Recvd-Size: 3136
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 02:30:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:To:From:Date:Sender:Reply-To:Cc:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=uPXPHVEYMLe1+2GVdYIOdPqr5CMV8EsylIRmKkmRT3Q=; b=mH0VY+ovyP9mQQyeA2pygVd+6
	jlgtHzACKYGkOPyDVHPZ1PjKaSFzvetqdR5EDtZcKQm5AZEUs7VM7R3dfG5jl0z5n+Ie4leAPKsGJ
	u/vM7LKI6mT/GNbP7XvILp+P6nx6S71Mv/CoaZ8idyC8hOQQZ3gwCUl+ZL/B2nzffjhxYzGyJWJNx
	KkcWSK7fwws93Q69B/L7lCriRIvh7VSGlJDyi2G4DHiyHNQM5dJK2HV73vxCCrwNwGaSZCu3Wc5P1
	McDsO+eyJSOiseL+x6zSQ+MN5Ix3KK3HW8EocfpujB8ickMfRLColHq2KFtkfRL3/UjGP4IDHSW+j
	s8IxFRwEg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hztup-0001lf-QO; Tue, 20 Aug 2019 02:30:31 +0000
Date: Mon, 19 Aug 2019 19:30:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: dsterba@suse.cz, Christophe Leroy <christophe.leroy@c-s.fr>,
	erhard_f@mailbox.org, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, David Sterba <dsterba@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-btrfs@vger.kernel.org, linux-mm@kvack.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] btrfs: fix allocation of bitmap pages.
Message-ID: <20190820023031.GC9594@infradead.org>
References: <20190817074439.84C6C1056A3@localhost.localdomain>
 <20190819174600.GN24086@twin.jikos.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190819174600.GN24086@twin.jikos.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 19, 2019 at 07:46:00PM +0200, David Sterba wrote:
> Another thing that is lost is the slub debugging support for all
> architectures, because get_zeroed_pages lacking the red zones and sanity
> checks.
> 
> I find working with raw pages in this code a bit inconsistent with the
> rest of btrfs code, but that's rather minor compared to the above.
> 
> Summing it up, I think that the proper fix should go to copy_page
> implementation on architectures that require it or make it clear what
> are the copy_page constraints.

The whole point of copy_page is to copy exactly one page and it makes
sense to assume that is aligned.  A sane memcpy would use the same
underlying primitives as well after checking they fit.  So I think the
prime issue here is btrfs' use of copy_page instead of memcpy.  The
secondary issue is slub fucking up alignments for no good reason.  We
just got bitten by that crap again in XFS as well :(

