Return-Path: <SRS0=TLXr=WI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E9CFC31E40
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:29:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAFE42067D
	for <linux-mm@archiver.kernel.org>; Mon, 12 Aug 2019 22:29:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="cWbc/657"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAFE42067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 565956B0008; Mon, 12 Aug 2019 18:29:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49EEF6B0005; Mon, 12 Aug 2019 18:29:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 323BD6B0007; Mon, 12 Aug 2019 18:29:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0091.hostedemail.com [216.40.44.91])
	by kanga.kvack.org (Postfix) with ESMTP id 07A5D6B0003
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 18:29:17 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id AA0C7181AC9AE
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:29:17 +0000 (UTC)
X-FDA: 75815217954.03.brake84_8b4a59a066a09
X-HE-Tag: brake84_8b4a59a066a09
X-Filterd-Recvd-Size: 3143
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com [67.231.145.42])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 22:29:17 +0000 (UTC)
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7CMS41U029348
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:29:15 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=qiofHP19MlmvHdnj3l6VS7qqrTUvd1N7ucXGb2hoq9Y=;
 b=cWbc/657cZcEAPWc56tMtbVX3CK9tBi+AGft2GYziIy8AZ1v/UMfBB+t9JX5quMd5O9s
 d5HrnmFO1XrJ7ILnOYgFPikSOL9cEBAnaoQPzl0qWHVhWOA1h7yIOjrfLup1VgnWji4e
 xiGax47wfqKNW4h6WslxAFzcyDDj1Ng2pCk= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2ubgft83j1-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 12 Aug 2019 15:29:15 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 12 Aug 2019 15:29:15 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 182E9163FCBF4; Mon, 12 Aug 2019 15:29:14 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH 0/2] flush percpu vmstats
Date: Mon, 12 Aug 2019 15:29:09 -0700
Message-ID: <20190812222911.2364802-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-12_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=551 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908120218
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

While working on v2 of the slabs vmstats flushing patch, I've realized
the the problem is much more generic and affects all vmstats, not only
slabs. So the patch has been converted to set of 2.

v2:
  1) added patch 1, patch 2 rebased on top
  2) s/for_each_cpu()/for_each_online_cpu() (by Andrew Morton)

Roman Gushchin (2):
  mm: memcontrol: flush percpu vmstats before releasing memcg
  mm: memcontrol: flush percpu slab vmstats on kmem offlining

 mm/memcontrol.c | 59 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

-- 
2.21.0


