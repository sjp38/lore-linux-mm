Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id KAA16095
	for <linux-mm@kvack.org>; Thu, 12 Dec 2002 10:20:12 -0800 (PST)
Message-ID: <3DF8D355.2219084A@digeo.com>
Date: Thu, 12 Dec 2002 10:20:05 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: Question on set_page_dirty()
References: <20021212102930.C15158@nightmaster.csn.tu-chemnitz.de> <1039696963.2420.1.camel@sisko.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, Jan Hudec <bulb@ucw.cz>, Martin Maletinsky <maletinsky@scs.ch>, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Thu, 2002-12-12 at 09:29, Ingo Oeser wrote:
> > set_page_dirty() can be used in all cases, IMHO, since it:
> >    - will not sleep
> ...
> 
> Unfortunately, it can take both the inode_lock and pagecache_lock
> spinlocks, so if you use it in the wrong place, with other locks already
> held, you can cause a deadlock.  So you _do_ need to be a bit careful,
> and you can't just use it with abandon.
> 

And in 2.5 the pagecache_lock is per-inode.  This ends up meaning that
it is not legal to run set_page_dirty(page) unless the caller has
done something to prevent the thing at page->mapping from being freed.

If that has not been done, it is conceivable (but hugely unlikely) that
the page could be truncated from its mapping and that mapping could be
thrown away while set_page_dirty() is trying to claim its ->page_lock.

So in 2.5, set_page_dirty() is only legal if the caller has a ref against
page->mapping->host, or if the page is locked.

It's currently wrong in a couple of places.  I have local fixes for
the VM, and direct-IO still needs to be done.  It will just be:

	lock_page(page);		/* pins page->mapping */
	set_page_dirty(page);
	unlock_page(page);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
