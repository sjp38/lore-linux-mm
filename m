Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 04F916B004D
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 13:37:03 -0500 (EST)
Date: Mon, 16 Nov 2009 13:36:13 -0500
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [PATCH 0/7] Reduce GFP_ATOMIC allocation failures, candidate
 fix V3
Message-ID: <20091116183613.GG27677@think>
References: <1258054211-2854-1-git-send-email-mel@csn.ul.ie>
 <20091112202748.GC2811@think>
 <20091112220005.GD2811@think>
 <20091113024642.GA7771@think>
 <4B018157.3080707@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B018157.3080707@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Milan Broz <mbroz@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>, device-mapper development <dm-devel@redhat.com>, Alasdair G Kergon <agk@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 16, 2009 at 05:44:07PM +0100, Milan Broz wrote:
> On 11/13/2009 03:46 AM, Chris Mason wrote:
> > On Thu, Nov 12, 2009 at 05:00:05PM -0500, Chris Mason wrote:
> > 
> > [ ...]
> > 
> >>
> >> The punch line is that the btrfs guy thinks we can solve all of this with
> >> just one more thread.  If we change dm-crypt to have a thread dedicated
> >> to sync IO and a thread dedicated to async IO the system should smooth
> >> out.
> 
> Please, can you cc DM maintainers with these kind of patches? dm-devel list at least.
> 

Well, my current patch is a hack.  If I had come up with a proven theory
(hopefully Mel can prove it ;), it definitely would have gone through
the dm-devel lists.

> Note that the crypt requests can be already processed synchronously or asynchronously,
> depending on used crypto module (async it is in the case of some hw acceleration).
> 
> Adding another queue make the situation more complicated and because the crypt
> requests can be queued in crypto layer I am not sure that this solution will help
> in this situation at all.
> (Try to run that with AES-NI acceleration for example.)

The problem is that async threads still imply a kind of ordering.
If there's a fifo serviced by one thread or 10, the latency ramifications
are very similar for a new entry on the list.  We have to wait for a
large portion of the low-prio items in order to service a high prio
item.

With a queue dedicated to sync requests and one dedicated to async,
you'll get better read latencies.  Btrfs has a similar problem around
the crc helper threads and it ends up solving things with two different
lists (high and low prio) processed by one thread.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
