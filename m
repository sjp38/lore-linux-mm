Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 208586B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:44:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 346CD3EE0AE
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:44:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1ABAC45DE84
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:44:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0592445DE80
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:44:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E8436E78003
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:44:38 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A735B1DB8037
	for <linux-mm@kvack.org>; Fri, 20 May 2011 12:44:38 +0900 (JST)
Date: Fri, 20 May 2011 12:37:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 0/8] memcg async reclaim v2
Message-Id: <20110520123749.d54b32fa.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>, hannes@cmpxchg.org, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>


Since v1, I did some brush up and more tests.

main changes are
  - disabled at default
  - add a control file to enable it
  - never allow enabled on UP machine.
  - don't writepage at all (revisit this when dirty_ratio comes.)
  - change handling of priorty and total scan, add more sleep chances.

But yes, maybe some more changes/tests will be needed and I don't want to
rush before next kernel version.

IIUC, what pointed out in previous post was "show numbers". Because this kind of
asyncronous reclaim just increase cpu usage and no help to latency, just makes
scores bad.

I tested with apatch bench in following way.

  1. create cgroup /cgroup/memory/httpd
  2. move httpd under it
  3. create 4096 files under /var/www/html/data
     each file's size is 160kb.
  4. prepare a cgi scipt to acess 4096 files in random as
  ==
  #!/usr/bin/python
  # -*- coding: utf-8 -*-

  import random

  print "Content-Type: text/plain\n\n"

  num = int(round(random.normalvariate(0.5, 0.1) * 4096))
  filename = "/var/www/html/data/" + str(num)

  with open(filename) as f:
         buf = f.read(128*1024)
  print "Hello world  " + str(num) + "\n"
  ==
  This reads random file and returns Hello World. I used "normalvariate()"
  for getting normal distribution access to files.

  By this, 160kb*4096 files of data is accessed in normal distribution.

  5. access files by apatch bench
     # ab -n 40960 -c 4 localhost:8080/cgi-bin/rand.py
 
  This access files 40960 times with concurrency 4.
  And see latency under memory cgroup.

  I run apatch bench 3 times for each test and following scores are score of
  3rd trial, we can think file cache is in good state....
  (But number other than "max" seems to be stable.)

  Note: httpd and apache bench runs on the same host.

A) No limit.

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       2
Processing:    30   32   1.5     32     123
Waiting:       28   31   1.5     31     122
Total:         30   32   1.5     32     123

Percentage of the requests served within a certain time (ms)
  50%     32
  66%     32
  75%     32
  80%     33
  90%     33
  95%     33
  98%     34
  99%     35
 100%    123 (longest request)

If no limit, most of access can be end around 32msecs. After this, I saw
memory.max_usage_in_bytes as mostly 600MB.


B) limit to 300MB and disable async reclaim.

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       1
Processing:    29   35  35.6     31    3507
Waiting:       28   34  33.4     30    3506
Total:         30   35  35.6     31    3507

Percentage of the requests served within a certain time (ms)
  50%     31
  66%     32
  75%     32
  80%     32
  90%     34
  95%     43
  98%     89
  99%    134
 100%   3507 (longest request)

When set limit, "max" latency can take various big value but latency goes
bad. 

C) limit to 300MB and enable async reclaim.

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       2
Processing:    29   33   6.9     32     279
Waiting:       27   32   6.8     31     275
Total:         29   33   6.9     32     279

Percentage of the requests served within a certain time (ms)
  50%     32
  66%     32
  75%     33
  80%     33
  90%     37
  95%     42
  98%     51
  99%     59
 100%    279 (longest request)

It seems latency goes better and stable rather than test B).


If you want to see other numbers/tests, please let me know. set up is easy.

I think automatic asynchronous reclaim works effectively for some class of
applications and stabilize its work.

Thanks,
-Kame










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
