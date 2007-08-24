Message-ID: <46CE3617.6000708@redhat.com>
Date: Thu, 23 Aug 2007 21:36:23 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: Drop caches - is this safe behavior?
References: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com> <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>
In-Reply-To: <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mike <mike503@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

mike wrote:
> I have a crontab running every 5 minutes on my servers now:
> 
>     echo 2 > /proc/sys/vm/drop_caches
> 
> Is this a safe thing to do? Am I risking any loss of data? It looks
> like "3" might allow for that but from what I can understand 0-2 won't
> lose data.
> 
> I was seeing some issues with my memory being taken up and thrown all
> into "cached" and eventually starts swapping (not a lot, but a little)
> - supposedly memory in "cached" is supposed to be available for new
> stuff, but I swear it is not. I've tried a variety of things, and this
> drop caches trick seems to make me feel quite comfortable seeing it be
> free as in free physical RAM, not stuck in the cache.

This widespread fallacy has been false for a long time.  The kernel will 
swap instead of dropping caches if it believes that doing so will 
improve performance.  It uses heuristics for this, and sometimes guesses 
wrong, but it's not a bad thing.  Consider the memory used in the 
initialization and shutdown routines for an application.  In normal 
operation, you're never using it, so it's much better to swap this out 
than to drop caches of a file you've actually accessed recently.  It is 
completely normal to use have a small amount of swap utilization for 
precisely this reason.  All you're doing by dropping caches is hurting 
performance, probably by a lot.  The drop_caches patch was resisted for 
a very long time because we knew people would use it to shoot themselves 
in the foot.  It should only be used for debugging or benchmarking.

> So far it appears to be keeping my webservers' memory usage tolerable
> and expected, as opposed to rampant and greedy. I haven't seen any
> loss in functionality either. These servers get all their files (sans
> local /var /etc stuff) from NFS, so I don't think a local memory-based
> cache needs to be that important.

"Rampant and greedy" is correct behavior, as long as it doesn't harm 
performance.  Usually it helps performance, but if it does harm 
performance, let us know, since that would be a bug we need to fix.  By 
dropping caches of NFS-backed files on multiple systems, you're moving 
the load from several underutilized systems to one heavily-utilized system.

> I've been trying to find more information on the drop_caches parameter
> and its effects but it appears to be too new and not very widespread.
> Any help is appreciated. Perhaps this is a safe behavior on a
> non-primary file storage system like a webserver mounting NFS, but the
> NFS server itself should not?

Safety aside, it's harmful no matter where you do it.  Forget about 
drop_caches.  Don't use it.  It wasn't meant for your use case.

If you think the system is doing the wrong thing (and it doesn't sound 
like it is) you should be tweaking the vm.swappiness sysctl.  The 
default is 60, but lower values will make it behave more like you think 
it should be behaving, though you'll still probably see a tiny bit of 
swap usage.  Of course, if your webservers are primarily serving up 
static content, you'll want a higher value, since swapping anonymous 
memory will leave more free for the pagecache you're primarily working with.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
