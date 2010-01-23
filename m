Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D26CA6B006A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 19:06:34 -0500 (EST)
Message-ID: <4B5A3D00.8080901@bx.jp.nec.com>
Date: Fri, 22 Jan 2010 19:04:16 -0500
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 0/2 v2] pagecache tracepoints proposal
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: lwoodman@redhat.com, linux-mm@kvack.org, mingo@elte.hu, tzanussi@gmail.com, riel@redhat.com, rostedt@goodmis.org, akpm@linux-foundation.org, fweisbec@gmail.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Hello,

This is v2 of a patchset to add some tracepoints for pagecache.

I would propose several tracepoints for tracing pagecache behaviors and
a script for these.
By using both the tracepoints and the script, we can monitor pagecache usage
with high resolution. Example output of the script looks like:

[file list]
                            cached
        device      inode    pages
  --------------------------------
         253:0    1051413      130
         253:0    1051399        2
         253:0    1051414       44
         253:0    1051417      154

o postmaster-2330
                            cached    added  removed      indirect
        device      inode    pages    pages    pages removed pages
  ----------------------------------------------------------------
         253:0    1051399        0        2        0             0
         253:0    1051417      154        0        0             0
         253:0    1051413      130        0        0             0
         253:0    1051414       44        0        0             0
  ----------------------------------------------------------------
  total:                       337        2        0             0

We can now know system-wide pagecache usage by /proc/meminfo.
But we have no method to get higher resolution information like per file or
per process usage than system-wide one.
A process may share some pagecache or add a pagecache to the memory or
remove a pagecache from the memory.
If a pagecache miss hit ratio rises, maybe it leads to extra I/O and
affects system performance.

So, by using the tracepoints we can get the following information.
 1. how many pagecaches each process has per each file
 2. how many pages are cached per each file
 3. how many pagecaches each process shares
 4. how often each process adds/removes pagecache
 5. how long a pagecache stays in the memory
 6. pagecache hit rate per file

Especially, the monitoring pagecache usage per each file would help us tune
some applications like database.

Changelog since v1
o Add a script based on "perf trace stream scripting support".

Any comments are welcome.
--
Keiichi Kii <k-keiichi@bx.jp.nec.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
