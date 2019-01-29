Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8617C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:15:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91BDD20880
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:15:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91BDD20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=de.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 283358E0002; Tue, 29 Jan 2019 08:15:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2338F8E0001; Tue, 29 Jan 2019 08:15:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D5758E0002; Tue, 29 Jan 2019 08:15:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA4698E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:15:03 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id i124so13908381pgc.2
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:15:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:references:mime-version:message-id
         :content-transfer-encoding;
        bh=hAF8WrPFKj5s+aR6qFYjS7obZpGr42T38qNl+vDkoGI=;
        b=IKm1EnAo4QF5dVOAhNlgztFGrru2AVOMsvONORG40BZOzb8dhPptGS1G1GFQcEaVpy
         VklCUXijLgBmufO3wcHWRNMRWESFUf2h0KMA756qFgizrlVnNmeB3dd9lj2sEWlpET9B
         Y9MSfPEc0+znLxXx72rXwIEpKtCMUdPgyHpSMvGsQA9i+9UnuJEWGEf6nxN4lzstBz9Z
         WyHNZ7qrAJcO5bUYYp04MLO/nlXCLy5C5CU7qrLlqCcwrq8IazA74Y/rlFcfq49i10PL
         PhbXigdv1+mDQ+nclNYFO6HLrAbkTkTFi20NaXHDiZeVOYZhUNsHX7ybBi/7z0NOR/Of
         84zg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukfHXkG5dnhBh0RHgyZ1m8FzVZ8S1MmfL3RIWEjWRN/NVBBfFOYL
	dgUCCpiyK0jooDqx35zZWHsHrURZWauP1IbHOOUgpdT81yeFVw90m07H6OLQbbTy1W0iH07BBGM
	vwNl76xXv/zjYSXoYgYx+w9UYdoRO+rlqf80z+IVe0CDK7Imt3WMMvaTy2e/dfKE41A==
X-Received: by 2002:a62:3c1:: with SMTP id 184mr26373728pfd.56.1548767703386;
        Tue, 29 Jan 2019 05:15:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4bw2xvv3uXKPEozBBv8zLU4VFOA6EMdD1Dt7QxI5Btaq7HKm/V5vukxz0TKPIv5spt3vyk
X-Received: by 2002:a62:3c1:: with SMTP id 184mr26373670pfd.56.1548767702603;
        Tue, 29 Jan 2019 05:15:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548767702; cv=none;
        d=google.com; s=arc-20160816;
        b=ulSFpiGV4ZH0vuGNk9e39QkeUZWEEmuC1qVB0rJgj7LfBYQ/n5QWJOJOGudS+AalD1
         /FZuNGdllywLrbgjRYgd6+Z6TW3H4dw5pAr4PUWVRUnsLW65wYzdQ/IiXU6rPYbFSP7l
         XkNKaqT2F7EjCyDv33EcKnaptX/tLpHZ7x/A7X9g+UOr223aGHv/OI2RYttAhTZwQvbR
         rYstZiHKtljJ1X0H/E/TEtEEVH/SMxd7aSGAgwwwgGWj/JWEkzU5Zqj23s2BhJUjCqWD
         FYtLGyvmfywEwE2AoQ917HF+QRRLpJ6pOgQtyg8Y5cVs7F5vue3BVxGHKRtvNBPZtzVK
         9COA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:message-id:mime-version:references
         :in-reply-to:subject:cc:to:from:date;
        bh=hAF8WrPFKj5s+aR6qFYjS7obZpGr42T38qNl+vDkoGI=;
        b=x5MWtQ4u0usNj6Jr0CmW0My3ssVhu9/XOP2uM2u4h/Z0FalCN5DeeiOTeXWCZkZ5ON
         IAAsN+AxW2hlJaJMDBnkvqxmgwGZtHaJw9gHp1OeD85E3Gtbt5kuX3IR7OaNkbdxpMIS
         UbBea3SRfLMTJskiFgIHF1RyNT4/zTC+iIeo0+lAMMWKgQlDKYgVhhJeMnXNb/eS2q68
         ewRqDIJOFVoCaGratmfWKsWe0E1pnddtHpB1flOPxDoPsrUjTRLTASEBFj3HRQEiLlF4
         yZYChTlmqg4AWHicFdkHtLho2s/Fd+fHGTvgGjXwFXL1HXZ7aVfdmANy8+DoAThARxIO
         aciQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s2si21930404pgj.60.2019.01.29.05.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 05:15:02 -0800 (PST)
Received-SPF: pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gerald.schaefer@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gerald.schaefer@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0TDCxOY105888
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:15:02 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qanm56qgh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:15:01 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Tue, 29 Jan 2019 13:14:54 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 29 Jan 2019 13:14:51 -0000
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0TDEoFl61735050
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 29 Jan 2019 13:14:50 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 58B3B42047;
	Tue, 29 Jan 2019 13:14:50 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F28C04204D;
	Tue, 29 Jan 2019 13:14:49 +0000 (GMT)
Received: from thinkpad (unknown [9.152.99.81])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 29 Jan 2019 13:14:49 +0000 (GMT)
Date: Tue, 29 Jan 2019 14:14:47 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mikhail Zaslonko <zaslonko@linux.ibm.com>,
        Mikhail Gavrilov
 <mikhail.v.gavrilov@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel Tatashin <pasha.tatashin@soleen.com>, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, <linux-mm@kvack.org>,
        LKML
 <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 0/2] mm, memory_hotplug: fix uninitialized pages
 fallouts.
In-Reply-To: <20190128144506.15603-1-mhocko@kernel.org>
References: <20190128144506.15603-1-mhocko@kernel.org>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-redhat-linux-gnu)
MIME-Version: 1.0
X-TM-AS-GCONF: 00
x-cbid: 19012913-0008-0000-0000-000002B775A7
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19012913-0009-0000-0000-00002223B856
Message-Id: <20190129141447.34aa9d0c@thinkpad>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-29_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901290099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019 15:45:04 +0100
Michal Hocko <mhocko@kernel.org> wrote:

> Hi,
> Mikhail has posted fixes for the two bugs quite some time ago [1]. I
> have pushed back on those fixes because I believed that it is much
> better to plug the problem at the initialization time rather than play
> whack-a-mole all over the hotplug code and find all the places which
> expect the full memory section to be initialized. We have ended up with
> 2830bf6f05fb ("mm, memory_hotplug: initialize struct pages for the full
> memory section") merged and cause a regression [2][3]. The reason is
> that there might be memory layouts when two NUMA nodes share the same
> memory section so the merged fix is simply incorrect.
> 
> In order to plug this hole we really have to be zone range aware in
> those handlers. I have split up the original patch into two. One is
> unchanged (patch 2) and I took a different approach for `removable'
> crash. It would be great if Mikhail could test it still works for his
> memory layout.
> 
> [1] http://lkml.kernel.org/r/20181105150401.97287-2-zaslonko@linux.ibm.com
> [2] https://bugzilla.redhat.com/show_bug.cgi?id=1666948
> [3] http://lkml.kernel.org/r/20190125163938.GA20411@dhcp22.suse.cz

I verified that both patches fix the issues we had with valid_zones
(with mem=2050M) and removable (with mem=3075M).

However, the call trace in the description of your patch 1 is wrong.
You basically have the same call trace for test_pages_in_a_zone in
both patches. The "removable" patch should have the call trace for
is_mem_section_removable from Mikhails original patches:

 CONFIG_DEBUG_VM_PGFLAGS=y
 kernel parameter mem=3075M
 --------------------------
 page:000003d08300c000 is uninitialized and poisoned
 page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
 Call Trace:
 ([<000000000038596c>] is_mem_section_removable+0xb4/0x190)
  [<00000000008f12fa>] show_mem_removable+0x9a/0xd8
  [<00000000008cf9c4>] dev_attr_show+0x34/0x70
  [<0000000000463ad0>] sysfs_kf_seq_show+0xc8/0x148
  [<00000000003e4194>] seq_read+0x204/0x480
  [<00000000003b53ea>] __vfs_read+0x32/0x178
  [<00000000003b55b2>] vfs_read+0x82/0x138
  [<00000000003b5be2>] ksys_read+0x5a/0xb0
  [<0000000000b86ba0>] system_call+0xdc/0x2d8
 Last Breaking-Event-Address:
  [<000000000038596c>] is_mem_section_removable+0xb4/0x190
 Kernel panic - not syncing: Fatal exception: panic_on_oops

