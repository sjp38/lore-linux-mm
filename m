Date: Wed, 29 Mar 2000 02:01:03 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: how text page of executable are shared ?
Message-ID: <20000329020103.I17288@redhat.com>
References: <20000328142253.A16752@redhat.com> <Pine.LNX.4.10.10003281019140.5753-100000@coffee.psychology.mcmaster.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.10003281019140.5753-100000@coffee.psychology.mcmaster.ca>; from hahn@coffee.psychology.mcmaster.ca on Tue, Mar 28, 2000 at 10:58:00AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Mar 28, 2000 at 10:58:00AM -0500, Mark Hahn wrote:
> 
> could you comment on a problem I'm seeing in the current (pre3) VM?
> the situation is a 256M machine, otherwise idle (random daemons, no X,
> couple ssh's) and a process that sequentially traverses 12 40M files
> by mmaping them (and munmapping them, in order, one at a time.)
> 
> the observation is that all goes well until the ~6th file, when we 
> run out of unused ram.  then we start _swapping_!  the point is that 
> shrink_mmap should really be scavenging those now unmapped files,
> shouldn't it?

Well, you've filled the whole of memory with recently referenced page 
cache pages.  The page cache scanner can now scan the whole of physical
memory without finding anything which is "old" enough to be evicted. 
It is only natural that it will start swapping at that point!

The swapping should be brief if all is working properly, though, as the
shrink_mmap() will rapidly find itself on the second pass over memory
and will start finding things which have been aged on the first pass 
and not used since.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
