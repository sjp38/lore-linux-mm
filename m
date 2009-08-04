Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CBC256B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 15:27:42 -0400 (EDT)
Date: Tue, 4 Aug 2009 21:57:17 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
Message-ID: <20090804195717.GA5998@elte.hu>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie> <1249409546-6343-5-git-send-email-mel@csn.ul.ie> <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Larry Woodman <lwoodman@redhat.com>, riel@redhat.com, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

3
* Andrew Morton <akpm@linux-foundation.org> wrote:

> > This patch adds a simple post-processing script for the 
> > page-allocator-related trace events. It can be used to give an 
> > indication of who the most allocator-intensive processes are and 
> > how often the zone lock was taken during the tracing period. 
> > Example output looks like
> > 
> > find-2840
> >  o pages allocd            = 1877
> >  o pages allocd under lock = 1817
> >  o pages freed directly    = 9
> >  o pcpu refills            = 1078
> >  o migrate fallbacks       = 48
> >    - fragmentation causing = 48
> >      - severe              = 46
> >      - moderate            = 2
> >    - changed migratetype   = 7
> 
> The usual way of accumulating and presenting such measurements is 
> via /proc/vmstat.  How do we justify adding a completely new and 
> different way of doing something which we already do?

/proc/vmstat has a couple of technical and usage disadvantages:

 - it is pretty coarse - all-of-system, nothing else 

 - expensive to read (have to read the full file with all fields)

 - has to be polled, has no notion for events

 - it does not offer sampling of workloads

 - it does not allow the separation of workloads: you cannot measure
   just a single workload, you cannot measure just a single process, 
   nor a single CPU.

Incidentally there's an upstream kernel instrumentation and 
statistics framework that solves all the above disadvantages of 
/proc/vmstat:

 - it is finegrained: per task or per workload or per cpu or full system

 - cheap to read - the counts can be accessed individually

 - is event based, can be poll()ed

 - offers sampling of workloads, of any subset of these values

 - it allows easy separation of workloads

All that is needed are the patches form Mel and Rik and it's 
plug-and-play.

Let me demonstrate these features in action (i've applied the 
patches for testing to -tip):

First, discovery/enumeration of available counters can be done via 
'perf list':

titan:~> perf list
  [...]
  kmem:kmalloc                             [Tracepoint event]
  kmem:kmem_cache_alloc                    [Tracepoint event]
  kmem:kmalloc_node                        [Tracepoint event]
  kmem:kmem_cache_alloc_node               [Tracepoint event]
  kmem:kfree                               [Tracepoint event]
  kmem:kmem_cache_free                     [Tracepoint event]
  kmem:mm_page_free_direct                 [Tracepoint event]
  kmem:mm_pagevec_free                     [Tracepoint event]
  kmem:mm_page_alloc                       [Tracepoint event]
  kmem:mm_page_alloc_zone_locked           [Tracepoint event]
  kmem:mm_page_pcpu_drain                  [Tracepoint event]
  kmem:mm_page_alloc_extfrag               [Tracepoint event]

Then any (or all) of the above event sources can be activated and 
measured. For example the page alloc/free properties of a 'hackbench 
run' are:

 titan:~> perf stat -e kmem:mm_page_pcpu_drain -e kmem:mm_page_alloc 
 -e kmem:mm_pagevec_free -e kmem:mm_page_free_direct ./hackbench 10
 Time: 0.575

 Performance counter stats for './hackbench 10':

          13857  kmem:mm_page_pcpu_drain 
          27576  kmem:mm_page_alloc      
           6025  kmem:mm_pagevec_free    
          20934  kmem:mm_page_free_direct

    0.613972165  seconds time elapsed

You can observe the statistical properties as well, by using the 
'repeat the workload N times' feature of perf stat:

 titan:~> perf stat --repeat 5 -e kmem:mm_page_pcpu_drain -e 
   kmem:mm_page_alloc -e kmem:mm_pagevec_free -e 
   kmem:mm_page_free_direct ./hackbench 10
 Time: 0.627
 Time: 0.644
 Time: 0.564
 Time: 0.559
 Time: 0.626

 Performance counter stats for './hackbench 10' (5 runs):

          12920  kmem:mm_page_pcpu_drain    ( +-   3.359% )
          25035  kmem:mm_page_alloc         ( +-   3.783% )
           6104  kmem:mm_pagevec_free       ( +-   0.934% )
          18376  kmem:mm_page_free_direct   ( +-   4.941% )

    0.643954516  seconds time elapsed   ( +-   2.363% )

Furthermore, these tracepoints can be used to sample the workload as 
well. For example the page allocations done by a 'git gc' can be 
captured the following way:

 titan:~/git> perf record -f -e kmem:mm_page_alloc -c 1 ./git gc
 Counting objects: 1148, done.
 Delta compression using up to 2 threads.
 Compressing objects: 100% (450/450), done.
 Writing objects: 100% (1148/1148), done.
 Total 1148 (delta 690), reused 1148 (delta 690)
 [ perf record: Captured and wrote 0.267 MB perf.data (~11679 samples) ]

To check which functions generated page allocations:

 titan:~/git> perf report
 # Samples: 10646
 #
 # Overhead          Command               Shared Object
 # ........  ...............  ..........................
 #
    23.57%       git-repack  /lib64/libc-2.5.so        
    21.81%              git  /lib64/libc-2.5.so        
    14.59%              git  ./git                     
    11.79%       git-repack  ./git                     
     7.12%              git  /lib64/ld-2.5.so          
     3.16%       git-repack  /lib64/libpthread-2.5.so  
     2.09%       git-repack  /bin/bash                 
     1.97%               rm  /lib64/libc-2.5.so        
     1.39%               mv  /lib64/ld-2.5.so          
     1.37%               mv  /lib64/libc-2.5.so        
     1.12%       git-repack  /lib64/ld-2.5.so          
     0.95%               rm  /lib64/ld-2.5.so          
     0.90%  git-update-serv  /lib64/libc-2.5.so        
     0.73%  git-update-serv  /lib64/ld-2.5.so          
     0.68%             perf  /lib64/libpthread-2.5.so  
     0.64%       git-repack  /usr/lib64/libz.so.1.2.3  

Or to see it on a more finegrained level:

titan:~/git> perf report --sort comm,dso,symbol
# Samples: 10646
#
# Overhead          Command               Shared Object  Symbol
# ........  ...............  ..........................  ......
#
     9.35%       git-repack  ./git                       [.] insert_obj_hash
     9.12%              git  ./git                       [.] insert_obj_hash
     7.31%              git  /lib64/libc-2.5.so          [.] memcpy
     6.34%       git-repack  /lib64/libc-2.5.so          [.] _int_malloc
     6.24%       git-repack  /lib64/libc-2.5.so          [.] memcpy
     5.82%       git-repack  /lib64/libc-2.5.so          [.] __GI___fork
     5.47%              git  /lib64/libc-2.5.so          [.] _int_malloc
     2.99%              git  /lib64/libc-2.5.so          [.] memset

Furthermore, call-graph sampling can be done too, of page 
allocations - to see precisely what kind of page allocations there 
are:

 titan:~/git> perf record -f -g -e kmem:mm_page_alloc -c 1 ./git gc
 Counting objects: 1148, done.
 Delta compression using up to 2 threads.
 Compressing objects: 100% (450/450), done.
 Writing objects: 100% (1148/1148), done.
 Total 1148 (delta 690), reused 1148 (delta 690)
 [ perf record: Captured and wrote 0.963 MB perf.data (~42069 samples) ]

 titan:~/git> perf report -g
 # Samples: 10686
 #
 # Overhead          Command               Shared Object
 # ........  ...............  ..........................
 #
    23.25%       git-repack  /lib64/libc-2.5.so        
                |          
                |--50.00%-- _int_free
                |          
                |--37.50%-- __GI___fork
                |          make_child
                |          
                |--12.50%-- ptmalloc_unlock_all2
                |          make_child
                |          
                 --6.25%-- __GI_strcpy
    21.61%              git  /lib64/libc-2.5.so        
                |          
                |--30.00%-- __GI_read
                |          |          
                |           --83.33%-- git_config_from_file
                |                     git_config
                |                     |          
   [...]

Or you can observe the whole system's page allocations for 10 
seconds:

titan:~/git> perf stat -a -e kmem:mm_page_pcpu_drain -e 
kmem:mm_page_alloc -e kmem:mm_pagevec_free -e 
kmem:mm_page_free_direct sleep 10

 Performance counter stats for 'sleep 10':

         171585  kmem:mm_page_pcpu_drain 
         322114  kmem:mm_page_alloc      
          73623  kmem:mm_pagevec_free    
         254115  kmem:mm_page_free_direct

   10.000591410  seconds time elapsed

Or observe how fluctuating the page allocations are, via statistical 
analysis done over ten 1-second intervals:

 titan:~/git> perf stat --repeat 10 -a -e kmem:mm_page_pcpu_drain -e 
   kmem:mm_page_alloc -e kmem:mm_pagevec_free -e 
   kmem:mm_page_free_direct sleep 1

 Performance counter stats for 'sleep 1' (10 runs):

          17254  kmem:mm_page_pcpu_drain    ( +-   3.709% )
          34394  kmem:mm_page_alloc         ( +-   4.617% )
           7509  kmem:mm_pagevec_free       ( +-   4.820% )
          25653  kmem:mm_page_free_direct   ( +-   3.672% )

    1.058135029  seconds time elapsed   ( +-   3.089% )

Or you can annotate the recorded 'git gc' run on a per symbol basis 
and check which instructions/source-code generated page allocations:

 titan:~/git> perf annotate __GI___fork
 ------------------------------------------------
  Percent |      Source code & Disassembly of libc-2.5.so
 ------------------------------------------------
          :
          :
          :      Disassembly of section .plt:
          :      Disassembly of section .text:
          :
          :      00000031a2e95560 <__fork>:
 [...]
     0.00 :        31a2e95602:   b8 38 00 00 00          mov    $0x38,%eax
     0.00 :        31a2e95607:   0f 05                   syscall 
    83.42 :        31a2e95609:   48 3d 00 f0 ff ff       cmp    $0xfffffffffffff000,%rax
     0.00 :        31a2e9560f:   0f 87 4d 01 00 00       ja     31a2e95762 <__fork+0x202>
     0.00 :        31a2e95615:   85 c0                   test   %eax,%eax

( this shows that 83.42% of __GI___fork's page allocations come from
  the 0x38 system call it performs. )

etc. etc. - a lot more is possible. I could list a dozen of 
other different usecases straight away - neither of which is 
possible via /proc/vmstat.

/proc/vmstat is not in the same league really, in terms of 
expressive power of system analysis and performance 
analysis.

All that the above results needed were those new tracepoints 
in include/tracing/events/kmem.h.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
