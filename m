Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65E3AC32757
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 05:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DA3A2086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 05:45:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="jaImOmkw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DA3A2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CCD36B0005; Thu, 15 Aug 2019 01:44:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 858146B0008; Thu, 15 Aug 2019 01:44:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65A796B000A; Thu, 15 Aug 2019 01:44:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0035.hostedemail.com [216.40.44.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3AE116B0005
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 01:44:59 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id DFA4A482A
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 05:44:58 +0000 (UTC)
X-FDA: 75823573476.26.limit86_82b7e5d266d28
X-HE-Tag: limit86_82b7e5d266d28
X-Filterd-Recvd-Size: 6650
Received: from userp2130.oracle.com (userp2130.oracle.com [156.151.31.86])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 05:44:58 +0000 (UTC)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7F5ilYa050196;
	Thu, 15 Aug 2019 05:44:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2019-08-05; bh=6XAZc0+sBcPGB3UEb+wYhsAGZZHSMFkfwxPpRpJqpHY=;
 b=jaImOmkwe0cn9nMRKYi/GOBf28cBRKUMUQOk8Z1ERh78e/+ioqyMf5FQbMD/V6OJz1GO
 xGJMI+5dQBdaiUf2k5ujcCqxQ8OkN12sbuvade3+s0z2di0pZkCJEwFSq4Lf9zfufQwV
 Ti5oZtAY3BELT+jjCxDVQvZSzZ54Dd8aMuOKy1MtW8QUkkMupUg84Q8o70zyRRAvp1dc
 AxbklrsiMC6XLzoqX35PlF5DMNvhpnsyn/pxe5ZKdehHy45/1JFNmR3gv+30dQmFiQ17
 UI8P26sbi8VTLGpp7fhNI7jNwj3Yb5tt/jd4AaLWCTlJfFbEI9s9gU9rOC4nrdiErJpL pQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2u9nbtrwtp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 15 Aug 2019 05:44:46 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x7F5iXDH156377;
	Thu, 15 Aug 2019 05:44:46 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2ucgf0n58u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 15 Aug 2019 05:44:44 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x7F5iMA6010832;
	Thu, 15 Aug 2019 05:44:22 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 14 Aug 2019 22:44:21 -0700
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
Subject: [PATCH v4 0/2] mm,thp: Add filemap_huge_fault() for THP
Date: Wed, 14 Aug 2019 23:44:10 -0600
Message-Id: <20190815054412.26713-1-william.kucharski@oracle.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9349 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=934
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908150059
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9349 signatures=668684
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=970 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908150059
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
 mm/filemap.c            | 357 ++++++++++++++++++++++++++++++++++++++--
 mm/huge_memory.c        |   3 +
 mm/mmap.c               |  38 ++++-
 mm/readahead.c          |   2 +-
 mm/rmap.c               |   4 +-
 net/ceph/pagelist.c     |   4 +-
 net/ceph/pagevec.c      |   2 +-
 15 files changed, 413 insertions(+), 36 deletions(-)

--=20
2.21.0


