Received: from smtp01.mail.gol.com (smtp01.mail.gol.com [203.216.5.11])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA27658
	for <linux-mm@kvack.org>; Tue, 2 Mar 1999 08:09:43 -0500
Received: from earthling.net (tc-1-130.ariake.gol.ne.jp [203.216.42.130])
	by smtp01.mail.gol.com (8.9.3/8.9.3/893-SMTP-P) with ESMTP id WAA14313
	for <linux-mm@kvack.org>; Tue, 2 Mar 1999 22:09:22 +0900 (JST)
Message-ID: <36DBE391.EF9C1C06@earthling.net>
Date: Tue, 02 Mar 1999 22:11:45 +0900
From: Neil Booth <NeilB@earthling.net>
MIME-Version: 1.0
Subject: A couple of questions
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have a couple of questions about do_wp_page; I hope they're welcome
here.

1) do_wp_page has most execution paths doing an unlock_kernel() but
there are a couple that don't. Why isn't this inconsistent? e.g. any of
the branches that call end_wp_page do not unlock the kernel. What am I
missing? Is it that these branches only happen if we slept while getting
the free page, and sleeping always unlocks the kernel?

2) The last 2 of the 3 branches to end_wp_page seem to me to be
impossible code paths.

	if (!pte_present(pte))
		goto end_wp_page;
	if (pte_write(pte))
		goto end_wp_page;

At entry, pte (= *page_table) is present and not writable as this is the
only way do_wp_page gets called from handle_pte_fault (and we hold the
kernel lock so nothing else can change *page_table). Being a local
variable, it contents cannot change, so why these 2 tests?

Cheers,

Neil.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
