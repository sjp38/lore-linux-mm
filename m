Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AB45C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 08:27:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1AA1218D3
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 08:27:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1AA1218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 516896B0003; Fri, 22 Mar 2019 04:27:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C5BE6B0006; Fri, 22 Mar 2019 04:27:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38DCF6B0007; Fri, 22 Mar 2019 04:27:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 147AA6B0003
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:27:47 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c67so1298128qkg.5
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 01:27:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=6PCprYjSQ8nK1qQbbDL5bDbJHXu2HcEcregW4qAnVmA=;
        b=FHCXCbejZ2GmAp2p0eNV9BazxuYvFo5v9b1cYYhaAHjzz2SIaY6eQAYwB3qwb+o7l5
         NBI4AV3HcjqKDa4ItTTSFfG7OVaQyUb4BZ7rszSu9LbcEOKzn0rHkevcyheoUiYAnYCR
         cICYMHNfx/vzFQEU/+GD5sfDYalZEZQuuDAcD3D591y2AlYPfKTrkqJXyUVDTKRZL0/l
         wS8dRu9K9gYMM66FPsTf5+xi71pD3d5Ppb6XoylBqMD+YXf1izUgNIxltADQZiYxP+Db
         aqs5fbSjb1fNqgYWEkFQbyjJp/4btkraws+qS6p1jFZhy9VSlFIKTQXXcR4WLuvtb5fb
         gHAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVTIiwuPP28xg392NyCyd29oOzFYJ8qMMk/9Ceg1HG3Ca9rr0ux
	kFi7WaOTIlmrwb4AekaaJuNmPyy8uz8uNKhpUej+8rSVjFzc4BdHcGoeGmyPPLbZywqidPTngfQ
	LU2X9yUHi4dT7duuCj/Vs4tlG+5n/5IRkpfS0fL638fOcqSFTs6NLCw4dQZBZUdbqYA==
X-Received: by 2002:a0c:b00c:: with SMTP id k12mr6987995qvc.118.1553243266842;
        Fri, 22 Mar 2019 01:27:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwT1M7QI0MQjePkdcXkRQ3DBdHtBEPkhIu6uAETMTq0uwAr/0R6l/rCOKl437iPXv4nlVRz
X-Received: by 2002:a0c:b00c:: with SMTP id k12mr6987970qvc.118.1553243266165;
        Fri, 22 Mar 2019 01:27:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553243266; cv=none;
        d=google.com; s=arc-20160816;
        b=RBSp9OIzAdTylT2JadiOJwW2Smo9VstSr3C01GVdhyWmLPQhPa1k17iRr9Ebypnq5t
         LOVaDtw8IwvJXUfGwUQhErL1bhtgzOGQVJsKstLyVUE8C+6LVQ4dcQ2HHT1yqKCJEpHJ
         MprLDtfBlZGDMY9NfenBR+kZiIzBT9sNC05QmKJUFLGPodXyPfBwNMqjdfAynP9rSYpB
         gEzYn2A5YqAmCEHfshL58jyBPrYQ0ZTy461mvKSp27vXhp1N/ozHbAfBaf3j9GGHvChE
         YHpb88b0/48nsdlzJws8UoDNaMKN1M5wpESnWU6nyKSu2iFZjNJMER9p2UW1NTqYkqy/
         8weg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=6PCprYjSQ8nK1qQbbDL5bDbJHXu2HcEcregW4qAnVmA=;
        b=BJ1l//HGFIuBGXFrBgFyYIWnzpOjwKDvvAEi6IiipJiSy5DDwF3aorqVvaPYoKTGv8
         EclJuvovSvXL5gPGQBprzOS038umfyaRwo+B0G8EMmEXN4jTdeJ3OzMfTEMsgwuOWrdq
         yGPclsHt0xeGBJsA9YBKOJspApo5o6uuPWNviQgkx+G262RtpyOU2QpPW/N+CC1nCuY7
         Q9o/VG04ZY0fZXtmgMunjs00oFmCkIhJbY9ZxIY/GHcgimkuRaFWruTaK4cgGz97epm3
         ML4HKDDtAwh34Jgd9qOu5TMWATarPTM//+1SkSn7mddCBKFxhojEny2B1h4lOM8NY8lK
         wVlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z6si73258qke.0.2019.03.22.01.27.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 01:27:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2M8RjX3024469
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:27:45 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rct9ymc72-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 04:27:44 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Fri, 22 Mar 2019 08:23:47 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 22 Mar 2019 08:23:45 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2M8NmVu41812204
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Mar 2019 08:23:48 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4D50911C04C;
	Fri, 22 Mar 2019 08:23:48 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 73FDC11C04A;
	Fri, 22 Mar 2019 08:23:46 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.68.197])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 22 Mar 2019 08:23:45 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
        Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: page_mkclean vs MADV_DONTNEED race
In-Reply-To: <20190321163147.cc2ff090a7388cdb7030eed0@linux-foundation.org>
References: <20190321040610.14226-1-aneesh.kumar@linux.ibm.com> <20190321163147.cc2ff090a7388cdb7030eed0@linux-foundation.org>
Date: Fri, 22 Mar 2019 13:53:42 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19032208-0012-0000-0000-00000305D4AD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032208-0013-0000-0000-0000213CEF9A
Message-Id: <8736nf8ghd.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903220065
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 21 Mar 2019 09:36:10 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> wrote:
>
>> MADV_DONTNEED is handled with mmap_sem taken in read mode.
>> We call page_mkclean without holding mmap_sem.
>> 
>> MADV_DONTNEED implies that pages in the region are unmapped and subsequent
>> access to the pages in that range is handled as a new page fault.
>> This implies that if we don't have parallel access to the region when
>> MADV_DONTNEED is run we expect those range to be unallocated.
>> 
>> w.r.t page_mkclean we need to make sure that we don't break the MADV_DONTNEED
>> semantics. MADV_DONTNEED check for pmd_none without holding pmd_lock.
>> This implies we skip the pmd if we temporarily mark pmd none. Avoid doing
>> that while marking the page clean.
>> 
>> Keep the sequence same for dax too even though we don't support MADV_DONTNEED
>> for dax mapping
>
> What were the runtime effects of the bug?

The bug was noticed by code review and I didn't observe any failures
w.r.t test run. This is similar to 

commit 58ceeb6bec86d9140f9d91d71a710e963523d063
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Thu Apr 13 14:56:26 2017 -0700

    thp: fix MADV_DONTNEED vs. MADV_FREE race
    
commit ced108037c2aa542b3ed8b7afd1576064ad1362a
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Thu Apr 13 14:56:20 2017 -0700

    thp: fix MADV_DONTNEED vs. numa balancing race
    
>
> Did you consider a -stable backport?

Considering nobody reported issues w.r.t MADV_DONTNEED I was not sure.

-aneesh

