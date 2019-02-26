Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4E22FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:41:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A535F2147C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:41:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A535F2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04C508E0003; Tue, 26 Feb 2019 01:41:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3D2F8E0002; Tue, 26 Feb 2019 01:41:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E04C68E0003; Tue, 26 Feb 2019 01:41:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 88E288E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:41:50 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d16so4917073edv.22
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:41:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=n6M6nvES4BgxT3A/U7TDsRBVRTBiZKsJPixJQmsgfB4=;
        b=V2/QIT6DdybPnntM7nm3DSBaOMZOVIPPm/INUpqauusE6ZzAmV7wFN3WtTxnr2+p5a
         CCxNCuZvsjSsaprnuvYBOPD50lA5/qPaA5sXnqKwSrj4lyN5YJfzBIzxSQKwo8zoicvw
         YSgcCmlMgK/dPh6ZSLs7xuWp151YUCjgr22QB2hNm6SVtLRQ5/u7xwzn38ILPnR2FiM/
         5RO5L8mIXqx9U5yxj/dsGshse5xEHizhWYEDIy6qzsrfKBfv9aMdlbcHsg1uyfRFY+tB
         LIaKoaMZVcgKnj0I2k4IYNlJA7XjnHQuJPIJ4Jez4nfYhjn0oDkyVCr68uSqvDeWcnrv
         41NA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZO633Txrh/VyWyakB89ZdZyDdDeaF4nYo9bHByTRYMxAMQCLkc
	ndozs0G/bZYYJStTtDmSy++cWVTVWZhrbSbp0ESZRNDuKFKq5OOi3pRtguqb6XVMg3qg+vidjt+
	wa8mzLt3gyjqWlzln2wUgcWyMjygmtm10hydxEyt2qc1nphuWfr0S5JpzEJtxL0FXWg==
X-Received: by 2002:a50:ac58:: with SMTP id w24mr17089699edc.287.1551163310097;
        Mon, 25 Feb 2019 22:41:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ8lUMgvykEiLDvWKD/Bbhfrr8cUi7DQFZqxWglXWRsQQpqmmH8C1MYotB0o9yE3N0SYVYc
X-Received: by 2002:a50:ac58:: with SMTP id w24mr17089645edc.287.1551163309054;
        Mon, 25 Feb 2019 22:41:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551163309; cv=none;
        d=google.com; s=arc-20160816;
        b=eoG7lss4X1pA19rB3ivAWcpow4dCXcVUm3xdHImGvhGG4r0scNp6OhJjB86sh3XqVA
         IdTTPaRBKVWcJazocFk+a8nIFNamWlUXop0m0zrAU5dBMGgPaochtCnKM63Xo3RkPkxj
         9Vdkaf09CsYk/jaya6Yui/i13LrXLy0ooANaLjDhvWXkktM40FFnvAoLFa8+wWEwpTvW
         dXSIggarEjdBuhXj3fC6bRpTQrG33KU5QKUZMiQ2kRJOSxQ7FINoLr6K+SxJEQgAg94a
         OAmtwkG1h71NvT8RrnFZevf3bCvFW948YPH+SPyruumZtbbHSK5VuoEmeL21Tr+GfZk6
         AEsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=n6M6nvES4BgxT3A/U7TDsRBVRTBiZKsJPixJQmsgfB4=;
        b=PG9XUGZOa83i1VXYIx4M1A4tAUal311c3sWE4kVTbnJfJeouAW+QTFloi9V57Dgp4q
         MAwR/zK2Y2lTgvisKRkp801+kVAKKJlwV3Q4D+x36enWovJxGWYcD3s78nz+kFXYb9Pb
         M7Xz9KDOmi/ydg77iUace9BdD3RFTlERFjJ1euCAQCzIqxQrEnmnCn17Jz2S7hH95yer
         Z2oZik6ZN2vOOsh7dz3OdBOhs5p20ZaSXPoP0rLNh32ddKRJWamgVnB289R8c+MShjI3
         gjndYAppdA8yTBHF5899gNWqHDPo7cdAIqSsCDw5Gfd7f0mbjEHxqIVWF0KZQ78Jxlis
         ki8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m23si485186eje.334.2019.02.25.22.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:41:49 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1Q6fk5V166785
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:41:47 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qvym2t6b3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:41:47 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Feb 2019 06:40:38 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Feb 2019 06:40:35 -0000
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1Q6eZ5055705656
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 26 Feb 2019 06:40:35 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 08DF042047;
	Tue, 26 Feb 2019 06:40:35 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 64E6B42042;
	Tue, 26 Feb 2019 06:40:34 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Feb 2019 06:40:34 +0000 (GMT)
Date: Tue, 26 Feb 2019 08:40:32 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>, kbuild-all@01.org,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [mmotm:master 342/391] arch/powerpc/kernel/setup_32.c:176:21:
 error: redefinition of 'alloc_stack'
References: <201902261214.GfZVc99M%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201902261214.GfZVc99M%fengguang.wu@intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19022606-0020-0000-0000-0000031B4837
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19022606-0021-0000-0000-0000216CAC14
Message-Id: <20190226064032.GA5873@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-26_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902260050
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 12:24:17PM +0800, kbuild test robot wrote:
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   896e6c5ee0c0ead9790f7ac202a672132bacbf66
> commit: 7b6550d180d48e250049759362b5cc2cf02544c9 [342/391] powerpc: use memblock functions returning virtual address
> config: powerpc-allnoconfig (attached as .config)
> compiler: powerpc-linux-gnu-gcc (Debian 8.2.0-11) 8.2.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 7b6550d180d48e250049759362b5cc2cf02544c9
>         # save the attached .config to linux build tree
>         GCC_VERSION=8.2.0 make.cross ARCH=powerpc 
> 
> All errors (new ones prefixed by >>):
> 
> >> arch/powerpc/kernel/setup_32.c:176:21: error: redefinition of 'alloc_stack'
>     static void *__init alloc_stack(void)
>                         ^~~~~~~~~~~
>    arch/powerpc/kernel/setup_32.c:165:21: note: previous definition of 'alloc_stack' was here
>     static void *__init alloc_stack(void)
>                         ^~~~~~~~~~~
> >> arch/powerpc/kernel/setup_32.c:165:21: error: 'alloc_stack' defined but not used [-Werror=unused-function]
>    cc1: all warnings being treated as errors
> 
> vim +/alloc_stack +176 arch/powerpc/kernel/setup_32.c
> 
>    164	
>  > 165	static void *__init alloc_stack(void)
>    166	{
>    167		void *ptr = memblock_alloc(THREAD_SIZE, THREAD_SIZE);
>    168	
>    169		if (!ptr)
>    170			panic("cannot allocate %d bytes for stack at %pS\n",
>    171			      THREAD_SIZE, (void *)_RET_IP_);
>    172	
>    173		return ptr;
>    174	}
>    175	
>  > 176	static void *__init alloc_stack(void)
>    177	{
>    178		void *ptr = memblock_alloc(THREAD_SIZE, THREAD_SIZE);
>    179	
>    180		if (!ptr)
>    181			panic("cannot allocate %d bytes for stack at %pS\n",
>    182			      THREAD_SIZE, (void *)_RET_IP_);
>    183	
>    184		return ptr;
>    185	}
>    186	

The fix is below: 

From e2228b90baf0b443650c2f391a4acb3beb688bea Mon Sep 17 00:00:00 2001
From: Mike Rapoport <rppt@linux.ibm.com>
Date: Tue, 26 Feb 2019 08:36:20 +0200
Subject: [PATCH] powerpc: remove duplicated alloc_stack() function

The patch "powerpc: use memblock functions returning virtual address" was
applied in both powerpc and mmotm trees and as a result function
alloc_stack() sneaked twice into arch/powerpc/kernel/setup_32.c

Remove one of the copies.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 arch/powerpc/kernel/setup_32.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/arch/powerpc/kernel/setup_32.c b/arch/powerpc/kernel/setup_32.c
index 40e9d99..4a65e08 100644
--- a/arch/powerpc/kernel/setup_32.c
+++ b/arch/powerpc/kernel/setup_32.c
@@ -173,17 +173,6 @@ static void *__init alloc_stack(void)
 	return ptr;
 }
 
-static void *__init alloc_stack(void)
-{
-	void *ptr = memblock_alloc(THREAD_SIZE, THREAD_SIZE);
-
-	if (!ptr)
-		panic("cannot allocate %d bytes for stack at %pS\n",
-		      THREAD_SIZE, (void *)_RET_IP_);
-
-	return ptr;
-}
-
 void __init irqstack_early_init(void)
 {
 	unsigned int i;
-- 
2.7.4

