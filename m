Message-ID: <425A8796.2050903@engr.sgi.com>
Date: Mon, 11 Apr 2005 09:20:06 -0500
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
> On Thu, Apr 07, 2005 at 05:16:30PM -0500, Ray Bryant wrote:
> 
>>Hirokazu (and Marcelo),
>>
>>In testing my manual page migration code, I've run up against a situation
>>where the migrations are occasionally very slow.  They work ok, but they
>>can take minutes to migrate a few megabytes of memory.
>>
>>Dropping into kdb shows that the migration code is waiting in msleep() in
>>migrate_page_common() due to an -EAGAIN return from page_migratable().
>>A little further digging shows that the specific return in page_migratable()
>>is the very last one there at the bottom of the routine.
>>
>>I'm puzzled as to why the page is still busy in this case.  Previous code
>>in page_migratable() has unmapped the page, its not in PageWriteback()
>>because we would have taken a different return statement in that case.
>>
>>According to /proc/meminfo, there are no pages in either SwapCache or
>>Dirty state, and the system has been sync'd before the migrate_pages()
>>call was issued.
> 
> 
> Who is using the page? 
> 
> A little debugging might help similar to what bad_page does can help: 
> 
>         printk(KERN_EMERG "flags:0x%0*lx mapping:%p mapcount:%d count:%d\n",
>                 (int)(2*sizeof(page_flags_t)), (unsigned long)page->flags,
>                 page->mapping, page_mapcount(page), page_count(page));
> --

The suspect pages all have flags field of 105d and mapcount of 0, pagecount
of 3.  If I'm decoding the bits correctly, we've got the following bits
set:

Locked
Referenced
Uptodate
Dirty
Active
PG_arch_1

Doesn't tell me much.  Anything spring to mind when you look at these
bits, Marcelo?

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
