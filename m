Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 334896B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 17:06:17 -0400 (EDT)
Received: by wgso17 with SMTP id o17so62805438wgs.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:06:16 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id yx7si21196031wjc.202.2015.04.24.14.06.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 14:06:15 -0700 (PDT)
Received: by widdi4 with SMTP id di4so35814645wid.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 14:06:15 -0700 (PDT)
From: Anisse Astier <anisse@astier.eu>
Subject: [PATCH 0/2] Sanitizing freed pages
Date: Fri, 24 Apr 2015 23:05:47 +0200
Message-Id: <1429909549-11726-1-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Anisse Astier <anisse@astier.eu>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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


[1] https://lwn.net/Articles/334747/
[2] https://staff.aist.go.jp/k.suzaki/EuroSec12-SUZAKI-revised2.pdf
[3] http://en.wikibooks.org/wiki/Grsecurity/Appendix/Grsecurity_and_PaX_Configuration_Options#Sanitize_all_freed_memory
[4] http://article.gmane.org/gmane.linux.kernel.mm/34398

Anisse Astier (2):
  mm/page_alloc.c: cleanup obsolete KM_USER*
  mm/page_alloc.c: add config option to sanitize freed pages

 mm/Kconfig      | 12 ++++++++++++
 mm/page_alloc.c | 15 +++++++--------
 2 files changed, 19 insertions(+), 8 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
