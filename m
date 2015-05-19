Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 11FE56B00A9
	for <linux-mm@kvack.org>; Tue, 19 May 2015 08:46:50 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so20888727wic.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 05:46:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q20si1701438wiv.60.2015.05.19.05.46.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 19 May 2015 05:46:48 -0700 (PDT)
Date: Tue, 19 May 2015 13:46:44 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v4 0/3] Sanitizing freed pages
Message-ID: <20150519124644.GD2462@suse.de>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1431613188-4511-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, May 14, 2015 at 04:19:45PM +0200, Anisse Astier wrote:
> Hi,
> 
> I'm trying revive an old debate here[1], though with a simpler approach than
> was previously tried. This patch series implements a new option to sanitize
> freed pages, a (very) small subset of what is done in PaX/grsecurity[3],
> inspired by a previous submission [4].
> 
> There are a few different uses that this can cover:
>  - some cases of use-after-free could be detected (crashes), although this not
>    as efficient as KAsan/kmemcheck

They're not detected, they're hidden. I'm currently seeing problems with
a glibc update in userspace where applications are crashing because glibc
returns buffers with uninitialised data that would previously have been
zero. In every case so far, they were application bugs that need fixing.
Having the kernel crash due to uninitialised memory use is bad but hiding
it is not better.

>  - it can help with long-term memory consumption in an environment with
>    multiple VMs and Kernel Same-page Merging on the host. [2]

This is not quantified but a better way of dealing with that problem would
be for a guest to signal to the host when a page is really free. I vaguely
recall that s390 has some hinting of this nature. While I accept there
may be some benefits in some cases, I think it's a weak justification for
always zeroing pages on free.

>  - finally, it can reduce infoleaks, although this is hard to measure.
> 

It obscures them.

That is leaving aside the fact that this has to be enabled at kconfig time
which is unlikely to happen on a distribution config. Not many workloads
depend on the freed path as such but streaming readers are one once the
files are larger than memory.

> The approach is voluntarily kept as simple as possible. A single configuration
> option, no command line option, no sysctl nob. It can of course be changed,
> although I'd be wary of runtime-configuration options that could be used for
> races.
> 
> I haven't been able to measure a meaningful performance difference when
> compiling a (in-cache) kernel; I'd be interested to see what difference it
> makes with your particular workload/hardware (I suspect mine is CPU-bound on
> this small laptop).
> 

What did you use to determine this and did you check if it was hitting
the free paths heavily while it's running? It can be very easy to hide
the cost of something like this if all the frees happen at exit.

Overall, I'm not a big fan of this series. I think it would have made more
sense to use non-temporal cleaning on pages if they are freed by kswapd or
on a non-critical path like exit and then track if the page was already
freed during allocation. Then add a runtime sysctl to make that strict
and force all zeroing on all frees.

As it is, I think it'll have very few users because of the need to
enable it at kernel build time and then incur an unavoidable penalty.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
