Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1616B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 16:00:13 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so19801098pad.1
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 13:00:13 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id nr8si3229866pdb.5.2015.01.15.13.00.10
        for <linux-mm@kvack.org>;
        Thu, 15 Jan 2015 13:00:11 -0800 (PST)
Message-ID: <54B82A57.9060000@intel.com>
Date: Thu, 15 Jan 2015 13:00:07 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: [LSF/MM TOPIC] Reclaim in the face of really fast I/O
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, lsf-pc@lists.linux-foundation.org, "Reddy, Dheeraj" <dheeraj.reddy@intel.com>
Cc: "Kleen, Andi" <andi.kleen@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, Linux-MM <linux-mm@kvack.org>

I/O devices are only getting faster.  In fact, they're getting closer
and closer to memory in latency and bandwidth.  But the VM is still
designed to do very orderly and costly procedures to reclaim memory, and
the existing algorithms don't parallelize particularly well.  They hit
contention on mmap_sem or the lru locks well before all of the CPU
horsepower that we have can be brought to bear on reclaim.

Once the latency to bring pages in and out of storage becomes low
enough, reclaiming the _right_ pages becomes much less important than
doing something useful with the CPU horsepower that we have.

We need to talk about ways to do reclaim with lower CPU overhead and to
parallelize more effectively.

There has been some research in this area by some folks at Intel and we
could quickly summarize what has been learned so far to help kick off a
discussion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
