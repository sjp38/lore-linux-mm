Message-ID: <462ACA40.8070407@yahoo.com.au>
Date: Sun, 22 Apr 2007 12:36:48 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com>
In-Reply-To: <4629524C.5040302@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> Andrew Morton wrote:
> 
>> On Fri, 20 Apr 2007 17:38:06 -0400
>> Rik van Riel <riel@redhat.com> wrote:
>>
>>> Andrew Morton wrote:
>>>
>>>> I've also merged Nick's "mm: madvise avoid exclusive mmap_sem".
>>>>
>>>> - Nick's patch also will help this problem.  It could be that your 
>>>> patch
>>>>   no longer offers a 2x speedup when combined with Nick's patch.
>>>>
>>>>   It could well be that the combination of the two is even better, 
>>>> but it
>>>>   would be nice to firm that up a bit.  
>>>
>>> I'll test that.
>>
>>
>> Thanks.
> 
> 
> Well, good news.
> 
> It turns out that Nick's patch does not improve peak
> performance much, but it does prevent the decline when
> running with 16 threads on my quad core CPU!
> 
> We _definately_ want both patches, there's a huge benefit
> in having them both.
> 
> Here are the transactions/seconds for each combination:
> 
>    vanilla   new glibc  madv_free kernel   madv_free + mmap_sem
> threads
> 
> 1     610         609             596                545
> 2    1032        1136            1196               1200
> 4    1070        1128            2014               2024
> 8    1000        1088            1665               2087
> 16    779        1073            1310               1999


Is "new glibc" meaning MADV_DONTNEED + kernel with mmap_sem patch?

The strange thing with your madv_free kernel is that it doesn't
help single-threaded performance at all. So that work to avoid
zeroing the new page is not a win at all there (maybe due to the
cache effects I was worried about?).

However MADV_FREE does improve scalability, which is interesting.
The most likely reason I can see why that may be the case is that
it avoids mmap_sem when faulting pages back in (I doubt it is due
to avoiding the page allocator, but maybe?).

So where is the down_write coming from in this workload, I wonder?
Heap management? What syscalls?

x86_64's rwsems are crap under heavy parallelism (even read-only),
as I fixed in my recent generic rwsems patch. I don't expect MySQL
to be such a mmap_sem microbenchmark, but I wonder how much this
would help?

What if we ran the private futexes patch to further cut down
mmap_sem contention?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
