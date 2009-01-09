Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7E26B0087
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 14:08:29 -0500 (EST)
Subject: Re: Increase dirty_ratio and dirty_background_ratio?
From: Chris Mason <chris.mason@oracle.com>
In-Reply-To: <20090109180241.GA15023@duck.suse.cz>
References: <alpine.LFD.2.00.0901070833430.3057@localhost.localdomain>
	 <20090107.125133.214628094.davem@davemloft.net>
	 <20090108030245.e7c8ceaf.akpm@linux-foundation.org>
	 <20090108.082413.156881254.davem@davemloft.net>
	 <alpine.LFD.2.00.0901080842180.3283@localhost.localdomain>
	 <1231433701.14304.24.camel@think.oraclecorp.com>
	 <alpine.LFD.2.00.0901080858500.3283@localhost.localdomain>
	 <20090108195728.GC14560@duck.suse.cz> <20090109180241.GA15023@duck.suse.cz>
Content-Type: text/plain
Date: Fri, 09 Jan 2009 14:07:22 -0500
Message-Id: <1231528042.5998.13.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Miller <davem@davemloft.net>, akpm@linux-foundation.org, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 2009-01-09 at 19:02 +0100, Jan Kara wrote:

>   What we observe in the seekwatcher graphs is, that there are three
> processes writing back the single database file in parallel (2 pdflush
> threads because the machine has 2 CPUs, and the database process itself
> because of dirty throttling). Each of the processes is writing back the
> file at a different offset and so they together create even more random IO
> (I'm attaching the graph and can provide blocktrace data if someone is
> interested). If there was just one process doing the writeback, we'd be
> writing back those data considerably faster...

I spent some time trying similar things for btrfs, and went as far as
making my own writeback thread and changing pdflush and throttled writes
to wait on it.  It was a great hack, but in the end I found the real
problem was the way write_cache_pages is advancing the page_index.

You probably remember the related ext4 discussion, and you could try my
simple patch in this workload to see if it helps ext3.

http://lkml.org/lkml/2008/10/1/278

Ext3 may need similar tricks.

-chris


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
