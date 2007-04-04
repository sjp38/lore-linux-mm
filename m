Message-ID: <46133A8B.50203@cosmosbay.com>
Date: Wed, 04 Apr 2007 07:41:31 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	<46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	<20070403125903.3e8577f4.akpm@linux-foundation.org>	<4612B645.7030902@redhat.com>	<20070403202937.GE355@devserv.devel.redhat.com> <20070403144948.fe8eede6.akpm@linux-foundation.org> <4612DCC6.7000504@cosmosbay.com> <46130BC8.9050905@yahoo.com.au>
In-Reply-To: <46130BC8.9050905@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin a ecrit :
> Eric Dumazet wrote:
>>
>> I do think such workloads might benefit from a vma_cache not shared by 
>> all threads but private to each thread. A sequence could invalidate 
>> the cache(s).
>>
>> ie instead of a mm->mmap_cache, having a mm->sequence, and each thread 
>> having a current->mmap_cache and current->mm_sequence
> 
> I have a patchset to do exactly this, btw.

Could you repost it please ?

I guess a seqlock could avoid some cache line bouncing on mmap_sem for some 
kind of operations. I wonder if it could speed up do_page_fault() ???

> 
> Anyway what is the status of the private futex work. I don't think that
> is very intrusive or complicated, so it should get merged ASAP (so then
> at least we have the interface there).
> 

It seems nobody but you and me cared.

BTW I am surprised of Ulrich bugging linux on MADV_KERNEL_CAN_DROP, while 
glibc still does :

FILE *F = fopen("/etc/passwd", "r");
fget(line, sizeof(line), F);
fclose(F);

->

open("/etc/passwd", O_RDONLY)           = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=1505, ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 
0x2b67097f0000
read(3, "root:x:0:0:root:/root:/bin/bash\n"..., 4096) = 1505
close(3)                                = 0
munmap(0x2b67097f0000, 4096)            = 0


using mmap()/munmap() to allocate one 4096 bytes area is certainly overkill. 
mmap_sem is apparently the thing we must hit forever.

Maybe nobody but me still uses fopen()/fclose() after all ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
