Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 83DB36B01E3
	for <linux-mm@kvack.org>; Sun, 11 Apr 2010 07:00:36 -0400 (EDT)
Date: Sun, 11 Apr 2010 13:00:15 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100411110015.GA10149@elte.hu>
References: <20100410190233.GA30882@elte.hu>
 <4BC0CFF4.5000207@redhat.com>
 <20100410194751.GA23751@elte.hu>
 <4BC0DE84.3090305@redhat.com>
 <4BC0E2C4.8090101@redhat.com>
 <q2s28f2fcbc1004101349ye3e44c9cl4f0c3605c8b3ffd3@mail.gmail.com>
 <4BC0E556.30304@redhat.com>
 <4BC19663.8080001@redhat.com>
 <v2q28f2fcbc1004110237w875d3ec5z8f545c40bcbdf92a@mail.gmail.com>
 <4BC19916.20100@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BC19916.20100@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Jason Garrett-Glaser <darkshikari@gmail.com>, Mike Galbraith <efault@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>


* Avi Kivity <avi@redhat.com> wrote:

> On 04/11/2010 12:37 PM, Jason Garrett-Glaser wrote:
> >
> >># time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads 2
> >>yuv4mpeg: 3840x2160@50/1fps, 1:1
> >>
> >>encoded 500 frames, 0.68 fps, 251812.80 kb/s
> >>
> >>real    12m17.154s
> >>user    20m39.151s
> >>sys    0m11.727s
> >>
> >># echo never>  /sys/kernel/mm/transparent_hugepage/enabled
> >># echo never>  /sys/kernel/mm/transparent_hugepage/khugepaged/enabled
> >># time x264 --crf 20 --quiet crowd_run_2160p.y4m -o /dev/null --threads 2
> >>yuv4mpeg: 3840x2160@50/1fps, 1:1
> >>
> >>encoded 500 frames, 0.66 fps, 251812.80 kb/s
> >>
> >>real    12m37.962s
> >>user    21m13.506s
> >>sys    0m11.696s
> >>
> >>Just 2.7%, even though the working set was much larger.
> >Did you make sure to check your stddev on those?
> 
> I'm doing another run to look at variability.

Sigh. Could you please stop using stone-age tools like /usr/bin/time and 
instead use:

 perf stat --repeat 3 x264 ...

you can install it via:

 cd linux
 cd tools/perf/
 make -j install

That way you will see 'variability' (sttdev/error bars/fuzz), and a whole lot 
of other CPU details beyond much more precise measurements:

 $ perf stat --repeat 3 x264 --crf 20 --quiet soccer_4cif.y4m -o /dev/null --threads 2
 yuv4mpeg: 704x576@60/1fps, 128:117

 encoded 2 frames, 23.47 fps, 39824.64 kb/s
 yuv4mpeg: 704x576@60/1fps, 128:117

 encoded 2 frames, 23.52 fps, 39824.64 kb/s
 yuv4mpeg: 704x576@60/1fps, 128:117

 encoded 2 frames, 23.45 fps, 39824.64 kb/s

 Performance counter stats for 'x264 --crf 20 --quiet soccer_4cif.y4m -o /dev/null --threads 2' (3 runs):

     130.624286  task-clock-msecs         #      1.496 CPUs    ( +-   0.081% )
             74  context-switches         #      0.001 M/sec   ( +-   7.151% )
              3  CPU-migrations           #      0.000 M/sec   ( +-  25.000% )
           2987  page-faults              #      0.023 M/sec   ( +-   0.162% )
      389234822  cycles                   #   2979.804 M/sec   ( +-   0.081% )
      481360693  instructions             #      1.237 IPC     ( +-   0.036% )
        4206296  cache-references         #     32.201 M/sec   ( +-   0.387% )
          55732  cache-misses             #      0.427 M/sec   ( +-   0.529% )

    0.087336553  seconds time elapsed   ( +-   0.100% )

Note that perf stat will run fine on older [pre-2.6.31] kernels too (it will 
measure elapsed time) and even there it will be much more precise than 
/usr/bin/time.

For more dTLB details, use something like:

 perf stat -e cycles -e instructions -e dtlb-loads -e dtlb-load-misses --repeat 3 x264 ...

Yes, i know we had a big flamewar about perf kvm, but IMHO that is no reason 
for you to pretend that this tool doesnt exist ;-)

> > I'm also curious how it compares for --preset ultrafast and so forth.
> 
> Is this something realistic or just a benchmark thing?

I'd suggest for you to use the default settings, to make it realistic. (Maybe 
also 'advanced/high-quality' settings that an advanced user would utilize.)

It is no doubt that benchmark advantages can be shown - the point of this 
exercise is to show that there are real-life speedups to various categories of 
non-server apps that hugetlb gives us.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
