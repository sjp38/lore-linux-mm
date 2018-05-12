Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0892A6B06D9
	for <linux-mm@kvack.org>; Fri, 11 May 2018 21:56:45 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id s201-v6so3445952ita.1
        for <linux-mm@kvack.org>; Fri, 11 May 2018 18:56:45 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id j128-v6si2258021itj.45.2018.05.11.18.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 May 2018 18:56:43 -0700 (PDT)
Date: Fri, 11 May 2018 18:56:38 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 10/33] iomap: add an iomap-based bmap implementation
Message-ID: <20180512015638.GX11261@magnolia>
References: <20180509074830.16196-1-hch@lst.de>
 <20180509074830.16196-11-hch@lst.de>
 <20180509164628.GV11261@magnolia>
 <20180510064250.GD11422@lst.de>
 <20180510150838.GE25312@magnolia>
 <20180511062527.GE7962@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180511062527.GE7962@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org

On Fri, May 11, 2018 at 08:25:27AM +0200, Christoph Hellwig wrote:
> On Thu, May 10, 2018 at 08:08:38AM -0700, Darrick J. Wong wrote:
> > > > > +	sector_t *bno = data;
> > > > > +
> > > > > +	if (iomap->type == IOMAP_MAPPED)
> > > > > +		*bno = (iomap->addr + pos - iomap->offset) >> inode->i_blkbits;
> > > > 
> > > > Does this need to be careful w.r.t. overflow on systems where sector_t
> > > > is a 32-bit unsigned long?
> > > > 
> > > > Also, ioctl_fibmap() typecasts the returned sector_t to an int, which
> > > > also seems broken.  I agree the interface needs to die, but ioctls take
> > > > a long time to deprecate.
> > > 
> > > Not much we can do about the interface.
> > 
> > Yes, the interface is fubar, but if file /foo maps to block 8589934720
> > then do we return the truncated result 128?
> 
> Then we'll get a corrupt result.  What do you think we could do here
> eithere in the old or new code?

I think the only thing we /can/ do is figure out if we'd be truncating
the result, dump a warning to the kernel, and return 0, because we don't
want smartypants FIBMAP callers to be using crap block pointers.

Something like this for the bmap implementation...

uint64_t mapping = iomap->addr;

#ifdef CONFIG_LBDAF
if (mapping > ULONG_MAX) {
	/* Do not truncate results. */
	return 0;
}
#endif

...and in the bmap ioctl...

sector_t mapping = ...;

if (mapping > INT_MAX) {
	WARN(1, "would truncate bmap result, go fix your stupid program");
	return 0;
}

--D

> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
