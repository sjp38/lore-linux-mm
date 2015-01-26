Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f52.google.com (mail-yh0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3DAF96B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 10:59:12 -0500 (EST)
Received: by mail-yh0-f52.google.com with SMTP id f10so3813061yha.11
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:59:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id le8si13701714qcb.11.2015.01.26.07.59.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 07:59:11 -0800 (PST)
Date: Mon, 26 Jan 2015 16:25:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v2] mm: incorporate read-only pages into transparent huge
 pages
Message-ID: <20150126152509.GT11755@redhat.com>
References: <1422113880-4712-1-git-send-email-ebru.akagunduz@gmail.com>
 <54C5EE66.4060700@suse.cz>
 <20150126151906.GS11755@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150126151906.GS11755@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name, mhocko@suse.cz, mgorman@suse.de, rientjes@google.com, sasha.levin@oracle.com, hughd@google.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Mon, Jan 26, 2015 at 04:19:06PM +0100, Andrea Arcangeli wrote:
> Overall I don't see how we could collapse in readonly vma and where
> the bug is for this case, but I may be overlooking something obvious.

I just realized what the problem was... that the "ro" is not the total
number of readonly ptes mapped by the pmd,.. because we don't count
the none ones as readonly too.

It misses a ro increase or equivalent adjustment:

		if (pte_none(pteval)) {
+			ro++;
			if (++none <= khugepaged_max_ptes_none)
[..]

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
