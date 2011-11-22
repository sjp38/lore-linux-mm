Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B3DD16B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 09:18:36 -0500 (EST)
Date: Tue, 22 Nov 2011 22:18:29 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 8/8] readahead: dont do start-of-file readahead after
 lseek()
Message-ID: <20111122141829.GB29261@localhost>
References: <20111121091819.394895091@intel.com>
 <20111121093847.015852579@intel.com>
 <20111121153624.dea4f320.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121153624.dea4f320.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

> > --- linux-next.orig/fs/read_write.c	2011-11-20 22:02:01.000000000 +0800
> > +++ linux-next/fs/read_write.c	2011-11-20 22:02:03.000000000 +0800
> > @@ -47,6 +47,10 @@ static loff_t lseek_execute(struct file 
> >  		file->f_pos = offset;
> >  		file->f_version = 0;
> >  	}
> > +
> > +	if (!(file->f_ra.ra_flags & READAHEAD_LSEEK))
> > +		file->f_ra.ra_flags |= READAHEAD_LSEEK;
> > +
> >  	return offset;
> >  }
> 
> Confused.  How does READAHEAD_LSEEK get cleared again?

I thought it's not necessary (at least for this case). But yeah, it's
good to clear it to make it more reasonable and avoid unexpected things.

And it would be simple to do, in ra_submit():

-       ra->ra_flags &= ~READAHEAD_MMAP;
+       ra->ra_flags &= ~(READAHEAD_MMAP | READAHEAD_LSEEK);

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
