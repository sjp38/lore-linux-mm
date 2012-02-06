Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 0FE176B13F1
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 03:14:59 -0500 (EST)
Received: by iagz16 with SMTP id z16so11200588iag.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 00:14:58 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 6 Feb 2012 00:14:58 -0800
Message-ID: <CANN689EAfiTdXSr8L+UTWxJLEGHeLVziNLCsdbLuqzsVdERexg@mail.gmail.com>
Subject: [ATTEND] LSF/MM conference
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm <linux-mm@kvack.org>

Hi,

I would like to attend the LSF/MM summit in April this year. I do not
have any formal topic proposals at this point; however there are
several MM areas I am interested in:

- mmap_sem locking: I have done some work in the past to reduce
mmap_sem hold times when page faults wait for transfering file pages
from disk, as well as during large mlock operations. However mmap_sem
can still be held for long times today when write page faults trigger
dirty write throttling, or when the system is under memory pressure
and page allocations within the page fault handler hit the ttfp path
(I have some pending work in these areas that I'd like to submit
shortly). This is an area that hasn't been much invested in, probably
because the fact that most users only need a read lock suffices to
mask the issues in many cases. However I expect it to become more
important as we keep improving performance isolation between
processes. One way we frequently hit mmap_sem related issues at Google
is when building monitoring mechanisms that are expected to stay
responsive when the monitored systems get into bad memory pressure
situations.

- idle page sampling / stale memory estimation: I have a proposal here
that I last submitted ~6 months ago; I have since worked to make it
more scalable by having it figure out page activity by scanning page
tables rather than using rmap. However, one downside of scanning page
tables is that it introduces a dependency on mmap_sem...

- memcg page charging: while we are currently working within the
framework of having pages get charged to the first cgroup that touches
them, we are starting to see the corresponding limitations. In
addition to the issue of shared files that has already been identified
(with some proposal for a mechanism to designate such files to be
charged to a particular cgroup), we are also seeing issues related to
cgroup destruction. The mechanism of transferring cached file pages to
the parent cgroup when the child is destructed doesn't work very well
with our idea of how we want accounting to work; we have been clearing
out the child cgroup memory before deletion as a workaround but this
seems like it could be improved on.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
