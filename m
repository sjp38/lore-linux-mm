Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43983C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 05:03:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AA3C20857
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 05:03:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AA3C20857
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CA2C8E0002; Thu, 31 Jan 2019 00:03:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 828788E0001; Thu, 31 Jan 2019 00:03:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C8CD8E0002; Thu, 31 Jan 2019 00:03:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1F97B8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:03:47 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id s71so1572706pfi.22
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 21:03:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=6ng/zvHN5Yf9T6rBQSJcB76/w96fjUWir5C4Z5RIhpI=;
        b=mscq/YgBUpQa5ZsdjZyfI7poEE1uMhlqzO77tSPttdw/+xEsLsVppOmnbfVnuWHiI1
         yIR0AUELj2o8f6sznYzsPl/qccc5trwS2ikB5lU6gmBOBqPOi7Dp0rGX3H4y+xe3xDrd
         dvtYIUg4ngUyFb+Q/s9BQbmVouMFJ90zc5uKsp+OXuAQWJM/6MINkPGsDrhcuYncphCO
         UitmVyWEdtmLmcckxEURPUFcl3hbontKlSlHT+wXBiwKRx/VIMDIgiCwbQXxbNQa+dw4
         Amw4yUqUHYHabR0X9I653n2bZvor3RS5H6GNqYP45vLKgNs5ksdEXxRXxitBl/+ZGbiC
         zM0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukeR1fn7br5fV6vSZHOG6phTaD4VgV6eYgsLeMMHTfo1/D5MXuJv
	cqvY58n9tXe9QlHJX/WlGBXmQK0rnnkA8JKXbowDoq5nLR0hMf3g2qdzd7oTv6135/mQwgee8rU
	ubTXk/f+ffGWYEk3TA8rX6IXE3fSWEvXqM3+2MpNMIqVLEGVFPq/sXT8CnDzKRb/UQQ==
X-Received: by 2002:a62:16d6:: with SMTP id 205mr33213216pfw.256.1548911026763;
        Wed, 30 Jan 2019 21:03:46 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4RWhqIM8L+kZU23qWxRENtJ+SZbO7flMy8rLUMMVbPpdTyM7dCP79F6n1TYioB2Q5yAdxl
X-Received: by 2002:a62:16d6:: with SMTP id 205mr33213182pfw.256.1548911026065;
        Wed, 30 Jan 2019 21:03:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548911026; cv=none;
        d=google.com; s=arc-20160816;
        b=MlsGdQKMk7VAq183hVRSlWukW/TzoXFUbpqlh+0rTY6xCnUJcAPuMDU+chUNWCN6C0
         MOb57BUa3MRNpIwUYrMVvUO9BD/kIqo2zPvZ/kI/ZpovpKsNzl3bFme+mQPuxq4VT0U2
         2rta3RUGHpbdeCy7+cUFi7hJdXMkUtw28yWd10jZ5MzXb3JgnY0SDMHMz+WYCMwoIRYq
         nwL7syniVDM0oimgztkI2lXEh4hrKPYP+NKlttdl9zsVlXsNzZE4QQH8du6xKZcQ+XN5
         AkCt9ZdDCglPtnWiehkNF5SUpT8BT3bceq0GB7+fXA9HjVmdBlkuSa2A8+YKheYvG4qV
         8UNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=6ng/zvHN5Yf9T6rBQSJcB76/w96fjUWir5C4Z5RIhpI=;
        b=U6ZnKZrc/Hz+FMgPK3ZkD2GyB0TJnVqiW/nqBjM2p0zluiUb/Gd+IPU+kH0FB0plaU
         LLY62KJLTOnSteW9FpZzMkuqN8vxAiqITgg08tF9Y9Vud6R/T8YJX2/UKqnVQ4eDvr4U
         c9tPPIPFEnMZ02UmRkbc8WOHIyE1no+ZrXNQHE5n+K++scQXZOUWH2Cpn/5tSjT8goU+
         nj9wJ4UeU0KdAO8NHzuo7eXmxe07iugKMDuE2feBgXGTUhjmfznOpUuGrNYHb47fS0ME
         YyLhIgMhW7aghmSPFnTE5RWopmMstWJnSGgenut5cxgi0vfNTde0LuWl0SHLi2ijssAK
         6a3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t6si3472014pgn.258.2019.01.30.21.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 21:03:46 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0V4xLHm096750
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:03:45 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qbqwdnxp3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:03:45 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 31 Jan 2019 05:03:42 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 05:03:38 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0V53bGp57016466
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 05:03:38 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B176C11C04C;
	Thu, 31 Jan 2019 05:03:37 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A602811C04A;
	Thu, 31 Jan 2019 05:03:35 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.38.122])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 31 Jan 2019 05:03:35 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>, npiggin@gmail.com,
        benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org,
        x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org
Subject: Re: [PATCH V5 2/5] mm: update ptep_modify_prot_commit to take old pte value as arg
In-Reply-To: <87imy6qv74.fsf@concordia.ellerman.id.au>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com> <20190116085035.29729-3-aneesh.kumar@linux.ibm.com> <87imy6qv74.fsf@concordia.ellerman.id.au>
Date: Thu, 31 Jan 2019 10:33:34 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19013105-4275-0000-0000-00000308218A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013105-4276-0000-0000-00003816296C
Message-Id: <87munho1uh.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=780 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310039
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michael Ellerman <mpe@ellerman.id.au> writes:

> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
>
>> Architectures like ppc64 require to do a conditional tlb flush based on the old
>> and new value of pte. Enable that by passing old pte value as the arg.
>
> It's not actually the architecture, it's to work around a specific bug
> on Power9.
>
>> diff --git a/mm/mprotect.c b/mm/mprotect.c
>> index c89ce07923c8..028c724dcb1a 100644
>> --- a/mm/mprotect.c
>> +++ b/mm/mprotect.c
>> @@ -110,8 +110,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>>  					continue;
>>  			}
>>  
>> -			ptent = ptep_modify_prot_start(vma, addr, pte);
>> -			ptent = pte_modify(ptent, newprot);
>> +			oldpte = ptep_modify_prot_start(vma, addr, pte);
>> +			ptent = pte_modify(oldpte, newprot);
>>  			if (preserve_write)
>>  				ptent = pte_mk_savedwrite(ptent);
>
> Is it OK to reuse oldpte here?
>
> It was set at the top of the loop with:
>
> 		oldpte = *pte;
>
> Is it guaranteed that ptep_modify_prot_start() returns the old value
> unmodified, or could an implementation conceivably filter some bits out?
>
> If so then it could be confusing for oldpte to have its value change
> half way through the loop.
>

ptep_modify_prot_start and ptep_modify_prot_commit is the sequence that
we can safely use to do read/modify/update of a pte entry. Now w.r.t old
pte, we can't update the pte bits from software because we are holding
the page table lock(ptl). Now we could definitely end up having updated
reference and change bit. But we make sure we don't lose those by using
prot_start and prot_commit sequence.

-aneesh

