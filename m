Date: Fri, 16 Apr 2004 23:09:20 -0700
From: Marc Singer <elf@buici.com>
Subject: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417060920.GC29393@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On my target board, an ARM cpu with 32MiB or RAM, I'm finding that the
performance is quite poor once RAM fills with IO pages and the code
pages of the program being executed are evicted.  

In my test setup, rootfs is mounted over NFS.  The degenerate example
is a simple program that copies a 40MiB file over NFS using a
read/write loop.  As it runs and as memory fills with NFS cached
pages, I can watched the VM evict the code that is executing the loop.
Since there are no other programs running (no TLB flushes from context
switching), there is nothing to stop the VM from aging the code pages.
During the copy, it may evict this same page a dozen times.  While I
understand that this setup by design, I wonder if there isn't
something that can (or should) be done to reduce this behavior.

There are a couple of other things to keep in mind.  

  1) This is an embedded system.  
  2) The root filesystem will not be NFS mounted in production.  The
     root is most likely to be stored in bootflash.  
  3) Some of these systems may perform significant amounts of IO, but
     almost none will be filesystem IO.  Thus, there is unlikely to be
     much hanging about the page cache.
  4) Performance in my test scenarios is quite poor.  Once I've copied
     the 40MiB file, executing an 'ls' command may take several
     seconds while the machine reloads libraries from the NFS server.
     The cached IO pages hang about in RAM for some time such
     that any programs executed will experience code page evictions.
  5) Removing the reclaim_mapped=1 line improves system response
     dramatically...just as I'd expect.

So, is this something to worry about?  Should it be a tunable feature?
Should this be something addressed in the platform specific VM code?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
