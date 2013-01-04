Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id EA46E6B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 17:58:13 -0500 (EST)
Received: by mail-vc0-f180.google.com with SMTP id p16so17194445vcq.11
        for <linux-mm@kvack.org>; Fri, 04 Jan 2013 14:58:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrVGvfm2VHUaVNDg40U4dbsRmriW7GfRnfpHGihG9v1=Uw@mail.gmail.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
	<CALCETrVGvfm2VHUaVNDg40U4dbsRmriW7GfRnfpHGihG9v1=Uw@mail.gmail.com>
Date: Fri, 4 Jan 2013 14:58:12 -0800
Message-ID: <CANN689GQLMKztfhymtE-NFvmOxMsf6UB6XssdoBVv17tUv_Qww@mail.gmail.com>
Subject: Re: [PATCH 0/9] Avoid populating unbounded num of ptes with mmap_sem held
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 4, 2013 at 10:16 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> I still have quite a few instances of 2-6 ms of latency due to
> "call_rwsem_down_read_failed __do_page_fault do_page_fault
> page_fault".  Any idea why?  I don't know any great way to figure out
> who is holding mmap_sem at the time.  Given what my code is doing, I
> suspect the contention is due to mmap or munmap on a file.  MCL_FUTURE
> is set, and MAP_POPULATE is not set.
>
> It could be the other thread calling mmap and getting preempted (or
> otherwise calling schedule()).  Grr.

The simplest way to find out who's holding the lock too long might be
to enable CONFIG_LOCK_STATS. This will slow things down a little, but
give you lots of useful information including which threads hold
mmap_sem the longest and the call stack for where they grab it from.
See Documentation/lockstat.txt

I think munmap is a likely culprit, as it still happens with mmap_sem
held for write (I do plan to go work on this next). But it's hard to
be sure without lockstats :)

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
