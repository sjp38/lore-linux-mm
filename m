Subject: Asynchronous I/O
Date: Thu, 09 Sep 1999 17:46:15 +0100
From: Steven Hand <Steven.Hand@cl.cam.ac.uk>
Message-Id: <E11P7JJ-0005Fd-00@heaton.cl.cam.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-MM@kvack.org
Cc: Steven.Hand@cl.cam.ac.uk
List-ID: <linux-mm.kvack.org>

Hi all, 

we have an application which generates large amounts of data from the
network (detailed TCP flow stats from a pair of 100Mbit NICs), and we
wish to log this data to disk. To keep things simple (and to prevent 
jitter) we want to 'trickle' the data out to disk; that is, to 
asynchronously request a flush of e.g. 1Mb of data, but not have our 
process wait for the I/O to complete. 

Building on a previous similar implementation for OSF/1, we decided to
use a memory-mapped log file (which is opened O_NONBLOCK) and then
periodically (e.g. every 1Mb of data) call e.g. 
 
       msync(start, 0x100000, MS_ASYNC); 

after which we would continue. 

Unfortunately, with the kernel version we are using (2.2.9, but the 
relevant code is the same 2.2.2 thru 2.2.12), the MS_ASYNC flag
prevents calling file->f_op->sync() on the mapped file, but does not 
actually cause non-blocking I/O. 

The path is: 

  sys_msync(),  msync_interval(), filemap_sync(), 
    filemap_sync_pmd_range/pte_range/pte(), filemap_write_page()

filemap_write_page() is always called with the 'wait' flag set to '1',
regardless of the flags to msync(). Hence we proceed with: 

  do_write_page(), file->f_op->write() 

which, among other things, will allocate some blocks and do a
copy_from_user() for the 1Mb buffer. 

Whatever occurs, anyway, can cause considerable delays (as observed 
from our user-process pre and post msync), even on an otherwise 
unloaded machine. 

To combat this, we hacked up filemap_sync_pte() to do: 

  error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, 
                             page, !(flags & MS_ASYNC));


With this change, pages are simply queued for the kpiod thread to
worry about, and control returns to our application far sooner. 

So now some questions: 

   a) is this a generally sensible thing to do? 

   b) should it work? 
       - we've tested it a bit, and it has been fine in all but one
         case (which we cannot appear to reproduce) in which pages 
         of the resulting files appear to be horribly interleaved ;-(

  c) is there a better way to do this on 2.2.x ?

  d) is there a better way to do this on 2.3.x ? 
      - I notice, for example, that much of the filemap code seems
        to have been rewritten. 


anyway, if you got this far, thanks for reading, and TIA for any 
advice/help, 

S. 









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
