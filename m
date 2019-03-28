Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDB9AC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:19:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 651C8206B6
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 17:19:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="CW501BxZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 651C8206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC4876B000C; Thu, 28 Mar 2019 13:19:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D73B16B000D; Thu, 28 Mar 2019 13:19:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C896B6B000E; Thu, 28 Mar 2019 13:19:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1026B000C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 13:19:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f7so4519182pgi.20
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 10:19:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:organization:subject:to:cc
         :message-id:date:user-agent:mime-version:content-transfer-encoding;
        bh=R/scbyalWWcAwYGjv7u5zfaf41OVbAOWWKozyYWY7cs=;
        b=d9vBKMcluZEWmnhvaYVvNE7JwUrfc4iN+NlOND3ersYgiepk3KLnzOLDqWUn0nGMVf
         fjEO/o44VH25byKmqBw/DiFkbCap4nQjHv7CMvBw5SfYmNY4Gm8Ndufwh2Goort0F9cI
         rqOU66NLGlwsKFyUp7rg7qG6woE7IHTAqbdonzUO7+TpPEaUkc0v+OCvxL65PuPv7Q0m
         3jw29sU190rmDrMImxSVE8Pvt/SXz4yrKRYZD6fAagBDcKixHM6rLEIZKfyo9Pfm5CC3
         35K404nx+HNrd3XpDjsoU8FDjKY5kNsz0NXbRyOAqCR/ggv72Hmt1nAppIumnYcbAf4l
         0URg==
X-Gm-Message-State: APjAAAV67j20Lv2HbegwQI4/oZP3rcc0Zf9fXtdDTX4MS/nIpQ3L8zCC
	WfYn0cbvNu6/TUmm2MfkVib+1dQJDEzJzON/drnF7aq45AR5nu8rzfZXfYvfGYQHW0orgi2Z0Lv
	eT0TU8BNz/E6zRm1PUNoUD1i0zTmFAdSjUYQENqYKfYLJ17aFu/uSiYJWdbNHyFbVgQ==
X-Received: by 2002:a63:2045:: with SMTP id r5mr40505391pgm.394.1553793554997;
        Thu, 28 Mar 2019 10:19:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzEmf1go1cFVD5Pbj9854Q2HgWvxvSoc6v76oFLvzzqzeSBkDvLzIuDaQjIjQyP1oIxDLSs
X-Received: by 2002:a63:2045:: with SMTP id r5mr40505311pgm.394.1553793554070;
        Thu, 28 Mar 2019 10:19:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553793554; cv=none;
        d=google.com; s=arc-20160816;
        b=jyoC4wo9t6kjicB6y6otV1DkCb/tq4BL5XGxDCXS1oO2T6t/vTzSJpwlQLFZ9swsTo
         uqg+Y/0wqxNeSDX2OYpTNpXYUudjsgJjYrUVxbXQLfCkviyJG+1URljIUkeOKZjhZlk8
         Hg+uNbxUSpLYkU/3YzibN5M2n4M7BAJ7XZnyEDawU34FeqfEJWYJSKxTVYbm1fn4W320
         BZNmt5uYJX53ma39K67oZqUp/4GsaeFh8iu24Z/Cfai8GwyFSqYE6XXBZYtPL6lwhe6/
         jYj89tyUiVYxlXkmXEl6bYYdsMrjjZHQZ3bzsb/0ciO8hVOYt6mOkYmJOApHAqspWnMy
         uxCg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:date:message-id
         :cc:to:subject:organization:from:dkim-signature;
        bh=R/scbyalWWcAwYGjv7u5zfaf41OVbAOWWKozyYWY7cs=;
        b=mvxb7w6zyGPNbZ80kvvmU4o5qux8ybiH768gHjdMuMcy8ofND7EUAdno/J8GgVY1sV
         XubHGOmyXdVqoUuIDXM00EdDFHOaN3zQHXKRsV/QqOL0B6EyMbOhXjnfQdfjPmmiqs6q
         DLmAP7apraRjjScNnAY1IqxUZJ0MTjBrdRTS+QOrmG6fpuAes74Un2S9bToEgeyl4YmQ
         EhQBZWYpaitIk96f0jZCs6xdK2RvlacoJ72+KYFDukyN+TmSYP34nTrUQZS2JzBHrLKn
         +XH98rJaSxNP8fFT6tNiLBulTJ5LRGTmT024CTXuJgIAZJUxvxFf1Dz/Bz3fTcncGUd4
         eqxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=CW501BxZ;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j184si3135652pfb.106.2019.03.28.10.19.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 10:19:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=CW501BxZ;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2SH9J0M014186;
	Thu, 28 Mar 2019 17:19:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : subject : to :
 cc : message-id : date : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=R/scbyalWWcAwYGjv7u5zfaf41OVbAOWWKozyYWY7cs=;
 b=CW501BxZpPkrM3zRCMdSbf/BzZWUCtkmyU84K48Lp82D3ip5K5Vo8VSpl5sMaJ6wrXI6
 kgVEVvtqfo0lo7R2l1QEtl5S/rz2A05FXZV7zOTRwPRZMRoOAsa7l4r1/LB1f+UMadMT
 47p0BiqD65aEnJ1RM6LqWXnxSWaj7lEiqWGNBFJcaMiZ3G7GwZ5n6F3u3ehFWCLNY0M9
 kli/s1VOLXvyGh3uslsAQySTl7RsSZ6DtxqeBH6itV0SPbni1xDZaPkz75NMi3Aapcij
 P55Yq6ibUNU992DcZZoMx5+dNmNF3jyeX4BUQbcgdccfb0qv0YWYDXyVK0aOpy2AoGAT PQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2re6g182bs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:19:09 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x2SHJ3Ex015790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Mar 2019 17:19:03 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x2SHJ08N021335;
	Thu, 28 Mar 2019 17:19:01 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Mar 2019 10:19:00 -0700
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Subject: [LSF/MM ATTEND] Address Space Isolation for KVM
To: lsf-pc@lists.linux-foundation.org
Cc: jwadams@google.com, James.Bottomley@hansenpartnership.com,
        rppt@linux.ibm.com, linux-mm@kvack.org, pjt@google.com,
        Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
        Alexandre Chartre <alexandre.chartre@oracle.com>
Message-ID: <806eb206-d0e4-3362-4e33-d9563269f016@oracle.com>
Date: Thu, 28 Mar 2019 18:18:57 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.6.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9209 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903280114
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi,

I am from the Oracle Linux kernel and virtualization team, and I am investigating
address space isolation inside the kernel.

I am working on a set of patches to have parts of KVM run with a subset of the kernel
address space. The ultimate goal would be to be able to run KVM code between a VMExit
and the next VMResume with a limited address space (containing only non-sensitive data),
in order to prevent any potential data stealing attack.

I am in conversation with Jonathan Adams about this work, and we would like guidance
from the community about this idea, and feedback about the patches currently in progress.
I will be happy to co-join to present the work done so far, to discuss problems and
challenges we are facing, and brainstorm any idea about address space isolation inside
the kernel.

Here is an overview of the changes being made:

  - add functions to copy page tables entries at different level (PGD, P4D, PUD, PMD, PTE),
    and corresponding functions for clearing/free.

  - add a dedicated mm to kvm (kvm_mm) for reducing the address space. kvm_mm is built
    by copying mapping from init_mm. The challenge is to identify the minimal set of
    data to map so that the task can at least run switch_mm() to switch the page table
    (and switch back). Current mappings are: the entire kernel text, per-cpu memory,
    cpu entry area, %esp fixup stacks, the task running kvm (with its stack, mm and pgd),
    kvm module, kvm_intel module, kvm vmx (with its kvm struct, pml_pg, guest_msrs,
    vmcs01.vmcs), vmx_l1d_flush_pages.

  - add a page fault handler to report unmapped data when running with the KVM reduced
    address space. The handler automatically switches to the full kernel address space.
    This is based on an original idea from Paul Turner.

  - add switches to the kvm address space (before VMResume) and back to the kernel address
    space when we may access sensitive data (for example when exiting the vcpu_run() loop,
    in interrupts, when we are scheduled...). This is based on original work from Liran Alon.


Thanks for your consideration. I will be happy to provide more information and to join any
discussion about this topic.


Rgds,

alex.

