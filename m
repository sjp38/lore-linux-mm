Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 146916B0044
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 20:03:45 -0500 (EST)
Received: by mail-vb0-f41.google.com with SMTP id l22so5149691vbn.14
        for <linux-mm@kvack.org>; Fri, 14 Dec 2012 17:03:44 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 14 Dec 2012 17:03:22 -0800
Message-ID: <CALCETrXqDrHnL-Bh16Gd6zV0tmcVJ4rtc+__9S2k=Nv=OHTfrg@mail.gmail.com>
Subject: MAP_HUGETLB sugbus bug on 3.7.0 (with nr_overcommit_hugepages=0)?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

I just hit a strange bug on 3.7.0 (plus this buggy patch:
https://lkml.org/lkml/2012/12/14/14, but I don't think the patch is
relevant).  With a bunch of MAP_HUGETLB-using programs running, one of
them got repeatedly killed by sigbus (BUS_ADRERR) on its first attempt
to write to the last huge page in an 18MiB allocation.  Here are some
observations:

1. hugetlb_shm_group is zero and the process is not in that group.
I'm not sure why the allocation worked at all, but it did and does.
(This is the case even on Linux 3.5.)

2. The problem happened with RLIMIT_MEMLOCK very low and very high.
(I tried both.)

3. The other processes using hugepages had mlockall(MCL_CURRENT |
MCL_FUTURE).  This one did not.

4. dmesg says nothing at all.

5. I couldn't reproduce it with a small test case.  I tried a few things.

6. thp is set to madvise, and nothing is using it.

7. I have 1000 hugepages reserved and <400 were in use.
nr_overcommit_hugepages is zero.

8. I changed the crashing program to memset its hugepage allocation to
zero immediately after allocating it.  That fixed the problem.  I
undid that and the problem did *not* come back.  I can't reproduce it
any more.

I thought that getting killed due to a failed hugepage fault with
nr_overcommit_hugepages=0 was impossible.

Any clue?  I'll keep trying to reproduce it, but I don't know if I'll succeed.

--Andy

P.S. Sorry, linux-mm people, for repeatedly reporting bugs that I
can't trigger the next day.  It's not intentional, I promise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
