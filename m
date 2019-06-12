Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB17CC31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 06:57:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AE20205ED
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 06:57:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AE20205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 378FB6B0003; Wed, 12 Jun 2019 02:57:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329C66B0005; Wed, 12 Jun 2019 02:57:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CA9A6B0006; Wed, 12 Jun 2019 02:57:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2A766B0003
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:57:47 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id y205so16268277ywy.19
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 23:57:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=bQ5ElHMquZ98Jikuuxx8wmOU76TOnQjkjV8/eth7ojA=;
        b=MrUPH7qw2Tka9gzuBRBcnx69chLFJrBt2JWNH+DlpTkUdYYxh6p8a6FQfViLIYeHvL
         KanWYDXNhaVozVvtnpDq3uNDpxS9r1dlz1oP8a+RMPlaXcZhNHUCZD2NLGcL6oGkb140
         9OpWWHqgcSQD82Zcwbc7qno/ZsGUWOrxYXa3Ppw4IbebzTirYmz+vDO5Vb7ajfrdRq36
         nRLaY62pO6FGE9jGbzMpiRjRAWVf7C6JxSUHVO+hbbTDaMCjZmilsbHdqE0alD+LJCqR
         8x6vHraFrlsDAO0Wma+TqMnRdTeqEIAQMpQlc4Q0KomwZ096WJprov7tVY+gFMEzLIt1
         pS/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVh8ATWIrdRbKcabXvR+NufQZp89tv0zzc/rwJ4kaMFW4EaP+X5
	M/igu4rX5A9f0fwBnXZFfP55Z0j1IYn0bhUEaNS0u6v6c7M6FT0ImLR+ibgle/CiHG99z2qJuDI
	na/c3Gc8JHxcC6RwaNcdsO81TwGQMnEk435uczOZ5ecIip2tNE02UgT3jJ0jKWj/YMg==
X-Received: by 2002:a25:4009:: with SMTP id n9mr39106134yba.39.1560322667696;
        Tue, 11 Jun 2019 23:57:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKzzidQxBXWsIDdW3cJgvmlE9hTDhjaHYxKShegLF442QVj1w9QW/HT+jFfFYQ/AmCbEN/
X-Received: by 2002:a25:4009:: with SMTP id n9mr39106113yba.39.1560322666869;
        Tue, 11 Jun 2019 23:57:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560322666; cv=none;
        d=google.com; s=arc-20160816;
        b=UHBNCI13dh/wyobSgzyRBVJfJA5pRt0UDazYIwFSAoydZ67T+1h+iYBj41UVeS0gAJ
         tC17/YMyyXo0tjOwR0cwBDlVAvqVlhuKNeJHl1lDKtJKEutQalfNo0eIis/uKOzYXRRP
         PvYkyWsvseXoPMlzZ4hkwKZVBX4B/xv72AlqvAJB+0x80RP0GvIpAEITgn4i07kzgXO+
         +2aEZXeubyNkjHbBodfLHaAQIlwV8/sI+uBBMBdbsjqiKfCBF2NBPChe4tUTcdHKsKeM
         aj3YRsi4AuAfJgCiqCF+oLQMH+U5tqDxxDYZVWGiSPng2RnHO5dh4h02eBCIHlMdojpv
         hvag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=bQ5ElHMquZ98Jikuuxx8wmOU76TOnQjkjV8/eth7ojA=;
        b=ztj8dRIUznPtz5Ovw8a3dTr5IyCg9DYJNvh7cAPxqxzMByJ7oLsKHl42GfFeQxbVL6
         S4GuPkMnxLjYE5M0nxFM8ubBom+82bARh0evN7H/KC9J1dp6XxF2SvHUUk97IvKEchCZ
         1frvnfvR7zYUYR0tHXrS8qGJY5RurU8NyQl9ZiXkldu4I769AnPynJ2to/hDMH2ydN9G
         ZmQ5KN+QYpuWJocbyRg7q/GjzoF6bWlbKRBTUaDGhXRDg+7vrMFTQ//jcMmameRTLpy3
         aJqYw7GSHe93cdCUoBd+72OMNr+l3bpbna90RMV8JEH1tuL3XogcrUEZHqQQas/GGABH
         38vQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z65si5391849ywe.324.2019.06.11.23.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 23:57:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5C6uW9i166891
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:57:46 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t2use9y43-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 02:57:46 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 12 Jun 2019 07:57:44 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 12 Jun 2019 07:57:40 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5C6vd3m45482136
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 12 Jun 2019 06:57:39 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B9985A4062;
	Wed, 12 Jun 2019 06:57:39 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7C96AA405C;
	Wed, 12 Jun 2019 06:57:38 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.79])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 12 Jun 2019 06:57:38 +0000 (GMT)
Date: Wed, 12 Jun 2019 09:57:36 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Qian Cai <cai@lca.pw>
Cc: Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>,
        Andrew Morton <akpm@linux-foundation.org>, catalin.marinas@arm.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        mhocko@kernel.org, linux-mm@kvack.org, vdavydov.dev@gmail.com,
        hannes@cmpxchg.org, cgroups@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190610114326.GF15979@fuggles.cambridge.arm.com>
 <1560187575.6132.70.camel@lca.pw>
 <20190611100348.GB26409@lakrids.cambridge.arm.com>
 <20190611124118.GA4761@rapoport-lnx>
 <3F6E1B9F-3789-4648-B95C-C4243B57DA02@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3F6E1B9F-3789-4648-B95C-C4243B57DA02@lca.pw>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19061206-0012-0000-0000-0000032863F9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061206-0013-0000-0000-000021616A3E
Message-Id: <20190612065728.GB4761@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-12_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=968 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906120048
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Jun 11, 2019 at 08:46:45AM -0400, Qian Cai wrote:
> 
> > On Jun 11, 2019, at 8:41 AM, Mike Rapoport <rppt@linux.ibm.com> wrote:
> > 
> > Sorry for the delay, I'm mostly offline these days.
> > 
> > I wanted to understand first what is the reason for the failure. I've tried
> > to reproduce it with qemu, but I failed to find a bootable configuration
> > that will have PGD_SIZE != PAGE_SIZE :(
> > 
> > Qian Cai, can you share what is your environment and the kernel config?
> 
> https://raw.githubusercontent.com/cailca/linux-mm/master/arm64.config
> 
> # lscpu
> Architecture:        aarch64
> Byte Order:          Little Endian
> CPU(s):              256
> On-line CPU(s) list: 0-255
> Thread(s) per core:  4
> Core(s) per socket:  32
> Socket(s):           2
> NUMA node(s):        2
> Vendor ID:           Cavium
> Model:               1
> Model name:          ThunderX2 99xx
> Stepping:            0x1
> BogoMIPS:            400.00
> L1d cache:           32K
> L1i cache:           32K
> L2 cache:            256K
> L3 cache:            32768K
> NUMA node0 CPU(s):   0-127
> NUMA node1 CPU(s):   128-255
> Flags:               fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics cpuid asimdrdm
> 
> # dmidecode
> Handle 0x0001, DMI type 1, 27 bytes
> System Information
>         Manufacturer: HPE
>         Product Name: Apollo 70             
>         Version: X1
>         Wake-up Type: Power Switch
>         Family: CN99XX
> 

Can you please also send the entire log when the failure happens?

Another question, is the problem exist with PGD_SIZE == PAGE_SIZE?
 

-- 
Sincerely yours,
Mike.

