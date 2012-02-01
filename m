Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 56ECC6B002C
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 22:37:05 -0500 (EST)
Date: Tue, 31 Jan 2012 22:36:53 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-ID: <20120201033653.GA12092@redhat.com>
References: <1327996780.21268.42.camel@sli10-conroe>
 <20120131220333.GD4378@redhat.com>
 <20120131141301.ba35ffe0.akpm@linux-foundation.org>
 <20120131222217.GE4378@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120131222217.GE4378@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Wu Fengguang <wfg@linux.intel.com>

On Tue, Jan 31, 2012 at 05:22:17PM -0500, Vivek Goyal wrote:
[..]

> > 
> > We've never really bothered making the /dev/sda[X] I/O very efficient
> > for large I/O's under the (probably wrong) assumption that it isn't a
> > very interesting case.  Regular files will (or should) use the mpage
> > functions, via address_space_operations.readpages().  fs/blockdev.c
> > doesn't even implement it.
> > 
> > > and by the time all the pages
> > > are submitted and one big merged request is formed it wates lot of time.
> > 
> > But that was the case in eariler kernels too.  Why did it change?
> 
> Actually, I assumed that the case of reading /dev/sda[X] worked well in
> earlier kernels. Sorry about that. Will build a 2.6.38 kernel tonight
> and run the test case again to make sure we had same overhead and
> relatively poor performance while reading /dev/sda[X].

Ok, I tried it with 2.6.38 kernel and results look more or less same.
Throughput varied between 105MB to 145MB. Many a times it was close to
110MB and other times it was 145MB. Don't know what causes that spike
sometimes.

I still see that IO is being submitted one page at a time. The only
real difference seems to be that queue unplug happening at random times
and many a times we are submitting much smaller requests (40 sectors, 48
sectors etc).

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
