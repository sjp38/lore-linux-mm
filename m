Date: Tue, 24 Apr 2007 23:39:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
In-Reply-To: <1177461251.1281.7.camel@dyn9047017100.beaverton.ibm.com>
Message-ID: <Pine.LNX.4.64.0704242329060.21213@schroedinger.engr.sgi.com>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704241320540.13005@schroedinger.engr.sgi.com>
 <20070424132740.e4bdf391.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704241332090.13005@schroedinger.engr.sgi.com>
 <20070424134325.f71460af.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704241351400.13382@schroedinger.engr.sgi.com>
 <20070424141826.952d2d32.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0704241429240.13904@schroedinger.engr.sgi.com>
 <20070424143635.cdff71de.akpm@linux-foundation.org>  <462E7AB6.8000502@shadowen.org>
  <462E9DDC.40700@shadowen.org> <1177461251.1281.7.camel@dyn9047017100.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Apr 2007, Badari Pulavarty wrote:

> quicklists-for-page-table-pages-avoid-useless-virt_to_page-
> conversion.patch
> 
> Andy, can you try backing out only this and enable QUICK_LIST
> on your machine ?

Ahh. Right..... The free that we switched to there to avoid the 
virt_to_page conversion does not decrement the refcount and thus
is not equivalent.

Does this patch fix it?

---
 include/linux/quicklist.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.21-rc7-mm1/include/linux/quicklist.h
===================================================================
--- linux-2.6.21-rc7-mm1.orig/include/linux/quicklist.h	2007-04-24 23:35:11.000000000 -0700
+++ linux-2.6.21-rc7-mm1/include/linux/quicklist.h	2007-04-24 23:35:59.000000000 -0700
@@ -61,7 +61,7 @@ static inline void __quicklist_free(int 
 	if (unlikely(nid != numa_node_id())) {
 		if (dtor)
 			dtor(p);
-		free_hot_page(page);
+		__free_page(page);
 		return;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
