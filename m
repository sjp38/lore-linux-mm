Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C335DC4CEC7
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 23:19:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5ECC320830
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 23:19:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="KEE3nZG/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5ECC320830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF1486B0003; Thu, 12 Sep 2019 19:19:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA1C06B0006; Thu, 12 Sep 2019 19:19:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB8156B0007; Thu, 12 Sep 2019 19:19:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 962236B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 19:19:02 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 461A7181AC9AE
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 23:19:02 +0000 (UTC)
X-FDA: 75927836124.19.hate79_31ba1de1fe65d
X-HE-Tag: hate79_31ba1de1fe65d
X-Filterd-Recvd-Size: 7475
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 23:19:01 +0000 (UTC)
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.42/8.16.0.42) with SMTP id x8CNFhiL002774
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:19:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=eJAkWK9ab3KEK9eiIEM2hNTnrj5bd98d2PXl3/7B5kA=;
 b=KEE3nZG/JOQDnNQzUYlH+IEZLdLgjHRmdAJPx87Fqvg3zAPIbhFkY0U06zvqcGBJlfoF
 dIdw22fCV29IeqB4y5BW9T4sn0gK0QOrl1DKttB/zx9vNdOOomaj3MSWTvHjsgXNK2dU
 zEpjdARG7yxKkIHUxb8kh5Grh47kTxdNKEs= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2uytdg1jsg-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 16:19:00 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 12 Sep 2019 16:18:31 -0700
Received: by devbig059.prn3.facebook.com (Postfix, from userid 4924)
	id 1E37017419B8; Thu, 12 Sep 2019 16:18:31 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Lucian Adrian Grijincu <lucian@fb.com>
Smtp-Origin-Hostname: devbig059.prn3.facebook.com
To: Lucian Adrian Grijincu <lucian@fb.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>,
        Andrew
 Morton <akpm@linux-foundation.org>, Rik van Riel <riel@fb.com>,
        Roman
 Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn3c05
Subject: [PATCH] mm: memory: fix /proc/meminfo reporting for MLOCK_ONFAULT
Date: Thu, 12 Sep 2019 16:18:20 -0700
Message-ID: <20190912231820.590276-1-lucian@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-12_12:2019-09-11,2019-09-12 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 lowpriorityscore=0
 suspectscore=2 priorityscore=1501 mlxscore=0 malwarescore=0
 impostorscore=0 clxscore=1011 adultscore=0 phishscore=0 mlxlogscore=636
 spamscore=0 bulkscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1908290000 definitions=main-1909120237
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As pages are faulted in MLOCK_ONFAULT correctly updates
/proc/self/smaps, but doesn't update /proc/meminfo's Mlocked field.

- Before this /proc/meminfo fields didn't change as pages were faulted in:

```
= Start =
/proc/meminfo
Unevictable:       10128 kB
Mlocked:           10132 kB
= Creating testfile =

= after mlock2(MLOCK_ONFAULT) =
/proc/meminfo
Unevictable:       10128 kB
Mlocked:           10132 kB
/proc/self/smaps
7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
Locked:                0 kB

= after reading half of the file =
/proc/meminfo
Unevictable:       10128 kB
Mlocked:           10132 kB
/proc/self/smaps
7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
Locked:           524288 kB

= after reading the entire the file =
/proc/meminfo
Unevictable:       10128 kB
Mlocked:           10132 kB
/proc/self/smaps
7f8714000000-7f8754000000 rw-s 00000000 08:04 50857050   /root/testfile
Locked:          1048576 kB

= after munmap =
/proc/meminfo
Unevictable:       10128 kB
Mlocked:           10132 kB
/proc/self/smaps
```

- After: /proc/meminfo fields are properly updated as pages are touched:

```
= Start =
/proc/meminfo
Unevictable:          60 kB
Mlocked:              60 kB
= Creating testfile =

= after mlock2(MLOCK_ONFAULT) =
/proc/meminfo
Unevictable:          60 kB
Mlocked:              60 kB
/proc/self/smaps
7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
Locked:                0 kB

= after reading half of the file =
/proc/meminfo
Unevictable:      524220 kB
Mlocked:          524220 kB
/proc/self/smaps
7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
Locked:           524288 kB

= after reading the entire the file =
/proc/meminfo
Unevictable:     1048496 kB
Mlocked:         1048508 kB
/proc/self/smaps
7f2b9c600000-7f2bdc600000 rw-s 00000000 08:04 63045798   /root/testfile
Locked:          1048576 kB

= after munmap =
/proc/meminfo
Unevictable:         176 kB
Mlocked:              60 kB
/proc/self/smaps
```

Repro code.
---

int mlock2wrap(const void* addr, size_t len, int flags) {
  return syscall(SYS_mlock2, addr, len, flags);
}

void smaps() {
  char smapscmd[1000];
  snprintf(
      smapscmd,
      sizeof(smapscmd) - 1,
      "grep testfile -A 20 /proc/%d/smaps | grep -E '(testfile|Locked)'",
      getpid());
  printf("/proc/self/smaps\n");
  fflush(stdout);
  system(smapscmd);
}

void meminfo() {
  const char* meminfocmd = "grep -E '(Mlocked|Unevictable)' /proc/meminfo";
  printf("/proc/meminfo\n");
  fflush(stdout);
  system(meminfocmd);
}

  {                                                 \
    int rc = (call);                                \
    if (rc != 0) {                                  \
      printf("error %d %s\n", rc, strerror(errno)); \
      exit(1);                                      \
    }                                               \
  }
int main(int argc, char* argv[]) {
  printf("= Start =\n");
  meminfo();

  printf("= Creating testfile =\n");
  size_t size = 1 << 30; // 1 GiB
  int fd = open("testfile", O_CREAT | O_RDWR, 0666);
  {
    void* buf = malloc(size);
    write(fd, buf, size);
    free(buf);
  }
  int ret = 0;
  void* addr = NULL;
  addr = mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

  if (argc > 1) {
    PCHECK(mlock2wrap(addr, size, MLOCK_ONFAULT));
    printf("= after mlock2(MLOCK_ONFAULT) =\n");
    meminfo();
    smaps();

    for (size_t i = 0; i < size / 2; i += 4096) {
      ret += ((char*)addr)[i];
    }
    printf("= after reading half of the file =\n");
    meminfo();
    smaps();

    for (size_t i = 0; i < size; i += 4096) {
      ret += ((char*)addr)[i];
    }
    printf("= after reading the entire the file =\n");
    meminfo();
    smaps();

  } else {
    PCHECK(mlock(addr, size));
    printf("= after mlock =\n");
    meminfo();
    smaps();
  }

  PCHECK(munmap(addr, size));
  printf("= after munmap =\n");
  meminfo();
  smaps();

  return ret;
}

---

Signed-off-by: Lucian Adrian Grijincu <lucian@fb.com>
---
 mm/memory.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index e0c232fe81d9..7e8dc3ed4e89 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3311,6 +3311,9 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page, false);
+		if ((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) == VM_LOCKED &&
+				!PageTransCompound(page))
+			mlock_vma_page(page);
 	}
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
-- 
2.17.1


