Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 83FB76B004D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 21:44:24 -0400 (EDT)
Date: Wed, 20 May 2009 09:44:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class  citizen
Message-ID: <20090520014445.GA7645@localhost>
References: <20090519161756.4EE4.A69D9226@jp.fujitsu.com> <20090519074925.GA690@localhost> <20090519170208.742C.A69D9226@jp.fujitsu.com> <20090519085354.GB2121@localhost> <2f11576a0905190528n5eb29e3fme42785a76eed3551@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f11576a0905190528n5eb29e3fme42785a76eed3551@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Tue, May 19, 2009 at 08:28:28PM +0800, KOSAKI Motohiro wrote:
> Hi
> 
> 2009/5/19 Wu Fengguang <fengguang.wu@intel.com>:
> > On Tue, May 19, 2009 at 04:06:35PM +0800, KOSAKI Motohiro wrote:
> >> > > > Like the console mode, the absolute nr_mapped drops considerably - to 1/13 of
> >> > > > the original size - during the streaming IO.
> >> > > >
> >> > > > The delta of pgmajfault is 3 vs 107 during IO, or 236 vs 393 during the whole
> >> > > > process.
> >> > >
> >> > > hmmm.
> >> > >
> >> > > about 100 page fault don't match Elladan's problem, I think.
> >> > > perhaps We missed any addional reproduce condition?
> >> >
> >> > Elladan's case is not the point of this test.
> >> > Elladan's IO is use-once, so probably not a caching problem at all.
> >> >
> >> > This test case is specifically devised to confirm whether this patch
> >> > works as expected. Conclusion: it is.
> >>
> >> Dejection ;-)
> >>
> >> The number should address the patch is useful or not. confirming as expected
> >> is not so great.
> >
> > OK, let's make the conclusion in this way:
> >
> > The changelog analyzed the possible beneficial situation, and this
> > test backs that theory with real numbers, ie: it successfully stops
> > major faults when the active file list is slowly scanned when there
> > are partially cache hot streaming IO.
> >
> > Another (amazing) finding of the test is, only around 1/10 mapped pages
> > are actively referenced in the absence of user activities.
> >
> > Shall we protect the remaining 9/10 inactive ones? This is a question ;-)
> 
> Unfortunately, I don't reproduce again.
> I don't apply your patch yet. but mapped ratio is reduced only very little.

mapped ratio or absolute numbers? The ratio wont change much because
nr_mapped is already small.

> I think smem can show which library evicted.  Can you try it?
> 
> download:  http://www.selenic.com/smem/
> usage:   ./smem -m -r --abbreviate

Sure, but I don't see much change in its output (see attachments).

smem-console-0 is collected after fresh boot,
smem-console-1 is collected after the big IO.

> We can't decide 9/10 is important or not. we need know actual evicted file list.

Right. But what I measured is the activeness. Almost zero major page
faults means the evicted 90% mapped pages are inactive during the
long 300 seconds of IO.

Thanks,
Fengguang

> > Or, shall we take the "protect active VM_EXEC mapped pages" approach,
> > or Christoph's "protect all mapped pages all time, unless they grow
> > too large" attitude? A I still prefer the best effort VM_EXEC heuristics.
> >
> > 1) the partially cache hot streaming IO is far more likely to happen
> > A  on (file) servers. For them, evicting the 9/10 inactive mapped
> > A  pages over night should be acceptable for sysadms.
> >
> > 2) for use-once IO on desktop, we have Rik's active file list
> > A  protection heuristics, so nothing to worry at all.
> >
> > 3) for big working set small memory desktop, the active list will
> > A  still be scanned, in this situation, why not evict some of the
> > A  inactive mapped pages? If they have not been accessed for 1 minute,
> > A  they are not likely be the user focus, and the tight memory
> > A  constraint can only afford to cache the user focused working set.
> >
> > Does that make sense?

--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=smem-console-0

Map                                       PIDs   AVGPSS      PSS 
[heap]                                       2     1.5M     2.9M 
<anonymous>                                  2   538.0K     1.1M 
/usr/bin/python2.5                           1     1.0M     1.0M 
/bin/zsh4                                    1   592.0K   592.0K 
/usr/lib/zsh/4.3.9/zsh/zle.so                1   216.0K   216.0K 
/lib/libncursesw.so.5.7                      1   156.0K   156.0K 
/lib/libc-2.9.so                             2    65.0K   130.0K 
[stack]                                      2    62.0K   124.0K 
/usr/lib/zsh/4.3.9/zsh/complete.so           1    56.0K    56.0K 
/usr/lib/locale/locale-archive               2    28.0K    56.0K 
/usr/lib/python2.5/lib-dynload/operator.     1    32.0K    32.0K 
/lib/libm-2.9.so                             2    15.0K    30.0K 
/usr/lib/zsh/4.3.9/zsh/complist.so           1    28.0K    28.0K 
/lib/ld-2.9.so                               2    13.0K    26.0K 
/usr/lib/zsh/4.3.9/zsh/parameter.so          1    24.0K    24.0K 
/usr/lib/python2.5/lib-dynload/_struct.s     1    24.0K    24.0K 
/usr/lib/zsh/4.3.9/zsh/zutil.so              1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/time.so       1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/strop.so      1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/_locale.s     1    20.0K    20.0K 
/lib/libpthread-2.9.so                       1    18.0K    18.0K 
/lib/libdl-2.9.so                            2     9.0K    18.0K 
/usr/lib/zsh/4.3.9/zsh/rlimits.so            1    16.0K    16.0K 
/lib/libcap.so.2.11                          1    16.0K    16.0K 
/lib/libattr.so.1.1.0                        1    16.0K    16.0K 
/usr/lib/zsh/4.3.9/zsh/terminfo.so           1    12.0K    12.0K 
/usr/lib/python2.5/lib-dynload/grp.so        1    12.0K    12.0K 
/lib/libutil-2.9.so                          1    11.0K    11.0K 
/lib/libnss_nis-2.9.so                       1    11.0K    11.0K 
/lib/libnss_files-2.9.so                     1    10.0K    10.0K 
/lib/libnss_compat-2.9.so                    1    10.0K    10.0K 
/lib/libnsl-2.9.so                           1    10.0K    10.0K 
/usr/lib/gconv/gconv-modules.cache           1     5.0K     5.0K 
[vsyscall]                                   2        0        0 
[vdso]                                       2        0        0 

--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=smem-console-1

Map                                       PIDs   AVGPSS      PSS 
[heap]                                       2     1.5M     2.9M 
<anonymous>                                  2   538.0K     1.1M 
/usr/bin/python2.5                           1     1.0M     1.0M 
/bin/zsh4                                    1   496.0K   496.0K 
/lib/libc-2.9.so                             2   180.0K   360.0K 
[stack]                                      2    60.0K   120.0K 
/lib/ld-2.9.so                               2    58.0K   116.0K 
/usr/lib/zsh/4.3.9/zsh/zle.so                1   112.0K   112.0K 
/lib/libncursesw.so.5.7                      1    56.0K    56.0K 
/usr/lib/locale/locale-archive               2    26.0K    52.0K 
/lib/libpthread-2.9.so                       1    48.0K    48.0K 
/lib/libm-2.9.so                             2    21.0K    42.0K 
/usr/lib/python2.5/lib-dynload/operator.     1    32.0K    32.0K 
/usr/lib/zsh/4.3.9/zsh/complete.so           1    24.0K    24.0K 
/usr/lib/python2.5/lib-dynload/_struct.s     1    24.0K    24.0K 
/lib/libdl-2.9.so                            2    12.0K    24.0K 
/usr/lib/python2.5/lib-dynload/time.so       1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/strop.so      1    20.0K    20.0K 
/usr/lib/python2.5/lib-dynload/_locale.s     1    20.0K    20.0K 
/lib/libutil-2.9.so                          1    16.0K    16.0K 
/usr/lib/python2.5/lib-dynload/grp.so        1    12.0K    12.0K 
/lib/libcap.so.2.11                          1    12.0K    12.0K 
/lib/libnss_compat-2.9.so                    1     9.0K     9.0K 
/usr/lib/zsh/4.3.9/zsh/zutil.so              1     8.0K     8.0K 
/usr/lib/zsh/4.3.9/zsh/rlimits.so            1     8.0K     8.0K 
/lib/libnss_nis-2.9.so                       1     8.0K     8.0K 
/lib/libnss_files-2.9.so                     1     8.0K     8.0K 
/lib/libnsl-2.9.so                           1     8.0K     8.0K 
/usr/lib/zsh/4.3.9/zsh/terminfo.so           1     4.0K     4.0K 
/usr/lib/zsh/4.3.9/zsh/parameter.so          1     4.0K     4.0K 
/usr/lib/zsh/4.3.9/zsh/complist.so           1     4.0K     4.0K 
/lib/libattr.so.1.1.0                        1     4.0K     4.0K 
[vsyscall]                                   2        0        0 
[vdso]                                       2        0        0 
/usr/lib/gconv/gconv-modules.cache           1        0        0 

--J/dobhs11T7y2rNN--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
