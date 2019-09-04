Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1282DC3A5A4
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:19:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D384C2073F
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 05:19:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D384C2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D2F66B0003; Wed,  4 Sep 2019 01:19:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 584056B0006; Wed,  4 Sep 2019 01:19:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C1E36B0007; Wed,  4 Sep 2019 01:19:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id 2B4746B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 01:19:39 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BD783824CA39
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:19:38 +0000 (UTC)
X-FDA: 75896085636.15.taste62_370b306354038
X-HE-Tag: taste62_370b306354038
X-Filterd-Recvd-Size: 2670
Received: from verein.lst.de (verein.lst.de [213.95.11.211])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 05:19:38 +0000 (UTC)
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7B64868AEF; Wed,  4 Sep 2019 07:19:33 +0200 (CEST)
Date: Wed, 4 Sep 2019 07:19:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>,
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
Message-ID: <20190904051933.GA10218@lst.de>
References: <20190826111627.7505-1-vbabka@suse.cz> <20190826111627.7505-3-vbabka@suse.cz> <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com> <20190828194607.GB6590@bombadil.infradead.org> <20190829073921.GA21880@dhcp22.suse.cz> <0100016ce39e6bb9-ad20e033-f3f4-4e6d-85d6-87e7d07823ae-000000@email.amazonses.com> <20190901005205.GA2431@bombadil.infradead.org> <0100016cf8c3033d-bbcc9ba3-2d59-4654-a7c2-8ba094f8a7de-000000@email.amazonses.com> <20190903205312.GK29434@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190903205312.GK29434@bombadil.infradead.org>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 03, 2019 at 01:53:12PM -0700, Matthew Wilcox wrote:
> > Its enabled in all full debug session as far as I know. Fedora for
> > example has been running this for ages to find breakage in device drivers
> > etc etc.
> 
> Are you telling me nobody uses the ramdisk driver on fedora?  Because
> that's one of the affected drivers.

For pmem/brd misaligned memory alone doesn't seem to be the problem.
Misaligned memory that cross a page barrier is.  And at least XFS
before my log recovery changes only used kmalloc for smaller than
page size allocation, so this case probably didn't hit.  But other
cases where alignment and not just not crossing a page boundary
occurred and we had problems with those before.  It just too a long
time for people to root cause them.

