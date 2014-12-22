Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 678F86B006E
	for <linux-mm@kvack.org>; Mon, 22 Dec 2014 02:32:40 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so5253335pde.26
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 23:32:40 -0800 (PST)
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com. [209.85.220.52])
        by mx.google.com with ESMTPS id cn5si24035006pdb.137.2014.12.21.23.32.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 21 Dec 2014 23:32:39 -0800 (PST)
Received: by mail-pa0-f52.google.com with SMTP id eu11so5410472pac.39
        for <linux-mm@kvack.org>; Sun, 21 Dec 2014 23:32:38 -0800 (PST)
Date: Sun, 21 Dec 2014 23:32:34 -0800
From: Omar Sandoval <osandov@osandov.com>
Subject: Re: [PATCH v2 4/5] swapfile: use ->read_iter and ->write_iter
Message-ID: <20141222073234.GA14207@mew>
References: <cover.1419044605.git.osandov@osandov.com>
 <d8819b57849221b3db7c479f070067808912f0d5.1419044605.git.osandov@osandov.com>
 <20141220061337.GB22149@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141220061337.GB22149@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>

On Sat, Dec 20, 2014 at 06:13:37AM +0000, Al Viro wrote:
> On Fri, Dec 19, 2014 at 07:18:28PM -0800, Omar Sandoval wrote:
> 
> > +		ret = swap_file->f_op->read_iter(&kiocb, &to);
> > +		if (ret == PAGE_SIZE) {
> > +			SetPageUptodate(page);
> >  			count_vm_event(PSWPIN);
> > +			ret = 0;
> > +		} else {
> > +			ClearPageUptodate(page);
> > +			SetPageError(page);
> > +		}
> > +		unlock_page(page);
> 
> Umm...  What's to guarantee that ->read_iter() won't try lock_page() on what
> turns out to be equal to page?

Ergh. I don't see why ->read_iter would be screwing around in the swap
cache or with the pages in the iterator, anything in particular you can
see happening?

-- 
Omar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
