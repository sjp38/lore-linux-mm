Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC770C73C6B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 04:50:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 71C3F20665
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 04:50:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 71C3F20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 139F18E0067; Wed, 10 Jul 2019 00:50:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EA8D8E0032; Wed, 10 Jul 2019 00:50:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF51F8E0067; Wed, 10 Jul 2019 00:50:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B832B8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 00:50:34 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x10so609551pfa.23
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 21:50:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version
         :content-transfer-encoding:message-id;
        bh=Rcm5OaZvShJUdKGLt53OBAUvsHpftRZu1WXRBqmJ5o0=;
        b=TkTc5WD6qfHFI6D/WOTBxbNZ/ZDAuenN9TToKt5QL+TFnC9ElDbGLs9N2cKPYPcyTM
         LohmnnN7vW39IswtB/InmeeI4aXyXtUCh9SGJRuFY91GUCVPV+tXf214dhc/ic20VChI
         sCqictxsmEoRzdzP3+f6TzmBq8Vg+sigS0V0oeTg+q5YWeNtBxHHL2YLpmnmKn2To7/i
         nWe/QSUTEDnXFVyhdgLS8SBtKlg/eF12/Cm/WKtUhUlf3G83R0sd4qk5S0G2eF7utrtb
         rExuCLbKmQ/sA7/XHW98dARJpADwNjXvqGP/QRTernLzAFwLAp4JiltnF5WEgo28abg+
         lABw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVp2aFP1FLebHAS0aeqAp2OXypF+CWs1NrXlY0NxBqAhl0KsCwN
	wApzlEzpmLOOuiQuQ/q3IGqSexijA11XjsacgpHXoox/BDMPVUnEQ6FurS7/GDCFc+Y/UPirkDu
	2WG89dBWAnoyg/odNWSi7S2YWodHDlXILZIYSaSPJhE7uSWYSxngph/B+gwQwIsGvmw==
X-Received: by 2002:a17:90a:c588:: with SMTP id l8mr4470946pjt.16.1562734234279;
        Tue, 09 Jul 2019 21:50:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCRmRgJr4sIlKhin6ltKtEOjVWdd1BmSNph/IGQAVTH8ycPSylBc4ImGDzD1PO/Ar8h3Ny
X-Received: by 2002:a17:90a:c588:: with SMTP id l8mr4470850pjt.16.1562734233105;
        Tue, 09 Jul 2019 21:50:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562734233; cv=none;
        d=google.com; s=arc-20160816;
        b=R+5Mx+PN2buTLD2RllodkdnRxVeHl7l7xn+UEKtf95Spc10NRJJ+1Pn5W2doZ9LOEa
         iyZZFL6vhgTLJwAXxSNpqWRnG0Jt7uCMCkiWPjjcQ3JOlKl9pzRBYSmMZTpYxkRrW+84
         PIdwwm5Ub7Lm6VpUBzTCoqr8/m3WyBWvuEuppHjA/wKNCdQT8+RhWO4xr1XwpJq14dPT
         zfATesQ+WLFxLlC+ID5+QgKUL25HztIICXSN4oQZfToxGzkPkL7yqpQ4el6Iuwk61mTt
         2IjeQgbDbOznY+0Mx6N+OFYAyVzuQ6qG+QWapjMT5V1BD//4C0pobbWn5WtoNthOHljC
         iNpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:references
         :in-reply-to:subject:cc:to:from;
        bh=Rcm5OaZvShJUdKGLt53OBAUvsHpftRZu1WXRBqmJ5o0=;
        b=fXE0wihSToVUwZ3lmy+SqzOCBU2eycFmg2ulsFAh9LIiQYTeYq6rwfbtTEztpvKc3y
         qGEYbq4KYkGbqWdbqAta9t783KFRcKUapTJn165caWachOIxUdSbu7yvx8gIi9FSm6yW
         sXy85KyOQMHlG94AJkcsYVgMSz43sUOadJKBCNZtTM/mNUcedbDtawKFXAJs03amrtcu
         mv4FAJacOOGSFyf+78JuEh4WUOYEoxMiA6I1tlpx3HUebkeIYyhKSpSbI82WWYjhnTXe
         zKA32eWnxo437EERxH8aFaEDMG1mggJwtcbICp3GFgff7k9ekNV13VX57k5gkBeU1DSv
         o7UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d8si1138036pgv.61.2019.07.09.21.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jul 2019 21:50:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6A4laAG074912
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 00:50:32 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2tn985g69n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 00:50:32 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 10 Jul 2019 05:50:30 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 10 Jul 2019 05:50:28 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6A4oRhf49938626
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Jul 2019 04:50:27 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 087C7A4051;
	Wed, 10 Jul 2019 04:50:27 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2F705A4040;
	Wed, 10 Jul 2019 04:50:26 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.35.64])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 10 Jul 2019 04:50:26 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v4 0/6] Fixes related namespace alignment/page size/big endian
In-Reply-To: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
References: <20190620091626.31824-1-aneesh.kumar@linux.ibm.com>
Date: Wed, 10 Jul 2019 10:20:24 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-TM-AS-GCONF: 00
x-cbid: 19071004-0012-0000-0000-00000330D993
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071004-0013-0000-0000-0000216A40BD
Message-Id: <87o9221oj3.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-10_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=892 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907100058
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Dan,

Can you merge this to your tree?

-aneesh
"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> This series handle configs where hugepage support is not enabled by defau=
lt.
> Also, we update some of the information messages to make sure we use PAGE=
_SIZE instead
> of SZ_4K. We now store page size and struct page size in pfn_sb and do ex=
tra check
> before enabling namespace. There also an endianness fix.
>
> The patch series is on top of subsection v10 patchset
>
> http://lore.kernel.org/linux-mm/156092349300.979959.17603710711957735135.=
stgit@dwillia2-desk3.amr.corp.intel.com
>
> Changes from V3:
> * Dropped the change related PFN_MIN_VERSION
> * for pfn_sb minor version < 4, we default page_size to PAGE_SIZE instead=
 of SZ_4k.
>
> Aneesh Kumar K.V (6):
>   nvdimm: Consider probe return -EOPNOTSUPP as success
>   mm/nvdimm: Add page size and struct page size to pfn superblock
>   mm/nvdimm: Use correct #defines instead of open coding
>   mm/nvdimm: Pick the right alignment default when creating dax devices
>   mm/nvdimm: Use correct alignment when looking at first pfn from a
>     region
>   mm/nvdimm: Fix endian conversion issues=C2=A0
>
>  arch/powerpc/include/asm/libnvdimm.h |  9 ++++
>  arch/powerpc/mm/Makefile             |  1 +
>  arch/powerpc/mm/nvdimm.c             | 34 +++++++++++++++
>  arch/x86/include/asm/libnvdimm.h     | 19 +++++++++
>  drivers/nvdimm/btt.c                 |  8 ++--
>  drivers/nvdimm/bus.c                 |  4 +-
>  drivers/nvdimm/label.c               |  2 +-
>  drivers/nvdimm/namespace_devs.c      | 13 +++---
>  drivers/nvdimm/nd-core.h             |  3 +-
>  drivers/nvdimm/nd.h                  |  6 ---
>  drivers/nvdimm/pfn.h                 |  5 ++-
>  drivers/nvdimm/pfn_devs.c            | 62 ++++++++++++++++++++++++++--
>  drivers/nvdimm/pmem.c                | 26 ++++++++++--
>  drivers/nvdimm/region_devs.c         | 27 ++++++++----
>  include/linux/huge_mm.h              |  7 +++-
>  kernel/memremap.c                    |  8 ++--
>  16 files changed, 194 insertions(+), 40 deletions(-)
>  create mode 100644 arch/powerpc/include/asm/libnvdimm.h
>  create mode 100644 arch/powerpc/mm/nvdimm.c
>  create mode 100644 arch/x86/include/asm/libnvdimm.h
>
> --=20
> 2.21.0

