Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC394C4CECB
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 19:29:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F244208C2
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 19:29:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="V3YXf0Ct"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F244208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECF256B0005; Fri, 13 Sep 2019 15:29:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E57F66B0006; Fri, 13 Sep 2019 15:29:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D46BE6B0007; Fri, 13 Sep 2019 15:29:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0072.hostedemail.com [216.40.44.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9D5C6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 15:29:33 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 3A2EA83ED
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 19:29:33 +0000 (UTC)
X-FDA: 75930886626.09.bears24_8d9083ef58856
X-HE-Tag: bears24_8d9083ef58856
X-Filterd-Recvd-Size: 7665
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 19:29:32 +0000 (UTC)
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.42/8.16.0.42) with SMTP id x8DJTV5O014926
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 12:29:31 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=bHkQuk7UWMdpIk9D0vbpXnfZ61mTNtqPQ+w2MbTsY90=;
 b=V3YXf0Ct5IKWNHJ8P+gY5WerBeqZvhH3I5JyMLRGs3+9J+IWvXhrfV/PQ701tFgxrDVb
 pwCtVj4aUC3aXItX+jgIiXQ38/OdNim3Q6dHkH0T6w9sHXAqCHRZcJ4V+MLY/7biqAhv
 4xXHd/EC7k7DPAudaU2S3+LPJw3XYMgneQ8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2uytd95f92-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 12:29:31 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 13 Sep 2019 12:29:10 -0700
Received: by devbig059.prn3.facebook.com (Postfix, from userid 4924)
	id C9B33174196F; Fri, 13 Sep 2019 12:29:09 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Lucian Adrian Grijincu <lucian@fb.com>
Smtp-Origin-Hostname: devbig059.prn3.facebook.com
To: Lucian Adrian Grijincu <lucian@fb.com>, <linux-mm@kvack.org>,
        Souptick
 Joarder <jrdr.linux@gmail.com>
CC: <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>,
        Andrew
 Morton <akpm@linux-foundation.org>, Rik van Riel <riel@fb.com>,
        Roman
 Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn3c05
Subject: [PATCH] mm: memory: fix /proc/meminfo reporting for MLOCK_ONFAULT
Date: Fri, 13 Sep 2019 12:29:07 -0700
Message-ID: <20190913192907.96530-1-lucian@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <CAFqt6zaVAuvoHveT9YeU5GWjWPZBeTXWnRjmHEazxZSUctT7+Q@mail.gmail.com>
References: <CAFqt6zaVAuvoHveT9YeU5GWjWPZBeTXWnRjmHEazxZSUctT7+Q@mail.gmail.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:6.0.70,1.0.8
 definitions=2019-09-13_09:2019-09-11,2019-09-13 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 phishscore=0
 lowpriorityscore=0 adultscore=0 clxscore=1015 mlxlogscore=716 spamscore=0
 bulkscore=0 malwarescore=0 suspectscore=2 priorityscore=1501
 impostorscore=0 mlxscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-1908290000 definitions=main-1909130199
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
 mm/memory.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index e0c232fe81d9..55da24f33bc4 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3311,6 +3311,8 @@ vm_fault_t alloc_set_pte(struct vm_fault *vmf, struct mem_cgroup *memcg,
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
 		page_add_file_rmap(page, false);
+		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(page))
+			mlock_vma_page(page);
 	}
 	set_pte_at(vma->vm_mm, vmf->address, vmf->pte, entry);
 
-- 
2.17.1


