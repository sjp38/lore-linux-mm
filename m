From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003290159.RAA95992@google.engr.sgi.com>
Subject: Re: how text page of executable are shared ?
Date: Tue, 28 Mar 2000 17:59:45 -0800 (PST)
In-Reply-To: <20000329020103.I17288@redhat.com> from "Stephen C. Tweedie" at Mar 29, 2000 02:01:03 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> On Tue, Mar 28, 2000 at 10:58:00AM -0500, Mark Hahn wrote:
> > 
> > could you comment on a problem I'm seeing in the current (pre3) VM?
> > the situation is a 256M machine, otherwise idle (random daemons, no X,
> > couple ssh's) and a process that sequentially traverses 12 40M files
> > by mmaping them (and munmapping them, in order, one at a time.)
> > 
> > the observation is that all goes well until the ~6th file, when we 
> > run out of unused ram.  then we start _swapping_!  the point is that 
> > shrink_mmap should really be scavenging those now unmapped files,
> > shouldn't it?
> 
> Well, you've filled the whole of memory with recently referenced page 
> cache pages.  The page cache scanner can now scan the whole of physical
> memory without finding anything which is "old" enough to be evicted. 
> It is only natural that it will start swapping at that point!
> 
> The swapping should be brief if all is working properly, though, as the
> shrink_mmap() will rapidly find itself on the second pass over memory
> and will start finding things which have been aged on the first pass 
> and not used since.
> 
> --Stephen
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

As I mentioned to Mark in private mail, it might be worthwhile looking
into the possiblity of using MADV_DONTNEED to discard file pages from 
the cache. In some os'es, I think msync(MS_INVALIDATE) actually takes
the page out from the cache.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
