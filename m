Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 82AEC6B021A
	for <linux-mm@kvack.org>; Wed, 26 May 2010 11:58:06 -0400 (EDT)
Subject: Re: [PATCH] do_generic_file_read: clear page errors when issuing a
	fresh read of the page
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20100526114940.49f51028@annuminas.surriel.com>
References: <20100526114940.49f51028@annuminas.surriel.com>
Content-Type: text/plain
Date: Wed, 26 May 2010 12:02:52 -0400
Message-Id: <1274889772.20515.103.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jmoyer@redhat.com, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-05-26 at 11:49 -0400, Rik van Riel wrote:
> From: Jeff Moyer <jmoyer@redhat.com>
> 
> I/O errors can happen due to temporary failures, like multipath
> errors or losing network contact with the iSCSI server. Because
> of that, the VM will retry readpage on the page.
> 
> However, do_generic_file_read does not clear PG_error.  This
> causes the system to be unable to actually use the data in the
> page cache page, even if the subsequent readpage completes
> successfully!
> 
> The function filemap_fault has had a ClearPageError before
> readpage forever.  This patch simply adds the same to
> do_generic_file_read.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Jeff Moyer <jmoyer@redhat.com>
> ---
>  mm/filemap.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> Index: linux-2.6.34/mm/filemap.c
> ===================================================================
> --- linux-2.6.34.orig/mm/filemap.c
> +++ linux-2.6.34/mm/filemap.c
> @@ -1106,6 +1106,12 @@ page_not_up_to_date_locked:
>  		}
>  
>  readpage:
> +		/*
> +		 * A previous I/O error may have been due to temporary
> +		 * failures, eg. multipath errors.
> +		 * PG_error will be set again if readpage fails.
> +		 */
> +		ClearPageError(page);
>  		/* Start the actual read. The read will unlock the page. */
>  		error = mapping->a_ops->readpage(filp, page);
>  
Acked-by: Larry Woodman <lwoodman@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
