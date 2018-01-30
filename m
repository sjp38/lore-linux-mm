Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75E966B0008
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 15:57:29 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id k188so8032154qkc.18
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 12:57:29 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id r23si326712qtk.471.2018.01.30.12.57.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 12:57:28 -0800 (PST)
Date: Tue, 30 Jan 2018 20:57:12 +0000
From: Roman Gushchin <guro@fb.com>
Subject: [LSF/MM ATTEND] memory.low hierarchic semantics
Message-ID: <20180130205711.GA21066@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org

Hello!

Current semantics of memory.low makes it hard to use in a hierarchy,
where some memcg's are more valuable than others. For instance,
let's say we have memcgs A, A/B and A/C; A/B should have 10Gb
of guaranteed memory, a A/C is expected to use the surplus
on the machine.
The question is what should we set as the A/memory.low value?

  A      A/memory.low ???
 / \
B   C    B/memory.low = 10G, C/memory.low = 0


If we set it to 10G (the minimum reasonable number), B's memory guarantee
will not work until sum of B and C memory consumption will reach 10G.
And it might be by far below 10G, which makes no sense. The only case,
when it might work, is when there is only one leaf cgroup in the sub-tree.

The only other option I see is to set it to 'max'. Then B's memory
guarantee will work as expected. But this basically means that all non-leaf
memcgs must have memory.low set to 'max', otherwise leaf's memory.low have
no meaning. Such approach makes impossible protecting the system from the
misbehavior in case of sub-tree delegation.

I have no solution for the described problem, but I believe that we should
somehow scale the memory pressure on B and C, depending on how much
their usage exceeds their guarantees. Another option is to scan only those
children memcgs, which are above their guarantees, until the are some
(as we do for memory.low in general).

It will be very valuable to discuss this problem and try to find a possible
approach to it, which will make sense semantically and be acceptable
in terms of performance.


Thanks!


Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
