Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D19FD6B025B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 08:02:07 -0500 (EST)
Received: by wmec201 with SMTP id c201so72420740wme.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 05:02:07 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by mx.google.com with ESMTPS id p9si11210499wjw.8.2015.12.09.05.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 05:02:06 -0800 (PST)
Received: by wmvv187 with SMTP id v187so260469679wmv.1
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 05:02:06 -0800 (PST)
Date: Wed, 9 Dec 2015 14:02:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: isolate_lru_page on !head pages
Message-ID: <20151209130204.GD30907@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi Kirill,
while looking at the issue reported by Minchan [1] I have noticed that
there is nothing to prevent from "isolating" a tail page from LRU because
isolate_lru_page checks PageLRU which is
PAGEFLAG(LRU, lru, PF_HEAD)
so it is checked on the head page rather than the given page directly
but the rest of the operation is done on the given (tail) page.

This is really subtle because this expects that every caller of this
function checks for the tail page otherwise we would clobber statistics
and who knows what else (I haven't checked that in detail) as the page
cannot be on the LRU list and the operation makes sense only on the head
page.

Would it make more sense to make PageLRU PF_ANY? That would return
false for PageLRU on any tail page and so it would be ignored by
isolate_lru_page.

I haven't checked other flags but there might be a similar situation. I
am wondering whether it is really a good idea to perform a flag check on
a different page then the operation which depends on the result of the
test in general. It sounds like a maintenance horror to me.

[1] http://lkml.kernel.org/r/20151201133455.GB27574@bbox
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
