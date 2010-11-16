Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DD3C88D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:43:02 -0500 (EST)
Received: by pzk32 with SMTP id 32so282400pzk.14
        for <linux-mm@kvack.org>; Tue, 16 Nov 2010 09:42:58 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 16 Nov 2010 09:42:57 -0800
Message-ID: <AANLkTikAybJkap8d_DjSZUTj6fsiQDigCoqHL6CfgBTt@mail.gmail.com>
Subject: Using page tables to confine memory accesses of subroutines
From: Thomas DuBuisson <thomas.dubuisson@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

All,

I've been working on confining memory accesses of subroutines of a
single process.  The idea is to protect the process's memory integrity
(and perhaps confidentiality) from potentially buggy libraries.  From
the user space standpoint its functionally similar to making a lot of
mprotect calls before and after calling the subroutine.

The initial implementation was done using some existing MM facuilities
(dup_mm, pgd_dup, use_mm, change_pud_range) to build a new system call
that allows the calling process to create, and switch between, a
number of page tables.  Initial benchmarks based on this code show a 2
to 10 time improvement on shared memory IPC performance.

Unfortunately the implementation is just a prototype - it doesn't
behave properly when interleaving
allocation or with multi-threaded processes.  A better implementation
might use the thread infrastructure
to track (and periodically activate) these alternate page tables.  I
figure this could behave properly in the face of allocation and
threading with less work on my part by using more existing code.

Perhaps there are other solutions you can think of, if so I'd be happy
to see a conversation on this front.

Cheers,
Thomas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
