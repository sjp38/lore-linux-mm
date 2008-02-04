Date: Mon, 4 Feb 2008 15:59:52 -0500
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [patch 0/3] add perform_write to a_ops
Message-ID: <20080204205950.GB14084@lst.de>
References: <20080204170409.991123259@szeredi.hu> <20080204193939.GA19236@lst.de> <E1JM8IQ-0003pP-Dw@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E1JM8IQ-0003pP-Dw@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: hch@lst.de, npiggin@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2008 at 09:52:06PM +0100, Miklos Szeredi wrote:
> Moving up to higher layers might not be possible, due to lock/unlock
> of i_mutex being inside generic_file_aio_write().

Well some bits can be moved up.  Here's my grand plan which I plan
to implement once I get some time for it (or let someone else do
if they beat me):

 - generic_segment_checks goes to fs/read_write.c before caling into
   the filesystem
 - dito for vfs_check_frozen
 - generic_write_checks is a suitable helper already
 - dito for remove_suid
 - dito for file_update_time
 - after that there's not a whole lot left in generic_file_aio_write,
   except for direct I/O handling which will probably be very fs-specific
   if you have your own buffered I/O code

generic_file_buffered_write is an almost trivial wrapper around what's
->perform_write in Nick's earlier patches and a helper for the syncing
activity.



> 
> But with fuse being the only user, it's not a huge issue duplicating
> some code.
> 
> Nick, were there any other candidates, that would want to use such an
> interface in the future?
> 
> Thanks,
> Miklos
> -
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
---end quoted text---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
