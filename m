Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 290B38E00C0
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 12:52:01 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e68so11085511plb.3
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 09:52:01 -0800 (PST)
Date: Tue, 11 Dec 2018 09:51:56 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] aio: Convert ioctx_table to XArray
Message-ID: <20181211175156.GF6830@bombadil.infradead.org>
References: <20181128183531.5139-1-willy@infradead.org>
 <x49va46e1p0.fsf@segfault.boston.devel.redhat.com>
 <x49pnuee1gm.fsf@segfault.boston.devel.redhat.com>
 <x49mupcm11r.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49mupcm11r.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>

On Tue, Dec 11, 2018 at 12:21:52PM -0500, Jeff Moyer wrote:
> I'm going to submit this version formally.  If you're interested in
> converting the ioctx_table to xarray, you can do that separately from a
> security fix.  I would include a performance analysis with that patch,
> though.  The idea of using a radix tree for the ioctx table was
> discarded due to performance reasons--see commit db446a08c23d5 ("aio:
> convert the ioctx list to table lookup v3").  I suspect using the xarray
> will perform similarly.

There's a big difference between Octavian's patch and mine.  That patch
indexed into the radix tree by 'ctx_id' directly, which was pretty
much guaranteed to exhibit some close-to-worst-case behaviour from the
radix tree due to IDs being sparsely assigned.  My patch uses the ring
ID which _we_ assigned, and so is nicely behaved, being usually a very
small integer.

What performance analysis would you find compelling?  Octavian's original
fio script:

> rw=randrw; size=256k ;directory=/mnt/fio; ioengine=libaio; iodepth=1
> blocksize=1024; numjobs=512; thread; loops=100
> 
> on an EXT2 filesystem mounted on top of a ramdisk

or something else?
