Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 536066B0106
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 17:32:20 -0400 (EDT)
Message-ID: <4E24A61D.4060702@bx.jp.nec.com>
Date: Mon, 18 Jul 2011 17:31:09 -0400
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 0/5] perf tools: pagecache monitoring
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, Keiichi KII <k-keiichi@bx.jp.nec.com>, Wu Fengguang <fengguang.wu@intel.com>, "BA, Moussa" <Moussa.BA@numonyx.com>

Hello,

I would propose pagecache monitoring tools using perf tools.
The purpose of the tools is to clarify pagecache behavior in a system.

We can now know system-wide pagecache usage by "/proc/meminfo".
But we don't have any way to get higher resolution information like
per file or per process usage than system-wide one.
If pagecache miss hit ratio rises due to unnecessary adding/removing
pagecaches, maybe it leads to extra I/O and affects system performance.
But it's difficult to find out what is going on in the system.

So, the tools I propose provide 2 functions:

1. pagecache snapshooting(perf script pagecache-snapshoot)

This function clarifies pagecache usage per each file in the system.
This function is based mainly on "pagecache object collections" that is
developed by Wu Fengguang (http://lkml.org/lkml/2010/2/9/156).
The following is sample output of this function.

pagecache snapshooting (time: 14131, path: /home)
                             file name cache(B)  file(B)  ratio  +/-(B)    age
-------------------------------------- -------- -------- ------ ------- ------
/home/foo/git/linux-2.6-tip/.git/objec    71.0M   436.6M    16%       0   9012
/home/foo/git/linux-2.6-tip/.git/objec    49.6M    57.7M    86%       0   9012
/home/foo/.thunderbird/xso5zn7g.defaul    19.8M    19.8M   100%       0   7223
/home/foo/.thunderbird/xso5zn7g.defaul     5.7M     5.7M   100%       0   6621
/home/foo/git/linux-2.6-tip/.git/index     3.5M     3.5M   100%       0   4306
/home/foo/.thunderbird/xso5zn7g.defaul     2.2M     2.2M   100%       0   7524
/home/foo/.thunderbird/xso5zn7g.defaul     2.2M     2.2M   100%       0   7526
/home/foo/.thunderbird/xso5zn7g.defaul     1.7M     1.7M   100%       0   6921
...

2. continuous pagecache monitoring(perf script pagecachetop)

This function clarifies pagecache behavior like pagecache hit ratio and
added/removed pagecache amount on the basis of file/process.
This functions is based on pagecache tracepoints I propose.
While the pagecache snapshooting can take a pagecache snapshoot at a point,
the continuous pagecache monitoring can measure dynamic change between
2 snapshoots.
The following is sample output of this function.

pagecache behavior per file (time:15826, interval:10)

                         find        hit    cache      add   remove  proc
                file    count      ratio pages(B) pages(B) pages(B) count
-------------------- -------- ---------- -------- -------- -------- -----
        libc-2.13.so      620    100.00%     1.2M        0        0     7
                bash      283    100.00%   888.0K        0        0     6
          ld-2.13.so      136    100.00%   148.0K        0        0     6
                gawk      130    100.00%   376.0K        0        0     2
         ld.so.cache       60    100.00%   116.0K        0        0     4
...

pagecache behavior per process (time:16294, interval:10)

                         find        hit      add   remove  file
             process    count      ratio pages(B) pages(B) count
-------------------- -------- ---------- -------- -------- -----
            zsh-7761     2968     99.93%     4.0K        0   246
           perf-7758      369    100.00%        0        0    17
           xmms-7634       52    100.00%        0        0     1
           perf-7759       11    100.00%        0        0     2
            zsh-2815        6     83.33%     4.0K     4.0K     2
       gconfd-2-4849        3      0.00%    12.0K    12.0K     4
       rsyslogd-7194        1    100.00%        0        0     1


By these 2 functions, we can find out whether pagecaches are used
efficiently or not.
And also these tools would help us tune some applications like database.
It will also help us tune the kernel parameters like "vm.dirty_*".

My patches are based on the latest "linux-tip.git" tree and
also the following 3 commits in "tip:tracing/mm" and a "pagecache
object collections" patch. 

  - dcac8cd: tracing/mm: add page frame snapshot trace
  - 1487a7a: tracing/mm: fix mapcount trace record field
  - eb46710: tracing/mm: rename 'trigger' file to 'dump_range'
  - http://lkml.org/lkml/2010/2/9/156

Any comments are welcome.
--
Keiichi Kii <k-keiichi@bx.jp.nec.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
