Date: Fri, 9 Feb 2007 09:30:58 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [PATCH 1 of 2] Implement generic block_page_mkwrite() functionality
Message-ID: <20070208223058.GV44411608@melbourne.sgi.com>
References: <20070207124922.GK44411608@melbourne.sgi.com> <Pine.LNX.4.64.0702071256530.25060@blonde.wat.veritas.com> <20070207144415.GN44411608@melbourne.sgi.com> <Pine.LNX.4.64.0702071454250.32223@blonde.wat.veritas.com> <20070207225013.GQ44411608@melbourne.sgi.com> <20070208131100.GH11967@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070208131100.GH11967@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: David Chinner <dgc@sgi.com>, Hugh Dickins <hugh@veritas.com>, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 08, 2007 at 08:11:00AM -0500, Chris Mason wrote:
> On Thu, Feb 08, 2007 at 09:50:13AM +1100, David Chinner wrote:
> > > You don't need to lock out all truncation, but you do need to lock
> > > out truncation of the page in question.  Instead of your i_size
> > > checks, check page->mapping isn't NULL after the lock_page?
> > 
> > Yes, that can be done, but we still need to know if part of
> > the page is beyond EOF for when we call block_commit_write()
> > and mark buffers dirty. Hence we need to check the inode size.
> > 
> > I guess if we block the truncate with the page lock, then the
> > inode size is not going to change until we unlock the page.
> > If the inode size has already been changed but the page not yet
> > removed from the mapping we'll be beyond EOF.
> > 
> > So it seems to me that we can get away with not using the i_mutex
> > in the generic code here.
> 
> vmtruncate changes the inode size before waiting on any pages.  So,
> i_size could change any time during page_mkwrite.

Which would put us beyond EOF. Ok.

> It would be a good idea to read i_size once and put it in a local var
> instead.

Will do - I'll snap it once the page is locked....

Thanks Chris.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
