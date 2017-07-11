Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D36E6B04CE
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 20:52:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u17so130208245pfa.6
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 17:52:28 -0700 (PDT)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id g128si9016111pgc.343.2017.07.10.17.52.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 17:52:27 -0700 (PDT)
Received: by mail-pg0-x236.google.com with SMTP id t186so57916128pgb.1
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 17:52:27 -0700 (PDT)
From: Nadav Amit <nadav.amit@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Potential race in TLB flush batching?
Message-Id: <69BBEB97-1B10-4229-9AEF-DE19C26D8DFF@gmail.com>
Date: Mon, 10 Jul 2017 17:52:25 -0700
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@kernel.org>
Cc: "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

Something bothers me about the TLB flushes batching mechanism that Linux
uses on x86 and I would appreciate your opinion regarding it.

As you know, try_to_unmap_one() can batch TLB invalidations. While doing =
so,
however, the page-table lock(s) are not held, and I see no indication of =
the
pending flush saved (and regarded) in the relevant mm-structs.

So, my question: what prevents, at least in theory, the following =
scenario:

	CPU0 				CPU1
	----				----
					user accesses memory using RW =
PTE=20
					[PTE now cached in TLB]
	try_to_unmap_one()
	=3D=3D> ptep_get_and_clear()
	=3D=3D> set_tlb_ubc_flush_pending()
					mprotect(addr, PROT_READ)
					=3D=3D> change_pte_range()
					=3D=3D> [ PTE non-present - no =
flush ]

					user writes using cached RW PTE
	...

	try_to_unmap_flush()


As you see CPU1 write should have failed, but may succeed.=20

Now I don=E2=80=99t have a PoC since in practice it seems hard to create =
such a
scenario: try_to_unmap_one() is likely to find the PTE accessed and the =
PTE
would not be reclaimed.

Yet, isn=E2=80=99t it a problem? Am I missing something?

Thanks,
Nadav=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
