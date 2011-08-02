Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 55078900163
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 22:43:44 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id p722hgpt012425
	for <linux-mm@kvack.org>; Mon, 1 Aug 2011 19:43:42 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by wpaz13.hot.corp.google.com with ESMTP id p722hcx3003988
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 1 Aug 2011 19:43:40 -0700
Received: by pzk36 with SMTP id 36so12218692pzk.34
        for <linux-mm@kvack.org>; Mon, 01 Aug 2011 19:43:37 -0700 (PDT)
Date: Mon, 1 Aug 2011 19:43:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <CAOJsxLGyC4=WwGu7kUTwVKF3AxhfWjBg2sZu=W08RtVMHKk8eQ@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1108011939180.15596@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com> <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com> <1312145146.24862.97.camel@jaguar>
 <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com> <1312175306.24862.103.camel@jaguar> <alpine.DEB.2.00.1108010229150.1062@chino.kir.corp.google.com> <CAOJsxLGyC4=WwGu7kUTwVKF3AxhfWjBg2sZu=W08RtVMHKk8eQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1617763585-1312253016=:15596"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1617763585-1312253016=:15596
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 1 Aug 2011, Pekka Enberg wrote:

> Looking at the data (in slightly reorganized form):
> 
>   alloc
>   =====
> 
>     16 threads:
> 
>       cache           alloc_fastpath          alloc_slowpath
>       kmalloc-256     4263275 (91.1%)         417445   (8.9%)
>       kmalloc-1024    4636360 (99.1%)         42091    (0.9%)
>       kmalloc-4096    2570312 (54.4%)         2155946  (45.6%)
> 
>     160 threads:
> 
>       cache           alloc_fastpath          alloc_slowpath
>       kmalloc-256     10937512 (62.8%)        6490753  (37.2%)
>       kmalloc-1024    17121172 (98.3%)        303547   (1.7%)
>       kmalloc-4096    5526281  (31.7%)        11910454 (68.3%)
> 
>   free
>   ====
> 
>     16 threads:
> 
>       cache           free_fastpath           free_slowpath
>       kmalloc-256     210115   (4.5%)         4470604  (95.5%)
>       kmalloc-1024    3579699  (76.5%)        1098764  (23.5%)
>       kmalloc-4096    67616    (1.4%)         4658678  (98.6%)
> 
>     160 threads:
>       cache           free_fastpath           free_slowpath
>       kmalloc-256     15469    (0.1%)         17412798 (99.9%)
>       kmalloc-1024    11604742 (66.6%)        5819973  (33.4%)
>       kmalloc-4096    14848    (0.1%)         17421902 (99.9%)
> 
> it's pretty sad to see how SLUB alloc fastpath utilization drops so
> dramatically. Free fastpath utilization isn't all that great with 160
> threads either but it seems to me that most of the performance
> regression compared to SLAB still comes from the alloc paths.
> 

It's the opposite, the cumulative effects of the free slowpath is more 
costly in terms of latency than the alloc slowpath because it occurs at a 
greater frequency; the pattern that I described as "slab thrashing" before 
causes a single free to a full slab, manipulation to get it back on the 
partial list, then the alloc slowpath grabs it for a single allocation, 
and requires another partial slab on the next alloc.
--397155492-1617763585-1312253016=:15596--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
