Date: Tue, 25 Apr 2000 17:30:12 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: pressuring dirty pages (2.3.99-pre6)
Message-ID: <20000425173012.B1406@redhat.com>
References: <852568CC.004F0BB1.00@raylex-gh01.eo.ray.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <852568CC.004F0BB1.00@raylex-gh01.eo.ray.com>; from Mark_H_Johnson.RTS@raytheon.com on Tue, Apr 25, 2000 at 09:27:57AM -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson.RTS@raytheon.com
Cc: "Eric W. Biederman" <ebiederman@uswest.net>, linux-mm@kvack.org, riel@nl.linux.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Apr 25, 2000 at 09:27:57AM -0500, Mark_H_Johnson.RTS@raytheon.com wrote:

> It would be great to have a dynamic max limit. However I can see a lot of
> complexity in doing so. May I make a few suggestions.
>  - take a few moments to model the system operation under load. If the model
> says RSS limits would help, by all means lets do it. If not, fix what we have.
> If RSS limits are what we need, then
>  - implement the RSS limit using the current mechanism [e.g., ulimit]
>  - use a simple page removal algorithm to start with [e.g.,"oldest page first"
> or "address space order"]. The only caution I might add on this is to check that
> the page you are removing isn't the one w/ the instruction you are executing

We already have simple page removal algorithms.  

The reason for the dynamic RSS limit isn't to improve the throughput 
under load.  It is to protect innocent processes from the effects of a
large memory hog in the system.  It's easy enough to see that any pageout
algorithm which treats all pages fairly will have trouble if you have a
memory hog paging rapidly through all of its pages --- the hog process's
pages will be treated the same as any other process's pages, which means
that since the hog process is thrashing, it forces other tasks to do
likewise.

Note that RSS upper bounds are not the only way to achieve this.  In a
thrashing situation, giving processes a lower limit --- an RSS guarantee
--- will also help, by allowing processes which don't need that much
memory to continue to work without any paging pressure at all.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
