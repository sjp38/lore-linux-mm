Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 82BFC6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 02:50:05 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id oB97o3dQ006455
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 23:50:03 -0800
Received: from pvd12 (pvd12.prod.google.com [10.241.209.204])
	by wpaz9.hot.corp.google.com with ESMTP id oB97njeG011424
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 23:50:02 -0800
Received: by pvd12 with SMTP id 12so495527pvd.34
        for <linux-mm@kvack.org>; Wed, 08 Dec 2010 23:50:02 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/2] RFC: page munlock issues when breaking up COW
Date: Wed,  8 Dec 2010 23:49:37 -0800
Message-Id: <1291880979-16309-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I'm sending this up as RFC only as I've only done minimal testing so far -
I would actually be particularly interested in comments about any corner
cases I must make sure to test for...

It looks like there is a race in the do_wp_page() code that munlocks the
old page after breaking up COW. The pte still points to that old page,
so I don't see that we are protected against vmscan mlocking back the
page right away. This can be easily worked around by moving that code to
the end of do_wp_page(), after the pte has been pointed to the new page.

Also, the corresponding code in __do_fault() seems entirely unnecessary,
since there was never a pte pointing to the old page in our vma.

I found this by code inspection only, and while I believe I understand
this code well by now, there is always the possibility that I may have
missed something. I hope Nick can comment, since he wrote this part of
the code.

Michel Lespinasse (2):
  mlock: fix race when munlocking pages in do_wp_page()
  mlock: do not munlock pages in __do_fault()

 mm/memory.c |   32 ++++++++++++--------------------
 1 files changed, 12 insertions(+), 20 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
