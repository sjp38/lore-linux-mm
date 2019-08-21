Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B62CC3A589
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 01:49:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FB5F22D6D
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 01:49:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="MQBLmHoe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FB5F22D6D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C407E6B027B; Tue, 20 Aug 2019 21:49:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC9AE6B027C; Tue, 20 Aug 2019 21:49:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A90586B027D; Tue, 20 Aug 2019 21:49:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0080.hostedemail.com [216.40.44.80])
	by kanga.kvack.org (Postfix) with ESMTP id 8122E6B027B
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 21:49:20 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 400318248ABE
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:49:20 +0000 (UTC)
X-FDA: 75844752480.01.bait23_173e693997318
X-HE-Tag: bait23_173e693997318
X-Filterd-Recvd-Size: 3131
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 01:49:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=SGtyDfOk7ztf7e1zq8UPqa3xUIMnaYAeWahTWcEr7d4=; b=MQBLmHoexH6YgdK4vldQKz4da
	8RAZW2Yi8DxJxQAlpwgczYaEaHM1c41vT1AnkpoCnNqXbGnGTNghSk0fVikznf0kIEi0v+5N5r8g1
	/6oblkV7iXrJ3a45Axj84aDQZSNiq8kQRjY+HUCF8V1Py56nJy0hBCl9/lpFyn+yndcDaRZqJkzVt
	bIi8Pv29Kk3FsfaRxdzwIJpj8AfPIsMMPyFdhswi9/+xmIhUaAbFj+F5czW5zAlG2znKGKTxCbpT/
	UF3RHjXmL4RitId7QozMvfJ4mmRlqlKtKIA6x7b3LDsgzeXJblkyLmEfssdO0Km6aGAzq3az5/zkW
	SJ4UIFkeA==;
Received: from hch by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i0FkA-0003gm-R5; Wed, 21 Aug 2019 01:48:58 +0000
Date: Tue, 20 Aug 2019 18:48:58 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, dsterba@suse.cz,
	Christophe Leroy <christophe.leroy@c-s.fr>, erhard_f@mailbox.org,
	Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>,
	David Sterba <dsterba@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-btrfs@vger.kernel.org, linux-mm@kvack.org,
	stable@vger.kernel.org, Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] btrfs: fix allocation of bitmap pages.
Message-ID: <20190821014858.GA9158@infradead.org>
References: <20190817074439.84C6C1056A3@localhost.localdomain>
 <20190819174600.GN24086@twin.jikos.cz>
 <20190820023031.GC9594@infradead.org>
 <6f99b73c-db8f-8135-b827-0a135734d7da@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f99b73c-db8f-8135-b827-0a135734d7da@suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 01:06:25PM +0200, Vlastimil Babka wrote:
> > The whole point of copy_page is to copy exactly one page and it makes
> > sense to assume that is aligned.  A sane memcpy would use the same
> > underlying primitives as well after checking they fit.  So I think the
> > prime issue here is btrfs' use of copy_page instead of memcpy.  The
> > secondary issue is slub fucking up alignments for no good reason.  We
> > just got bitten by that crap again in XFS as well :(
> 
> Meh, I should finally get back to https://lwn.net/Articles/787740/ right

Yes.  For now Dave came up with an idea for a workaround that will
be forward-compatible with that:

https://www.spinics.net/lists/linux-xfs/msg30521.html

