Return-Path: <SRS0=U3FQ=WP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F104C3A5A0
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 23:01:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C79720644
	for <linux-mm@archiver.kernel.org>; Mon, 19 Aug 2019 23:01:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="a2YqjvGn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C79720644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 759626B0007; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 70AD36B0008; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F88B6B000A; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0165.hostedemail.com [216.40.44.165])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC166B0007
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 19:01:01 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id D764E8248AAD
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:01:00 +0000 (UTC)
X-FDA: 75840699480.01.blade78_60194afebc430
X-HE-Tag: blade78_60194afebc430
X-Filterd-Recvd-Size: 3274
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com [67.231.153.30])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 23:01:00 +0000 (UTC)
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7JMwYZQ024474
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:00:59 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=VpSPCuRkw9YjLy32A3fG7gTdrUBWo/zGfrtLtIVsUJs=;
 b=a2YqjvGnN7k9OvLr3eaEijYPfALwKTQQWZYMzAE5fcR8UqOvu1Y1+XLC8q5QaI6WloAl
 wUdK2Nv58TnHBYKNUa/KWlfZRSDKXoJyMl+uwhzg4sCZR0wWFEdKwFmILl/GDSnenV9g
 GpQ+A6BDw9PpmEGaS6JrCS+LvuWULIoYEug= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ug3kr8bpj-4
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 16:00:59 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 19 Aug 2019 16:00:57 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 6D0D8168C4889; Mon, 19 Aug 2019 16:00:56 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v3 0/3] vmstats/vmevents flushing
Date: Mon, 19 Aug 2019 16:00:51 -0700
Message-ID: <20190819230054.779745-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-19_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=544 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908190227
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v3:
  1) rearranged patches [2/3] and [3/3] to make [1/2] and [2/2] suitable
  for stable backporting

v2:
  1) fixed !CONFIG_MEMCG_KMEM build by moving memcg_flush_percpu_vmstats()
  and memcg_flush_percpu_vmevents() out of CONFIG_MEMCG_KMEM
  2) merged add-comments-to-slab-enums-definition patch in

Thanks!

Roman Gushchin (3):
  mm: memcontrol: flush percpu vmstats before releasing memcg
  mm: memcontrol: flush percpu vmevents before releasing memcg
  mm: memcontrol: flush percpu slab vmstats on kmem offlining

 include/linux/mmzone.h |  5 +--
 mm/memcontrol.c        | 79 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 82 insertions(+), 2 deletions(-)

-- 
2.21.0


