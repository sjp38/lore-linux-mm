Date: Tue, 16 May 2000 11:20:12 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: More observations...
Message-ID: <20000516112012.D26581@redhat.com>
References: <20000515224403.B5677@moria.simons-clan.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000515224403.B5677@moria.simons-clan.com>; from msimons@moria.simons-clan.com on Mon, May 15, 2000 at 10:44:03PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Simons <msimons@moria.simons-clan.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, May 15, 2000 at 10:44:03PM -0400, Mike Simons wrote:

>   Sure if the kernel flushed started forcing flushed buffers to disk after
> 75% dirty the application could redirty ones already flushed and there 
> would be some wasted I/O but that might just prevent the system from
> completely running out of "available" pages to use, since it could
> reuse one of it just put out to disk...

With mmap(), it is nothing to do with dirty buffers.  There are, in fact,
_no_ dirty buffers when you have the mmap() case --- the buffer_heads
backing the files will remain clean.  It is the pages themselves which 
are dirty, and the only record of their dirtiness is in the ptes.

For buffer_heads, we can (and do) throttle write activity when
the dirty list grows too long.  However, we don't do anything like
that for mmaped pages.  Think what happens if you have an application
(say, a simulation, in which a lot of the data is constantly being 
modified) which fits in memory, but only just --- if you put a limit
on the %age of dirty memory, you'd be constantly thrashing to disk
despite having enough memory for the workload.

We _could_ keep track of the number of dirty pages quite easily, by
making all clean ptes readonly.  It's not at all clear that it helps,
though. 
 
I think that the real solution here is still dynamic RSS limits for
mms.  We can allow the RSS limits to grow as the RSS grows as long as
there are sufficient free pages in the GFP_USER class.  As soon as we
start to swap, however, imposing RSS limits is an ideal way (right 
now, it's pretty much the only way) to limit the impact of heavy
threaded memory write activity by a process.

The concept is quite simple: if you can limit a process's RSS, you 
can limit the amount of memory which is pinned in process page tables,
and thus subject to expensive swapping.  Note that you don't have to
get rid of the pages --- you can leave them in the page cache/swap
cache, where they can be re-faulted rapidly if needed, but if the
memory is needed for something else then shrink_mmap can reclaim the
pages rapidly.  

Rick's old memory hog flag is essentially a simple case of an RSS
limit (the task RSS is limited to what it is currently set at).  In 
general, if you can identify severe memory pressure being caused by
a specific process, then you can start doing early RSS limiting on 
the mm in question and substantially reduce the impact on the rest
of the system.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
