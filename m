Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j1CL4bcO020419
	for <linux-mm@kvack.org>; Sat, 12 Feb 2005 16:04:37 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1CL4bC1146538
	for <linux-mm@kvack.org>; Sat, 12 Feb 2005 16:04:37 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id j1CL4bVC018308
	for <linux-mm@kvack.org>; Sat, 12 Feb 2005 16:04:37 -0500
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration --
	sys_page_migrate
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	 <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
Content-Type: text/plain
Date: Sat, 12 Feb 2005 13:04:22 -0800
Message-Id: <1108242262.6154.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Hugh DIckins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Marcello Tosatti <marcello@cyclades.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-02-11 at 19:26 -0800, Ray Bryant wrote:
> This patch introduces the sys_page_migrate() system call:
> 
> sys_page_migrate(pid, va_start, va_end, count, old_nodes, new_nodes);
> 
> Its intent is to cause the pages in the range given that are found on
> old_nodes[i] to be moved to new_nodes[i].  Count is the the number of
> entries in these two arrays of short.

Might it be useful to use nodemasks instead of those arrays?  That's
already the interface that the mbind() interfaces use, and it probably
pays to be consistent with all of the numa syscalls.

There also probably needs to be a bit more coordination between the
other NUMA API and this one.  I noticed that, for now, the migration
loop only makes a limited number of passes.  It appears that either you
don't require that, once the syscall returns, that *all* pages have been
migrated (there could have been allocations done behind the loop) or you
have some way of keeping the process from doing any more allocations.

There might also be some use to making sure that the NUMA binding API
and the migration code agree what is in the affected VMA.  Otherwise,
there might be some interesting situations where kswapd is swapping
pages out behind a migration call, and the NUMA API is refilling those
pages with ones that the migration call doesn't agree with.

That's one reason I was looking at the loop to make sure it's only one
pass.  I think doing passes until all pages are migrated gives you a
livelock, so the limited number obviously makes sense. 

Will you need other APIs to tell how successful the migration request
was?  Simply returning how many pages were migrated back from the
syscall doesn't really tell you anything concrete because there could be
kswapd activity or other migration calls that could be messing up the
work from the previous call.  Are all of these VMAs meant to be
mlock()ed?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
