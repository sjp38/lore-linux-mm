Received: from alogconduit1ah.ccr.net (ccr@alogconduit1ao.ccr.net [208.130.159.15])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA02361
	for <linux-mm@kvack.org>; Mon, 26 Apr 1999 10:42:30 -0400
Subject: Re: 2.2.6_andrea2.bz2
References: <Pine.LNX.4.05.9904261505080.414-100000@laser.random>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 26 Apr 1999 09:44:36 -0500
In-Reply-To: Andrea Arcangeli's message of "Mon, 26 Apr 1999 15:06:40 +0200 (CEST)"
Message-ID: <m1so9nfnl7.fsf@flinx.ccr.net>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "AA" == Andrea Arcangeli <andrea@e-mind.com> writes:

AA> On 26 Apr 1999, Eric W. Biederman wrote:
>> The real gain of this is not so much in the current cases we are fast at
>> but for things like network, and compressed files (in general anything that

AA> Could you produce an example (also "look at file.c" will be ok ;) to allow
AA> me to see which are the issues with network and compressed files? Thanks.

The primary one is they can't use the buffer cache so they must roll their
own caching mechanism.

Look at the smbfs version of updatepage. (write through!)
Look at e2compr which doesn't compress data until the file is closed!
    It writes the data uncompressed, and then at iput time
    rewrites the file compressed.
Run a moderately early version of fat_cvf/dmsdos, before they found out how
    to use the buffer cache, and watch it crawl on a read-only fs.
nfs doesn't periodically flush dirty data, to keep the volume low.
    It does flush on file close (which helps, and is as correct as possible
    for nfs), but you can still find

I haven't seen any provision in any of these roll your own solutions
for flushing the dirty buffers when the system is low on memory.
Etc.

The point is that because there isn't a caching subsystem
all of the filesystems above have to roll their own.  And because
they roll their own the code is less polished than a solution which
would work for all of them would be.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
