Date: Fri, 28 Apr 2006 16:46:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] page migration: synchronize from and to lists
Message-Id: <20060428164619.4b8bc28c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20060428060323.30257.90761.sendpatchset@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
	<20060428060323.30257.90761.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lee.schermerhorn@hp.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 27 Apr 2006 23:03:23 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> page migration: synchronize from and to lists to migrate_pages()
> 
> Handle pages from the "from" and "to" lists in such a way that the nth page
> from "from" is moved to the nth page from "to". That way page placement
> for each page can be controlled separately.
> 
It looks this path is not treated in desired way.
==
		rc=0;
                if (page_count(page) == 1)
                        /* page was freed from under us. So we are done. */
                        goto next;
next:
                if (rc) {
			<snip>;
		} else {
			 if (newpage) <--- new page is NULL. here
                                /* Successful migration. Return page to LRU */
                                move_to_lru(newpage);

                        list_move(&page->lru, moved);
                }
==

you should rotate "to" list in this case, I think.		

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
