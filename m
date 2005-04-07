Date: Thu, 7 Apr 2005 15:08:59 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: question on page-migration code
Message-ID: <20050407180858.GB19449@logos.cnet>
References: <4255B13E.8080809@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4255B13E.8080809@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Apr 07, 2005 at 05:16:30PM -0500, Ray Bryant wrote:
> Hirokazu (and Marcelo),
> 
> In testing my manual page migration code, I've run up against a situation
> where the migrations are occasionally very slow.  They work ok, but they
> can take minutes to migrate a few megabytes of memory.
> 
> Dropping into kdb shows that the migration code is waiting in msleep() in
> migrate_page_common() due to an -EAGAIN return from page_migratable().
> A little further digging shows that the specific return in page_migratable()
> is the very last one there at the bottom of the routine.
> 
> I'm puzzled as to why the page is still busy in this case.  Previous code
> in page_migratable() has unmapped the page, its not in PageWriteback()
> because we would have taken a different return statement in that case.
> 
> According to /proc/meminfo, there are no pages in either SwapCache or
> Dirty state, and the system has been sync'd before the migrate_pages()
> call was issued.

Who is using the page? 

A little debugging might help similar to what bad_page does can help: 

        printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
                (int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
                page->mapping, page_mapcount(page), page_count(page));
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
