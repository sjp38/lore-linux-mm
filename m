From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] rd: Preserve the dirty bit in init_page_buffers()
Date: Tue, 16 Oct 2007 18:12:01 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <m18x64knqx.fsf@ebiederm.dsl.xmission.com> <m14pgsknmd.fsf_-_@ebiederm.dsl.xmission.com>
In-Reply-To: <m14pgsknmd.fsf_-_@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710161812.01970.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 October 2007 08:40, Eric W. Biederman wrote:
> The problem:  When we are trying to free buffers try_to_free_buffers()
> will look at ramdisk pages with clean buffer heads and remove the
> dirty bit from the page.  Resulting in ramdisk pages with data that get
> removed from the page cache.  Ouch!
>
> Buffer heads appear on ramdisk pages when a filesystem calls
> __getblk() which through a series of function calls eventually calls
> init_page_buffers().
>
> So to fix the mismatch between buffer head and page state this patch
> modifies init_page_buffers() to transfer the dirty bit from the page to
> the buffer heads like we currently do for the uptodate bit.
>
> This patch is safe as only __getblk calls init_page_buffers, and
> there are only two implementations of block devices cached in the
> page cache.  The generic implementation in block_dev.c and the
> implementation in rd.c.
>
> The generic implementation of block devices always does everything
> in terms of buffer heads so it always has buffer heads allocated
> before a page is marked dirty so this change does not affect it.

This is probably a good idea. Was this causing the reiserfs problems?
If so, I think we should be concentrating on what the real problem
is with reiserfs... (or at least why this so obviously correct
looking patch is wrong).

Acked-by: Nick Piggin <npiggin@suse.de>

>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  fs/buffer.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
>
> diff --git a/fs/buffer.c b/fs/buffer.c
> index 75b51df..8b87beb 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -972,6 +972,7 @@ init_page_buffers(struct page *page, struct
> block_device *bdev, struct buffer_head *head = page_buffers(page);
>  	struct buffer_head *bh = head;
>  	int uptodate = PageUptodate(page);
> +	int dirty = PageDirty(page);
>
>  	do {
>  		if (!buffer_mapped(bh)) {
> @@ -980,6 +981,8 @@ init_page_buffers(struct page *page, struct
> block_device *bdev, bh->b_blocknr = block;
>  			if (uptodate)
>  				set_buffer_uptodate(bh);
> +			if (dirty)
> +				set_buffer_dirty(bh);
>  			set_buffer_mapped(bh);
>  		}
>  		block++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
