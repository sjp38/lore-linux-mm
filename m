Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 75CDD6B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 19:35:32 -0400 (EDT)
Date: Thu, 8 Oct 2009 16:34:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2][v2] mm: add notifier in pageblock isolation for
 balloon drivers
Message-Id: <20091008163449.00dce972.akpm@linux-foundation.org>
In-Reply-To: <20091002184458.GC4908@austin.ibm.com>
References: <20091002184458.GC4908@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robert Jennings <rcj@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009 13:44:58 -0500
Robert Jennings <rcj@linux.vnet.ibm.com> wrote:

> Memory balloon drivers can allocate a large amount of memory which
> is not movable but could be freed to accomodate memory hotplug remove.
> 
> Prior to calling the memory hotplug notifier chain the memory in the
> pageblock is isolated.  If the migrate type is not MIGRATE_MOVABLE the
> isolation will not proceed, causing the memory removal for that page
> range to fail.
> 
> Rather than failing pageblock isolation if the the migrateteype is not
> MIGRATE_MOVABLE, this patch checks if all of the pages in the pageblock
> are owned by a registered balloon driver (or other entity) using a
> notifier chain.  If all of the non-movable pages are owned by a balloon,
> they can be freed later through the memory notifier chain and the range
> can still be isolated in set_migratetype_isolate().

The patch looks sane enough to me.

I expect that if the powerpc and s390 guys want to work on CMM over the
next couple of months, they'd like this patch merged into 2.6.32.  It's
a bit larger and more involved than one would like, but I guess we can
do that if suitable people (Mel?  Kamezawa?) have had a close look and
are OK with it.

What do people think?

Has it been carefully compile- and run-time tested with
CONFIG_MEMORY_HOTPLUG_SPARSE=n?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
