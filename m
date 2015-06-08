Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 6646F6B007D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 10:29:31 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so78639320qkh.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 07:29:31 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l136si2644468qhl.122.2015.06.08.07.29.30
        for <linux-mm@kvack.org>;
        Mon, 08 Jun 2015 07:29:30 -0700 (PDT)
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: [PATCH v2 0/4] Fix kmemleak races on the disable/error path
Date: Mon,  8 Jun 2015 15:29:14 +0100
Message-Id: <1433773758-21994-1-git-send-email-catalin.marinas@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, vigneshr@codeaurora.org

This is a follow-up to the initial patch fixing the kmemleak_scan page
fault during kmemleak disabling:

http://article.gmane.org/gmane.linux.kernel.mm/133707

The first patch is pretty much the same, apart from a clearer
(hopefully) commit log and code comment regarding the ordering of
kmemleak_free_enabled with the scanning thread. The race between
kmemleak_free() and kmemleak_do_cleanup() is fixed in the second patch.

The third patch fixes a potential deadlock on scan_mutex between the
kmemleak_scan_thread and kmemleak_do_cleanup().

The fourth patch is more of a theoretical scenario but worth fixing the
lock acquiring order.

Catalin Marinas (4):
  mm: kmemleak: Allow safe memory scanning during kmemleak disabling
  mm: kmemleak: Fix delete_object_*() race when called on the same
    memory block
  mm: kmemleak: Do not acquire scan_mutex in kmemleak_do_cleanup()
  mm: kmemleak: Avoid deadlock on the kmemleak object insertion error
    path

 mm/kmemleak.c | 75 +++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 53 insertions(+), 22 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
