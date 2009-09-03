Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DC4716B0092
	for <linux-mm@kvack.org>; Thu,  3 Sep 2009 01:55:14 -0400 (EDT)
Received: by ywh8 with SMTP id 8so2551608ywh.14
        for <linux-mm@kvack.org>; Wed, 02 Sep 2009 22:55:22 -0700 (PDT)
MIME-Version: 1.0
Date: Thu, 3 Sep 2009 14:55:22 +0900
Message-ID: <2014bcab0909022255i53e9f72t4c131c648fb4754@mail.gmail.com>
Subject: BUG? misused atomic instructions in mm/swapfile.c
From: =?UTF-8?B?7ZmN7IugIHNoaW4gaG9uZw==?= <hongshin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello. I am reporting atomic instructions usages
which are suspected to be misused in mm/swapfile.c
of Linux 2.6.30.5.

I do not have much background on mm
so that I am not certain whether it is correct or not.
But I hope this report is helpful. Please examine the code.

In try_to_use(), setup_swap_extents(), and SYSCALL_DEFINE2(),
there are following codes:

    if (atomic_read(&start_mm->mm_users) == 1) {
        mmput(start_mm) ;
        start_mm = &init_mm ;
        atomic_inc(&init_mm.mm_users) ;
    }

It first checks start_mm->mm_users and then increments its value by one.

If one of these functions is executed in two different threads
for the same start_mm concurrently,
mmput(start_mm) can be executed twice as result of race.

I think it would be better to combine two atomic operations
into one atomic operation (e.g. atomic_cmpxchg).

Thank you.

Sincerely
Shin Hong

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
