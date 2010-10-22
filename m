Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A63F6B0087
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 15:03:11 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o9MJ365e010565
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:03:07 -0700
Received: from wyb42 (wyb42.prod.google.com [10.241.225.106])
	by hpaq7.eem.corp.google.com with ESMTP id o9MJ35B1004871
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:03:05 -0700
Received: by wyb42 with SMTP id 42so1155415wyb.13
        for <linux-mm@kvack.org>; Fri, 22 Oct 2010 12:03:05 -0700 (PDT)
Subject: VFS scaling evaluation results, redux.
From: Frank Mayhar <fmayhar@google.com>
In-Reply-To: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
References: <1286580739.3153.57.camel@bobble.smo.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Oct 2010 12:03:00 -0700
Message-ID: <1287774180.23017.228.camel@bobble.smo.corp.google.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: mrubin@google.com, ext4-team@google.com
List-ID: <linux-mm.kvack.org>

After seeing the newer work a couple of weeks ago, I decided to rerun
the tests against Dave Chinner's tree just to see how things fare with
his changes.  This time I only ran the "socket test" due to time
constraints and since the "storage test" didn't produce anything
particularly interesting last time.

Unfortunately I was unable to use the hardware I used previously so I
reran the test against both the 2.6.35 base and 2.6.35 plus Nick's
changes in addition to the 2.6.36 base and Dave's version of same.  The
changed hardware changed the absolute test results substantially, so I'm
making no comparisons with the previous runs.

Once more I ran a a??socket testa?? on systems with a moderate number of
cores and memory (unfortunately I cana??t say more about the hardware).  I
gathered test results and kernel profiling data for each. 

The "Socket Test" does a lot of socket operations; it fields lots of
connections, receiving and transmitting small amounts of data over each.
The application it emulates has run into bottlenecks on the dcache_lock
and the inode_lock several times in the past, which is why I chose it as
a target.

The test is multithreaded with at least one thread per core and is
designed to put as much load on the application being tested as
possible.  It is in fact designed specifically to find performance
regressions (albeit at a higher level than the kernel), which makes it
very suitable for this testing.

The kernels were very stable; I saw no crashes or hangs during my
testing.

The "Socket Test" has a target rate which I'll refer to as 100%.
Internal Google kernels (with modifications to specific code paths)
allow the test to generally achieve that rate, albeit not without
substantial effort.  Against the base 2.6.35 kernel I saw a rate of
around 13.9%; the modified 2.6.35 kernel had a rate of around 8.38%.
The base 2.6.36 kernel was effectively unchanged relative to the 2.6.35
kernel with a rate of 14.12% and, likewise, the modified 2.6.36 kernel
had a rate of around 9.1%.  In each case the difference is small and
expected given the environment.

The kernel profiles were not nearly as straightforward this time.
Running the test against a base and improved 2.6.35 kernel, there were
some (fairly subtle) improvements with respect to the dcache locking, in
which as before the amount of time there dropped slightly.  This time,
however, both tests spend essentially the same amount of time in locking
primitives.

I compared the 2.6.35 base and 2.6.36 base kernels as well, to see where
improvements might show up without Nick's and Dave's improvements.  I
saw that time spent in locking primitives dropped slightly but
consistently.

Comparing 2.6.36 base and improved kernels, again there seemed to be
some subtle improvements to the dcache locking but otherwise the tests
spent about the same amount of time in the locking primitives.

As before the original profiles are available at
    http://code.google.com/p/vfs-scaling-eval/downloads/list
The newer data is marked as "Socket_test-profile-<kernel
version>-<name>".  Data from the previous evaluation is there as well.
-- 
Frank Mayhar <fmayhar@google.com>
Google Inc.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
