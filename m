Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA07980
	for <linux-mm@kvack.org>; Fri, 15 Nov 2002 14:44:34 -0800 (PST)
Message-ID: <3DD578D1.1E3134A0@digeo.com>
Date: Fri, 15 Nov 2002 14:44:33 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: VM trouble, both 2.4 and 2.5
References: <02111521422000.00195@7ixe4>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@keyaccess.nl>
Cc: linux-mm@kvack.org, Con Kolivas <contest@kolivas.net>
List-ID: <linux-mm.kvack.org>

Rene Herman wrote:
> 
> ...
> rene@7ixe4:~$ cat /proc/meminfo
> MemTotal:       776156 kB
> MemFree:        412112 kB
> MemShared:           0 kB
> Buffers:          7668 kB
> Cached:          61564 kB
> SwapCached:          0 kB
> Active:          42168 kB
> Inactive:       296572 kB
> HighTotal:           0 kB
> HighFree:            0 kB
> LowTotal:       776156 kB
> LowFree:        412112 kB
> SwapTotal:           0 kB
> SwapFree:            0 kB
> Dirty:             440 kB
> Writeback:           0 kB
> Mapped:          34228 kB
> Slab:            10932 kB
> Committed_AS:    34868 kB
> PageTables:        668 kB
> ReverseMaps:     31360

That looks like the ext3 truncate thing.
 
> ...
> Maybe significant (?): does *not* happen with of=/dev/null. Does happen both
> with ext2 and ext3 on /tmp.

Are you *sure* it happens with ext2?  Checked /proc/mounts to ensure that
/tmp is really ext2?

Because if you write a ton of memory to an ext3 file and then immediately
delete the file, that memory ends on on the inactive list, not in pagecache,
just as you have shown.

But ext2 won't do that, because truncate is able to take the buffers
away from the truncated pages.

I could certainly believe that the (weird) ext3 behaviour would upset
the overcommit beancounting though.  Hundreds of megabytes of memory
on the inactive list but not in pagecache probably looks like anonymous
memory to the overcommit logic.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
