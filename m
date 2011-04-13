Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CCA68900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 22:19:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 361EF3EE0BC
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:19:50 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1864245DE95
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:19:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F30FF45DE93
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:19:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE938E18003
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:19:49 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A7A61E08004
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:19:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/3] mm: add __nocast attribute to vm_flags
In-Reply-To: <20110413084047.41DD.A69D9226@jp.fujitsu.com>
References: <BANLkTinLdWB+ON=TY=KHyzsrC8gC5bXg7Q@mail.gmail.com> <20110413084047.41DD.A69D9226@jp.fujitsu.com>
Message-Id: <20110413112002.41E8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 13 Apr 2011 11:19:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

> > On Tue, Apr 12, 2011 at 10:12 AM, KOSAKI Motohiro
> > <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > After next year? All developers don't have to ignore compiler warning=
s!
> >=20
> > At least add vm_flags_t which is sparse-checked, just like we do with g=
fp_t.
>=20
> Good idea.

Alexy, I have to deeply thank you. Your suggestion help to find two
hidden vm_flags usage. (I'll post them as reply of this mail)

Now, i386 allyesconfig build doesn't detect nocast violation. Then, I
believe we don't have a big overlooking anymore.



=46rom 254787536ac871d313a02db5dfe8c539e0bbf605 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 13 Apr 2011 09:26:37 +0900
Subject: [PATCH 1/3] mm: add __nocast attribute to vm_flags

Now, We are converting vm_flags to 64bit. so nocast attribute help to
find hidden wrong vm_flags usage.

Suggested-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/mm_types.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4b0b990..ca01ab2 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -109,7 +109,7 @@ struct page {
  */
 struct vm_region {
 	struct rb_node	vm_rb;		/* link in global region tree */
-	unsigned long long vm_flags;	/* VMA vm_flags */
+	unsigned long long __nocast vm_flags;	/* VMA vm_flags */
 	unsigned long	vm_start;	/* start address of region */
 	unsigned long	vm_end;		/* region initialised to here */
 	unsigned long	vm_top;		/* region allocated to here */
@@ -137,7 +137,7 @@ struct vm_area_struct {
 	struct vm_area_struct *vm_next, *vm_prev;
=20
 	pgprot_t vm_page_prot;		/* Access permissions of this VMA. */
-	unsigned long long vm_flags;		/* Flags, see mm.h. */
+	unsigned long long __nocast vm_flags;	/* Flags, see mm.h. */
=20
 	struct rb_node vm_rb;
=20
--=20
1.7.3.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
