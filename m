Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E96916B003B
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 14:24:44 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lf10so1019352pab.27
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:24:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ef1si1085243pbc.343.2014.04.23.11.24.43
        for <linux-mm@kvack.org>;
        Wed, 23 Apr 2014 11:24:43 -0700 (PDT)
Date: Wed, 23 Apr 2014 11:24:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2014-04-22-15-20 uploaded (uml 32- and 64-bit defconfigs)
Message-Id: <20140423112442.5a5c8f23d580a65575e0c5fc@linux-foundation.org>
In-Reply-To: <20140423141600.4a303d95@redhat.com>
References: <20140422222121.2FAB45A431E@corp2gmr1-2.hot.corp.google.com>
	<5357F405.20205@infradead.org>
	<20140423134131.778f0d0a@redhat.com>
	<5357FCEB.2060507@infradead.org>
	<20140423141600.4a303d95@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, nacc@linux.vnet.ibm.com, Richard Weinberger <richard@nod.at>

On Wed, 23 Apr 2014 14:16:00 -0400 Luiz Capitulino <lcapitulino@redhat.com> wrote:

> On Wed, 23 Apr 2014 10:48:27 -0700
> > >>> You will need quilt to apply these patches to the latest Linus release (3.x
> > >>> or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> > >>> http://ozlabs.org/~akpm/mmotm/series
> > >>>
> > >>
> > >> include/linux/hugetlb.h:468:9: error: 'HPAGE_SHIFT' undeclared (first use in this function)
> > > 
> > > The patch adding HPAGE_SHIFT usage to hugetlb.h in current mmotm is this:
> > > 
> > > http://www.ozlabs.org/~akpm/mmotm/broken-out/hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported.patch
> > > 
> > > But I can't reproduce the issue to be sure what the problem is. Are you
> > > building the kernel on 32bits? Can you provide the output of
> > > "grep -i huge .config" or send your .config in private?
> > > 
> > 
> > [adding Richard to cc:]
> > 
> > 
> > As in $subject, if I build uml x86 32-bit or 64-bit defconfig, the build fails with
> > this error.
> 
> Oh, I missed the subject info completely. Sorry about that.
> 
> So, the issue really seems to be introduced by patch:
> 
>  hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported.patch
> 
> And the problem is that UML doesn't define HPAGE_SHIFT. The following patch
> fixes it, but I'll let Nishanth decide what to do here.

I'll try moving hugepages_supported() into the #ifdef
CONFIG_HUGETLB_PAGE section.

--- a/include/linux/hugetlb.h~hugetlb-ensure-hugepage-access-is-denied-if-hugepages-are-not-supported-fix-fix
+++ a/include/linux/hugetlb.h
@@ -412,6 +412,16 @@ static inline spinlock_t *huge_pte_lockp
 	return &mm->page_table_lock;
 }
 
+static inline bool hugepages_supported(void)
+{
+	/*
+	 * Some platform decide whether they support huge pages at boot
+	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
+	 * there is no such support
+	 */
+	return HPAGE_SHIFT != 0;
+}
+
 #else	/* CONFIG_HUGETLB_PAGE */
 struct hstate {};
 #define alloc_huge_page_node(h, nid) NULL
@@ -460,14 +470,4 @@ static inline spinlock_t *huge_pte_lock(
 	return ptl;
 }
 
-static inline bool hugepages_supported(void)
-{
-	/*
-	 * Some platform decide whether they support huge pages at boot
-	 * time. On these, such as powerpc, HPAGE_SHIFT is set to 0 when
-	 * there is no such support
-	 */
-	return HPAGE_SHIFT != 0;
-}
-
 #endif /* _LINUX_HUGETLB_H */
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
