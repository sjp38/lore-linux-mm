Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 73D966B004D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 08:04:16 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id oi10so326039obb.12
        for <linux-mm@kvack.org>; Tue, 08 Jan 2013 05:04:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
References: <20130105152208.GA3386@redhat.com>
	<CAJd=RBCb0oheRnVCM4okVKFvKGzuLp9GpZJCkVY3RR-J=XEoBA@mail.gmail.com>
	<alpine.LNX.2.00.1301061037140.28950@eggly.anvils>
	<CAJd=RBAps4Qk9WLYbQhLkJd8d12NLV0CbjPYC6uqH_-L+Vu0VQ@mail.gmail.com>
	<CA+55aFyYAf6ztDLsxWFD+6jb++y0YNjso-9j+83Mm+3uQ=8PdA@mail.gmail.com>
Date: Tue, 8 Jan 2013 21:04:15 +0800
Message-ID: <CAJd=RBDTvCcYV8qAd-++_DOyDSypQD4Dvt216pG9nTQnWA2uCA@mail.gmail.com>
Subject: Re: oops in copy_page_rep()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>

On Tue, Jan 8, 2013 at 1:34 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Jan 7, 2013 at 4:24 AM, Hillf Danton <dhillf@gmail.com> wrote:
>>
>> I take another try with waiting added, take a look please.
>
> Hmm. Is there some reason we never need to worry about it for the
> "pmd_numa()" case just above?
>
> A comment about this all might be a really good idea.
>
Yes Sir, added.
---
From: Hillf Danton <dhillf@gmail.com>
Subject: [PATCH] mm: restore huge pmd splitting check

Hugh said, it's clear that 3.7 had an important pmd_trans_splitting(orig_pmd)
check there, which went AWOL in
d10e63f29488 "mm: numa: Create basic numa page hinting infrastructure".

It is restored for handling stable page fault, with wait_split_huge_page()
added, as suggested also by Hugh, to avoid reapted faults until the split
has completed.

This work is inspired by the oops reported by Dave Jones at
https://lkml.org/lkml/2013/1/5/115

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/memory.c	Sun Jan  6 19:49:50 2013
+++ b/mm/memory.c	Tue Jan  8 20:28:04 2013
@@ -3710,6 +3710,14 @@ retry:
 				return do_huge_pmd_numa_page(mm, vma, address,
 							     orig_pmd, pmd);

+			/*
+			 * Check if pmd is stable
+			 * (numa pmd is stable, see change_huge_pmd())
+			 */
+			if (pmd_trans_splitting(orig_pmd)) {
+				wait_split_huge_page(vma->anon_vma, pmd);
+				goto retry;
+			}
 			if (dirty && !pmd_write(orig_pmd)) {
 				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
 							  orig_pmd);
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
