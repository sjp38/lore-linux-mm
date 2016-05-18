Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB666B025E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 05:21:05 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id ne4so20698388lbc.1
        for <linux-mm@kvack.org>; Wed, 18 May 2016 02:21:05 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id n124si9825287wma.8.2016.05.18.02.21.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 02:21:03 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 966B81C1832
	for <linux-mm@kvack.org>; Wed, 18 May 2016 10:21:02 +0100 (IST)
Date: Wed, 18 May 2016 10:21:01 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v1] mm: bad_page() checks bad_flags instead of
 page->flags for hwpoison page
Message-ID: <20160518092100.GB2527@techsingularity.net>
References: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, May 17, 2016 at 04:42:55PM +0900, Naoya Horiguchi wrote:
> There's a race window between checking page->flags and unpoisoning, which
> taints kernel with "BUG: Bad page state". That's overkill. It's safer to
> use bad_flags to detect hwpoisoned page.
> 

I'm not quite getting this one. Minimally, instead of = __PG_HWPOISON, it
should have been (bad_flags & __PG_POISON). As Vlastimil already pointed
out, __PG_HWPOISON can be 0. What I'm not getting is why this fixes the
race. The current race is

1. Check poison, set bad_flags
2. poison clears in parallel
3. Check page->flag state in bad_page and trigger warning

The code changes it to

1. Check poison, set bad_flags
2. poison clears in parallel
3. Check bad_flags and trigger warning

There is warning either way. What did I miss?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
