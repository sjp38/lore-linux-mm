Date: Sat, 14 Oct 2006 06:30:41 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 6/6] mm: fix pagecache write deadlocks
Message-ID: <20061014043041.GC14467@wotan.suse.de>
References: <20061013143516.15438.8802.sendpatchset@linux.site> <20061013143616.15438.77140.sendpatchset@linux.site> <20061013151457.81bb7f03.akpm@osdl.org> <20061014041927.GA14467@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061014041927.GA14467@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>, Neil Brown <neilb@suse.de>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 14, 2006 at 06:19:27AM +0200, Nick Piggin wrote:
> On Fri, Oct 13, 2006 at 03:14:57PM -0700, Andrew Morton wrote:
> > On Fri, 13 Oct 2006 18:44:52 +0200 (CEST)
> > Nick Piggin <npiggin@suse.de> wrote:
> > > 
> > > - This also showed up a number of buggy prepare_write / commit_write
> > >   implementations that were setting the page uptodate in the prepare_write
> > >   side: bad! this allows uninitialised data to be read. Fix these.
> > 
> > Well.  It's non-buggy under the current protocol because the page remains
> > locked throughout.  This patch would make these ->prepare_write()
> > implementations buggy.
> 
> But if it becomes uptodate, then do_generic_mapping_read can read it
> without locking it (and so can filemap_nopage at present, although it
> looks like that's going to take the page lock soon).

So the simple_prepare_write bug is an uninitialised data loeak. If
you read the part of the file which is about to be written to (and thus
does not get memset()ed), you can read junk.

I was able to trigger this with a simple test on ramfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
