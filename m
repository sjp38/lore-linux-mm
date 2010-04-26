Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id DEC796B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 18:31:56 -0400 (EDT)
Date: Mon, 26 Apr 2010 15:31:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: swapping when there's a free memory
Message-Id: <20100426153120.1f55de01.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.1.10.1004220248280.19246@artax.karlin.mff.cuni.cz>
References: <alpine.DEB.1.10.1004220248280.19246@artax.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010 02:55:58 +0200 (CEST)
Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz> wrote:

> Hi

You had the wrong address for linux-mm.  Perhaps that explains the lack
of response <whistles innocently>.

> I captured this output of vmstat. The machine was freeing cache and 
> swapping out pages even when there was a plenty of free memory.
> 
> The machine is sparc64 with 1GB RAM with 2.6.34-rc4. This abnormal 
> swapping happened during running spadfsck --- a fsck program for a custom 
> filesystem that caches most reads in its internal cache --- so it reads 
> buffers and allocates memory at the same time.
> 
> Note that sparc64 doesn't have any low/high memory zones, so it couldn't 
> be explained by filling one zone and needing to allocate pages in it.
> 
> This abnormal behavior doesn't happen everytime, it happend about twice 
> for many spadfsck attempts.
> 
> Mikulas
> 
>  1  0  36736 289176 389504  57200    0    0  9776     0  346  292 34 36  0 31
>  1  0  36736 260496 402664  57200    0    0 13167     0  459  426 12 41  0 48
>  1  0  36736 231936 415464  57200    0    0 12800     0  422  333 22 35  0 44
>  1  0  36736 206016 426984  57200    0    0 11520     0  408  319 36 35  0 30
>  1  0  36736 193056 432360  57200    0    0  5376     0  240  195 61 18  0 21
> *** here it starts unreasonable swappping and cache-trimming
>  0  2  59216 200136 429424  47992    0 22528  3216 22528  219  194 55 25  0 20
>  1  1  68096 194376 431880  45192    0 8960  4896  8968  311  292 58 34  0  8
> procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
>  r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
>  1  1  74752 179856 438632  43240    0 6656  8456  6656  387  348 36 29  0 36
>  2  1  78824 165336 444944  42136    0 4096  7939  4104  400  452 43 27  0 31
>  0  2  86368 152736 449416  41008    0 7552  8069  7552  387  376 48 30  0 23
>  2  1  94400 159696 434344  38920    0 8064  9624  8072  483  443 30 40  0 31
>  2  0 102688 150696 435104  37992    0 8304  7504  8304  355  366 32 27  0 42
>  2  2 105768 168696 411672  34816    0 3088  9144  3104  450  416 52 27  0 21
>  2  2 111384 183576 394016  34416    8 5640  3640  5728  322  282 62 27  0 11
>  1  1 117056 266256 318136  29536  128 5672   136  5688  153  175 54 24  0 22
>  2  1 117032 259776 321536  29600  240    0  3697     0  253  259 46 16  0 39
>  1  0 117016 243816 329640  29600    0    0  8127     8  399  389 53 35  0 12
>  1  0 116968 241536 330800  29600   64    0  1224     0  156  122 70 18  0 12
>  1  0 114856 300456 292536  29600   64    0  3264     0  190   99 58 34  0  8
> *** here, spadfsck finished
>  0  0  54152 736072 132392  29600    0    0     0     0   84   27  0 60 40  0
>  0  0  54072 736072 132392  29600    0    0     0     0   30   34  3  0 97  0
>  0  1  54064 736640 132392  29632    0    0    32     0   33   51  1  0 93  6
>  3  0  54064 731640 132408  32136    0    0  2512     0  219  425 12  7  0 81
>  0  1  54064 733112 132432  32536    0    0   432     0  155  311 47 29  0 25
>  0  1  54064 732528 132440  32848    0    0   328     0  146  298 43 22  0 36
>  1  0  54064 726960 132448  33456    0    0   616     0  152  175 29  7  0 64
>  0  1  54064 723840 132448  33856    0    0   400     0  163  136 43  2  0 55
>  1  0  54064 720480 132448  34248    0    0   392     0  203  132 45  3  0 52
>  0  1  54064 717056 132448  34496    0    0   248     0  137   91 51  1  0 48
>  1  0  54064 712632 132456  34840    0    0   352     0  145   70 85  3  0 12
>  1  0  54064 710952 132456  34952    0    0   112     0  129   50 92  0  0  8
>  1  0  54064 709872 132456  34952    0    0     0     0  123   24 98  2  0  0
>  1  0  54064 708792 132456  34952    0    0     0     0  121   24 100  0  0  0

That's nuts - we shouldn't have entered page reclaim at all with 20% of
memory on the freelist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
