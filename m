Message-ID: <476A850A.1080807@hp.com>
Date: Thu, 20 Dec 2007 10:06:50 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: SLUB
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Forgive me if this is the wrong place to be asking this, but if so could 
someone point me to a better place?

This past summer I released a tool on sourceforge called collectl - see 
http://collectl.sourceforge.net/ which does some pretty nifty system 
monitoring, one component of which is slabs.  I finally got around to 
trying it out on a newer kernel and I picked 2.6.23 and lo and behold, 
it didn't work because /proc/slabinfo has disappeared to be replaced by 
/sys/slab.  I've been looking around to try and better understand how to 
map slubs to slabs and couldn't find anything written up the definitions 
of the field on /sys/slab and I also suspect that while some of 
information reported by slub might map there could be other useful 
information worth tracking.

To back up a few steps, in my collectl tool I can monitor slabs both in 
real time or log that data to a file for later playback.  The format I 
use for display is modeled after slabtop, but I simply record data for 
all slabs (you can supply a filter).  What I think is particularly 
useful about collectl is a switch that only shows allocations that have 
changed.  This means if you run my tool with a monitoring interval of a 
second (the default interval I use for slabs is 60 seconds since it is 
more work to read/process all of slabinfo) you only see occasional 
changes as they occur.  I've also found this feature very useful when 
analyzing longer term data that was collected at the 60 second 
intervals.  Here's an example of running it with a 1 second monitoring 
interval on a relatively idle system:

#                               
<-----------Objects----------><---------Slab Allocation------>
#         Name                  InUse   Bytes   Alloc   Bytes   InUse   
Bytes   Total   Bytes
09:28:54 sgpool-32                 32   32768      36   36864       8   
32768       9   36864
09:28:54 blkdev_requests           12    3168      30    7920       1    
4096       2    8192
09:28:54 bio                      313   40064     372   47616      11   
45056      12   49152
09:28:55 sgpool-32                 32   32768      32   32768       8   
32768       8   32768
09:28:55 blkdev_requests           12    3168      15    3960       1    
4096       1    4096
09:28:55 bio                      313   40064     341   43648      11   
45056      11   45056
09:28:56 bio                      287   36736     341   43648      10   
40960      11   45056
09:28:56 task_struct              128  253952     140  277760      69  
282624      70  286720
09:28:58 sgpool-64                 33   67584      34   69632      17   
69632      17   69632
09:28:58 bio                      403   51584     403   51584      13   
53248      13   53248
09:28:58 task_struct              124  246016     140  277760      68  
278528      70  286720
09:28:59 journal_handle             0       0       0       0       
0       0       0       0
09:28:59 task_struct              124  246016     136  269824      68  
278528      68  278528
09:29:00 journal_handle            16     768      81    3888       1    
4096       1    4096
09:29:00 scsi_cmd_cache            24   12288      35   17920       5   
20480       5   20480
09:29:00 sgpool-64                 32   65536      34   69632      16   
65536      17   69632
09:29:00 sgpool-8                  51   13056      75   19200       5   
20480       5   20480

The thing that is especially useful with collectl is that by monitoring 
slabs at the same time as monitoring cpu, processes, disk, network and 
more, you can get a very comprehensive picture of what's going on at any 
one time.

My main purpose for writing to this list then becomes what would make 
the most sense to do with slabs with the new slub allocator?  Should I 
simply report on these same fields?  Are there others that make more 
sense?  Do I need to read all 184 entries in /sys/slab and then all the 
entries under them?  Clearly I want to do this efficiently and provide 
meaningful data at the same time.  Perhaps someone would like to take 
this discussion off-line with me and even collaborate with me on 
enhancements for slub in collectl?

-mark


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
