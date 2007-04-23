Message-ID: <462C2EDE.4090805@yahoo.com.au>
Date: Mon, 23 Apr 2007 13:58:22 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com> <20070420150618.179d31a4.akpm@linux-foundation.org> <4629524C.5040302@redhat.com> <462ACA40.8070407@yahoo.com.au> <462B0156.9020407@redhat.com> <462BFAF3.4040509@yahoo.com.au> <462C2DC7.5070709@redhat.com>
In-Reply-To: <462C2DC7.5070709@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:

> I've added a 5th column, with just your mmap_sem patch and
> without my madv_free patch.  It is run with the glibc patch,
> which should make it fall back to MADV_DONTNEED after the
> first MADV_FREE call fails.

Thanks! (I edited slightly so it doesn't wrap)


>   vanilla   new glibc   madv_free    mmap_sem        both
> threads
>
> 1     610         609         596         534         545
> 2    1032        1136        1196        1180        1200
> 4    1070        1128        2014        2027        2024
> 8    1000        1088        1665        2089        2087
> 16    779        1073        1310        2012        1999
> 
> 
> Not doing the mprotect calls is the big one I guess, especially
> the fact that we don't need to take the mmap_sem for writing.

Yes.


> With both our patches, single and two thread performance with
> MySQL sysbench is somewhat better than with just your patch,
> 4 and 8 thread performance are basically the same and just
> your patch gives a slight benefit with 16 threads.
> 
> I guess I should benchmark up to 64 or 128 threads tomorrow,
> to see if this is just luck or if the cache benefit of doing
> the page faults and reusing hot pages is faster than not
> having page faults at all.
> 
> I should run some benchmarks on other systems, too.  Some of
> these results could be an artifact of my quad core CPU.  The
> results could be very different on other systems...

I'm getting the 16 core box out of retirement as we speak :)

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
