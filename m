Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id C4DCD6B006C
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:17:07 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so86449046wic.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:17:07 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id ga17si1684298wic.36.2015.05.04.14.17.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 14:17:06 -0700 (PDT)
Received: by wiun10 with SMTP id n10so124153769wiu.1
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:17:05 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH v2 0/4] Sanitizing freed pages
Date: Mon,  4 May 2015 23:16:54 +0200
Message-Id: <1430774218-5311-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
