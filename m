Date: Fri, 25 May 2001 15:11:17 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: Possible bug in tlb shootdown patch (IA64)
In-Reply-To: <200105251729.MAA46671@fsgi056.americas.sgi.com>
Message-ID: <Pine.LNX.4.33.0105251506570.20484-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, alan@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2001, Jack Steiner wrote:

> I posted this to linux-mm@kvack.org but failed to
> send you a copy.
>
> ----
>
> We hit a problem that looks like it is related to the tlb
> shootdown patch.

Thanks for the analysis.  I think the following patch should help...

		-ben


diff -urN v2.4.4-ac17/mm/memory.c wrk/mm/memory.c
--- v2.4.4-ac17/mm/memory.c	Thu May 24 19:45:18 2001
+++ wrk/mm/memory.c	Fri May 25 15:10:16 2001
@@ -285,9 +285,9 @@
 		return 0;
 	}
 	ptep = pte_offset(pmd, address);
-	address &= ~PMD_MASK;
-	if (address + size > PMD_SIZE)
-		size = PMD_SIZE - address;
+	offset = address & ~PMD_MASK;
+	if (offset + size > PMD_SIZE)
+		size = PMD_SIZE - offset;
 	size &= PAGE_MASK;
 	for (offset=0; offset < size; ptep++, offset += PAGE_SIZE) {
 		pte_t pte = *ptep;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
