Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 113E66B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 01:25:56 -0500 (EST)
Received: by pfu207 with SMTP id 207so21310965pfu.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 22:25:55 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id q11si17238516pfi.218.2015.12.03.22.25.55
        for <linux-mm@kvack.org>;
        Thu, 03 Dec 2015 22:25:55 -0800 (PST)
Date: Fri, 4 Dec 2015 14:25:52 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151204062552.GA2243@aaronlu.sh.intel.com>
References: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449130247-8040-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On Thu, Dec 03, 2015 at 09:10:44AM +0100, Vlastimil Babka wrote:
> Aaron, could you try this on your testcase?

One time result isn't stable enough, so I did 9 runs for each commit,
here is the result:

base: 25364a9e54fb8296837061bf684b76d20eec01fb
head: 7433b1009ff5a02e1e9f3444802daba2cf385d27
(head =  base + this_patch_serie)

The always-always case(transparent_hugepage set to always and defrag set
to always):

Result for base:
$ cat {0..8}/swap
cmdline: /lkp/aaron/src/bin/usemem 100000622592
100000622592 transferred in 103 seconds, throughput: 925 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99999559680
99999559680 transferred in 92 seconds, throughput: 1036 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99996171264
99996171264 transferred in 92 seconds, throughput: 1036 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100005663744
100005663744 transferred in 150 seconds, throughput: 635 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100002966528
100002966528 transferred in 87 seconds, throughput: 1096 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99995784192
99995784192 transferred in 131 seconds, throughput: 727 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100003731456
100003731456 transferred in 97 seconds, throughput: 983 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100006440960
100006440960 transferred in 109 seconds, throughput: 874 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99998813184
99998813184 transferred in 122 seconds, throughput: 781 MB/s
Max: 1096 MB/s
Min: 635 MB/s
Avg: 899 MB/s

Result for head:
$ cat {0..8}/swap
cmdline: /lkp/aaron/src/bin/usemem 100003163136
100003163136 transferred in 105 seconds, throughput: 908 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99998524416
99998524416 transferred in 78 seconds, throughput: 1222 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99993646080
99993646080 transferred in 108 seconds, throughput: 882 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99998936064
99998936064 transferred in 114 seconds, throughput: 836 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100002204672
100002204672 transferred in 73 seconds, throughput: 1306 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99998140416
99998140416 transferred in 146 seconds, throughput: 653 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100002941952
100002941952 transferred in 78 seconds, throughput: 1222 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99996917760
99996917760 transferred in 109 seconds, throughput: 874 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100001405952
100001405952 transferred in 96 seconds, throughput: 993 MB/s
Max: 1306 MB/s
Min: 653 MB/s
Avg: 988 MB/s

Result for v4.3 as a reference:
$ cat {0..8}/swap
cmdline: /lkp/aaron/src/bin/usemem 100002459648
100002459648 transferred in 96 seconds, throughput: 993 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99997375488
99997375488 transferred in 96 seconds, throughput: 993 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99999028224
99999028224 transferred in 107 seconds, throughput: 891 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100000137216
100000137216 transferred in 91 seconds, throughput: 1047 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100003835904
100003835904 transferred in 80 seconds, throughput: 1192 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100000143360
100000143360 transferred in 96 seconds, throughput: 993 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100020593664
100020593664 transferred in 101 seconds, throughput: 944 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100005805056
100005805056 transferred in 87 seconds, throughput: 1096 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100008360960
100008360960 transferred in 74 seconds, throughput: 1288 MB/s
Max: 1288 MB/s
Min: 891 MB/s
Avg: 1048 MB/s

The always-never case:

Result for head:
$ cat {0..8}/swap
cmdline: /lkp/aaron/src/bin/usemem 100003940352
100003940352 transferred in 71 seconds, throughput: 1343 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100007411712
100007411712 transferred in 62 seconds, throughput: 1538 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100001875968
100001875968 transferred in 64 seconds, throughput: 1490 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100003912704
100003912704 transferred in 62 seconds, throughput: 1538 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100002238464
100002238464 transferred in 66 seconds, throughput: 1444 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100003670016
100003670016 transferred in 65 seconds, throughput: 1467 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99998364672
99998364672 transferred in 68 seconds, throughput: 1402 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100005417984
100005417984 transferred in 70 seconds, throughput: 1362 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100005304320
100005304320 transferred in 64 seconds, throughput: 1490 MB/s
Max: 1538 MB/s
Min: 1343 MB/s
Avg: 1452 MB/s

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
