Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E4A0C6B008A
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 13:55:13 -0500 (EST)
Date: Thu, 10 Dec 2009 19:54:59 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC mm][PATCH 2/5] percpu cached mm counter
Message-ID: <20091210185459.GA8697@elte.hu>
References: <20091210163115.463d96a3.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210163448.338a0bd2.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210075454.GB25549@elte.hu>
 <20091210172040.37d259d3.kamezawa.hiroyu@jp.fujitsu.com>
 <20091210083310.GB6834@elte.hu>
 <alpine.DEB.2.00.0912101134220.5481@router.home>
 <20091210173819.GA5256@elte.hu>
 <alpine.DEB.2.00.0912101203320.5481@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912101203320.5481@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>


* Christoph Lameter <cl@linux-foundation.org> wrote:

> On Thu, 10 Dec 2009, Ingo Molnar wrote:
> 
> >
> > * Christoph Lameter <cl@linux-foundation.org> wrote:
> >
> > > On Thu, 10 Dec 2009, Ingo Molnar wrote:
> > >
> > > > No, i'm not suggesting that - i'm just suggesting that right now 
> > > > MM stats are not very well suited to be exposed via perf. If we 
> > > > wanted to measure/sample the information in /proc/<pid>/statm it 
> > > > just wouldnt be possible. We have a few events like pagefaults 
> > > > and a few tracepoints as well - but more would be possible IMO.
> > >
> > > vital MM stats are exposed via /proc/<pid> interfaces. Performance 
> > > monitoring is something optional MM VM stats are used for VM 
> > > decision on memory and process handling.
> >
> > You list a few facts here but what is your point?
> 
> The stats are exposed already in a well defined way. [...]

They are exposed in a well defined but limited way: you cannot profile 
based on those stats, you cannot measure them across a workload 
transparently at precise task boundaries and you cannot trace based on 
those stats.

For example, just via the simple page fault events we can today do 
things like:

 aldebaran:~> perf stat -e minor-faults /bin/bash -c "echo hello"
 hello

  Performance counter stats for '/bin/bash -c echo hello':

             292  minor-faults            

     0.000884744  seconds time elapsed

 aldebaran:~> perf record -e minor-faults -c 1 -f -g firefox                  
 Error: cannot open display: :0
 [ perf record: Woken up 3 times to write data ]
 [ perf record: Captured and wrote 0.324 MB perf.data (~14135 samples) ]

 aldebaran:~> perf report
 no symbols found in /bin/sed, maybe install a debug package?
 # Samples: 5312
 #
 # Overhead         Command                             Shared Object  Symbol
 # ........  ..............  ........................................  ......
 #
     12.54%         firefox  ld-2.10.90.so                             
 [.] _dl_relocate_object
                   |
                   --- _dl_relocate_object
                       dl_open_worker
                       _dl_catch_error
                       dlopen_doit
                       0x7fffdf8c6562
                       0x68733d54524f5053

     4.95%         firefox  libc-2.10.90.so                           
 [.] __GI_memset
                   |
                   --- __GI_memset
 ...

I.e. 12.54% of the pagefaults in the firefox startup occur in 
dlopen_doit()->_dl_catch_error()->dl_open_worker()->_dl_relocate_object()-> 
_dl_relocate_object() call path. 4.95% happen in __GI_memset() - etc.

> [...] Exposing via perf is outside of the scope of his work.

Please make thoughts about intelligent instrumentation solutions, and 
please think "outside of the scope" of your usual routine.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
