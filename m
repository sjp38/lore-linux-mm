Return-Path: <SRS0=2Zku=W5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29E95C3A5A7
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:24:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D19B9215EA
	for <linux-mm@archiver.kernel.org>; Mon,  2 Sep 2019 09:24:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pu4E28W6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D19B9215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85E7D6B0007; Mon,  2 Sep 2019 05:24:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80E5C6B0008; Mon,  2 Sep 2019 05:24:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7243F6B000A; Mon,  2 Sep 2019 05:24:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0191.hostedemail.com [216.40.44.191])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2456B0007
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 05:24:13 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id ED8D3180AD7C3
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:24:12 +0000 (UTC)
X-FDA: 75889444344.27.hand62_24b14504a560b
X-HE-Tag: hand62_24b14504a560b
X-Filterd-Recvd-Size: 6976
Received: from userp2120.oracle.com (userp2120.oracle.com [156.151.31.85])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  2 Sep 2019 09:24:11 +0000 (UTC)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x829NTaU112903;
	Mon, 2 Sep 2019 09:23:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2019-08-05; bh=WP5SWb5aqTyQm1j2T5BZONlHyn/oglQhKd+u/iDEp+I=;
 b=pu4E28W6U0XN4iSXIuscxOwdDYGtPxhnWcpPJxIRtX0wf6UTyDCvTQSArWW/BkjNLu/0
 Q81mx+aRNRGKD2cEHuypQHBx2FCrkxArk0952PZRnvMFo+V1MijUsWnxLafNi/TeVhIG
 4Sj4zcuKya4FISNEKp7A8RqZfpO+hoWxkSou/PfpkJxtkf1W76msnb/dNJZ/GBJoVNRj
 R5axY+zQMnphc94EJ024BRhScuqg23/I+MXmNmJoRQonrjgtBF/Jj5Sb9tir/9QWgS6A
 QKAKxBxrhcbeJ5V6X6ZPj1N0jeeDIG2IYuBZWR8iSygVNjvvBmTkBPNQYtWmqRfqzzP1 dQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2us0bh80ng-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 02 Sep 2019 09:23:54 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x829MVVE065290;
	Mon, 2 Sep 2019 09:23:53 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2urww6c70y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 02 Sep 2019 09:23:53 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x829Noge002005;
	Mon, 2 Sep 2019 09:23:50 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 02 Sep 2019 02:23:49 -0700
From: William Kucharski <william.kucharski@oracle.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>,
        Song Liu <songliubraving@fb.com>,
        Bob Kasten <robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        William Kucharski <william.kucharski@oracle.com>,
        Chad Mynhier <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 0/2]  mm,thp: Add filemap_huge_fault() for THP
Date: Mon,  2 Sep 2019 03:23:39 -0600
Message-Id: <20190902092341.26712-1-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9367 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=945
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1909020107
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9367 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1909020107
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This set of patches is the first step towards a mechanism for automatical=
ly
mapping read-only text areas of appropriate size and alignment to THPs
whenever possible.

For now, the central routine, filemap_huge_fault(), amd various support
routines are only included if the experimental kernel configuration optio=
n

        RO_EXEC_FILEMAP_HUGE_FAULT_THP

is enabled.

This is because filemap_huge_fault() is dependent upon the
address_space_operations vector readpage() pointing to a routine that wil=
l
read and fill an entire large page at a time without poulluting the page
cache with PAGESIZE entries for the large page being mapped or performing
readahead that would pollute the page cache entries for succeeding large
pages. Unfortunately, there is no good way to determine how many bytes
were read by readpage(). At present, if filemap_huge_fault() were to call
a conventional readpage() routine, it would only fill the first PAGESIZE
bytes of the large page, which is definitely NOT the desired behavior.

However, by making the code available now it is hoped that filesystem
maintainers who have pledged to provide such a mechanism will do so more
rapidly.

The first part of the patch adds an order field to __page_cache_alloc(),
allowing callers to directly request page cache pages of various sizes.
This code was provided by Matthew Wilcox.

The second part of the patch implements the filemap_huge_fault() mechanis=
m
as described above.

As this code is only run when the experimental config option is set,
there are some issues that need to be resolved but this is a good step
step that will enable further developemt.

Changes since v4:
1. More code review comments addressed, fixed bug in rcu logic
2. Add code to delete hugepage from page cache upon failure within
   filemap_huge_fault
3. Remove improperly crafted VM_BUG_ON when removing a THP from the
   page cache
4. Fixed mapping count issue

Changes since v3:
1. Multiple code review comments addressed
2. filemap_huge_fault() now does rcu locking when possible
3. filemap_huge_fault() now properly adds the THP to the page cache befor=
e
   calling readpage()

Changes since v2:
1. FGP changes were pulled out to enable submission as an independent
   patch
2. Inadvertent tab spacing and comment changes were reverted

Changes since v1:
1. Fix improperly generated patch for v1 PATCH 1/2

Matthew Wilcox (1):
  Add an 'order' argument to __page_cache_alloc() and
    do_read_cache_page(). Ensure the allocated pages are compound pages.

William Kucharski (1):
  Add filemap_huge_fault() to attempt to satisfy page faults on
    memory-mapped read-only text pages using THP when possible.

 fs/afs/dir.c            |   2 +-
 fs/btrfs/compression.c  |   2 +-
 fs/cachefiles/rdwr.c    |   4 +-
 fs/ceph/addr.c          |   2 +-
 fs/ceph/file.c          |   2 +-
 include/linux/mm.h      |   2 +
 include/linux/pagemap.h |  10 +-
 mm/Kconfig              |  15 ++
 mm/filemap.c            | 418 ++++++++++++++++++++++++++++++++++++++--
 mm/huge_memory.c        |   3 +
 mm/mmap.c               |  39 +++-
 mm/readahead.c          |   2 +-
 mm/rmap.c               |   4 +-
 mm/vmscan.c             |   2 +-
 net/ceph/pagelist.c     |   4 +-
 net/ceph/pagevec.c      |   2 +-
 16 files changed, 473 insertions(+), 40 deletions(-)

--=20
2.21.0


