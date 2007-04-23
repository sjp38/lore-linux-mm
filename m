Message-ID: <462C2DC7.5070709@redhat.com>
Date: Sun, 22 Apr 2007 23:53:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au>
In-Reply-To: <462BFAF3.4040509@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> Rik van Riel wrote:
>> Nick Piggin wrote:
>>
>>> Rik van Riel wrote:
> 
>>>> Here are the transactions/seconds for each combination:

I've added a 5th column, with just your mmap_sem patch and
without my madv_free patch.  It is run with the glibc patch,
which should make it fall back to MADV_DONTNEED after the
first MADV_FREE call fails.

>>>>    vanilla   new glibc  madv_free kernel   madv_free + mmap_sem  mmap_sem
>>>> threads
>>>>
>>>> 1     610         609             596                545         534
>>>> 2    1032        1136            1196               1200        1180
>>>> 4    1070        1128            2014               2024        2027
>>>> 8    1000        1088            1665               2087        2089
>>>> 16    779        1073            1310               1999        2012

Not doing the mprotect calls is the big one I guess, especially
the fact that we don't need to take the mmap_sem for writing.

With both our patches, single and two thread performance with
MySQL sysbench is somewhat better than with just your patch,
4 and 8 thread performance are basically the same and just
your patch gives a slight benefit with 16 threads.

I guess I should benchmark up to 64 or 128 threads tomorrow,
to see if this is just luck or if the cache benefit of doing
the page faults and reusing hot pages is faster than not
having page faults at all.

I should run some benchmarks on other systems, too.  Some of
these results could be an artifact of my quad core CPU.  The
results could be very different on other systems...

> Yeah. That's funny, because it means either there is some
> contention on the mmap_sem (or ptl) at 1 thread, or that my
> patch alters the uncontended performance.

Maybe MySQL has various different threads to do
different tasks.  Something to look into...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
