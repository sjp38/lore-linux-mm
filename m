Date: Mon, 03 Mar 2003 15:06:21 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: [PATCH 2.5.63] Teach page_mapped about the anon flag
Message-ID: <103400000.1046725581@baldur.austin.ibm.com>
In-Reply-To: <20030227142450.1c6a6b72.akpm@digeo.com>
References: <20030227025900.1205425a.akpm@digeo.com>
 <200302280822.09409.kernel@kolivas.org>
 <20030227134403.776bf2e3.akpm@digeo.com>
 <118810000.1046383273@baldur.austin.ibm.com>
 <20030227142450.1c6a6b72.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========1907709384=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--==========1907709384==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--On Thursday, February 27, 2003 14:24:50 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> I'm just looking at page_mapped().  It is now implicitly assuming that the
> architecture's representation of a zero-count atomic_t is all-bits-zero.
> 
> This is not true on sparc32 if some other CPU is in the middle of an
> atomic_foo() against that counter.  Maybe the assumption is false on other
> architectures too.
> 
> So page_mapped() really should be performing an atomic_read() if that is
> appropriate to the particular page.  I guess this involves testing
> page->mapping.  Which is stable only when the page is locked or
> mapping->page_lock is held.
> 
> It appears that all page_mapped() callers are inside lock_page() at
> present, so a quick audit and addition of a comment would be appropriate
> there please.

I'm not at all confident that page_mapped() is adequately protected.
Here's a patch that explicitly handles the atomic_t case.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--==========1907709384==========
Content-Type: text/plain; charset=iso-8859-1; name="objfix-2.5.63-1.diff"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename="objfix-2.5.63-1.diff"; size=718

--- 2.5.63-objrmap/include/linux/mm.h	2003-02-27 15:58:34.000000000 -0600
+++ 2.5.63-objfix/include/linux/mm.h	2003-02-28 14:21:56.000000000 -0600
@@ -363,10 +363,16 @@
  * Return true if this page is mapped into pagetables.  Subtle: test =
pte.direct
  * rather than pte.chain.  Because sometimes pte.direct is 64-bit, and =
.chain
  * is only 32-bit.
+ *
+ * If the page is an object-mapped page, we need to do an atomic read of
+ * pte.mapcount instead, since atomic values may not be zero in the upper =
bits.
  */
 static inline int page_mapped(struct page *page)
 {
-	return page->pte.direct !=3D 0;
+	if (PageAnon(page))
+		return page->pte.direct !=3D 0;
+	else
+		return atomic_read(&page->pte.mapcount) !=3D 0;
 }
=20
 /*

--==========1907709384==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
