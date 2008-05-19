Date: Mon, 19 May 2008 09:35:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: bootmem: Double freeing a PFN on nodes spanning other nodes
Message-Id: <20080519093525.4867bfb4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <87skwhyj8g.fsf@saeurebad.de>
References: <87skwhyj8g.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 17 May 2008 00:30:55 +0200
Johannes Weiner <hannes@saeurebad.de> wrote:

> Hi,
> 
> When memory nodes overlap each other, the bootmem allocator is not aware
> of this and might pass the same page twice to __free_pages_bootmem().
> 

1. init_bootmem_node() is called against a node, [start, end). After this,
   all pages are 'allocated'.
2. free_bootmem_node() is called against available memory in a node.
3. bootmem allocator is ready.

memory overlap seems not to be trouble while an arch's code calls
free_bootmem_node() correctly.

Thanks,
-Kame





> As I traced the code, this should result in bad_page() calls on every
> boot but noone has yet reported something like this and I am wondering
> why.
> 
> __free_pages_bootmem() boils down to either free_hot_cold_page() or
> __free_one_page().  Either path should lead to setting the page private
> or buddy:
> 
> free_hot_cold_page() sets ->private to the page block's migratetype (and
> sets PG_private).
> 
> __free_one_page sets ->private to the page's order (and sets PG_private
> and PG_buddy).
> 
> If a page is passed in twice, free_pages_check() should now warn (via
> bad_page()) on the flags set above.
> 
> Am I missing something?  Thanks in advance.
> 
> 	Hannes
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
