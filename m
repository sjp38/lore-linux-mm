Subject: Re: [PATCH] nfs: fix congestion control
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1168985323.5975.53.camel@lappy>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
	 <20070116135325.3441f62b.akpm@osdl.org>  <1168985323.5975.53.camel@lappy>
Content-Type: text/plain
Date: Tue, 16 Jan 2007 17:27:46 -0500
Message-Id: <1168986466.6056.52.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-01-16 at 23:08 +0100, Peter Zijlstra wrote:
> Subject: nfs: fix congestion control
> 
> The current NFS client congestion logic is severely broken, it marks the
> backing device congested during each nfs_writepages() call and implements
> its own waitqueue.
> 
> Replace this by a more regular congestion implementation that puts a cap
> on the number of active writeback pages and uses the bdi congestion waitqueue.
> 
> NFSv[34] commit pages are allowed to go unchecked as long as we are under 
> the dirty page limit and not in direct reclaim.
> 
> 	A buxom young lass from Neale's Flat,
> 	Bore triplets, named Matt, Pat and Tat.
> 	"Oh Lord," she protested,
> 	"'Tis somewhat congested ...
> 	"You've given me no tit for Tat." 


What on earth is the point of adding congestion control to COMMIT?
Strongly NACKed.

Why 16MB of on-the-wire data? Why not 32, or 128, or ...
Solaris already allows you to send 2MB of write data in a single RPC
request, and the RPC engine has for some time allowed you to tune the
number of simultaneous RPC requests you have on the wire: Chuck has
already shown that read/write performance is greatly improved by upping
that value to 64 or more in the case of RPC over TCP. Why are we then
suddenly telling people that they are limited to 8 simultaneous writes?

Trond


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
