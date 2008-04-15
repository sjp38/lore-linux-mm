Date: Tue, 15 Apr 2008 12:31:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080415191350.0dc847b6.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0804151227050.1785@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
 <20080415191350.0dc847b6.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Apr 2008, KAMEZAWA Hiroyuki wrote:

> > An !uptodate page is not migratable. Maybe we need to add better checking?
> > 
> adding check is good but...
> 
> I found I can reproduce this. I'd like to chase this a bit more.
> 
> following is just a report.
> ==
> a page which caused trouble was
> - Dirty, Private, Locked (locked because of migration)
> - a file cache of ext3. (maybe)
> 
> When I added following check,
> ==
> @@ -648,6 +649,10 @@ static int unmap_and_move(new_page_t get
>                         goto move_newpage;
>                 lock_page(page);
>         }
> +       /* All caches should be Uptodate before migration.*/
> +       if (page_mapping(page) && !PageUptodate(page))
> +               goto unlock;
> +
> 
>         if (PageWriteback(page)) {
>                 if (!force)
> ==
> A page offlining never ends until I run "echo 3 > /proc/sys/vm/drop_caches".

Page migration should stop after 10 retries though? You need to set the RC 
to another value than -EAGAIN in order to avoid the retries.

if (page_mapping(page) && !PageUptodate(page)) {
	rc = -EBUSY;
	goto unlock;
}

will stop retries.

> Once I use drop_caches, memory offlining works very well.
> (even under some workload.) If the code I added is bad, plz blame me.

The retries during page migration may hold off the completion of bringing 
up a page up to date since the PageLock is repeatedly acquired. So either 
pass more pages in one go to migrate_pages() or pause once in awhile?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
