Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2507CC43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:56:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C163620651
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 19:56:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C163620651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 222C66B0005; Wed,  1 May 2019 15:56:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D3C66B0006; Wed,  1 May 2019 15:56:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09C5F6B0007; Wed,  1 May 2019 15:56:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C492A6B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 15:56:32 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id x9so33426pln.0
        for <linux-mm@kvack.org>; Wed, 01 May 2019 12:56:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=42qUX89KCYtTD0pU+SGw56e3eXXfg016lHBId3nK3JU=;
        b=XD8mgJFY2kJUrGt2e9ZLI1/bGbeCuErA4+OEoSbxqHeob+3uc2tBztKZKLamWZ/GLP
         AnSfijffIW/iNp1cG/RS3jNNIpjZJtk3AStg7yUv95EHVENo9BTABJEiXy0Dqn+HJBHU
         4MLF9Q8iUrU9rlqt6fuXsWb/o/1UYp82Wdju9TD/WM+Z2sMDYLHt7rY0RZ07zN5f079o
         9wuA2hu2oSl6RUyzv8KL8k8doh14ZS/HZG3ydIvt882Z0/RObai9QtiXFhSAhi7vajbj
         6oNejEidHNp4FT0znN91PNim9IBozjTCQe0+64rjOlXJIpyx5BS3cy1S/4eAmDPmvIXe
         tBYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVRJubzdOd4SwFuzSVmSnSfAmy6wlJhSo9diPnDZUfHHAEx10Se
	NGkMzWXz12f2TyYcqjoTRNLp4F5IH3RCRatKQ5up1oPyCicrBBI7QFyObI5Zh/Y5q0XbhwpWtLo
	lAbiBAcXRhErkX9qrt42sOn+ajLc/HJRykqRd1PuR2kaNXRt7pSFKLCYc7otP0YoOJQ==
X-Received: by 2002:a63:c746:: with SMTP id v6mr75716895pgg.401.1556740592342;
        Wed, 01 May 2019 12:56:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw+c89ac3ys58McNHrl1bJgFeNZts7nDYVvPcWTgPt7FfzU8px47A/WER2Vnzb/W96ZDHoZ
X-Received: by 2002:a63:c746:: with SMTP id v6mr75716814pgg.401.1556740591336;
        Wed, 01 May 2019 12:56:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556740591; cv=none;
        d=google.com; s=arc-20160816;
        b=QkQD0VwgAoyOx7PiR1RpLsXzP84T5m5EgrwPetEd8UdGGIzg0NCNYJmOOWE9/0gvbm
         0w8l5oABAqtoSIanDoDXsXwGz35Bxl3/AmAkv6oS1hN2xqD5/X9xz3IPkC3+z5P7jCSZ
         jy2pPKy5TLW7gFgw1hPrqlbYTM/9Dke3nviDTV4jr4+qie8tgyHbAzyZ+v6oBC0Ah7Qf
         Yf4IqcqG+HKUiy1YnCW7cs3IhsVCqbI0ah1IW6Yg0t7SC+HZUoFmL+NSUooAv8zVH0S3
         Hr4Fr6zXsswLhV9b2A4N+IxGHBc880nZ48IW80z1eAXPFK1HKMCXK8qJ9FrIRaoG48BZ
         ux9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=42qUX89KCYtTD0pU+SGw56e3eXXfg016lHBId3nK3JU=;
        b=W3BqL0x4W8pqy3ntG6LXsDTpgxyxP6B3LjBOuck8rKUyqba/uXECly2RztxTYeSNFz
         ipYHFbGewWsWm6nHih7n2yvzsOfIjFJQ9SZwkfs78moLiqxuK32+pktv/2Ygly5JnTge
         8hfqXv+nPZiDl0j5kF5STXn6b0J7zy9zbNGsaFcbXjkZKuJXjiTQHkIrtADxCS4HKDsN
         a+HQ1oIXAKb1Yfd5Q6rKSrtF3OluZqUyDK3s3yUsLpBHt9iJ0VrXWYpDZ7wgaoc2J5rd
         LjuITVS9oh8ZOM9l8qJydMdzxqyzDsY0m00/nDjLAHEwyt6TGce+O0KOfFj77YBObGnQ
         YHwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b6si41060384plx.325.2019.05.01.12.56.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 12:56:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x41JqFFK028442
	for <linux-mm@kvack.org>; Wed, 1 May 2019 15:56:30 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s7f0wrbxa-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 May 2019 15:56:30 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 1 May 2019 20:56:27 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 1 May 2019 20:56:24 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x41JuNGo38338626
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 1 May 2019 19:56:23 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8362BAE05D;
	Wed,  1 May 2019 19:56:23 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5D165AE055;
	Wed,  1 May 2019 19:56:20 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.12])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  1 May 2019 19:56:20 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Wed, 01 May 2019 22:56:18 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Russell King <linux@armlinux.org.uk>,
        linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org,
        sparclinux@vger.kernel.org, linux-arch@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH 0/3] remove ARCH_SELECT_MEMORY_MODEL where it has no effect
Date: Wed,  1 May 2019 22:56:14 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19050119-0020-0000-0000-000003384BDA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050119-0021-0000-0000-0000218AD092
Message-Id: <1556740577-4140-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=529 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905010124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

For several architectures the ARCH_SELECT_MEMORY_MODEL has no real effect
because the dependencies for the memory model are always evaluated to a
single value.

Remove the ARCH_SELECT_MEMORY_MODEL from the Kconfigs for these
architectures.

Mike Rapoport (3):
  arm: remove ARCH_SELECT_MEMORY_MODEL
  s390: remove ARCH_SELECT_MEMORY_MODEL
  sparc: remove ARCH_SELECT_MEMORY_MODEL

 arch/arm/Kconfig   | 3 ---
 arch/s390/Kconfig  | 3 ---
 arch/sparc/Kconfig | 3 ---
 3 files changed, 9 deletions(-)

-- 
2.7.4

