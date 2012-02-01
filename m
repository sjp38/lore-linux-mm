Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 284B76B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 15:22:43 -0500 (EST)
Date: Wed, 1 Feb 2012 12:22:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fix readahead pipeline break caused by block plug
Message-Id: <20120201122241.db4056f6.akpm@linux-foundation.org>
In-Reply-To: <20120201201017.GC13246@redhat.com>
References: <1327996780.21268.42.camel@sli10-conroe>
	<20120131220333.GD4378@redhat.com>
	<20120131141301.ba35ffe0.akpm@linux-foundation.org>
	<20120131222217.GE4378@redhat.com>
	<20120201033653.GA12092@redhat.com>
	<20120201091807.GA7451@infradead.org>
	<20120201201017.GC13246@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Shaohua Li <shaohua.li@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Herbert Poetzl <herbert@13thfloor.at>, Eric Dumazet <eric.dumazet@gmail.com>, Wu Fengguang <wfg@linux.intel.com>

On Wed, 1 Feb 2012 15:10:17 -0500
Vivek Goyal <vgoyal@redhat.com> wrote:

> On Wed, Feb 01, 2012 at 04:18:07AM -0500, Christoph Hellwig wrote:
> > On Tue, Jan 31, 2012 at 10:36:53PM -0500, Vivek Goyal wrote:
> > > I still see that IO is being submitted one page at a time. The only
> > > real difference seems to be that queue unplug happening at random times
> > > and many a times we are submitting much smaller requests (40 sectors, 48
> > > sectors etc).
> > 
> > This is expected given that the block device node uses
> > block_read_full_page, and not mpage_readpage(s).
> 
> What is the difference between block_read_full_page() and
> mpage_readpage().

block_read_full_page() will attach buffer_heads to the page and will
perform IO via those buffer_heads.  mpage_readpage() feeds the page
directly to the BIO layer and leaves it without attached buffer_heads.

> IOW, why block device does not use mpage_readpage(s)
> interface?

We've tried it in the past and problems ensued.  A quick google search
for blkdev_readpages turns up stuff like
http://us.generation-nt.com/answer/patch-add-readpages-support-block-devices-help-201462802.html

> Applying following patch improved the speed from 110MB/s to more than
> 230MB/s.

Yeah.  It should be doable - it would be a matter of hunting down and
squishing the oddball corner cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
