Date: Tue, 15 Apr 2008 19:13:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080415191350.0dc847b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Apr 2008 10:46:47 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > <snip>
> >         if (PageDirty(page)) {
> >                 clear_page_dirty_for_io(page);
> >                 set_page_dirty(newpage);------------------------(**)
> >         }
> > 
> > ==
> > Then, Uptodate() is copied before set_page_dirty(). 
> > So, "page" is not Uptodate and Dirty when it reaches (**)
> 
> The page will be marked uptodate before we reach ** so its okay in 
> general. If a page is not uptodate then we should not be getting here.
> 
> An !uptodate page is not migratable. Maybe we need to add better checking?
> 
adding check is good but...

I found I can reproduce this. I'd like to chase this a bit more.

following is just a report.
==
a page which caused trouble was
- Dirty, Private, Locked (locked because of migration)
- a file cache of ext3. (maybe)

When I added following check,
==
@@ -648,6 +649,10 @@ static int unmap_and_move(new_page_t get
                        goto move_newpage;
                lock_page(page);
        }
+       /* All caches should be Uptodate before migration.*/
+       if (page_mapping(page) && !PageUptodate(page))
+               goto unlock;
+

        if (PageWriteback(page)) {
                if (!force)
==
A page offlining never ends until I run "echo 3 > /proc/sys/vm/drop_caches".

Once I use drop_caches, memory offlining works very well.
(even under some workload.) If the code I added is bad, plz blame me.

Thanks,
-Kame

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
