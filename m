Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3E631900002
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 06:18:09 -0400 (EDT)
Date: Thu, 8 Aug 2013 12:18:07 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 0/3] Add madvise(..., MADV_WILLWRITE)
Message-ID: <20130808101807.GB4325@quack.suse.cz>
References: <cover.1375729665.git.luto@amacapital.net>
 <20130807134058.GC12843@quack.suse.cz>
 <520286A4.1020101@intel.com>
 <CALCETrXAz1fc7y07LhmxNh6zA_KZB4yv57NY2MrhUwKdkypB9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXAz1fc7y07LhmxNh6zA_KZB4yv57NY2MrhUwKdkypB9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 07-08-13 11:00:52, Andy Lutomirski wrote:
> On Wed, Aug 7, 2013 at 10:40 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> > On 08/07/2013 06:40 AM, Jan Kara wrote:
> >>   One question before I look at the patches: Why don't you use fallocate()
> >> in your application? The functionality you require seems to be pretty
> >> similar to it - writing to an already allocated block is usually quick.
> >
> > One problem I've seen is that it still costs you a fault per-page to get
> > the PTEs in to a state where you can write to the memory.  MADV_WILLNEED
> > will do readahead to get the page cache filled, but it still leaves the
> > pages unmapped.  Those faults get expensive when you're trying to do a
> > couple hundred million of them all at once.
> 
> I have grand plans to teach the kernel to use hardware dirty tracking
> so that (some?) pages can be left clean and writable for long periods
> of time.  This will be hard.
  Right that will be tough... Although with your application you could
require such pages to be mlocked and then I could imagine we would get away
at least from problems with dirty page accounting.

> Even so, the second write fault to a page tends to take only a few
> microseconds, while the first one often blocks in fs code.
  So you wrote blocks are already preallocated with fallocate(). If you
also preload pages in memory with MADV_WILLNEED is there still big
difference between the first and subsequent write fault?

> (mmap_sem is a different story, but I see it as a separate issue.)
  Yeah, agreed.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
