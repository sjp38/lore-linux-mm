Date: Fri, 20 Jan 2006 12:25:04 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Lhms-devel] Re: [PATCH 0/5] Reducing fragmentation using zones
In-Reply-To: <20060120210353.1269.Y-GOTO@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.58.0601201216280.14292@skynet>
References: <43D03C24.5080409@jp.fujitsu.com> <Pine.LNX.4.58.0601200934300.10920@skynet>
 <20060120210353.1269.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Joel Schopp <jschopp@austin.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Fri, 20 Jan 2006, Yasunori Goto wrote:

> > What sort of tests would you suggest? The tests I have been running to
> > date are
> >
> > "kbuild + aim9" for regression testing
> >
> > "updatedb + 7 -j1 kernel compiles + highorder allocation" for seeing how
> > easy it was to reclaim contiguous blocks
>
> BTW, is "highorder allocation test" your original test code?
> If so, just my curious, I would like to see it too. ;-).
>

1. Download http://www.csn.ul.ie/~mel/projects/vmregress/vmregress-0.20.tar.gz
2. Extract it to /usr/src/vmregress (i.e. there should be a
   /usr/src/vmregress/bin directory)
3. Download linux-2.6.11.tar.gz to /usr/src
4. Make a directory /usr/src/bench-stresshighalloc-test
5. cd to /usr/src/vmregress and run 3. cd to the directory and run
   ./configure --with-linux=/path/to/running/kernel
   make

5. Run the test
   bench-stresshighalloc.sh -z -k 6 --oprofile

   -z Will test using high memory
   -k 6 will build 1 kernel + 6 additional ones
   By default, it will try and allocate 275 order-10 pages. Specify the
   number of pages with -c and the order with -s

The paths above are default paths. They can all be overridden with command
line parameters like -t to specify a different kernel to use and -b to
specify a different path to build all the kernels in.

By default, the results will be logged to a directory whose name is based
on the kernel being tested. For example, one result directory is
~/vmregressbench-2.6.16-rc1-mm1-clean/highalloc-heavy/log.txt

Comparisions between different runs can be analysed by using
diff-highalloc.sh. e.g.

diff-highalloc.sh vmregressbench-2.6.16-rc1-mm1-clean vmregressbench-2.6.16-rc1-mm1-mbuddy-v22

If you want to test just high-order allocations while some other workload
is running, use bench-plainhighalloc.sh. See --help for a list of
available options.

If you want to use bench-aim9.sh, download and build aim9 in /usr/src/aim9
and edit the s9workfile to specify the tests you are interested in. Use
diff-aim9.sh to compare different runs of aim9.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
