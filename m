Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [RFC][PATCH] dcache and rmap
Date: Mon, 6 May 2002 11:12:55 -0400
References: <200205060354.52173.tomlins@cam.org> <17314927.1020670845@[10.10.2.3]>
In-Reply-To: <17314927.1020670845@[10.10.2.3]>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200205061112.55252.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On May 6, 2002 10:40 am, Martin J. Bligh wrote:
> >> > I got tired of finding my box with 50-60% percent of memory tied
> >> > up in dentry/inode caches every morning after update-db runs or
> >> > after doing a find / -name "*" to generate a list of files for
> >> > backups.  So I decided to make a stab at fixing this.
> >>
> >> Are you actually out of memory at this point, and they're consuming
> >> space you really need?
> >
> > Think of this another way.  There are 100000+ dentry/inodes in memory
> > comsuming 250M or so.  Meanwhile load is light and the background
> > aging is able to supply pages for the freelist.  We do not reclaim this
> > storage until we have vm pressure.  Usually this pressure is artifical,
> > if we had reclaimed the storage it would not have occured, our caches
> > would have more useful data in them, and half the memory would not
> > sit idle for half a day.
> >
> > We age the rest of the memory to keep it hot.   Rmap does a good job
> > and keeps the freelist heathly.  In this case nothing ages the dentries
> > and they get very cold.  My code ensures that the memory consumed
> > by the, potentially cold, dentries/inodes is not excessive.
>
> If there's no pressure on memory, then using it for caches is a good
> thing. Why throw away data before we're out of space? If we are under

The point is there is always memory pressure.  Sometimes kswapd can
supply the pages needed without calling do_try_to_free_pages.  When this
happens the dcache/icache can grow since we never try to shrink it.  My
patch changes this.

> pressure on memory then dcache should shrink easily and rapidly. If
> it's not, then make it shrink properly, don't just limit it to an
> arbitrary size that may be totally unsuitable for some workloads.

There is _no_ arbitrary limit.  All that happens is that if the dcache grows
by more than n pages we try to shrink it once.   If the system its actually
using the dentries, the dcache/icache will grow as needed.  If its not using 
them, which is the case here more often than not, they get dropped and
storage is freed to be better used by the rest of the vm.

> You could even age it instead ... that'd make more sense than
> restricting it to a static size.

Again I apply pressure.  There are no static limits.  Aging would be nice but
that would probably require rather massive changes to the way the slab cache
works.

Ed Tomlinson




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
