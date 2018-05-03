Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AD3796B0005
	for <linux-mm@kvack.org>; Thu,  3 May 2018 08:13:34 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id r9-v6so7892879pgp.12
        for <linux-mm@kvack.org>; Thu, 03 May 2018 05:13:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q1-v6si13308309plb.549.2018.05.03.05.13.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 03 May 2018 05:13:30 -0700 (PDT)
Date: Thu, 3 May 2018 05:13:22 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
Message-ID: <20180503121322.GA14864@infradead.org>
References: <20180426215406.GB27853@wotan.suse.de>
 <20180427053556.GB11339@infradead.org>
 <20180427161456.GD27853@wotan.suse.de>
 <20180428084221.GD31684@infradead.org>
 <20180428185514.GW27853@wotan.suse.de>
 <CAFhKne8u7KcBkpgiQ0fFZyh5_EorfY-_MJJaEYk3feCOd9LsRQ@mail.gmail.com>
 <20180503120338.GG4535@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180503120338.GG4535@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy6545@gmail.com>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Christoph Hellwig <hch@infradead.org>, Dan Carpenter <dan.carpenter@oracle.com>, Julia Lawall <julia.lawall@lip6.fr>, linux-mm@kvack.org, cl@linux.com, Jan Kara <jack@suse.cz>, matthew@wil.cx, x86@kernel.org, luto@amacapital.net, martin.petersen@oracle.com, jthumshirn@suse.de, broonie@kernel.org, Juergen Gross <jgross@suse.com>, linux-spi@vger.kernel.org, Joerg Roedel <joro@8bytes.org>, linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Thu, May 03, 2018 at 02:03:38PM +0200, Michal Hocko wrote:
> On Sat 28-04-18 19:10:47, Matthew Wilcox wrote:
> > Another way we could approach this is to get rid of ZONE_DMA. Make GFP_DMA
> > a flag which doesn't map to a zone. Rather, it redirects to a separate
> > allocator. At boot, we hand all memory under 16MB to the DMA allocator. The
> > DMA allocator can have a shrinker which just hands back all the memory once
> > we're under memory pressure (if it's never had an allocation).
> 
> Yeah, that was exactly the plan with the CMA allocator... We wouldn't
> need the shrinker because who cares about 16MB which is not usable
> anyway.

The CMA pool sounds fine.  But please kill GFP_DMA off first / at the
same time.  95% of the users are either completely bogus or should be
using the DMA API, and the few other can use the new allocator directly.
