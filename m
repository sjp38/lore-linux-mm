Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FAA26B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 08:21:44 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id x1so1386049lff.6
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 05:21:44 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id f70si6520744lfe.108.2017.02.09.05.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Feb 2017 05:21:42 -0800 (PST)
From: peter enderborg <peter.enderborg@sonymobile.com>
Subject: [PATCH 0/3 staging-next] android: Lowmemmorykiller task tree
Message-ID: <df828d70-3962-2e43-0512-1777a9842bb2@sonymobile.com>
Date: Thu, 9 Feb 2017 14:21:40 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

Lowmemorykiller efficiency problem and a solution.

Lowmemorykiller in android has a severe efficiency problem. The basic
problem is that the registered shrinker gets called very often without
  anything actually happening. This is in some cases not a problem as
it is a simple calculation that returns a value. But when there is
high pressure on memory and we get to start killing processes to free
memory we get some heavy work that does lots of cpu processing and
lock holding for no real benefit. This occurs when we are below the
first threshold level in minfree. We call that waste. To see this
problem we introduce a patch that collects statistics from
lowmemorykiller. We collect the amount of kills, scans, counts and
some other metrics. One of this metrics is called waste. These metrics
are presented in procfs as /proc/lmkstats.

Patchset:
0001-android-Collect-statistics-from-lowmemorykiller.patch
0002-oom-Add-notification-for-oom_score_adj.patch
0003-mm-Remove-RCU-and-tasklocks-from-lmk.patch


Collect-statistics-from-lowmemorykiller.patch
---------------------------------------------
This patch only adds metrics and is there to show
behavour before and after and is a good way to
see that the device is in waste zone.


0002-oom-Add-notification-for-oom_score_adj.patch
------------------------------------------------
This is the prerequisite patch to be able to do
the lowmemorykiller change. It introduces notifiers
for oom_score_adj. It generates notifier events for
process creation and death, and when process values
are changed.  These patches are outside from stageing
drivers and are applied to core functions in e.g. fork.c.

0003-mm-Remove-RCU-and-tasklocks-from-lmk.patch
-----------------------------------------------
This patch is the change of lowmemorykiller. It
builds a tree structure that works as cache for
the task list, but only contains the tasks that
are relevant for the lmk. The key thing here is
that the cache is sorted based on the oom_score_adj
value so the scan and count function can find
the right task with only a tree first operation.
Based on the right task the count can give a
proper reply and give a right estimate of the
amount it will free, and more important when
it is not willing to free anything. This makes
the shrinker not to call the scan function at all,
and when it is called it actually do what it's
supposed to do that is to free up some memory.
I consider this as mm based on the behaviour
changes for the shrinker even if the code is
a driver.

About testing.
Reproduce the problem. For this the first patch is needed and enabeld.
It does not change the lowmemory killer other than it add some metrics.
One counter is called WASTE. This is what this patch-set is about.
In android environment this can be tested directly. On other systems
like fedora a method using the stress package can be used. Apply the
patches. (First with only metrics) then in your

shell: echo 400 > /proc/self/oom_score_adj

Now you have created a shell that has something that can be killed.
In the same shell use stress program. The parameters will be very
dependent on your configuration, but you need to run out of memmory.

Most of the wasted cpu cycles are accounted in kswapd0 task so a compare
of the reduced waste can also be seen in the schedstat for that task.
However activitymanager will get some more work done in kernel space.
Finaly the new version also has the WASTE counter, but this one is
the cost of only a rbtree search.

Cost/Drawback
The impact on the fork call is on a 2ghz arm64 is about 500ns for the
notifier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
