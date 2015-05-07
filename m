Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 147D26B0038
	for <linux-mm@kvack.org>; Thu,  7 May 2015 02:34:46 -0400 (EDT)
Received: by widdi4 with SMTP id di4so47471319wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:34:45 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id cp11si1695681wjb.135.2015.05.06.23.34.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 23:34:43 -0700 (PDT)
Received: by widdi4 with SMTP id di4so229064710wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 23:34:42 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH v3 0/4] Sanitizing freed pages
Date: Thu,  7 May 2015 08:34:08 +0200
Message-Id: <1430980452-2767-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

I'm trying revive an old debate here[1], though with a simpler approach than
was previously tried. This patch series implements a new option to sanitize
freed pages, a (very) small subset of what is done in PaX/grsecurity[3],
inspired by a previous submission [4].

The first patch is fairly independent, and could be taken as-is. The second is
the meat and should be straight-forward to review.

There are a few different uses that this can cover:
 - some cases of use-after-free could be detected (crashes), although this not
   as efficient as KAsan/kmemcheck
 - it can help with long-term memory consumption in an environment with
   multiple VMs and Kernel Same-page Merging on the host. [2]
 - finally, it can reduce infoleaks, although this is hard to measure.

The approach is voluntarily kept as simple as possible. A single configuration
option, no command line option, no sysctl nob. It can of course be changed,
although I'd be wary of runtime-configuration options that could be used for
races.

I haven't been able to measure a meaningful performance difference when
compiling a (in-cache) kernel; I'd be interested to see what difference it
makes with your particular workload/hardware (I suspect mine is CPU-bound on
this small laptop).

Second patch fixes the hibernate use case which will load all the pages of the restored kernel, and then jump into it, leaving the loader kernel pages hanging around unclean. We use the free pages bitmap to know which pages should be cleaned after restore.

Fourth patch is debug code that can be used to find issues if this feature fails on your system. It shouldn't necessarily be merged.

Changes since v2:
 - reorder patches to fix hibernate first
 - update debug patch to use memchr_inv
 - cc linux-pm and maintainers

Changes since v1:
 - fix some issues raised by David Rientjes, Andi Kleen and PaX Team.
 - add hibernate fix (third patch)
 - add debug code, this is "just in case" someone has an issue with this
   feature. Not sure if it should be merged.


[1] https://lwn.net/Articles/334747/
[2] https://staff.aist.go.jp/k.suzaki/EuroSec12-SUZAKI-revised2.pdf
[3] http://en.wikibooks.org/wiki/Grsecurity/Appendix/Grsecurity_and_PaX_Configuration_Options#Sanitize_all_freed_memory
[4] http://article.gmane.org/gmane.linux.kernel.mm/34398



Anisse Astier (4):
  mm/page_alloc.c: cleanup obsolete KM_USER*
  mm/page_alloc.c: add config option to sanitize freed pages
  PM / Hibernate: fix SANITIZE_FREED_PAGES
  mm: Add debug code for SANITIZE_FREED_PAGES

 kernel/power/hibernate.c |  7 ++++++-
 kernel/power/power.h     |  4 ++++
 kernel/power/snapshot.c  | 24 ++++++++++++++++++++++
 mm/Kconfig               | 22 ++++++++++++++++++++
 mm/page_alloc.c          | 52 ++++++++++++++++++++++++++++++++++--------------
 5 files changed, 93 insertions(+), 16 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
