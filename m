Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 2CB4D6B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 06:30:39 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id fp1so3551926pdb.33
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 03:30:38 -0700 (PDT)
Received: from mail-pa0-x22f.google.com (mail-pa0-x22f.google.com [2607:f8b0:400e:c03::22f])
        by mx.google.com with ESMTPS id az6si5732162pdb.103.2014.07.15.03.30.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 03:30:37 -0700 (PDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so5738897pab.20
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 03:30:37 -0700 (PDT)
Date: Tue, 15 Jul 2014 03:28:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/2] shmem: fix faulting into a hole while it's punched, take
 3
Message-ID: <alpine.LSU.2.11.1407150247540.2584@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Lukas Czerner <lczerner@redhat.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Andrew,

Here's my latest and hopefully last stab at fixing the trinity
hole-punch starvation issue that became known as CVE-2014-4171.

You may prefer to hear a testing update from Sasha and Vlastimil before
paying any attention to these, or you may prefer to add them into mmotm
for wider testing now: whichever you think appropriate.

Please throw away mmotm's
revert-shmem-fix-faulting-into-a-hole-while-its-punched.patch
and replace it by 1/2, which fixes that commit instead of reverting it.

Please throw away mmotm's
shmem-fix-faulting-into-a-hole-while-its-punched-take-2.patch
and replace it by 2/2, which reworks the commit message and adds a fix.

Please keep the 3/3 I sent last time in mmotm
mm-fs-fix-pessimization-in-hole-punching-pagecache.patch
which remains valid.

In the end I decided that we had better look at it as two problems,
the trinity faulting starvation, and the indefinite punching loop,
so 1/2 and 2/2 present both solutions: belt and braces.

Which may be the best for fixing, but the worst for ease of backporting.
Vlastimil, I have prepared (and lightly tested) a 3.2.61-based version
of the combination of f00cdc6df7d7 and 1/2 and 2/2 (basically, I moved
vmtruncate_range from mm/truncate.c to mm/shmem.c, since nothing but
shmem ever implemented the truncate_range method).  It should give a
good hint for backports earlier and later: I'll send it privately to
you now, but keep in mind that it may need to be revised if today's
patches for 3.16 get revised again (I'll send it to Ben Hutchings
only when that's settled).

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
