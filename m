Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 9A5E46B0070
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:30:12 -0400 (EDT)
Date: Mon, 16 Jul 2012 12:30:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 4] mm: fix possible incorrect return value of move_pages()
 syscall
In-Reply-To: <1342458889-19090-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1207161230010.32319@router.home>
References: <1342455272-32703-1-git-send-email-js1304@gmail.com> <1342458889-19090-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Brice Goglin <brice@myri.com>, Minchan Kim <minchan@kernel.org>

On Tue, 17 Jul 2012, Joonsoo Kim wrote:

> move_pages() syscall may return success in case that
> do_move_page_to_node_array return positive value which means migration failed.
> This patch changes return value of do_move_page_to_node_array
> for not returning positive value. It can fix the problem.
>
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> Cc: Brice Goglin <brice@myri.com>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Minchan Kim <minchan@kernel.org>
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 294d52a..adabaf4 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1171,7 +1171,7 @@ set_status:
>  	}
>
>  	up_read(&mm->mmap_sem);
> -	return err;
> +	return err > 0 ? -EIO : err;
>  }

Please use EBUSY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
