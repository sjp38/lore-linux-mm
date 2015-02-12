Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3565B6B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 10:12:40 -0500 (EST)
Received: by mail-yk0-f177.google.com with SMTP id 20so4742006yks.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 07:12:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si5186312qab.57.2015.02.12.07.12.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Feb 2015 07:12:39 -0800 (PST)
Message-ID: <54DCC2DE.10503@redhat.com>
Date: Thu, 12 Feb 2015 10:12:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix negative nr_isolated counts
References: <alpine.LSU.2.11.1502102303040.13607@eggly.anvils> <20150211130905.4b0d1809b0689ffd6e83d851@linux-foundation.org> <54DC61C6.10502@suse.cz>
In-Reply-To: <54DC61C6.10502@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rafael Aquini <aquini@redhat.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 02/12/2015 03:18 AM, Vlastimil Babka wrote:
> On 02/11/2015 10:09 PM, Andrew Morton wrote:

>>> Fixes: edc2ca612496 ("mm, compaction: move pageblock checks up
>>> from isolate_migratepages_range()") Signed-off-by: Hugh Dickins
>>> <hughd@google.com> Cc: stable@vger.kernel.org # v3.18+
>> 
>> And why -stable?  What user-visible problem is the bug causing?
>> 
> 
> Commit 35cd78156c "vmscan: throttle direct reclaim when too many
> pages are isolated already" by Rik seems to have introduced this 
> congestion_wait() based on too_many_isolated(). The bug it was
> fixing:
> 
> "When way too many processes go into direct reclaim, it is possible
> for all of the pages to be taken off the LRU. One result of this is
> that the next process in the page reclaim code thinks there are no
> reclaimable pages left and triggers an out of memory kill."
> 
> So either this is now prevented by something else and 
> too_many_isolated() could go away, or we should restore its 
> functionality. Any idea, Rik?

I don't think that bug is prevented.

I have seen reports of OOM kills happening while the system
still has a lot of reclaimable page cache pages.

This might actually help explain that bug...

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJU3MLdAAoJEM553pKExN6DheAH/RgOqPr/HwzgaalKd2JcQcSx
xuIL/AhjIf8SYIHO5TTr00lF6mMpXfLs6+7UzYlICYmJ+wA4jZ6MapfpqYH/nkYG
tCS/8kMvH+rfkrUMp8NDz1od4Akp9w153xpA/6rmNrGTrcwXY9L4R2ANj30sJ9bw
5aRvwsYKAbGjXwJqDFbkR6UySthEZ8wPlOZpjJyhBoA9kMx+hP/Aka+qjYkiS7Ny
DfMuEjaNl8dsFZuulc7olhKNSXLyQPNmZt+oQCfb82KH78r6qpH2mhIrRtTunY6z
9iLHrxRgN2j8ZtDPFVaxMWQ3CQlaBZgTigSx1p+MTYVq8nfUe2HhkBgs2EKuV18=
=hWac
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
