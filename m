Date: Fri, 12 Nov 1999 11:24:34 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: pagecache in highmem with 2.3.27
Message-ID: <Pine.LNX.4.10.9911121118040.3494-200000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="650352740-754828006-942402274=:3494"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--650352740-754828006-942402274=:3494
Content-Type: TEXT/PLAIN; charset=US-ASCII


with the 2.3.27 kernel we have the pagecache in high memory. Also there is
a new, schedulable and caching kmap implementation. [note that the
attached small patch has to be used as well to get it stable]

without this feature we cannot take more than 25 Netbench users in
'dbench' simulations without running out of low memory. With the patch i'm
running a 250-user simulation just fine with only 30% of low memory used.
Speed of the 250-user run is identical (~230 MB/sec) to the 25-user run
with CONFIG_HIGHMEM turned off.

here is the changelog, comments/suggestions welcome:

- kmap interface redesigned along Linus' idea. The main two functions are
  kmap(page) and kunmap(page). There is a current limit of
  2MB of total maps, i never actually ran into this limit. Basically all
  code uses this new kmap/kunmap variant, and i've seen no performance
  degradation. (in fact, during a dbench run we have a cache hit ratio of
  50%, and only about 100 'total flushes' in a 300 use dbench run.)

- there is a limited additional API: kmap_atomic()/kunmap_atomic(). It's
  discouraged to use this (comments are warning people about this), the
  only place right now is the bounce-buffer code, it has to copy to high
  memory from IRQ contexts.

- exec.c now uses high memory to store argument pages.

- bounce buffer support in highmem.c. I kept it simple and stupid, but
  it's fully functional and should behave well in low memory and
  allocation-deadlock situations. The only impact on the generic code is a
  single #ifdef in ll_rw_blk.c.

- filemap.c: pagecache in high memory.

- This also prompted a cleanup of the page allocation APIs in
  page_alloc.c. Fortunately all functions that return 'struct page *' are
  relatively young and so we could change them without impacting third party
  code so shortly before 2.4. The new page allocation interface is i
  believe now pretty clean and intuitive:

      __get_free_pages() & friends does what it always did.

      alloc_page(flag) and alloc_pages(flag,order) returns 'struct page *'
 
  the weird get_highmem_page-type of confusing interfaces are now gone.

  all highmem-related code uses now the alloc_page() variants.
  alloc_page() can be used to allocate non-highmem pages as well, and this
  is used in a couple of places as well.

- cleaned up page_alloc.c a bit more, removed an oversight.
  (page_alloc_lock)

- arch/i386/mm/init.c needed some changes to get the kmap pagetable
  right.

- fixes to a few unrelated fs and architecture-specific places that
  either use kmap or the 'struct page *' allocators. So this patch should
  cause no breakage.

This should be the 'last' larger highmem-related patch, the Linux 64GB
feature is now pretty mature and we can expect to scale to 32/64GB RAM
just fine with typical server usage.

-- mingo

--650352740-754828006-942402274=:3494
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="highmem-2.3.27-A0"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.10.9911121124340.3494@chiara.csoma.elte.hu>
Content-Description: 
Content-Disposition: attachment; filename="highmem-2.3.27-A0"

LS0tIGxpbnV4L21tL2hpZ2htZW0uYy5vcmlnCUZyaSBOb3YgMTIgMDA6MzE6
MTMgMTk5OQ0KKysrIGxpbnV4L21tL2hpZ2htZW0uYwlGcmkgTm92IDEyIDAw
OjMyOjMwIDE5OTkNCkBAIC0yNjksOSArMjY5LDkgQEANCiAJdW5zaWduZWQg
bG9uZyB2dG87DQogDQogCXBfdG8gPSB0by0+Yl9wYWdlOw0KLQl2dG8gPSBr
bWFwX2F0b21pYyhwX3RvLCBLTV9CT1VOQ0VfV1JJVEUpOw0KKwl2dG8gPSBr
bWFwX2F0b21pYyhwX3RvLCBLTV9CT1VOQ0VfUkVBRCk7DQogCW1lbWNweSgo
Y2hhciAqKXZ0byArIGJoX29mZnNldCh0byksIGZyb20tPmJfZGF0YSwgdG8t
PmJfc2l6ZSk7DQotCWt1bm1hcF9hdG9taWModnRvLCBLTV9CT1VOQ0VfV1JJ
VEUpOw0KKwlrdW5tYXBfYXRvbWljKHZ0bywgS01fQk9VTkNFX1JFQUQpOw0K
IH0NCiANCiBzdGF0aWMgaW5saW5lIHZvaWQgYm91bmNlX2VuZF9pbyAoc3Ry
dWN0IGJ1ZmZlcl9oZWFkICpiaCwgaW50IHVwdG9kYXRlKQ0K
--650352740-754828006-942402274=:3494--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
