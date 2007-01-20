Date: Sat, 20 Jan 2007 04:52:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 6/10] mm: be sure to trim blocks
Message-ID: <20070120035204.GB30774@wotan.suse.de>
References: <20070113011159.9449.4327.sendpatchset@linux.site> <20070113011255.9449.33228.sendpatchset@linux.site> <1168968985.5975.30.camel@lappy> <1168974857.5975.36.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1168974857.5975.36.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 16, 2007 at 08:14:16PM +0100, Peter Zijlstra wrote:
> On Tue, 2007-01-16 at 18:36 +0100, Peter Zijlstra wrote:
> >   							buf, bytes);
> > > @@ -1935,10 +1922,9 @@ generic_file_buffered_write(struct kiocb
> > >  						cur_iov, iov_offset, bytes);
> > >  		flush_dcache_page(page);
> > >  		status = a_ops->commit_write(file, page, offset, offset+bytes);
> > > -		if (status == AOP_TRUNCATED_PAGE) {
> > > -			page_cache_release(page);
> > > -			continue;
> > > -		}
> > > +		if (unlikely(status))
> > > +			goto fs_write_aop_error;
> > > +
> > 
> > I don't think this is correct, see how status >= 0 is used a few lines
> > downwards. Perhaps something along the lines of an
> > is_positive_aop_return() to test on?
> 
> Hmm, if commit_write() will never return non error positive values then
> this and 8/10 look sane.

It's really ugly, but it looks like at least some filesystems do. So
I'll fix up this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
