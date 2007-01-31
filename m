Date: Wed, 31 Jan 2007 01:32:16 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 0/9] buffered write deadlock fix
Message-ID: <20070131003215.GA7163@wotan.suse.de>
References: <20070129081905.23584.97878.sendpatchset@linux.site> <20070130125558.ae9119b0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070130125558.ae9119b0.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Filesystems <linux-fsdevel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 30, 2007 at 12:55:58PM -0800, Andrew Morton wrote:
> On Mon, 29 Jan 2007 11:31:37 +0100 (CET)
> Nick Piggin <npiggin@suse.de> wrote:
> 
> > The following set of patches attempt to fix the buffered write
> > locking problems 
> 
> y'know, four or five years back I fixed this bug by doing
> 
> 	current->locked_page = page;
> 
> in the write() code, and then teaching the pagefault code to avoid locking
> the same page.  Patch below.
> 
> But then evil mean Hugh pointed out that the patch is still vulnerable to
> ab/ba deadlocking so I dropped it.
> 
> But Hugh lied!  There is no ab/ba deadlock because both a and b need
> i_mutex to get into the write() path.

Not only is there still the abba deadlock on page locks, as you point
out in your next mail, but there is also an abba on page lock vs mmap_sem.

> This approach doesn't fix the writev() performance regresson which
> nobody has measured yet but which the NFS guys reported.
> 
> But I think with this fix in place we can go back to a modified version of
> the 2.6.17 filemap.c code and get that performance back, but I haven't
> thought about that.
> 
> It's a heck of a lot simpler than your patches though ;)

Ignoring the cleanup patches, the only thing mine really do is to use
get_user_pages in  generic_file_buffered_write if the destination page
is not uptodate, and use atomic copies if it is. Conceptually pretty simple.

Mine fixes the writev performance regression iff the destination page
it uptodate. More importantly, they fix 3 deadlocks in the core mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
