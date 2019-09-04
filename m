Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA5E7C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:41:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E02B22CF5
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 06:41:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E02B22CF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 08C056B0006; Wed,  4 Sep 2019 02:41:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03C716B0007; Wed,  4 Sep 2019 02:41:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFA216B000A; Wed,  4 Sep 2019 02:41:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0214.hostedemail.com [216.40.44.214])
	by kanga.kvack.org (Postfix) with ESMTP id B791C6B0006
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 02:41:01 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 61BE7AF90
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:41:01 +0000 (UTC)
X-FDA: 75896290722.27.straw10_25fcccac8c95d
X-HE-Tag: straw10_25fcccac8c95d
X-Filterd-Recvd-Size: 3268
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 06:41:00 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9D48E315C006;
	Wed,  4 Sep 2019 06:40:59 +0000 (UTC)
Received: from ming.t460p (ovpn-8-23.pek2.redhat.com [10.72.8.23])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C585C60BFB;
	Wed,  4 Sep 2019 06:40:48 +0000 (UTC)
Date: Wed, 4 Sep 2019 14:40:44 +0800
From: Ming Lei <ming.lei@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Matthew Wilcox <willy@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-btrfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] mm, sl[aou]b: guarantee natural alignment for
 kmalloc(power-of-two)
Message-ID: <20190904064043.GA7578@ming.t460p>
References: <20190826111627.7505-1-vbabka@suse.cz>
 <20190826111627.7505-3-vbabka@suse.cz>
 <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com>
 <20190828194607.GB6590@bombadil.infradead.org>
 <20190829073921.GA21880@dhcp22.suse.cz>
 <0100016ce39e6bb9-ad20e033-f3f4-4e6d-85d6-87e7d07823ae-000000@email.amazonses.com>
 <20190901005205.GA2431@bombadil.infradead.org>
 <0100016cf8c3033d-bbcc9ba3-2d59-4654-a7c2-8ba094f8a7de-000000@email.amazonses.com>
 <20190903205312.GK29434@bombadil.infradead.org>
 <20190904051933.GA10218@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904051933.GA10218@lst.de>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 04 Sep 2019 06:41:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 04, 2019 at 07:19:33AM +0200, Christoph Hellwig wrote:
> On Tue, Sep 03, 2019 at 01:53:12PM -0700, Matthew Wilcox wrote:
> > > Its enabled in all full debug session as far as I know. Fedora for
> > > example has been running this for ages to find breakage in device drivers
> > > etc etc.
> > 
> > Are you telling me nobody uses the ramdisk driver on fedora?  Because
> > that's one of the affected drivers.
> 
> For pmem/brd misaligned memory alone doesn't seem to be the problem.
> Misaligned memory that cross a page barrier is.  And at least XFS
> before my log recovery changes only used kmalloc for smaller than
> page size allocation, so this case probably didn't hit.

BTW, does sl[aou]b guarantee that smaller than page size allocation via kmalloc()
won't cross page boundary any time?

Thanks,
Ming

