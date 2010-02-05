Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4136C6B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 21:28:29 -0500 (EST)
Message-ID: <4B6B7FBF.9090005@bx.jp.nec.com>
Date: Thu, 04 Feb 2010 21:17:35 -0500
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 0/2 v3] pagecache tracepoints proposal
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, mingo@elte.hu
Cc: lwoodman@redhat.com, linux-mm@kvack.org, Tom Zanussi <tzanussi@gmail.com>, riel@redhat.com, rostedt@goodmis.org, akpm@linux-foundation.org, fweisbec@gmail.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>, Keiichi KII <k-keiichi@bx.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Hello,

This is v3 of a patchset to add some tracepoints for pagecache.

I would propose several tracepoints for tracing pagecache behavior and
a script for these.
By using both the tracepoints and the script, we can analysis pagecache behavior
like usage or hit ratio with high resolution like per process or per file. 
Example output of the script looks like:

[process list]
o yum-3215
                          cache find  cache hit  cache hit
        device      inode      count      count      ratio
  --------------------------------------------------------
         253:0         16      34434      34130     99.12%
         253:0        198       9692       9463     97.64%
         253:0        639        647        628     97.06%
         253:0        778         32         29     90.62%
         253:0       7305      50225      49005     97.57%
         253:0     144217         12         10     83.33%
         253:0     262775         16         13     81.25%
*snip*

-------------------------------------------------------------------------------

[file list]
        device              cached
     (maj:min)      inode    pages
  --------------------------------
         253:0         16     5752
         253:0        198     2233
         253:0        639       51
         253:0        778       86
         253:0       7305    12307
         253:0     144217       11
         253:0     262775       39
*snip*

[process list]
o yum-3215
        device              cached    added  removed      indirect
     (maj:min)      inode    pages    pages    pages removed pages
  ----------------------------------------------------------------
         253:0         16    34130     5752        0             0
         253:0        198     9463     2233        0             0
         253:0        639      628       51        0             0
         253:0        778       29       78        0             0
         253:0       7305    49005    12307        0             0
         253:0     144217       10       11        0             0
         253:0     262775       13       39        0             0
*snip*
  ----------------------------------------------------------------
  total:                    102346    26165        1             0

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

Especially, the monitoring pagecache usage per each file and pagecache hit 
ratio would help us tune some applications like database.
And it will also help us tune the kernel parameters like "vm.dirty_*".

Changelog since v2
  o add new script to monitor pagecache hit ratio per process.
  o use DECLARE_EVENT_CLASS

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
