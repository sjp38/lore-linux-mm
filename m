Subject: [PATCH] mm:D-cache aliasing issue in cow_user_page
From: Dmitriy Monakhov <dmonakhov@openvz.org>
Date: Tue, 17 Oct 2006 13:15:37 +0400
Message-ID: <8764ejqp52.fsf@sw.ru>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-=-=

 from mm/memory.c:
  1434  static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va)
  1435  {
  1436          /*
  1437           * If the source page was a PFN mapping, we don't have
  1438           * a "struct page" for it. We do a best-effort copy by
  1439           * just copying from the original user address. If that
  1440           * fails, we just zero-fill it. Live with it.
  1441           */
  1442          if (unlikely(!src)) {
  1443                  void *kaddr = kmap_atomic(dst, KM_USER0);
  1444                  void __user *uaddr = (void __user *)(va & PAGE_MASK);
  1445  
  1446                  /*
  1447                   * This really shouldn't fail, because the page is there
  1448                   * in the page tables. But it might just be unreadable,
  1449                   * in which case we just give up and fill the result with
  1450                   * zeroes.
  1451                   */
  1452                  if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
  1453                          memset(kaddr, 0, PAGE_SIZE);
  1454                  kunmap_atomic(kaddr, KM_USER0);
  #### D-cache have to be flushed here.
  #### It seems it is just forgotten.

  1455                  return;
  1456                  
  1457          }
  1458          copy_user_highpage(dst, src, va);
  #### Ok here. flush_dcache_page() called from this func if arch need it 
  1459  }

Following is the patch  fix this issue:
Signed-off-by: Dmitriy Monakhov <dmonakhov@openvz.org>
---

--=-=-=
Content-Disposition: inline;
  filename=d-cache-aliasing-issue-in-cow-user-page.patch

diff --git a/mm/memory.c b/mm/memory.c
index b5a4aad..156861f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1452,6 +1452,7 @@ static inline void cow_user_page(struct 
 		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
 			memset(kaddr, 0, PAGE_SIZE);
 		kunmap_atomic(kaddr, KM_USER0);
+		flush_dcache_page(dst);
 		return;
 		
 	}

--=-=-=

---

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
