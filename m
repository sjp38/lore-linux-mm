Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E0CE26B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 11:11:51 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w2so293610pgm.17
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 08:11:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id 90si429908pfp.65.2018.04.09.08.11.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 09 Apr 2018 08:11:51 -0700 (PDT)
Date: Mon, 9 Apr 2018 08:11:47 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Block layer use of __GFP flags
Message-ID: <20180409151147.GA11756@bombadil.infradead.org>
References: <20180408065425.GD16007@bombadil.infradead.org>
 <aea2f6bcae3fe2b88e020d6a258706af1ce1a58b.camel@wdc.com>
 <20180408190825.GC5704@bombadil.infradead.org>
 <63d16891d115de25ac2776088571d7e90dab867a.camel@wdc.com>
 <20180409085349.31b10550@pentland.suse.de>
 <20180409082650.GA869@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180409082650.GA869@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Hannes Reinecke <hare@suse.de>, Bart Van Assche <Bart.VanAssche@wdc.com>, "axboe@kernel.dk" <axboe@kernel.dk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "martin@lichtvoll.de" <martin@lichtvoll.de>, "oleksandr@natalenko.name" <oleksandr@natalenko.name>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>

On Mon, Apr 09, 2018 at 01:26:50AM -0700, Christoph Hellwig wrote:
> On Mon, Apr 09, 2018 at 08:53:49AM +0200, Hannes Reinecke wrote:
> > Why don't you fold the 'flags' argument into the 'gfp_flags', and drop
> > the 'flags' argument completely?
> > Looks a bit pointless to me, having two arguments denoting basically
> > the same ...
> 
> Wrong way around.  gfp_flags doesn't really make much sense in this
> context.  We just want the plain flags argument, including a non-block
> flag for it.

Look at this sequence from scsi_ioctl.c:

        if (bytes) {
                buffer = kzalloc(bytes, q->bounce_gfp | GFP_USER| __GFP_NOWARN);
                if (!buffer)
                        return -ENOMEM;

        }

        rq = blk_get_request(q, in_len ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN,
                        __GFP_RECLAIM);

That makes no damn sense.  If the buffer can be allocated using GFP_USER,
then the request should also be allocatable using GFP_USER.  In the current
tree, that (wrongly) gets translated into __GFP_DIRECT_RECLAIM.
