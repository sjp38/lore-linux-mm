Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 714B56B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 02:29:19 -0500 (EST)
Date: Fri, 5 Feb 2010 08:28:58 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC PATCH -tip 0/2 v3] pagecache tracepoints proposal
Message-ID: <20100205072858.GC9320@elte.hu>
References: <4B6B7FBF.9090005@bx.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B6B7FBF.9090005@bx.jp.nec.com>
Sender: owner-linux-mm@kvack.org
To: Keiichi KII <k-keiichi@bx.jp.nec.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jason Baron <jbaron@redhat.com>, Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>
Cc: linux-kernel@vger.kernel.org, lwoodman@redhat.com, linux-mm@kvack.org, Tom Zanussi <tzanussi@gmail.com>, riel@redhat.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>


* Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:

> Hello,
> 
> This is v3 of a patchset to add some tracepoints for pagecache.
> 
> I would propose several tracepoints for tracing pagecache behavior and
> a script for these.
> By using both the tracepoints and the script, we can analysis pagecache behavior
> like usage or hit ratio with high resolution like per process or per file. 
> Example output of the script looks like:
> 
> [process list]
> o yum-3215
>                           cache find  cache hit  cache hit
>         device      inode      count      count      ratio
>   --------------------------------------------------------
>          253:0         16      34434      34130     99.12%
>          253:0        198       9692       9463     97.64%
>          253:0        639        647        628     97.06%
>          253:0        778         32         29     90.62%
>          253:0       7305      50225      49005     97.57%
>          253:0     144217         12         10     83.33%
>          253:0     262775         16         13     81.25%
> *snip*
> 
> -------------------------------------------------------------------------------
> 
> [file list]
>         device              cached
>      (maj:min)      inode    pages
>   --------------------------------
>          253:0         16     5752
>          253:0        198     2233
>          253:0        639       51
>          253:0        778       86
>          253:0       7305    12307
>          253:0     144217       11
>          253:0     262775       39
> *snip*
> 
> [process list]
> o yum-3215
>         device              cached    added  removed      indirect
>      (maj:min)      inode    pages    pages    pages removed pages
>   ----------------------------------------------------------------
>          253:0         16    34130     5752        0             0
>          253:0        198     9463     2233        0             0
>          253:0        639      628       51        0             0
>          253:0        778       29       78        0             0
>          253:0       7305    49005    12307        0             0
>          253:0     144217       10       11        0             0
>          253:0     262775       13       39        0             0
> *snip*
>   ----------------------------------------------------------------
>   total:                    102346    26165        1             0
> 
> We can now know system-wide pagecache usage by /proc/meminfo.
> But we have no method to get higher resolution information like per file or
> per process usage than system-wide one.
> A process may share some pagecache or add a pagecache to the memory or
> remove a pagecache from the memory.
> If a pagecache miss hit ratio rises, maybe it leads to extra I/O and
> affects system performance.
> 
> So, by using the tracepoints we can get the following information.
>  1. how many pagecaches each process has per each file
>  2. how many pages are cached per each file
>  3. how many pagecaches each process shares
>  4. how often each process adds/removes pagecache
>  5. how long a pagecache stays in the memory
>  6. pagecache hit rate per file
> 
> Especially, the monitoring pagecache usage per each file and pagecache hit 
> ratio would help us tune some applications like database.
> And it will also help us tune the kernel parameters like "vm.dirty_*".
> 
> Changelog since v2
>   o add new script to monitor pagecache hit ratio per process.
>   o use DECLARE_EVENT_CLASS
> 
> Changelog since v1
>   o Add a script based on "perf trace stream scripting support".
> 
> Any comments are welcome.

Looks really nice IMO! It also demonstrates nicely the extensibility via 
Tom's perf trace scripting engine. (which will soon get a Python script 
engine as well, so Perl and C wont be the only possibility to extend perf 
with.)

I've Cc:-ed a few parties who might be interested in this. Wu Fengguang has 
done MM instrumentation in this area before - there might be some common 
ground instead of scattered functionality in /proc, debugfs, perf and 
elsewhere?

Note that there's also these older experimental commits in tip:tracing/mm 
that introduce the notion of 'object collections' and adds the ability to 
trace them:

3383e37: tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
c33b359: tracing, page-allocator: Add trace event for page traffic related to the buddy lists
0d524fb: tracing, mm: Add trace events for anti-fragmentation falling back to other migratetypes
b9a2817: tracing, page-allocator: Add trace events for page allocation and page freeing
08b6cb8: perf_counter tools: Provide default bfd_demangle() function in case it's not around
eb46710: tracing/mm: rename 'trigger' file to 'dump_range'
1487a7a: tracing/mm: fix mapcount trace record field
dcac8cd: tracing/mm: add page frame snapshot trace

this concept, if refreshed a bit and extended to the page cache, would allow 
the recording/snapshotting of the MM state of all currently present pages in 
the page-cache - a possibly nice addition to the dynamic technique you apply 
in your patches.

there's similar "object collections" work underway for 'perf lock' btw., by 
Hitoshi Mitake and Frederic.

So there's lots of common ground and lots of interest.

Btw., instead of "perf trace record pagecache-usage", you might want to think 
about introducing a higher level tool as well: 'perf mm' or 'perf pagecache' 
- just like we have 'perf kmem' for SLAB instrumentation, 'perf sched' for 
scheduler instrumentation and 'perf lock' for locking instrumentation. [with 
'perf timer' having been posted too.]

'perf mm' could then still map to Perl scripts, it's just a convenience. It 
could then harbor other MM related instrumentation bits as well. Just an idea 
- this is a possibility, if you are trying to achieve higher organization.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
