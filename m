Date: Thu, 14 Jun 2007 09:12:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
In-Reply-To: <20070615010217.62908da3.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706140909030.29612@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
 <20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
 <20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
 <20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
 <20070614172936.12b94ad7.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706140706370.28544@schroedinger.engr.sgi.com>
 <20070615010217.62908da3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jun 2007, KAMEZAWA Hiroyuki wrote:

> > Is there an issue with calling try_to_unmap for an unmapped page? We check 
> > in try_to_unmap if the pte is valid. If it was unmapped then try_to_unmap 
> > will fail anyways.
> > 
> I met following case.
> ---
>    CPU 0                                          CPU 1
> 
> do_swap_page()                                                                        
>   -> read_swap_cache_async()               
> 	-> # alloc new page 
> 	   # page is added to swapcache
>            # page is locked here.
>            # added to LRU                      <- we find this page because of PG_lru
>            # start asynchrous read I/O         lock_page()
> 	   # page is unlocked here             we acquire the lock.
>   -> lock_page()                                     
>      wait....                                  unmap_and_move() is called.
>                                                try_to_unmap() is called.
>                                                PageAnon() returns 0. beacause the page is not
>                                                added to rmap yet. page->mapping is NULL, here.
>                                                try_to_unmap_file() is called.
>                                                try_to_unmap_file() touches NULL pointer.
> --
> An unmapped swapcache page, which is just added to LRU, may be accessed via migrate_page().
> But page->mapping is NULL yet. 

Yes then lets add a check for page->mapping == NULL there.

if (!page->mapping)
	goto unlock;

That will retry the migration on the next pass. Add some concise comment 
explaining the situation. This is general bug in page migration.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
