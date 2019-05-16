Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C253C04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 05:19:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 136F620818
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 05:19:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 136F620818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6207F6B0005; Thu, 16 May 2019 01:19:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A80D6B0006; Thu, 16 May 2019 01:19:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F9E66B0007; Thu, 16 May 2019 01:19:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 17E7E6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 01:19:33 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id l192so2157251ywc.10
        for <linux-mm@kvack.org>; Wed, 15 May 2019 22:19:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=r2bjRKZtRbAzPoU524xjEIV548Xlfu3vFQQ2+2rZSnc=;
        b=eZHuyL1cLYaxD1OvsnxSU74D010DfFjNs3SWOG8h1WThTb/gOXRZdi93pneFNAT87D
         fPzRuwqWw+R9jEDFV+pRm23k7NH9eMNj34yb5wVyGr1nac5d7j8RXb172akPy7HFhxGT
         nnwZ5ZooDgswkUdTfIyA6Imyh88uv4vEys2s/jezMMx8Z6Lr0cCfwJEAsavquJVkiJng
         s/kkrlZL1NzZ2ihkAjt5ss7cVHpExZmxMCKy8tmcZohSncUEvmYaexgWKo688QrsbtmF
         TkUAY442HoxDmEei1Bu770AGl92ADy3I15nk1q5FjyX7G8LgBA+upZClcyyYGPKj6UdD
         eOAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWswG8DjExRaa72dXdrB6meKwGv8QFN+XJGrUuxx634kFHdj5HN
	JVPgaF2rizwXqkaHt3xfabi1W5VWDcB7r5QjnrtnxctE4bQQg3VjO936uNJzJ7UGU2ZDhe3Lxch
	W/23dA/ieGFcAWlcAteWbUKYnkFm5XVNyktSG32NDi6oamxuHDYNubhb4zfr0ozEm7A==
X-Received: by 2002:a81:2d42:: with SMTP id t63mr13416175ywt.232.1557983972789;
        Wed, 15 May 2019 22:19:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywcaf7Qv2fU147Wk+en9I0eA27sZ0mDhYttBFon7SEsKCkwFTXOb3ickuGW50G4P+V+7+V
X-Received: by 2002:a81:2d42:: with SMTP id t63mr13416157ywt.232.1557983971902;
        Wed, 15 May 2019 22:19:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557983971; cv=none;
        d=google.com; s=arc-20160816;
        b=Sn9nMJMNbKUZYv1H0hxj2oy1JzWMcuDLGeZppiu5OK3gDQi0FfPt0WwEAER/m3bRn8
         9mN7fymAtJP1H5+nLsTffRktYMRFtk+cU2/fNAgo9gU40rOLTQNwn0HfZx5Qd4tSgLku
         JPnF2CdppiTfAQ8Ssb2mg5BVBzDv5ekuQzb1dmODQEftQ7uxO0CUyU/VOe0VEecwlWqb
         HVffBEMWIf+8ZFVkOUdNb9l/k+0qeMMcaUcAyIbD45teSkRYMCRGJl6fooyrZMC94OBX
         xG7bdPkTrZEt527dO1Fy3Ujk5Qni7H6LwF3pL4EywbulvUS52W+WhTX4uHQjOlhK81ZN
         8DZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=r2bjRKZtRbAzPoU524xjEIV548Xlfu3vFQQ2+2rZSnc=;
        b=ROUTNMk5IVksOhas4B26YbOlkVoCXNsCRRhgpdkPgr6bDkMBPGkv/AR7EvU0k0HBmv
         arzTVTD46NrY+kPYvACWpifBwi/W1wlxT0WQem6q03ynjCOMygk/akx2sEV6Zzc2gUru
         uvf3ca6YLf/Cyo8YRY4dlSZvhXi18FilY8FReHgvoTqipyFuCi/dJ63Z4U/xvcdHJBZk
         RArnn6Xat6j9mihGraJi/VfIn+u/P3403o/j0pEXvfcPhNirzOVaSOB3z+AmMrX+Z1om
         347lum7yzoeQ/JVuxFfnb9yJoLkL/oI+1gZ+vSUSOuAsQWfWg9t0Noy+ea9fBNJwlIN5
         klUg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j203si1152309ybg.323.2019.05.15.22.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 22:19:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4G5HKSD040229
	for <linux-mm@kvack.org>; Thu, 16 May 2019 01:19:31 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sh0byjhwf-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 16 May 2019 01:19:31 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 16 May 2019 06:19:29 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 16 May 2019 06:19:25 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4G5JOew57802782
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 16 May 2019 05:19:24 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7A8A911C06E;
	Thu, 16 May 2019 05:19:24 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 81D8911C05B;
	Thu, 16 May 2019 05:19:23 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 16 May 2019 05:19:23 +0000 (GMT)
Date: Thu, 16 May 2019 08:19:21 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/3] remove ARCH_SELECT_MEMORY_MODEL where it has no
 effect
References: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19051605-4275-0000-0000-000003354B30
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19051605-4276-0000-0000-00003844D161
Message-Id: <20190516051921.GC21366@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-16_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=687 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905160037
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew,

Can this go via the -mm tree?

On Wed, May 01, 2019 at 10:56:14PM +0300, Mike Rapoport wrote:
> Hi,
> 
> For several architectures the ARCH_SELECT_MEMORY_MODEL has no real effect
> because the dependencies for the memory model are always evaluated to a
> single value.
> 
> Remove the ARCH_SELECT_MEMORY_MODEL from the Kconfigs for these
> architectures.
> 
> Mike Rapoport (3):
>   arm: remove ARCH_SELECT_MEMORY_MODEL
>   s390: remove ARCH_SELECT_MEMORY_MODEL
>   sparc: remove ARCH_SELECT_MEMORY_MODEL
> 
>  arch/arm/Kconfig   | 3 ---
>  arch/s390/Kconfig  | 3 ---
>  arch/sparc/Kconfig | 3 ---
>  3 files changed, 9 deletions(-)
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

