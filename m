Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD5F8C49ED7
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 01:08:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62EEE206A1
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 01:08:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62EEE206A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=au1.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 129236B0005; Mon, 16 Sep 2019 21:08:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D9696B0006; Mon, 16 Sep 2019 21:08:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE3616B0008; Mon, 16 Sep 2019 21:08:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id CB2336B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 21:08:37 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4CF66180AD804
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 01:08:37 +0000 (UTC)
X-FDA: 75942627474.14.eye19_4b3b284bcd236
X-HE-Tag: eye19_4b3b284bcd236
X-Filterd-Recvd-Size: 6371
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf39.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 01:08:36 +0000 (UTC)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x8H170fG001864
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 21:08:36 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2v2eer5mmq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 21:08:35 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <alastair@au1.ibm.com>;
	Tue, 17 Sep 2019 02:08:34 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 17 Sep 2019 02:08:29 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x8H18Ttt54984852
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 17 Sep 2019 01:08:29 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 04CB8A4054;
	Tue, 17 Sep 2019 01:08:29 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A3E56A405F;
	Tue, 17 Sep 2019 01:08:28 +0000 (GMT)
Received: from ozlabs.au.ibm.com (unknown [9.192.253.14])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 17 Sep 2019 01:08:28 +0000 (GMT)
Received: from adsilva.ozlabs.ibm.com (haven.au.ibm.com [9.192.254.114])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by ozlabs.au.ibm.com (Postfix) with ESMTPSA id 4E27EA019A;
	Tue, 17 Sep 2019 11:08:27 +1000 (AEST)
From: "Alastair D'Silva" <alastair@au1.ibm.com>
To: alastair@d-silva.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
        Jason Gunthorpe <jgg@ziepe.ca>, Logan Gunthorpe <logang@deltatee.com>,
        Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v3 1/2] memory_hotplug: Add a bounds check to check_hotplug_memory_range()
Date: Tue, 17 Sep 2019 11:07:47 +1000
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190917010752.28395-1-alastair@au1.ibm.com>
References: <20190917010752.28395-1-alastair@au1.ibm.com>
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19091701-0008-0000-0000-000003173CB8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19091701-0009-0000-0000-00004A35B80D
Message-Id: <20190917010752.28395-2-alastair@au1.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-09-16_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1908290000 definitions=main-1909170011
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alastair D'Silva <alastair@d-silva.org>

On PowerPC, the address ranges allocated to OpenCAPI LPC memory
are allocated from firmware. These address ranges may be higher
than what older kernels permit, as we increased the maximum
permissable address in commit 4ffe713b7587
("powerpc/mm: Increase the max addressable memory to 2PB"). It is
possible that the addressable range may change again in the
future.

In this scenario, we end up with a bogus section returned from
__section_nr (see the discussion on the thread "mm: Trigger bug on
if a section is not found in __section_nr").

Adding a check here means that we fail early and have an
opportunity to handle the error gracefully, rather than rumbling
on and potentially accessing an incorrect section.

Further discussion is also on the thread ("powerpc: Perform a bounds
check in arch_add_memory").

Signed-off-by: Alastair D'Silva <alastair@d-silva.org>
---
 include/linux/memory_hotplug.h |  1 +
 mm/memory_hotplug.c            | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
index f46ea71b4ffd..bc477e98a310 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -110,6 +110,7 @@ extern void __online_page_increment_counters(struct p=
age *page);
 extern void __online_page_free(struct page *page);
=20
 extern int try_online_node(int nid);
+int check_hotplug_memory_addressable(u64 start, u64 size);
=20
 extern int arch_add_memory(int nid, u64 start, u64 size,
 			struct mhp_restrictions *restrictions);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c73f09913165..02cb9a74f561 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1030,6 +1030,17 @@ int try_online_node(int nid)
 	return ret;
 }
=20
+int check_hotplug_memory_addressable(u64 start, u64 size)
+{
+#ifdef MAX_PHYSMEM_BITS
+	if ((start + size - 1) >> MAX_PHYSMEM_BITS)
+		return -E2BIG;
+#endif
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(check_hotplug_memory_addressable);
+
 static int check_hotplug_memory_range(u64 start, u64 size)
 {
 	/* memory range must be block size aligned */
@@ -1040,7 +1051,7 @@ static int check_hotplug_memory_range(u64 start, u6=
4 size)
 		return -EINVAL;
 	}
=20
-	return 0;
+	return check_hotplug_memory_addressable(start, size);
 }
=20
 static int online_memory_block(struct memory_block *mem, void *arg)
--=20
2.21.0


