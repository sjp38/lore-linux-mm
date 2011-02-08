Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8EC8D0039
	for <linux-mm@kvack.org>; Mon,  7 Feb 2011 19:48:00 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p180lvYn019658
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:47:57 -0800
Received: from ywf7 (ywf7.prod.google.com [10.192.6.7])
	by wpaz33.hot.corp.google.com with ESMTP id p180lujH008243
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 7 Feb 2011 16:47:56 -0800
Received: by ywf7 with SMTP id 7so2050522ywf.36
        for <linux-mm@kvack.org>; Mon, 07 Feb 2011 16:47:56 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 0/2] page munlock issues when breaking up COW
Date: Mon,  7 Feb 2011 16:47:34 -0800
Message-Id: <1297126056-14322-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org

It looks like there is a race in the do_wp_page() code that munlocks the
old page after breaking up COW. The pte still points to that old page,
so I don't see that we are protected against vmscan mlocking back the
page right away. This can be easily worked around by moving that code to
the end of do_wp_page(), after the pte has been pointed to the new page.

Also, the corresponding code in __do_fault() seems entirely unnecessary,
since there was never a pte pointing to the old page in our vma.

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
