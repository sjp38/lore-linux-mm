Message-ID: <4255B13E.8080809@engr.sgi.com>
Date: Thu, 07 Apr 2005 17:16:30 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: question on page-migration code
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hirokazu (and Marcelo),

In testing my manual page migration code, I've run up against a situation
where the migrations are occasionally very slow.  They work ok, but they
can take minutes to migrate a few megabytes of memory.

Dropping into kdb shows that the migration code is waiting in msleep() in
migrate_page_common() due to an -EAGAIN return from page_migratable().
A little further digging shows that the specific return in page_migratable()
is the very last one there at the bottom of the routine.

I'm puzzled as to why the page is still busy in this case.  Previous code
in page_migratable() has unmapped the page, its not in PageWriteback()
because we would have taken a different return statement in that case.

According to /proc/meminfo, there are no pages in either SwapCache or
Dirty state, and the system has been sync'd before the migrate_pages()
call was issued.
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
