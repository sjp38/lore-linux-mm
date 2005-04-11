Message-ID: <425AC932.2030300@engr.sgi.com>
Date: Mon, 11 Apr 2005 14:00:02 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: question on page-migration code
References: <4255B13E.8080809@engr.sgi.com> <20050407180858.GB19449@logos.cnet>
In-Reply-To: <20050407180858.GB19449@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

> Who is using the page? 
> 
> A little debugging might help similar to what bad_page does can help: 
> 
>         printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
>                 (int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
>                 page->mapping, page_mapcount(page), page_count(page));
> --

Marcello,

I wrote:

"PagePrivate() is cleared by truncation specific code in migrate_onepage(),
but it doesn't appear to be cleared (directly) by code on the
generic_migrate_page() patch.  I wonder if this has something to do with
the problem I am seeing. "

Ooops.  I didn't look deep enough.  migrate_page_common() calls
writeback_and_free_buffers(), which in turn calls try_to_release_page()
which will eventually call down to __clear_page_buffers() which will
clear PagePrivate().

So it looks like the following is perhaps what is happening:

(1)  We come into migrate_one_page() with the pages dirty.  (The first
      time we enter the -EAGAIN section of migate_page_common() we have
      flags = 105d, the last time through before succeeding, flags are
      104d, and when we do return flags=004d.
(2)  We have to wait around until the pages get paged out before we can
      migrated them.  (flags=004d).

I'll have to check and see if I believe it might take 3 minutes to page
out all of the pages of my application.  If so, then this explains what
is happening.

Does that make sense?

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
