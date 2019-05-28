Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15DC5C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:49:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CED252070D
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 06:49:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CED252070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AA326B0270; Tue, 28 May 2019 02:49:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 680AC6B0276; Tue, 28 May 2019 02:49:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570846B0278; Tue, 28 May 2019 02:49:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3A07A6B0270
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:52 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b189so18133910ywa.19
        for <linux-mm@kvack.org>; Mon, 27 May 2019 23:49:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=uJPrBhJHfig/Leoub8OHrF7gZBq4Quq56TmGKhnJqtE=;
        b=CZ0b0DWVI8fCJ+aBndLMMpw3bgdia+H6NLeLU+AU//YIhOUgObiDG46h3wohv73hHg
         LhScufsxWjlLn5L9wszFeh8opLAJLwh3rweWyH3AexpBqhp/hKbx5FdBBdZrVG04afvN
         M3XDmPDRvJFFf37tE94ggI8PHIjxyzHbA2Wif4+FCa4SKWEj4m2Jf8G2XUHb9b43/hBk
         RDDKh/ZetLy1Anrm+lngR5TC0S+HvO0xhqe+vPQCSvTODw0YxanKJ2f5d9weXZaA8Tol
         MSJuH0tB3TpqsAAur3IYz0WE4uJmqBMLcmOu3uXJCoD/4u4/CphRe11qbIbctngENmB0
         oxBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX+1ZZTU6wAjY1yrmfrl0j7ie4TtGq3mrgq9tJTIgnfPsQnhcjt
	oedE5kX8wGJAJHpIrDHE1dTDq03igHm2BGMECZICsKegmy28R+18UT3Co5UUh113wSrBp6u0xeb
	S2EioClgspN/9UsshQT98UgT0JJDhWxfnQxVB1gelg0XTkMoSKg86AUUWrjUv96k0Wg==
X-Received: by 2002:a25:6641:: with SMTP id z1mr7424414ybm.63.1559026191977;
        Mon, 27 May 2019 23:49:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ0I3K89uoplWq3S0BrQuPgis3/2DzBomXKShGpo73zcILBhPbClO43JgwlIvdlYdvd1gj
X-Received: by 2002:a25:6641:: with SMTP id z1mr7424401ybm.63.1559026191259;
        Mon, 27 May 2019 23:49:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559026191; cv=none;
        d=google.com; s=arc-20160816;
        b=J2eSIrEJiQlTNAeAA2t1h+VJCiWOlWzbyjbnlEg2oedWfy2nTNqo7+5/K2EMbkegAI
         UtvUx+m7SxRVR+eU92unKkHhpWfziO2E2JbiFG6TwaTH2le6ZLPR4Qayvl6C12zVfJHR
         yRFsPfn99Y5C+/NI1+5UvCwGIX3QJdJU1xaIwfLpsS0vDC/XkCOPnJYz6xAiMGeunBn/
         t3k6TrFSFoQUQD7FI/MHATgFGP4zchj1tX2Wd1gBTatOR3SeDUUfP7fbfE51nq4jCO1S
         jVEJFIgpgVqynxmATeCvHD31A7637t10kc+B/WZAjgHJlOFH+rlrS46CWDLMaR6ZpfBJ
         WnVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=uJPrBhJHfig/Leoub8OHrF7gZBq4Quq56TmGKhnJqtE=;
        b=AiWy2E85WKD69ZPQpse65CwZgljUSQfqXxMjLCIkG2rZ65ooZhLfn658gqxslxvcVg
         aBrq5DrJqN6AOF6xFX7xy0WLKS3iN/QwyqwJZYgxCahLTEwKkbkvbxhas95ZLaFu39oW
         NGwm26GiBFmitR/fxA01E7dDSplScO4e3Ox+E/vmFpuy0h5kRUO7wREjOx8iu2dIJJXF
         Ao1qq2lq0r0v/fVvEEWvXhVQI1Wcbh2+f+LuX3KmUAxjoFECVGhgEUjsSK55xyBdOcC4
         ln1YrKqsbVNd6v4nAnrgfdwKivcsDftIb+jn6s/12lRIveTRo9uYS/WwXYbvxZmnuoQQ
         o7/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t127si4404054ywf.410.2019.05.27.23.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 May 2019 23:49:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4S6bsrf105767
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:50 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2srxxm29kq-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 May 2019 02:49:50 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Tue, 28 May 2019 07:49:48 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 28 May 2019 07:49:46 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4S6niUS47316996
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 06:49:44 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7242C11C04A;
	Tue, 28 May 2019 06:49:44 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BA5F011C04C;
	Tue, 28 May 2019 06:49:42 +0000 (GMT)
Received: from bharata.in.ibm.com (unknown [9.124.35.100])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 28 May 2019 06:49:42 +0000 (GMT)
From: Bharata B Rao <bharata@linux.ibm.com>
To: linuxppc-dev@lists.ozlabs.org
Cc: kvm-ppc@vger.kernel.org, linux-mm@kvack.org, paulus@au1.ibm.com,
        aneesh.kumar@linux.vnet.ibm.com, jglisse@redhat.com,
        linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com, Bharata B Rao <bharata@linux.ibm.com>
Subject: [PATCH v4 0/6] kvmppc: HMM driver to manage pages of secure guest
Date: Tue, 28 May 2019 12:19:27 +0530
X-Mailer: git-send-email 2.17.1
X-TM-AS-GCONF: 00
x-cbid: 19052806-0020-0000-0000-000003411FD2
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052806-0021-0000-0000-0000219419A1
Message-Id: <20190528064933.23119-1-bharata@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-28_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905280045
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

A pseries guest can be run as a secure guest on Ultravisor-enabled
POWER platforms. On such platforms, this driver will be used to manage
the movement of guest pages between the normal memory managed by
hypervisor (HV) and secure memory managed by Ultravisor (UV).

Private ZONE_DEVICE memory equal to the amount of secure memory
available in the platform for running secure guests is created
via a HMM device. The movement of pages between normal and secure
memory is done by ->alloc_and_copy() callback routine of migrate_vma().

The page-in or page-out requests from UV will come to HV as hcalls and
HV will call back into UV via uvcalls to satisfy these page requests.

These patches apply and work on top of the base Ultravisor patches
posted by Claudio Carvalho at:
https://lists.ozlabs.org/pipermail/linuxppc-dev/2019-May/190694.html

In this version, the last two patches are the new additions.

Changes in v4
=============
- Handling HV side page invalidations by issuing UV_PAGE_INVAL ucall
- Handling HV side radix page faults by sending the page to UV
- Support for rebooting a secure guest
- Some cleanups and code reorgs

v3: https://lists.ozlabs.org/pipermail/linuxppc-dev/2019-January/184731.html

Bharata B Rao (6):
  kvmppc: HMM backend driver to manage pages of secure guest
  kvmppc: Shared pages support for secure guests
  kvmppc: H_SVM_INIT_START and H_SVM_INIT_DONE hcalls
  kvmppc: Handle memory plug/unplug to secure VM
  kvmppc: Radix changes for secure guest
  kvmppc: Support reset of secure guest

 arch/powerpc/include/asm/hvcall.h         |   9 +
 arch/powerpc/include/asm/kvm_book3s_hmm.h |  41 ++
 arch/powerpc/include/asm/kvm_host.h       |  37 ++
 arch/powerpc/include/asm/kvm_ppc.h        |   4 +
 arch/powerpc/include/asm/ultravisor-api.h |   6 +
 arch/powerpc/include/asm/ultravisor.h     |  47 ++
 arch/powerpc/kvm/Makefile                 |   3 +
 arch/powerpc/kvm/book3s_64_mmu_radix.c    |  19 +
 arch/powerpc/kvm/book3s_hv.c              |  69 +++
 arch/powerpc/kvm/book3s_hv_hmm.c          | 666 ++++++++++++++++++++++
 arch/powerpc/kvm/powerpc.c                |  12 +
 include/uapi/linux/kvm.h                  |   1 +
 tools/include/uapi/linux/kvm.h            |   1 +
 13 files changed, 915 insertions(+)
 create mode 100644 arch/powerpc/include/asm/kvm_book3s_hmm.h
 create mode 100644 arch/powerpc/kvm/book3s_hv_hmm.c

-- 
2.17.1

