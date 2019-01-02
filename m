Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A50008E0002
	for <linux-mm@kvack.org>; Tue,  1 Jan 2019 23:16:39 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id d7so21773134oif.5
        for <linux-mm@kvack.org>; Tue, 01 Jan 2019 20:16:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x2sor26440580ota.72.2019.01.01.20.16.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 Jan 2019 20:16:38 -0800 (PST)
Date: Tue, 1 Jan 2019 20:16:28 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 2/2] mm: rid swapoff of quadratic complexity
In-Reply-To: <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1901012010440.13241@eggly.anvils>
References: <20181203170934.16512-1-vpillai@digitalocean.com> <20181203170934.16512-2-vpillai@digitalocean.com> <alpine.LSU.2.11.1812311635590.4106@eggly.anvils> <CANaguZAStuiXpk2S0rYwdn3Zzsoakavaps4RzSRVqMs3wZ49qg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineeth Pillai <vpillai@digitalocean.com>
Cc: Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kelley Nielsen <kelleynnn@gmail.com>, Rik van Riel <riel@surriel.com>

On Tue, 1 Jan 2019, Vineeth Pillai wrote:

> Thanks a lot for the fixes and detailed explanation Hugh! I shall fold all
> the changes from you and Huang in the next iteration.
> 
> Thanks for all the suggestions and comments as well. I am looking into all
> those and will include all the changes in the next version. Will discuss
> over mail in case of any clarifications.

One more fix on top of what I sent yesterday: once I delved into
the retries, I found that the major cause of exceeding MAX_RETRIES
was the way the retry code neatly avoided retrying the last part of
its work.  With this fix in, I have not yet seen retries go above 1:
no doubt it could, but at present I have no actual evidence that
the MAX_RETRIES-or-livelock issue needs to be dealt with urgently.
Fix sent for completeness, but it reinforces the point that the
structure of try_to_unuse() should be reworked, and oldi gone.

Hugh

---

 mm/swapfile.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- mmotm/mm/swapfile.c	2018-12-31 12:30:55.822407154 -0800
+++ linux/mm/swapfile.c	2019-01-01 19:50:34.377277830 -0800
@@ -2107,8 +2107,8 @@ int try_to_unuse(unsigned int type, bool
 	struct swap_info_struct *si = swap_info[type];
 	struct page *page;
 	swp_entry_t entry;
-	unsigned int i = 0;
-	unsigned int oldi = 0;
+	unsigned int i;
+	unsigned int oldi;
 	int retries = 0;
 
 	if (!frontswap)
@@ -2154,6 +2154,7 @@ retry:
 		goto out;
 	}
 
+	i = oldi = 0;
 	while ((i = find_next_to_unuse(si, i, frontswap)) != 0) {
 		/*
 		 * Under global memory pressure, swap entries
