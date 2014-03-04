Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id F1FFD6B0035
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 12:11:35 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id rd3so3962464pab.25
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 09:11:35 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id n8si14908498pab.0.2014.03.04.09.11.18
        for <linux-mm@kvack.org>;
        Tue, 04 Mar 2014 09:11:29 -0800 (PST)
Message-ID: <53160932.6060200@sr71.net>
Date: Tue, 04 Mar 2014 09:11:14 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH RFC 0/1] ksm: check and skip page, if it is already scanned
References: <1393901333-5569-1-git-send-email-pradeep.sawlani@gmail.com>
In-Reply-To: <1393901333-5569-1-git-send-email-pradeep.sawlani@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pradeep Sawlani <pradeep.sawlani@gmail.com>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>
Cc: LKML <linux-kernel@vger.kernel.org>, MEMORY MANAGEMENT <linux-mm@kvack.org>, Arjan van de Ven <arjan@linux.intel.com>, Suri Maddhula <surim@amazon.com>, Matt Wilson <msw@amazon.com>, Anthony Liguori <aliguori@amazon.com>, Pradeep Sawlani <sawlani@amazon.com>

On 03/03/2014 06:48 PM, Pradeep Sawlani wrote:
> Patch uses two bits to detect if page is scanned, one bit for odd cycle
> and other for even cycle. This adds one more bit in page flags and
> overloads existing bit (PG_owner_priv_1).
> Changes are based of 3.4.79 kernel, since I have used that for verification.
> Detail discussion can be found at https://lkml.org/lkml/2014/2/13/624
> Suggestion(s) are welcome for alternative solution in order to avoid one more
> bit in page flags.

Allocate a big bitmap (depends on how many pages you are scanning).
Hash the page's pfn and index in to the bitmap.  If the bit is set,
don't scan the page.  If not set, then set it.  Vary the hash for each
scanning pass to reduce the same collision happening repeatedly.  Clear
the bitmap before each scan.

You'll get plenty of collisions, especially for a small table, but who
cares?

The other option is to bloat anon_vma instead, and only do one scan for
each anon_vma that shares the same root.  That's a bit more invasive though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
