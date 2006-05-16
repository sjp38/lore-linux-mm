From: Con Kolivas <kernel@kolivas.org>
Subject: [PATCH] mm: cleanup swap unused warning
Date: Tue, 16 May 2006 23:14:35 +1000
References: <200605102132.41217.kernel@kolivas.org> <Pine.LNX.4.64.0605101604330.7472@schroedinger.engr.sgi.com> <200605162055.36957.kernel@kolivas.org>
In-Reply-To: <200605162055.36957.kernel@kolivas.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200605162314.36059.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 May 2006 20:55, Con Kolivas wrote:
> Ok so if we fix it by making swp_entry_t __attribute__((__unused__) we
> break swap migration code?
>
> If we make swap_free() an empty static inline function then gcc compiles in
> the variable needlessly and we won't know it.

Rather than assume I checked the generated code and I was wrong (which is
something I'm getting good at being).

The variable is not compiled in so the empty static inline as suggested by
Pekka suffices to silence this warning.

---
if CONFIG_SWAP is not defined we get:

mm/vmscan.c: In function a??remove_mappinga??:
mm/vmscan.c:387: warning: unused variable a??swapa??

Signed-off-by: Con Kolivas <kernel@kolivas.org>

---
 include/linux/swap.h |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6.17-rc4/include/linux/swap.h
===================================================================
--- linux-2.6.17-rc4.orig/include/linux/swap.h	2006-05-16 23:07:35.000000000 +1000
+++ linux-2.6.17-rc4/include/linux/swap.h	2006-05-16 23:08:08.000000000 +1000
@@ -292,7 +292,10 @@ static inline void disable_swap_token(vo
 #define show_swap_cache_info()			/*NOTHING*/
 #define free_swap_and_cache(swp)		/*NOTHING*/
 #define swap_duplicate(swp)			/*NOTHING*/
-#define swap_free(swp)				/*NOTHING*/
+static inline void swap_free(swp_entry_t swp)
+{
+}
+
 #define read_swap_cache_async(swp,vma,addr)	NULL
 #define lookup_swap_cache(swp)			NULL
 #define valid_swaphandles(swp, off)		0

-- 
-ck

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
