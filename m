Message-ID: <477511F7.3010307@hp.com>
Date: Fri, 28 Dec 2007 10:10:47 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: Re: collectl and the new slab allocator [slub] statistics
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com> <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com> <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com> <4773CBD2.10703@hp.com> <Pine.LNX.4.64.0712271141390.30555@schroedinger.engr.sgi.com> <477403A6.6070208@hp.com> <Pine.LNX.4.64.0712271157190.30817@schroedinger.engr.sgi.com> <47741156.4060500@hp.com> <Pine.LNX.4.64.0712271258340.533@schroedinger.engr.sgi.com> <47743A10.7080605@hp.com> <Pine.LNX.4.64.0712271551290.1144@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0712271551290.1144@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 27 Dec 2007, Mark Seger wrote:
>
>   
>> particular slab you can always look up its mapping.  I would also provide a
>> mechanism for specifying those slabs you want to monitor and even if not a
>> 'primary' name it would use that name.
>>     
>
> Sounds good.
>  
>   
>> Today's kind of over for me but perhaps I can send out an updated prototype
>> format tomorrow.
>>     
>
> Great. But I will only be back next Wednesday.
>   
So here's the latest...  I made a couple of tweaks to the format but I 
think it's getting real close and as you can see, I'm now printing the 
longest alias associated with a slab as is done in slabinfo.  I'm also 
including the time to make it easier to read but typically this is an 
option in case the user doesn't want to use the extra screen 
real-estate.  As a minor point, as I was debugging this and comparing 
its output to slabinfo (and we don't always get the same aliases if 
there are multiple aliases of the same length) I found that slabinfo 
reports on 'kmalloc-1024' and I'm reporting 'biovec-64'.  I thought you 
wanted to only print the kmalloc* names when there was nothing else and 
so I suspect a slight bug in slabinfo...

Note that I decided to print the number of objects in a slab, even 
though one could derive that themselves.  I also decided to report the 
size of the slabs in K bytes as well as the user/total memory.  I'm 
still reporting the objects inuse/avail in bytes since these are often 
<1K and I really don't want to report fractions.

                                     <----------- objects 
-----------><--- slabs ---><----- memory ----->
Time      Slab Name                     Size  /slab   In Use    Avail  
SizeK   Number     UsedK    TotalK
10:25:04  TCP                           1728      4       13       
20      8        5        21        40
10:25:04  TCPv6                         1856      4       15       
20      8        5        27        40
10:25:04  UDP-Lite                       896      4       51       
64      4       16        44        64
10:25:04  UDPLITEv6                     1088      7       28       
28      8        4        29        32
10:25:04  anon_vma                        48     85      773     
1105      4       13        36        52

Anyhow, here's an example of watching the system once a second for any 
slabs that change while the system is idle

                                     <----------- objects 
-----------><--- slabs ---><----- memory ----->
Time      Slab Name                     Size  /slab   In Use    Avail  
SizeK   Number     UsedK    TotalK
10:25:34  skbuff_fclone_cache            448      9       16       
36      4        4         7        16
10:25:34  skbuff_head_cache              256     16     1266     
1552      4       97       316       388
10:25:35  skbuff_fclone_cache            448      9       23       
36      4        4        10        16
10:25:35  skbuff_head_cache              256     16     1265     
1552      4       97       316       388
10:25:36  biovec-64                     1024      4      303      
320      4       80       303       320
10:25:36  dentry                         224     18   215543   
215568      4    11976     47150     47904
10:25:36  skbuff_fclone_cache            448      9       19       
36      4        4         8        16
10:25:36  skbuff_head_cache              256     16     1269     
1552      4       97       317       388

And finally, here's watching a single slab while writing a large file, 
noting the I/O started at 10:26:30...

                                     <----------- objects 
-----------><--- slabs ---><----- memory ----->
Time      Slab Name                     Size  /slab   In Use    Avail  
SizeK   Number     UsedK    TotalK
10:26:25  blkdev_requests                288     14       39       
84      4        6        10        24
10:26:30  blkdev_requests                288     14      189      
224      4       16        53        64
10:26:31  blkdev_requests                288     14      187      
224      4       16        52        64
10:26:32  blkdev_requests                288     14      174      
224      4       16        48        64
10:26:33  blkdev_requests                288     14      173      
224      4       16        48        64
10:26:34  blkdev_requests                288     14       46       
84      4        6        12        24

It shouldn't take too much time to actually implement this in collectl, 
but I do need to find the block of time to update the code, man pages, 
etc before releasing it so if there are any final tweaks, now is the 
time to say so...

-mark


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
