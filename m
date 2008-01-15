Date: Tue, 15 Jan 2008 10:45:47 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC] mmaped copy too slow?
Message-Id: <20080115100450.1180.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="------_478C06B20000000011D9_MULTIPART_MIXED_"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

--------_478C06B20000000011D9_MULTIPART_MIXED_
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit

Hi

at one point, I found the large file copy speed was different depending on
the copy method.

I compared below method
 - read(2) and write(2).
 - mmap(2) x2 and memcpy.
 - mmap(2) and write(2).

in addition, effect of fadvice(2) and madvice(2) is checked.

to a strange thing, 
   - most faster method is read + write + fadvice.
   - worst method is mmap + memcpy.

some famous book(i.e. Advanced Programming in UNIX Environment 
by W. Richard Stevens) written mmap copy x2 faster than read-write.
but, linux doesn't.

and, I found bottleneck is page reclaim.
for comparision, I change page reclaim function a bit. and test again.


test machine:
   CPU:      Pentium4 with HT 2.8GHz
   memory:   512M
   Disk I/O: can about 20M/s transfer.
             (in other word, 1GB transfer need 50s at ideal state)


spent time of 1GB file copy.(unit is second)

                 2.6.24-rc6    2.6.24-rc6       ratio
                               +my patch        (small is faster)
    ------------------------------------------------------------
    rw_cp             59.32       58.60          98.79%
    rw_fadv_cp        57.96       57.96          100.0%
    mm_sync_cp        69.97       61.68          88.15%
    mm_sync_madv_cp   69.41       62.54          90.10%
    mw_cp             61.69       63.11         102.30%
    mw_madv_cp        61.35       61.31          99.93%

this patch is too premature and ugly.
but I think that there is enough information to discuss to 
page reclaim improvement. 

the problem is when almost page is mapped and PTE access bit on,
page reclaim process below steps.

  1) page move to inactive list -> active list
  2) page move to active list   -> inactive list
  3) really pageout

It is too roundabout and unnecessary memory pressure happend.
if you don't mind, please discuss.




Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/vmscan.c |   46 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 43 insertions(+), 3 deletions(-)

Index: linux-2.6.24-rc6-cp3/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-cp3.orig/mm/vmscan.c	2008-01-13 21:58:03.000000000 +0900
+++ linux-2.6.24-rc6-cp3/mm/vmscan.c	2008-01-13 22:30:27.000000000 +0900
@@ -446,13 +446,18 @@ static unsigned long shrink_page_list(st
 	struct pagevec freed_pvec;
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
+	unsigned long nr_scanned = 0;
+	LIST_HEAD(l_mapped_pages);
+	unsigned long nr_mapped_page_activate = 0;
+	struct page *page;
+	int reference_checked = 0;
 
 	cond_resched();
 
 	pagevec_init(&freed_pvec, 1);
+retry:
 	while (!list_empty(page_list)) {
 		struct address_space *mapping;
-		struct page *page;
 		int may_enter_fs;
 		int referenced;
 
@@ -466,6 +471,7 @@ static unsigned long shrink_page_list(st
 
 		VM_BUG_ON(PageActive(page));
 
+		nr_scanned++;
 		sc->nr_scanned++;
 
 		if (!sc->may_swap && page_mapped(page))
@@ -493,11 +499,17 @@ static unsigned long shrink_page_list(st
 				goto keep_locked;
 		}
 
-		referenced = page_referenced(page, 1);
-		/* In active use or really unfreeable?  Activate it. */
-		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapping_inuse(page))
-			goto activate_locked;
+		if (!reference_checked) {
+			referenced = page_referenced(page, 1);
+			/* In active use or really unfreeable?  Activate it. */
+			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
+			    referenced && page_mapping_inuse(page)) {
+				nr_mapped_page_activate++;
+				unlock_page(page);
+				list_add(&page->lru, &l_mapped_pages);
+				continue;
+			}
+		}
 
 #ifdef CONFIG_SWAP
 		/*
@@ -604,7 +616,31 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page));
 	}
+
+	if (nr_scanned == nr_mapped_page_activate) {
+		/* may be under copy by mmap.
+		   ignore reference flag. */
+		reference_checked = 1;
+		list_splice(&l_mapped_pages, page_list);
+		goto retry;
+	} else {
+		/* move active list just now */
+		while (!list_empty(&l_mapped_pages)) {
+			page = lru_to_page(&l_mapped_pages);
+			list_del(&page->lru);
+			prefetchw_prev_lru_page(page, &l_mapped_pages, flags);
+
+			if (!TestSetPageLocked(page)) {
+				SetPageActive(page);
+				pgactivate++;
+				unlock_page(page);
+			}
+			list_add(&page->lru, &ret_pages);
+		}
+	}
+
 	list_splice(&ret_pages, page_list);
+
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);


--------_478C06B20000000011D9_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="mmap-write.c"
Content-Disposition: attachment;
 filename="mmap-write.c"
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPHN0ZGlvLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHN0cmluZy5o
PgojaW5jbHVkZSA8dW5pc3RkLmg+CiNpbmNsdWRlIDxhc3NlcnQuaD4KI2luY2x1ZGUgPHN5cy9t
bWFuLmg+CiNpbmNsdWRlIDxzeXMvdHlwZXMuaD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRl
IDxzeXMvc3RhdC5oPgoKaW50IG1haW4oaW50IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkKewogICAgaWYg
KGFyZ2MgIT0gMykgewogICAgICAgIGZwcmludGYoc3RkZXJyLCAidXNhZ2U6ICVzIGZyb21fZmls
ZSB0b19maWxlIiwgYXJndlswXSk7CiAgICAgICAgZXhpdCgwKTsKICAgIH0KCiAgICAvKiBmcm9t
ICovCiAgICBpbnQgZnJvbSA9IG9wZW4oYXJndlsxXSwgT19SRE9OTFksIDA2NDQpOwogICAgYXNz
ZXJ0KGZyb20gPj0gMCk7CgogICAgc3RydWN0IHN0YXQgc3RfYnVmOwogICAgYXNzZXJ0KGZzdGF0
KGZyb20sICZzdF9idWYpID49IDApOwogICAgc2l6ZV90IHNpemUgPSBzdF9idWYuc3Rfc2l6ZTsK
CiAgICB2b2lkICpmcm9tX21tYXAgPSBtbWFwKE5VTEwsIHNpemUsIFBST1RfUkVBRCwgTUFQX1NI
QVJFRCwgZnJvbSwgMCk7CiAgICBhc3NlcnQoZnJvbV9tbWFwID49IDApOwoKI2lmIFVTRV9NQURW
SVNFCiAgICBhc3NlcnQobWFkdmlzZShmcm9tX21tYXAsIHNpemUsIE1BRFZfU0VRVUVOVElBTCkg
Pj0gMCk7CiNlbmRpZgoKICAgIC8qIHRvICovCiAgICBpbnQgdG8gPSBvcGVuKGFyZ3ZbMl0sIE9f
Q1JFQVQgfCBPX1dST05MWSwgMDY2Nik7CiAgICBhc3NlcnQodG8gPj0gMCk7CgogICAgLyogY29w
eSAqLwogICAgY2hhciAqcCA9IGZyb21fbW1hcDsKICAgIGNvbnN0IGNoYXIgKiBjb25zdCBlbmRw
ID0gZnJvbV9tbWFwICsgc2l6ZTsKICAgIHdoaWxlIChwIDwgZW5kcCkgewogICAgICAgIGludCBu
dW1fYnl0ZXMgPSB3cml0ZSh0bywgcCwgZW5kcCAtIHApOwogICAgICAgIHAgKz0gbnVtX2J5dGVz
OwogICAgfQogICAgYXNzZXJ0KHAgPT0gZW5kcCk7CgogICAgZnN5bmModG8pOwoKICAgIGNsb3Nl
KHRvKTsKICAgIGNsb3NlKGZyb20pOwoKICAgIHJldHVybiAwOwp9Cg==
--------_478C06B20000000011D9_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="read-write.c"
Content-Disposition: attachment;
 filename="read-write.c"
Content-Transfer-Encoding: base64

I2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KI2luY2x1ZGUgPHN0ZGlvLmg+
CiNpbmNsdWRlIDxzdHJpbmcuaD4KI2luY2x1ZGUgPGFzc2VydC5oPgojaW5jbHVkZSA8c3lzL3R5
cGVzLmg+CiNpbmNsdWRlIDxzeXMvc3RhdC5oPgojaW5jbHVkZSA8dW5pc3RkLmg+CiNpbmNsdWRl
IDxsaW51eC9mYWR2aXNlLmg+CgojZGVmaW5lIEJVRl9TSVpFIDgxOTIKCmludCBtYWluKGludCBh
cmdjLCBjaGFyICoqYXJndikKewogICAgY2hhciBidWZbQlVGX1NJWkVdOwogICAgc3RydWN0IHN0
YXQgc3RfYnVmOwoKICAgIGlmIChhcmdjIDwgMykgewogICAgICAgIGZwcmludGYoc3RkZXJyLCAi
dXNhZ2U6ICVzIHNyYyBvdXRcbiIsIGFyZ3ZbMF0pOwogICAgICAgIGV4aXQoRVhJVF9TVUNDRVNT
KTsKICAgIH0KCiAgICBjaGFyICpzcmMgID0gYXJndlsxXTsKICAgIGNoYXIgKmRlc3QgPSBhcmd2
WzJdOwogICAgYXNzZXJ0KHN0cmNtcChzcmMsIGRlc3QpICE9IDApOwoKICAgIGludCBzcmNmZCA9
IG9wZW4oc3JjLCBPX1JET05MWSwgMDY0NCk7CiAgICBhc3NlcnQoc3JjZmQgPj0gMCk7CgojaWYg
VVNFX0ZBRFZJU0UKICAgIHBvc2l4X2ZhZHZpc2Uoc3JjZmQsIDAsIDAsIFBPU0lYX0ZBRFZfU0VR
VUVOVElBTCk7CiAgICBwb3NpeF9mYWR2aXNlKHNyY2ZkLCAwLCAwLCBQT1NJWF9GQURWX05PUkVV
U0UpOwojZW5kaWYKCiAgICAvKiBnZXQgcGVybWlzc2lvbiAqLwogICAgYXNzZXJ0KGZzdGF0KHNy
Y2ZkLCAmc3RfYnVmKSA+PSAwKTsKCiAgICBpbnQgZGVzdGZkID0gb3BlbihkZXN0LCBPX1dST05M
WSB8IE9fQ1JFQVQsIHN0X2J1Zi5zdF9tb2RlKTsKICAgIGFzc2VydChkZXN0ZmQgPj0gMCk7Cgog
ICAgaW50IG4gPSAwOwogICAgd2hpbGUgKChuID0gcmVhZChzcmNmZCwgYnVmLCBzaXplb2YoYnVm
KSkpID4gMCkgewogICAgICAgIGNoYXIgKnAgPSAmYnVmWzBdOwogICAgICAgIGNvbnN0IGNoYXIg
KiBjb25zdCBlbmRwID0gYnVmICsgbjsKICAgICAgICB3aGlsZSAocCA8IGVuZHApIHsKICAgICAg
ICAgICAgaW50IG51bV9ieXRlcyA9IHdyaXRlKGRlc3RmZCwgcCwgZW5kcCAtIHApOwogICAgICAg
ICAgICBwICs9IG51bV9ieXRlczsKICAgICAgICB9CiAgICB9CiAgICBhc3NlcnQobiA9PSAwKTsK
CiAgICBmc3luYyhkZXN0ZmQpOwoKICAgIGNsb3NlKGRlc3RmZCk7CiAgICBjbG9zZShzcmNmZCk7
CgogICAgZXhpdChFWElUX1NVQ0NFU1MpOwp9Cg==
--------_478C06B20000000011D9_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="test.sh"
Content-Disposition: attachment;
 filename="test.sh"
Content-Transfer-Encoding: base64

IyEvYmluL3pzaCAteAoKU1JDPXRlc3RmaWxlMUcKRFNUPXRlc3RmaWxlMUcyClRJTUVYPS91c3Iv
YmluL3RpbWUKUFJFUEFSRT0ncm0gJERTVDtzeW5jO3N5bmM7c3luYztzdWRvIHNoIC1jICJlY2hv
IDMgPiAvcHJvYy9zeXMvdm0vZHJvcF9jYWNoZXMiO3NsZWVwIDEnClJFUEVBVD0xCgoKKHJlcGVh
dCAkUkVQRUFUIChldmFsICRQUkVQQVJFOyAkVElNRVggLi9yd19jcCAke1NSQ30gJHtEU1R9KSkK
KHJlcGVhdCAkUkVQRUFUIChldmFsICRQUkVQQVJFOyAkVElNRVggLi9yd19mYWR2X2NwICR7U1JD
fSAke0RTVH0pKQoocmVwZWF0ICRSRVBFQVQgKGV2YWwgJFBSRVBBUkU7ICRUSU1FWCAuL21tX3N5
bmNfY3AgJHtTUkN9ICR7RFNUfSkpCihyZXBlYXQgJFJFUEVBVCAoZXZhbCAkUFJFUEFSRTsgJFRJ
TUVYIC4vbW1fc3luY19tYWR2X2NwICR7U1JDfSAke0RTVH0pKQoocmVwZWF0ICRSRVBFQVQgKGV2
YWwgJFBSRVBBUkU7ICRUSU1FWCAuL213X2NwICR7U1JDfSAke0RTVH0pKQoocmVwZWF0ICRSRVBF
QVQgKGV2YWwgJFBSRVBBUkU7ICRUSU1FWCAuL213X21hZHZfY3AgJHtTUkN9ICR7RFNUfSkpCg==
--------_478C06B20000000011D9_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="Makefile"
Content-Disposition: attachment;
 filename="Makefile"
Content-Transfer-Encoding: base64

Q0ZMQUdTID0gLVdhbGwgLU8yIC0tc3RhdGljIApUQVJHRVQgPSByd19jcCByd19mYWR2X2NwIG1t
X3N5bmNfY3AgbW1fbXVuX2NwIG1tX3N5bmNfbWFkdl9jcCBtbV9tdW5fbWFkdl9jcCBtd19jcCBt
d19tYWR2X2NwIG1tX3N5bmNfbm9jYWNoZV9jcCBtbV9zeW5jX21hZHZfbm9jYWNoZV9jcAoKYWxs
OiAkKFRBUkdFVCkKCnJ3X2NwOiByZWFkLXdyaXRlLmMKCWdjYyAkKENGTEFHUykgIC1vIHJ3X2Nw
IHJlYWQtd3JpdGUuYwoKcndfZmFkdl9jcDogcmVhZC13cml0ZS5jCglnY2MgJChDRkxBR1MpICAt
RFVTRV9GQURWSVNFIC1vIHJ3X2ZhZHZfY3AgcmVhZC13cml0ZS5jCgptbV9zeW5jX2NwOiBtbWFw
LW1tYXAuYwoJZ2NjICQoQ0ZMQUdTKSAtRFdJVEhfTVNZTkMgLW8gbW1fc3luY19jcCBtbWFwLW1t
YXAuYwoKbW1fc3luY19ub2NhY2hlX2NwOiBtbWFwLW1tYXAuYwoJZ2NjICQoQ0ZMQUdTKSAtRFdJ
VEhfTVNZTkMgLURVU0VfTk9DQUNIRV9NRU1DUFkgLW8gJEAgJDwKCm1tX211bl9jcDogbW1hcC1t
bWFwLmMKCWdjYyAkKENGTEFHUykgLURXSVRIX01VTk1BUCAtbyBtbV9tdW5fY3AgbW1hcC1tbWFw
LmMKCm1tX3N5bmNfbWFkdl9jcDogbW1hcC1tbWFwLmMKCWdjYyAkKENGTEFHUykgLURVU0VfTUFE
VklTRSAtRFdJVEhfTVNZTkMgLW8gbW1fc3luY19tYWR2X2NwIG1tYXAtbW1hcC5jCgptbV9zeW5j
X21hZHZfbm9jYWNoZV9jcDogbW1hcC1tbWFwLmMKCWdjYyAkKENGTEFHUykgLURXSVRIX01TWU5D
IC1EVVNFX05PQ0FDSEVfTUVNQ1BZIC1vICRAICQ8CgptbV9tdW5fbWFkdl9jcDogbW1hcC1tbWFw
LmMKCWdjYyAkKENGTEFHUykgLURVU0VfTUFEVklTRSAtRFdJVEhfTVVOTUFQIC1vIG1tX211bl9t
YWR2X2NwIG1tYXAtbW1hcC5jCgptd19jcDogbW1hcC13cml0ZS5jCglnY2MgJChDRkxBR1MpIC1v
IG13X2NwIG1tYXAtd3JpdGUuYwoKbXdfbWFkdl9jcDogbW1hcC13cml0ZS5jCglnY2MgJChDRkxB
R1MpIC1EVVNFX01BRFZJU0UgLW8gbXdfbWFkdl9jcCBtbWFwLXdyaXRlLmMKCmNsZWFuOgoJLXJt
ICoubwoJLXJtICQoVEFSR0VUKQoK
--------_478C06B20000000011D9_MULTIPART_MIXED_
Content-Type: application/octet-stream;
 name="mmap-mmap.c"
Content-Disposition: attachment;
 filename="mmap-mmap.c"
Content-Transfer-Encoding: base64

I2RlZmluZSBfR05VX1NPVVJDRQojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0ZGxpYi5o
PgojaW5jbHVkZSA8c3RyaW5nLmg+CiNpbmNsdWRlIDxhc3NlcnQuaD4KI2luY2x1ZGUgPHVuaXN0
ZC5oPgojaW5jbHVkZSA8c3lzL21tYW4uaD4KI2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVk
ZSA8ZmNudGwuaD4KI2luY2x1ZGUgPHN5cy9zdGF0Lmg+CiNpbmNsdWRlIDxzeXMvZXJybm8uaD4K
CmludCBtYWluKGludCBhcmdjLCBjaGFyICphcmd2W10pCnsKICAgIGludCBlcnI7CgogICAgaWYg
KGFyZ2MgIT0gMykgewogICAgICAgIGZwcmludGYoc3RkZXJyLCAidXNhZ2U6ICVzIGZyb21fZmls
ZSB0b19maWxlIiwgYXJndlswXSk7CiAgICAgICAgZXhpdCgwKTsKICAgIH0KCiAgICAvKiBmcm9t
ICovCiAgICBpbnQgZnJvbSA9IG9wZW4oYXJndlsxXSwgT19SRE9OTFksIDA2NDQpOwogICAgYXNz
ZXJ0KGZyb20gPj0gMCk7CgogICAgc3RydWN0IHN0YXQgc3RfYnVmOwogICAgYXNzZXJ0KGZzdGF0
KGZyb20sICZzdF9idWYpID49IDApOwogICAgc2l6ZV90IHNpemUgPSBzdF9idWYuc3Rfc2l6ZTsK
CiAgICB2b2lkICpmcm9tX21tYXAgPSBtbWFwKE5VTEwsIHNpemUsIFBST1RfUkVBRCwgTUFQX1NI
QVJFRCwgZnJvbSwgMCk7CiAgICBhc3NlcnQoZnJvbV9tbWFwID49IDApOwoKI2lmIFVTRV9NQURW
SVNFCiAgICBlcnIgPSBtYWR2aXNlKGZyb21fbW1hcCwgc2l6ZSwgTUFEVl9TRVFVRU5USUFMKTsK
ICAgIGFzc2VydChlcnIgPj0gMCk7CiNlbmRpZgoKICAgIC8qIHRvICovCiAgICBpbnQgdG8gPSBv
cGVuKGFyZ3ZbMl0sIE9fQ1JFQVR8T19SRFdSLCBzdF9idWYuc3RfbW9kZSk7CiAgICBhc3NlcnQo
dG8gPj0gMCk7CgogICAgaW50IGkgPSAwOwogICAgYXNzZXJ0KGxzZWVrKHRvLCBzaXplIC0gc2l6
ZW9mKGludCksIDBMKSA+PSAwKTsKICAgIGFzc2VydCh3cml0ZSh0bywgKCZpKSwgc2l6ZW9mKGlu
dCkpID09IHNpemVvZihpbnQpKTsKCiAgICBlcnJubz0wOwogICAgdm9pZCAqdG9fbW1hcCA9IG1t
YXAoTlVMTCwgc2l6ZSwgUFJPVF9XUklURSwgTUFQX1NIQVJFRCwgdG8sIDApOwogICAgYXNzZXJ0
X3BlcnJvcihlcnJubyk7CgojaWYgVVNFX01BRFZJU0UKICAgIGVycm5vPTA7CiAgICBlcnIgPSBt
YWR2aXNlKHRvX21tYXAsIHNpemUsIE1BRFZfU0VRVUVOVElBTCk7CiAgICBhc3NlcnRfcGVycm9y
KGVycm5vKTsKI2VuZGlmCgogICAgLyogY29weSAqLwogICAgbWVtY3B5KHRvX21tYXAsIGZyb21f
bW1hcCwgc2l6ZSk7CgojaWYgV0lUSF9NU1lOQwogICAgYXNzZXJ0KG1zeW5jKHRvX21tYXAsIHNp
emUsIE1TX1NZTkMpID49IDApOwojZW5kaWYKI2lmIFdJVEhfTVVOTUFQCiAgICBhc3NlcnQobXVu
bWFwKHRvX21tYXAsIHNpemUpID49IDApOwojZW5kaWYKCiAgICBhc3NlcnQoZnRydW5jYXRlKHRv
LCBzaXplKSA+PSAwKTsKCiAgICByZXR1cm4gMDsKfQo=
--------_478C06B20000000011D9_MULTIPART_MIXED_--


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
