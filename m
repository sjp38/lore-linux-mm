Message-ID: <39121254.F7F71DAC@directlink.net>
Date: Thu, 04 May 2000 19:14:12 -0500
From: Matthew Vanecek <linuxguy@directlink.net>
MIME-Version: 1.0
Subject: Re: Updates to /bin/bash
References: <852568D5.006DBD55.00@raylex-gh01.eo.ray.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark_H_Johnson.RTS@raytheon.com
Cc: trond.myklebust@fys.uio.no, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mark_H_Johnson.RTS@raytheon.com wrote:
> 
> On this issue [updates to active files...] how does the typical distribution
> update process handle this? For example, if I'm doing a package update using a
> typical tool [gnoRPM, kpackage, etc.] what is happening behind the scenes to
> prevent disaster? The situation where I've booted from CD-ROM & doing a major
> distribution update would be safe doing a simple replacement. OTOH, if I get an
> "urgent" patch that I need to apply, must I track down all the jobs that are
> currently using the files being updated, get them stopped, do the update, and
> then restart them to be "safe"? [and I'll quit doing the "dangerous" updates
> that I've been doing through ignorance] If so, is that going to kill the use of
> Linux in high availability situations [or must I run redundant systems to work
> around this]?
> 

Well, the executable is loaded into memory once started.  For the most
part, you can overwrite the executable (or other file) on the disk, as
long as you have permissions to do so.  So, no, you don't have to track
down all the other processes and stop them, in order to replace the file
on disk.  Be careful, though, with things like your libc.  If you
overwrite *that* with an invalid version, you're pretty much screwed,
without a rescue disk set.

Other operating systems, AFAIK, implement an operating-system level
locking mechanism, whereby the OS locks the file and won't let it be
overwritten.  On Linux (and Unix in general, I guess), there are a
couple of different types of lock, and if you have a program which
performs, say, a partial file lock, you cannot be guaranteed that that
lock will be respected--unless and until every application written
implements the same type of locking and also checks to see if a file is
locked before doing something to it.

> On 4 May 2000, Trond Myklebust wrote:
> 
> >Not good. If I'm running /bin/bash, and somebody on the server updates
> >/bin/bash, then I don't want to reboot my machine. With the above
> 

You wouldn't have to reboot.  Why would you think you need to reboot?
This isn't Winbloze, for god's sake.  All it means is that new bash
processes will use the updated version, while old processes would still
be using the old version--it's loaded in memory, remember?  Hell, you
can even overwrite the libc on a running system.

> If you use rename(2) to update the shell (as you should since `cp` would
> corrupt also users that are reading /bin/bash from local fs) then nfs
> should get it right also with my patch since it should notice the inode
> number changed (the nfs fd handle should get the inode number as cookie),
> right?

My understanding of rename(2) is that it only returns EBUSY on
directories, and not on individual files.  BTW, I don't see the message
this was in reference to on lkml--what was your patch?


-- 
Matthew Vanecek
Visit my Website at http://mysite.directlink.net/linuxguy
For answers type: perl -e 'print
$i=pack(c5,(41*2),sqrt(7056),(unpack(c,H)-2),oct(115),10);'
*****************************************************************
For 93 million miles, there is nothing between the sun and my shadow
except me. I'm always getting in the way of something...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
