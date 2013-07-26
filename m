Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 08A186B0031
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 10:35:32 -0400 (EDT)
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id r6QEZNXB001246
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 16:35:23 +0200
Message-ID: <51F28926.8060502@itwm.fraunhofer.de>
Date: Fri, 26 Jul 2013 16:35:18 +0200
From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
MIME-Version: 1.0
Subject: Re: Linux Plumbers IO & File System Micro-conference
References: <51E03AFB.1000000@gmail.com> <51E998E0.10207@itwm.fraunhofer.de> <20130722004741.GC11674@dastard> <51ED274B.1060103@itwm.fraunhofer.de> <20130723062559.GI19986@dastard>
In-Reply-To: <20130723062559.GI19986@dastard>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Ric Wheeler <ricwheeler@gmail.com>, linux-mm@kvack.org, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Andreas Dilger <adilger@dilger.ca>, sage@inktank.com

On 07/23/2013 08:25 AM, Dave Chinner wrote:
> On Mon, Jul 22, 2013 at 02:36:27PM +0200, Bernd Schubert wrote:
>> On 07/22/2013 02:47 AM, Dave Chinner wrote:
>>> On Fri, Jul 19, 2013 at 09:52:00PM +0200, Bernd Schubert wrote:
>>>> Hello Ric, hi all,
>>>>
>>>> On 07/12/2013 07:20 PM, Ric Wheeler wrote:
>>>>>

[...]

>>> For example, we changed XFS to have it's own metdata buffer cache
>>> reclaim mechanisms driven by a shrinker that uses prioritised cache
>>> reclaim to ensure we reclaim less important metadata buffers before
>>> ones that are more frequently hit (e.g. to reclaim tree leaves
>>> before nodes and roots). This was done because the page cache based
>>> reclaim of metadata was completely inadequate (i.e. mostly random!)
>>> and would frequently reclaim the wrong thing and cause performance
>>> under memory pressure to tank....
>>
>> Well, especially with XFS I see reads all the time and btrace tells
>> me these are meta-reads. So far I didn't find a way to make XFS to
>> cache meta data permanenly and so far I didn't track that down any
>> further.
>
> Sure. That's what *I* want to confirm - what sort of metadata is
> being read. And what I see is the inode and dentry caches getting
> trashed, and that results in directory reads to repopulate the
> dentry cache....
>
>> For reference and without full bonnie output, with XFS I got about
>> 800 to 1000 creates/s.
>> Somewhat that seems to confirm my idea not to let file systems try
>> to handle it themselves, but to introduce a generic way to cache
>> meta data.
>
> We already have generic metadata caches - the inode and dentry
> caches.
>
> The reason some filesystems have their own caches is that the
> generic caches are not always suited to the physical metadata
> structure of the filesystem, and hence they have their own
> multi-level caches and reclaim implementations that are more optimal
> than the generic cache mechanisms.
>
> IOWs, there isn't an "optimal" generic metadata caching mechanism
> that can be implemented.

Maybe just the generic framework should be improved?

>
>>>> Entirely cached hash directories (16384), which are populated with
>>>> about 16 million files, so 1000 files per hash-dir.
>>>>
>>>>> Version  1.96       ------Sequential Create------ --------Random Create--------
>>>>> fslab3              -Create-- --Read--- -Delete-- -Create-- --Read--- -Delete--
>>>>> files:max:min        /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP  /sec %CP
>>>>>            60:32:32  1702  14  2025  12  1332   4  1873  16  2047  13  1266   3
>>>>> Latency              3874ms    6645ms    8659ms     505ms    7257ms    9627ms
>>>>> 1.96,1.96,fslab3,1,1374655110,,,,,,,,,,,,,,60,32,32,,,1702,14,2025,12,1332,4,1873,16,2047,13,1266,3,,,,,,,3874ms,6645ms,8659ms,505ms,7257ms,9627ms
>>>
>>> Command line parameters, details of storage, the scripts you are
>>> running, etc please. RAM as well, as 16 million files are going to
>>> require at least 20GB RAM to fully cache...
>>
>> 16 million files are only laying around in the hash directories and
>> are not touched at all when new files are created. So I don't know
>> where you take 20GB from.
>
> Each inode in memory requires between 1-1.4k of memory depending on
> the filesystem they belong to.  Then there's another ~200 bytes per
> dentry per inode, and if the names are long enough, then another 64+
> bytes for the name of the file held by the dentry.  So caching 16
> million inodes (directory or files) requires 15-25GB of RAM to
> cache.

Yes, but the 16 million files just lay around, I don't want to cache 
them. With ext4 it works fine just to cache corresponding disk directory 
blocks. So if a new file is created it can lookup from these blocks that 
the file does not exist.

>
> FWIW, have you tried experimenting with
> /proc/sys/vm/vfs_cache_pressure to change the ratio of metadata to
> page cache reclaim? You might find that all you need to do is change
> this ratio and your problem is solved.....

Did you try that with kernels < 3.11? I did and others did, see for 
example here https://nf.nci.org.au/training/talks/rjh.lug2011.pdfa??
In the past it did not help at all. However, and that is really good 
news, with 3.11 it eventually works. Probably due to Mel patches. Thanks 
Mel!

>
>> Our file names have a typical size of 21 bytes, so with a classical
>> ext2 layout that gives 29 bytes, with alignment that makes 32 bytes
>> per directory entry. Ignoring '.' and '..' we need 125000 x 4kiB
>> directory blocks, so about 500MB + some overhead.
>
> If the dentry cache stays populated, then how the filesystem lays
> out dirents on disk is irrelevant - you won't ever be reading them
> more than once....

How does the dentry cache help you for file creates of new files? The 
dentry cache cannot know if the file exists on disk or not? Or do you 
want to have a negative dentry cache of all possible file name combinations?

>
>>> Numbers without context or with "handwavy context" are meaningless
>>> for the purpose of analysis and understanding.
>>
>> I just wanted to show here, that creating new files introduces reads
>> when meta-data have been evicted from the cache and how easily that
>> can happen. From my point of view the hardware does not matter much
>> for that purpose.
>
> In my experience, hardware always matters when you are asking
> someone else to understand and reproduce your performance
> problem. It's often the single most critical aspect that we need to
> understand....
>
>> This was with rotating disks as typically used to store huge amounts
>> of HPC data. With SSDs the effect would have been smaller, but even
>> SSDs are not as fast as in-memory-cache lookups.
> ....
>> Our customer systems usually have >=64GiB RAM and often _less_ than
>> 16 million files per server. But still meta-reads impact latency and
>> streaming performance.
> .....
>> Please not that bonnie++ is not ideally suitable for
>> meta-benchmarks, but as I said above, I just wanted to demonstrate
>> cache evictions.
>
> Sure. On the other hand, you're describing a well known workload and
> memory pressure eviction pattern that can be entirely prevented from
> userspace.  Do you reuse any of the data that is streamed to disk
> before it is evicted from memory by other streaming data? I suspect
> the data cache hit rate for the workloads you are describing (HPC
> and bulk data storage) is around 0%.
>
> If so, why aren't you making use of fadvise(DONTNEED) to tell the
> kernel it doesn't need to cache that data that is being
> read/written? That will prevent streaming Io from creating memory
> pressure, and that will prevent the hot data and metadata caches
> from being trashed by cold streaming IO. I know of several large
> scale/distributed storage server implementations that do exactly
> this...

I'm afraid it is not that easy. For example we have several users 
running OpenFoam over FhGFS. And while I really think that someone 
should fix OpenFoams IO routines, OpenFoam as it is has cache hit of 
99%. So already due to this single program I cannot simple disable 
caching on the FhGFS storage side. And there are many other examples 
were caching helps. And then as  fadvise(DONTNEED) does not even notify 
the file systems, it does not help to implement an RPC for well behaved 
applications - there would be no code path to call this RPC.
I already thought some time ago to write a simple patch, but then the 
FhGFS client is not in the kernel and servers are closed source, so 
chances to get such a patch accepted without a user in the kernel are 
almost zero.

> Remember: not all IO problems need to be solved by changing kernel
> code ;)

Yes sure, therefore I'm working on different fhgfs storage layout to 
allow better caching. But I think it still would be useful if file 
systems could use a more suitable generic framework for caching their 
metadata and if admins would have better control over that.


Cheers,
Bernd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
