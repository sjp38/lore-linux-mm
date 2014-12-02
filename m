Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3BF6B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 05:12:17 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id a1so16537824wgh.25
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 02:12:17 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eo6si20956550wib.75.2014.12.02.02.12.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 02:12:16 -0800 (PST)
Date: Tue, 2 Dec 2014 10:12:10 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/10] mm: Add p[te|md] protnone helpers for use by NUMA
 balancing
Message-ID: <20141202101210.GA6043@suse.de>
References: <1416578268-19597-1-git-send-email-mgorman@suse.de>
 <1416578268-19597-3-git-send-email-mgorman@suse.de>
 <1417473519.7182.6.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1417473519.7182.6.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LinuxPPC-dev <linuxppc-dev@lists.ozlabs.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@redhat.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Paul Mackerras <paulus@samba.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Dec 02, 2014 at 09:38:39AM +1100, Benjamin Herrenschmidt wrote:
> On Fri, 2014-11-21 at 13:57 +0000, Mel Gorman wrote:
> 
> >  #ifdef CONFIG_NUMA_BALANCING
> > +/*
> > + * These work without NUMA balancing but the kernel does not care. See the
> > + * comment in include/asm-generic/pgtable.h
> > + */
> > +static inline int pte_protnone(pte_t pte)
> > +{
> > +	return (pte_val(pte) &
> > +		(_PAGE_PRESENT | _PAGE_USER)) == _PAGE_PRESENT;
> > +}
> 
> I would add a comment clarifying that this only works for user pages,
> ie, this accessor will always return "true" for a kernel page on ppc.
> 

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 490bd6d..7b889a3 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -41,7 +41,8 @@ static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PA
 #ifdef CONFIG_NUMA_BALANCING
 /*
  * These work without NUMA balancing but the kernel does not care. See the
- * comment in include/asm-generic/pgtable.h
+ * comment in include/asm-generic/pgtable.h . On powerpc, this will only
+ * work for user pages and always return true for kernel pages.
  */
 static inline int pte_protnone(pte_t pte)
 {

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
