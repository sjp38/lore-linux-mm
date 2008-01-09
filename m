Date: Wed, 9 Jan 2008 18:41:41 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH][RFC][BUG] updating the ctime and mtime time stamps in
 msync()
Message-ID: <20080109184141.287189b8@bree.surriel.com>
In-Reply-To: <20080109223340.GH25527@unthought.net>
References: <1199728459.26463.11.camel@codedot>
	<20080109155015.4d2d4c1d@cuia.boston.redhat.com>
	<26932.1199912777@turing-police.cc.vt.edu>
	<20080109170633.292644dc@cuia.boston.redhat.com>
	<20080109223340.GH25527@unthought.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jakob Oestergaard <jakob@unthought.net>
Cc: Valdis.Kletnieks@vt.edu, Anton Salikhmetov <salikhmetov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Jan 2008 23:33:40 +0100
Jakob Oestergaard <jakob@unthought.net> wrote:
> On Wed, Jan 09, 2008 at 05:06:33PM -0500, Rik van Riel wrote:

> > Can we get by with simply updating the ctime and mtime every time msync()
> > is called, regardless of whether or not the mmaped pages were still dirty
> > by the time we called msync() ?
> 
> The update must still happen, eventually, after a write to the mapped region
> followed by an unmap/close even if no msync is ever called.
> 
> The msync only serves as a "no later than" deadline. The write to the region
> triggers the need for the update.
> 
> At least this is how I read the standard - please feel free to correct me if I
> am mistaken.
 
You are absolutely right.  If we wrote dirty pages to disk, the ctime
and mtime updates must happen no later than msync or close time.

I guess a third possible time (if we want to minimize the number of
updates) would be when natural syncing of the file data to disk, by
other things in the VM, would be about to clear the I_DIRTY_PAGES
flag on the inode.  That way we do not need to remember any special
"we already flushed all dirty data, but we have not updated the mtime
and ctime yet" state.

Does this sound reasonable?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
