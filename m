Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18FF46B026C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:08:43 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so308781043pgc.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:08:43 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z20si26449043pgn.201.2017.01.26.05.08.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 05:08:42 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0QD8ZNK115960
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:08:41 -0500
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0a-001b2d01.pphosted.com with ESMTP id 287b7tebp9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 08:08:41 -0500
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jan 2017 13:08:36 -0000
Date: Thu, 26 Jan 2017 15:08:32 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [LSF/MM ATTEND] userfaultfd
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Message-Id: <20170126130831.GA28055@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hello,

I'm working on integration of userfaultfd into CRIU. Currently we can
perform lazy restore and post-copy migration with the help of
userfaultfd, but there are some limitations because of incomplete
in-kernel support for non-cooperative mode of userfaultfd.

I'd like to particpate in userfaultfd-WP discussion suggested by
Andrea Acangeli [1].
Besides, I would like to broaden userfaultfd discussion so it will
also cover the following topics:

* Non-cooperative userfaultfd APIs for checkpoint/restore

Checkpoint/restore of an application that uses userfaultfd will
require additions to the userfaultfd API. The new APIs are needed to
allow saving parts of in-kernel state of userfaultfd during checkpoint
and then recreating this state during restore.

* Userfaultfd and COW-sharing.

If we have two tasks that fork()-ed from each other and we try to
lazily restore a page that is still COW-ed between them, the uffd API
doesn't give us anything to do it. So we effectively break COW on lazy
restore.

* Userfaultfd "nesting" [2]

CRIU uses soft-dirty to track memory changes. We would like to switch
to userfaultfd-WP once it gets merged. If the process for which we are
tracking memory changes uses userfaultfd, we would need some notion of
uffd "nesting", so that the same memory region could be monitored by
different userfault file descriptors. Even more interesting case is
tracking memory changes of two different processes: one process that
has memory regions monitored by uffd and another one that owns the
non-cooperative userfault file descriptor to monitor the first
process.
The userfaultfd "nesting" is also required for lazy restore scenario so
that CRIU will be able to use userfaultfd for memory ranges that the
restored application is already managing with userfaultfd.

[1] http://www.spinics.net/lists/linux-mm/msg119866.html
[2] https://www.spinics.net/lists/linux-mm/msg112500.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
