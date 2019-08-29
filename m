Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC79FC3A5A6
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:39:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 792B623403
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 07:39:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 792B623403
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0ABA96B0005; Thu, 29 Aug 2019 03:39:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05D8E6B0006; Thu, 29 Aug 2019 03:39:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB3D36B0266; Thu, 29 Aug 2019 03:39:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0166.hostedemail.com [216.40.44.166])
	by kanga.kvack.org (Postfix) with ESMTP id C528E6B0005
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 03:39:24 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 6B1756117
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:39:24 +0000 (UTC)
X-FDA: 75874665048.04.river10_34f96252ee65a
X-HE-Tag: river10_34f96252ee65a
X-Filterd-Recvd-Size: 3091
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:39:23 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 78FB3B03B;
	Thu, 29 Aug 2019 07:39:22 +0000 (UTC)
Date: Thu, 29 Aug 2019 09:39:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christopher Lameter <cl@linux.com>, Vlastimil Babka <vbabka@suse.cz>,
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
Message-ID: <20190829073921.GA21880@dhcp22.suse.cz>
References: <20190826111627.7505-1-vbabka@suse.cz>
 <20190826111627.7505-3-vbabka@suse.cz>
 <0100016cd98bb2c1-a2af7539-706f-47ba-a68e-5f6a91f2f495-000000@email.amazonses.com>
 <20190828194607.GB6590@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190828194607.GB6590@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 28-08-19 12:46:08, Matthew Wilcox wrote:
> On Wed, Aug 28, 2019 at 06:45:07PM +0000, Christopher Lameter wrote:
[...]
> > be suprising and it limits the optimizations that slab allocators may use
> > for optimizing data use. The SLOB allocator was designed in such a way
> > that data wastage is limited. The changes here sabotage that goal and show
> > that future slab allocators may be similarly constrained with the
> > exceptional alignents implemented. Additional debugging features etc etc
> > must all support the exceptional alignment requirements.
> 
> While I sympathise with the poor programmer who has to write the
> fourth implementation of the sl*b interface, it's more for the pain of
> picking a new letter than the pain of needing to honour the alignment
> of allocations.
> 
> There are many places in the kernel which assume alignment.  They break
> when it's not supplied.  I believe we have a better overall system if
> the MM developers provide stronger guarantees than the MM consumers have
> to work around only weak guarantees.

I absolutely agree. A hypothetical benefit of a new implementation
doesn't outweigh the complexity the existing code has to jump over or
worse is not aware of and it is broken silently. My general experience
is that the later is more likely with a large variety of drivers we have
in the tree and odd things they do in general.
-- 
Michal Hocko
SUSE Labs

