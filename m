Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E6FDC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 13:49:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EECDB2081C
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 13:49:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EECDB2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=de.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D19A6B0003; Fri,  3 May 2019 09:49:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85BAF6B0005; Fri,  3 May 2019 09:49:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72ADB6B0006; Fri,  3 May 2019 09:49:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 389E36B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 09:49:01 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id x2so2980563plr.21
        for <linux-mm@kvack.org>; Fri, 03 May 2019 06:49:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :message-id;
        bh=/uHni8/NAT19/dtSbEBALy/wFqOfy8eYAIE489pbGWY=;
        b=B1HWw849XKErwD+7rO0RBX+LTB2U7DDUFARz3t4k04FqZ+ybG3K9XNzgWfgkwt07Je
         zDe4tpLjcEwO2xV7SfaVt9s4sbzNQnD1aO+S3OLcK2022G3MPAqjlqawbFsN0bkI08+F
         gw3o6LJERAHKDX/7ZDognyVYOq4YXaCO8Cau99I3G5yFSh+brrcrG+vuETjMVFvXSKvH
         Zb1kAGShMB2t6pDlx0xTwQb93mzR6Jq9YuDXPecN2IGHT+zbHFlBfuIUkJuiqKUUgDe3
         WcMz84GB85hztL2J8J/jP1a/VLbrdmRPRtPjme6AA8hzAKFhpBYw/GIHjwWHyDnFpdTq
         9e/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of heiko.carstens@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=heiko.carstens@de.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXZO25TchbG0w7gsvWbFA+AjUkI0En+/W39o6a+ECQBYDpF7VWa
	Lns1Pa5VPKWSuJAk+TmCQSdG7uwJKiMFj77SiOOn57CyT9Wz2tjPLz14hRFmWHP/vmZHRByVzcw
	sEPCjWsxoHL8SJOjEHRSvh+6lPZq9kgFVAFNVHa1OztNGvCRu6WkxuGr9U3cUGF3APA==
X-Received: by 2002:a63:ed10:: with SMTP id d16mr10152535pgi.75.1556891340774;
        Fri, 03 May 2019 06:49:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyBsXK3Arba9LgJxEtlYdn5cTmMlwwn0sBL+emDtOJxt9I8Wj1YvioTD/LDb8qONpf7uuRA
X-Received: by 2002:a63:ed10:: with SMTP id d16mr10152446pgi.75.1556891339891;
        Fri, 03 May 2019 06:48:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556891339; cv=none;
        d=google.com; s=arc-20160816;
        b=uDrxi+hgaNuJ3OCQm8/A/5KdNoUHnEknYXGEPh9ea/WaIUmPUsFJIzbGO2Dwp6pGQg
         WWw55mcMIt9xAbG0zOcLhXwt4vwdw5O7jzbP7yvKF6tLN4Yk1FWpWOp3FByBfkXshOOE
         zmXwYfTTtE9wJdA5iHPTki4fQu5HPaW8YtTKsXsTBEBpnJjGYbkeAe4ZmL3x4MSp5NLQ
         BTRZs7MKK+wQGqMdw4bfSPgl/e4p3/xP/6Vm/4dLxQw3iUscUXSy0i68bXIxnZyVC0zl
         ebH6s1ekQIvhODiXFOarmGs5AZQuRkQUF5EHuzDOGK/YwxlzGeD+JXA+We3Uj9mPlTMr
         G5wA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:content-disposition:mime-version:references
         :subject:cc:to:from:date;
        bh=/uHni8/NAT19/dtSbEBALy/wFqOfy8eYAIE489pbGWY=;
        b=XQwmrHtOgrA6z3+yLTnb4Je9Vbv08fd004OXEaAkQoI8VCGLV3UtWdYPlzzkwe3eap
         oG/n6YB/zSCG7ymZZgHMzqpH5l9qQvtEWbqWqFrSVfUpTSIxsix2irRMApWXmin1/g1+
         M+5oTS9NdH7gwqFxwwe7/S+jDsKRWcCTsg6u+pgDQ31A9CUdLxvHQ4Ra0/NFiU9kWdef
         OtUl79T0KzqmN43OUoG+44MbIRRhvZxjuKvBPwaM/yTSnqkqNLBtAMR6VCarKtpmVwHe
         mw4LYpue5L//NMFQcGKOVHyDZ0SXNkhRjAlYhnzW/zqOoUyRwSBC9n5b9D+PdNHIw1bZ
         bTsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of heiko.carstens@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=heiko.carstens@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s2si2222447pgp.69.2019.05.03.06.48.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 06:48:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of heiko.carstens@de.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of heiko.carstens@de.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=heiko.carstens@de.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x43DmG9p105480
	for <linux-mm@kvack.org>; Fri, 3 May 2019 09:48:59 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s8maaeqax-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 May 2019 09:48:48 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Fri, 3 May 2019 14:47:26 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 3 May 2019 14:47:22 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x43DlLHG23330858
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 3 May 2019 13:47:21 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 27CA642045;
	Fri,  3 May 2019 13:47:21 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9B8E742041;
	Fri,  3 May 2019 13:47:20 +0000 (GMT)
Received: from osiris (unknown [9.152.212.21])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  3 May 2019 13:47:20 +0000 (GMT)
Date: Fri, 3 May 2019 15:47:19 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>,
        Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3] s390: remove ARCH_SELECT_MEMORY_MODEL
References: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
 <1556740577-4140-3-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556740577-4140-3-git-send-email-rppt@linux.ibm.com>
X-TM-AS-GCONF: 00
x-cbid: 19050313-0012-0000-0000-00000317F2E3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050313-0013-0000-0000-0000215065E1
Message-Id: <20190503134719.GB5602@osiris>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-03_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=854 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905030087
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:56:16PM +0300, Mike Rapoport wrote:
> The only reason s390 has ARCH_SELECT_MEMORY_MODEL option in
> arch/s390/Kconfig is an ancient compile error with allnoconfig which was
> fixed by commit 97195d6b411f ("[S390] fix sparsemem related compile error
> with allnoconfig on s390") by adding the ARCH_SELECT_MEMORY_MODEL option.
> 
> Since then a lot have changed and now allnoconfig builds just fine without
> ARCH_SELECT_MEMORY_MODEL, so it can be removed.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  arch/s390/Kconfig | 3 ---
>  1 file changed, 3 deletions(-)

Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>

