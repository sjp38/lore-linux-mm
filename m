Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA24086
	for <linux-mm@kvack.org>; Thu, 27 May 1999 02:24:53 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14156.58667.141026.238904@dukat.scot.redhat.com>
Date: Thu, 27 May 1999 07:24:43 +0100 (BST)
Subject: Re: [PATCHES]
In-Reply-To: <m1emk7skik.fsf@flinx.ccr.net>
References: <Pine.LNX.3.96.990523171206.21583A-100000@chiara.csoma.elte.hu>
	<m1emk7skik.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On 23 May 1999 13:34:11 -0500, ebiederm+eric@ccr.net (Eric W. Biederman) said:

> My work on dirty pages sets up a bdflush like mechanism on top of the page
> cache.  So for anything that can fit in the page cache the buffer cache
> simply isn't needed.   Where the data goes when it is written simply doesn't
> matter.

One good reason for using buffers aliased into the page cache is
precisely to avoid a new bdflush mechanism.  We have had enough deadlock
and resource starvation issues with one bdflush that I get nervous about
adding another one!

(IM == Ingo)
IM> I'd like the page cache end up in a design where we can almost
IM> completely avoid any filesystem overhead for quickly
IM> created/destroyed and/or fully cached files. I'd like to have a very
IM> simple unaliased pagecache and no filesystem overhead, on big RAM
IM> boxes.  This was the orignal goal of the page cache as well, as far
IM> as i remember.

Actually the initial motivation of the page cache was to try to keep
per-file dirty lists, to fix fsync.  We just never got round to that!

However, this brings up another point: 

	ftp://ftp.uk.linux.org/pub/linux/sct/fs/misc/fsync-2.2.8-v5.diff

is a set of diffs to fix fsync performance on 2.2.  It fully implements
fsync and fdatasync, and applies the same optimisations to O_SYNC.  It
uses per-inode dirty buffer lists.  Please bear in mind that we still
need such functionality even with the dirty-page-cache mechanism, to
keep track of the indirect blocks if nothing else.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
