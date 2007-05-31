From: Neil Brown <neilb@suse.de>
Date: Thu, 31 May 2007 16:51:26 +1000
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18014.28782.874934.912337@notabene.brown>
Subject: Re: [PATCH/RFC] Is it OK for 'read' to return nuls for a file   that
 never had nuls in it?
In-Reply-To: message from Nick Piggin on Tuesday May 29
References: <18011.51290.257450.26100@notabene.brown>
	<465BCAA9.3070707@yahoo.com.au>
	<18011.53140.20314.43413@notabene.brown>
	<465BD63B.5020603@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Linich <plinich@cse.unsw.edu.au>, Ram Pai <linuxram@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tuesday May 29, nickpiggin@yahoo.com.au wrote:
> 
> But then I think a problem remains after your patch that if the page is
> partially truncated after you test that it is uptodate and resample i_size,
> then the page tail can be zero filled and then you'll again get back a
> nul tail from read(2), don't we? We could probably fix this beautifully by
> doing a lock_page over do_generic_mapping_read... ha ha, that would be
> popular.
> 
> For now I think your patch probably eliminates some classes of the bug
> completely and remainder are a small race-window rather than a straight-line
> bug, so it is probably the best way to go for now. I'd say
> Acked-by: Nick Piggin <npiggin@suse.de>. Ram Pai I believe also worked on
> similar issues with me, so I'll cc him.

Yes, the race with truncate_partial_page had occurred to me too.  It
can zero-out part of a page at any time with-respect-to
do_generic_mapping_read.  Apart from locking the page (which is
unlikely to go down well) the only solution I can think of is to check
the size again afterwards and fix things up if we over-shot the new
end-of-file.  We would at-least need to fix up 'ret' and
desc->written, and maybe desc->count and desc->arg.buf as well -
sounds messy.  Best to just leave it for now?

As an aside, what do you suppose should happen in the face of a race
between readv and extension of the file.
To be more specific, suppose we do a readv passing an iovec holding 2
1K buffers.  Suppose further that at this point in time we are 512
bytes from the end of the file.
If do_readv_writev takes the do_sync_readv_writev branch and calls
generic_file_aio_read, it will simply call do_generic_read_file for
each of the two buffers.
The first gets 512 bytes.  Then someone extends the file before the
second call which - for example - gets another 512 bytes.
So readv returns 1024, but the bytes aren't all in the first buffer.
They are half in the first buffer and half in the second.

So do we need this patch?  (It is my fourth attempt at getting the
logic right, but it now looks similar to the logic in
do_loop_readv_writev, so that is encouraging).

NeilBrown

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./mm/filemap.c |    2 ++
 1 file changed, 2 insertions(+)

diff .prev/mm/filemap.c ./mm/filemap.c
--- .prev/mm/filemap.c	2007-05-29 16:45:26.000000000 +1000
+++ ./mm/filemap.c	2007-05-31 16:49:45.000000000 +1000
@@ -1227,6 +1227,8 @@ generic_file_aio_read(struct kiocb *iocb
 				retval = retval ?: desc.error;
 				break;
 			}
+			if (desc.count > 0)
+				break;
 		}
 	}
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
