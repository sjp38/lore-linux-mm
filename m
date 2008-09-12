Message-ID: <48CA748F.8020701@inria.fr>
Date: Fri, 12 Sep 2008 15:54:23 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: make do_move_pages() complexity linear
References: <48CA611A.8060706@inria.fr> <48CA727F.1050405@linux-foundation.org>
In-Reply-To: <48CA727F.1050405@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Nathalie Furmento <nathalie.furmento@labri.fr>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Brice Goglin wrote:
>> Page migration is currently very slow because its overhead is quadratic
>> with the number of pages. This is caused by each single page migration
>> doing a linear lookup in the page array in new_page_node().
> 
> Page migration in general is not affected by this issue. This is specific to
> the sys_move_pages() system call. The API was so far only used to migrate a
> limited number of pages. For more one would use either the cpuset or the
> sys_migrate_pages() APIs since these do not require an array that describes
> how every single page needs to be moved.
> 
>> Since pages are stored in the array order in the pagelist and do_move_pages
>> process this list in order, new_page_node() can increase the "pm" pointer
>> to the page array so that the next iteration will find the next page in
>> 0 or few lookup steps.
> 
> I agree. It would be good increase the speed of sys_move_pages().
> 
> However, note that your patch assumes that new_page_node() is called in
> sequence for each of the pages in the page descriptor array.

No, it assumes that pages are stored in pagelist in order. But some of
them can be missing compared to the page array.

> new_page_node() is skipped in the loop if
> 
> 1. The page is not present
> 2. The page is reserved
> 3. The page is already on the intended node
> 4. The page is shared between processes.
> 
> If any of those cases happen then your patch will result in the association of
> page descriptors with the wrong pages for the remaining pages in the array.

I don't think so. If this happens, the while loop will skip those pages.
(while in the regular case, the while loop does 0 iterations).
The while loop is still here to make sure we are processing the right pm
entry. What the patch changes is only that we don't uselessly look at
the already-processed beginning of pm.

thanks,
Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
