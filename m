Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DADD2C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 07:20:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F5BC20830
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 07:20:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F5BC20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80E066B0003; Mon, 25 Mar 2019 03:20:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BE2B6B0005; Mon, 25 Mar 2019 03:20:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 685826B0007; Mon, 25 Mar 2019 03:20:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 296266B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:20:35 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j10so8892255pfn.13
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 00:20:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=9WeP9jzN7+rTrI8UEgVuW9fgzthsSonlS8P111uz+HQ=;
        b=Pt3D2AmjoIMuqgmZ5nAoyIavKBvgA53FL8OFEpQpDQbnhSu5QLPfBahf248KgoZcQh
         I9Gt0TVjAsA+/o8IpJkkW/0cN0fYSG2UD69ZlRZ+2/zcM8ubcIq9DmyTKpfOWZOoz6H9
         EpYZvhiXZn8qvNQYoHq0Vsb6NMacx2It5QiXOSG/Tm9yjYm/WcBuOUhxcRPSAm2s/R2K
         f805/0wFKASKvUnpl2LfAq+IpM3Cm/Cc1Xrt9T6P4WHiAJqiIrXXxbvOnB1OuCTiIKAr
         bXA7X25i5fvrwKAe6HSvq56uqc3bFajELD2YeE7DnQcsM6qJkmrYTKRsJPq62rHwo5pY
         TVpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVj00ImAnu31CkYNXGzBpXqtpOvJhyF8Y3/QvZ2RgKWwYcUAXp5
	kOmnJkBVgWQqH1BVyQPOA4LOpnIYI6rqszGODRY+Mo0qWh8m8PAE59TU10O3Jx4oCNitfWIG7XD
	tUWDYQoAb4vJVVfLlZrLT2XVJ6v250BPAOFD3gx0mpGmEYDUu87sUKmGuaJUkPnqshw==
X-Received: by 2002:a62:1d90:: with SMTP id d138mr22355613pfd.232.1553498434678;
        Mon, 25 Mar 2019 00:20:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUhQXVywUkWMM2Kn+z+BGfRbklGaMxstmUN6gTzjzuA1b6qnRfbVgoTtKlHf9QIIWfZmTi
X-Received: by 2002:a62:1d90:: with SMTP id d138mr22355580pfd.232.1553498433868;
        Mon, 25 Mar 2019 00:20:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553498433; cv=none;
        d=google.com; s=arc-20160816;
        b=qPOEi67PVHHhm20TLQAnbw1QnMwGJedxshGFns/7OCWIr7XQ29BBN7T3eia3iCD7MA
         /2uvG0Cran16Bl6dlag46AeciCrOVSXW//ZeX40EqGW2vOGRzYPDuhOum2bjvaaumPQc
         GH+jX8KHbFWOqS7OTSokj4EfogJGirHOCak4yEfFFmiWNvyZTm6Or/NL/7sAMBkVDL+t
         FsISmY+GVEndhbVUyGVyYSJCJHFBwRCIyBefkQZxETE/IinyrOtxuiLEEeieCE9PkBTH
         4TdDoKurAvabLYCT3TxB4SnKnT6wO8LAHbZBZreqwP9A4i/2c9KjioSaaQRl0kC1DHKI
         0kuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=9WeP9jzN7+rTrI8UEgVuW9fgzthsSonlS8P111uz+HQ=;
        b=bV6bbtvFK6nKVL2zcnA2Or0zcCPCmcYMxqQM3GQxM6xp/qLQUQLML+4TK0XNDaammn
         3rzU2/evz3EWbAAyCl1p1ew+hzEgcZpr/v+v8546unHaZ1w+iG7p1/WRW2ycqBWWlEjT
         WTFFeP6VNkYYVzRy8UHFN7H9xU6VMFeVQDWIHFJYkFU9YW/NGb2kNUzcR71j52XL30GJ
         8sWIIxtybL8fnfhg9IfXRtM6mHNSc0FC2jKNaG0AfsLbbDWEJWDjJirVDfQfntaNJcmc
         ghFREGSEaunIIfWjNRC1An1k1DpmQj5EQmMbDLQ8PitolDM2rUK+lFE6vdpJ5ILvtjsA
         0Ocw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f11si12236411pgs.291.2019.03.25.00.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 00:20:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2P7FtAL049184
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:20:33 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ressb1xg5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 03:20:32 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 25 Mar 2019 07:20:30 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 25 Mar 2019 07:20:26 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2P7KPQc55116010
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 25 Mar 2019 07:20:25 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B35974C05C;
	Mon, 25 Mar 2019 07:20:25 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CD6164C044;
	Mon, 25 Mar 2019 07:20:24 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.233])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 25 Mar 2019 07:20:24 +0000 (GMT)
Date: Mon, 25 Mar 2019 09:20:23 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Palmer Dabbelt <palmer@sifive.com>,
        Richard Kuo <rkuo@codeaurora.org>, linux-arch@vger.kernel.org,
        linux-hexagon@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-riscv@lists.infradead.org
Subject: Re: [PATCH v2 0/4] provide a generic free_initmem implementation
References: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550515285-17446-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032507-0028-0000-0000-00000357E015
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032507-0029-0000-0000-000024169150
Message-Id: <20190325072022.GD2925@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-25_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=973 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903250055
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Any comments on this?

On Mon, Feb 18, 2019 at 08:41:21PM +0200, Mike Rapoport wrote:
> Hi,
> 
> Many architectures implement free_initmem() in exactly the same or very
> similar way: they wrap the call to free_initmem_default() with sometimes
> different 'poison' parameter.
> 
> These patches switch those architectures to use a generic implementation
> that does free_initmem_default(POISON_FREE_INITMEM).
> 
> This was inspired by Christoph's patches for free_initrd_mem [1] and I
> shamelessly copied changelog entries from his patches :)
> 
> v2: rebased on top of v5.0-rc7 + Christoph's patches for free_initrd_mem
> 
> [1] https://lore.kernel.org/lkml/20190213174621.29297-1-hch@lst.de/
> 
> Mike Rapoport (4):
>   init: provide a generic free_initmem implementation
>   hexagon: switch over to generic free_initmem()
>   init: free_initmem: poison freed init memory
>   riscv: switch over to generic free_initmem()
> 
>  arch/alpha/mm/init.c      |  6 ------
>  arch/arc/mm/init.c        |  8 --------
>  arch/c6x/mm/init.c        |  5 -----
>  arch/h8300/mm/init.c      |  6 ------
>  arch/hexagon/mm/init.c    | 10 ----------
>  arch/microblaze/mm/init.c |  5 -----
>  arch/nds32/mm/init.c      |  5 -----
>  arch/nios2/mm/init.c      |  5 -----
>  arch/openrisc/mm/init.c   |  5 -----
>  arch/riscv/mm/init.c      |  5 -----
>  arch/sh/mm/init.c         |  5 -----
>  arch/sparc/mm/init_32.c   |  5 -----
>  arch/unicore32/mm/init.c  |  5 -----
>  arch/xtensa/mm/init.c     |  5 -----
>  init/main.c               |  5 +++++
>  15 files changed, 5 insertions(+), 80 deletions(-)
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

