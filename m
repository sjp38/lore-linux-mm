Message-ID: <463C1900.7060409@cosmosbay.com>
Date: Sat, 05 May 2007 07:41:20 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/3] Slab Defrag / Slab Targeted Reclaim and general Slab
 API changes
References: <20070504221555.642061626@sgi.com> <463C10F8.4040803@cosmosbay.com> <Pine.LNX.4.64.0705042209050.14211@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705042209050.14211@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dgc@sgi.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Christoph Lameter a ecrit :
> On Sat, 5 May 2007, Eric Dumazet wrote:
> 
>>> C. Introduces a slab_ops structure that allows a slab user to provide
>>>    operations on slabs.
>> Could you please make it const ?
> 
> Sure. Done.

thanks :)

> 
>>> All of this is really not necessary since the compiler knows how to align
>>> structures and we should use this information instead of having the user
>>> specify an alignment. I would like to get rid of SLAB_HWCACHE_ALIGN
>>> and kmem_cache_create. Instead one would use the following macros (that
>>> then result in a call to __kmem_cache_create).
>> Hum, the problem is the compiler sometimes doesnt know the target processor
>> alignment.
>>
>> Adding ____cacheline_aligned to 'struct ...' definitions might be overkill if
>> you compile a generic kernel and happens to boot a Pentium III with it.
> 
> Then add ___cacheline_aligned_in_smp or specify the alignment in the 
> various other ways that exist. Practice is that most slabs specify 
> SLAB_HWCACHE_ALIGN. So most slabs are cache aligned today.

Yes but this alignement is dynamic, not at compile time.

include/asm-i386/processor.h:739:#define cache_line_size() 
(boot_cpu_data.x86_cache_alignment)

So adding ____cacheline_aligned  to 'struct file' for example would be a 
regression for people with PII or PIII

> 
>> G. Being able to track the number of pages in a kmem_cache
>>
>>
>> If you look at fs/buffer.c, you'll notice the bh_accounting, recalc_bh_state()
>> that might be overkill for large SMP configurations, when the real concern is
>> to be able to limit the bh's not to exceed 10% of LOWMEM.
>>
>> Adding a callback in slab_ops to track total number of pages in use by a given
>> kmem_cache would be good.
> 
> Such functionality exists internal to SLUB and in the reporting tool. 
> I can export that function if you need it.
> 
>> Same thing for fs/file_table.c : nr_file logic
>> (percpu_counter_dec()/percpu_counter_inc() for each file open/close) could be
>> simplified if we could just count the pages in use by filp_cachep kmem_cache.
>> The get_nr_files() thing is not worth the pain.
> 
> Sure. What exactly do you want? The absolute number of pages of memory 
> that the slab is using?
> 
> 	kmem_cache_pages_in_use(struct kmem_cache *) ?
> 
> The call will not be too lightweight since we will have to loop over all 
> nodes and add the counters in each per node struct for allocates slabs.
> 
> 

On a typical system, number of pages for 'filp' kmem_cache tends to be stable

-bash-2.05b# grep filp /proc/slabinfo
filp              234727 374100    256   15    1 : tunables  120   60    8 : 
slabdata  24940  24940    135
-bash-2.05b# grep filp /proc/slabinfo
filp              234776 374100    256   15    1 : tunables  120   60    8 : 
slabdata  24940  24940    168
-bash-2.05b# grep filp /proc/slabinfo
filp              234728 374100    256   15    1 : tunables  120   60    8 : 
slabdata  24940  24940    180
-bash-2.05b# grep filp /proc/slabinfo
filp              234724 374100    256   15    1 : tunables  120   60    8 : 
slabdata  24940  24940    174

So revert nr_files logic to a single integer would be enough, even for NUMA

int nr_pages_used_by_filp;
int nr_pages_filp_limit;
int filp_in_danger __read_mostly;

static void callback_pages_in_use_by_filp(int inc)
{
     int in_danger;

     nr_pages_used_by_filp += inc;

     in_danger = nr_pages_used_by_filp >= nr_pages_filp_limit;
     if (in_danger != filp_in_danger)
         filp_in_danger = in_danger;
}

struct file *get_empty_filp(void)
{
...
if (filp_in_danger && !capable(CAP_SYS_ADMIN))
	goto over;

...
}


void __init files_init(unsigned long mempages)
{
...
nr_pages_filp_limit = (mempages * 10) / 100; /* 10% for filp use */
...
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
