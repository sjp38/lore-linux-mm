Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A2EEC10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 05:04:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B04452075B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 05:04:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B04452075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A97A6B0007; Mon, 15 Apr 2019 01:04:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 458AC6B0008; Mon, 15 Apr 2019 01:04:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 348C76B000A; Mon, 15 Apr 2019 01:04:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DA4286B0007
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 01:04:40 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n11so8322235edy.5
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 22:04:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=tBacxYYr5jJDp/mNEcEd0r1ead0eRh6rtRa+cn6JjTE=;
        b=imBi1qlyq88OJhz35zwRDllAdS5aqWY2VLmli6rGn5FAIhLzfrvEnc4B1O4LmHf4D6
         efRQiex4rTJ9G4aWWrf66fyOCjIZZucWug0WBEsicWFRFGciBvhKfmiu2w/XZmpMwXod
         0D1ZOs14Qsgqbjg1PneOLvVr8la0aM2+kPbRebqM6t6liwQw3nHmQ91BT8XKQ49w5zHu
         GsrULPKnRFkKe2JiTWunesII8y+qLL+h4k63QrvSg9qt3PsNOsRi2hBBN8lN44oEGVgq
         W5RtRHLk+PWdeZde2j45FQcOC+P4D/6oW+AQquwzWUoruZ8wan2DI6QxGY4EsdptNxty
         P11A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVwcqEIjf3qDj4dp3gynWhRmJaHGPLPNEplHlSYcwK+U/gLPfWQ
	Cvk/4BvL1rGjkHDNu10m/Tzspb0/fKHcAi1AuMp+5dcRCP+7BnH7dow/vUBjCKN7Gx/25MJcTgT
	wsHYeUrJnvyJ4Us6IlPGMq35olPzf8TKkBPybSlmVP5AeTDGldtV7fBjgpVK8L+7pSA==
X-Received: by 2002:a17:906:1906:: with SMTP id a6mr39078315eje.236.1555304680453;
        Sun, 14 Apr 2019 22:04:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5sQZO61/2OI9VTYr6HWu1zhtQT1s+FngY170g3tTqTitCZDGM1yUtXaRBk7J/BowQ4eSI
X-Received: by 2002:a17:906:1906:: with SMTP id a6mr39078280eje.236.1555304679612;
        Sun, 14 Apr 2019 22:04:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555304679; cv=none;
        d=google.com; s=arc-20160816;
        b=0kxDnl1EE0wm3GQOcb+8PgPb9ytM6BgKeRJ3VC/3ePoTkANQb9u/cXBNYfKtBFKn+1
         2TLgDT4wXgceCep34341gYN7CqC2lzQPoFD9v4w8ssuGZfIEXazaiFJK3ck3GTVztQKE
         UfA2w+qQqYkEXXCmWUkotwWqynlEESTrJEpCfJedxDo3S016Mja0qBNEJEPRYA2LZ/F9
         XX9tDR+MqH7TssHDJw1b9eL8V0rIRmyjakza9r65QcdaJw0Hal1QiEhv3DQvB8DjwZFR
         Qf+5YrDzPcZ83iW3q3tPN+pThPCWX8tL5baUMVq73fIiwxXTrBEnBTV6tr58KovgfTNJ
         BJUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=tBacxYYr5jJDp/mNEcEd0r1ead0eRh6rtRa+cn6JjTE=;
        b=GNBwBXEjjTcNW7f6mDDLSRkN03M61h9myGaqO63V9dXvWyPMNoLkGjSKjL4B0shrJ6
         GlYSPoICB3nYKNpOkTjUqOjufmxmhBuSBnOVJjykJaTJH+k8EVBVmREf4Nu01ik66uDU
         5Zp9EPA5HCkkcjSBtUOIquYebOxpY7c2U2ZnjJBqHpGT1F0Xhjkio3bOFdW/xktsSOh5
         DcWtRP5GSaCql/cKmpzV3NNPPb8VZivpFFZoG0mjDngZX1xzbiMHJ6+BHBSveXlHyob1
         ymjMxLyvVMeIabXf5u5aKxJEwOuq19M/ayV8a3YTcTXMTu+WKe7hxTBsfxs7IbM4YIJa
         qF1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x53si3501216edb.4.2019.04.14.22.04.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 22:04:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3F53s3E043336
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 01:04:37 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rvkftg2n5-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 01:04:37 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 15 Apr 2019 06:04:34 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 15 Apr 2019 06:04:22 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3F54LAc42598586
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 15 Apr 2019 05:04:21 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 0ADC152051;
	Mon, 15 Apr 2019 05:04:21 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id DA6875204E;
	Mon, 15 Apr 2019 05:04:19 +0000 (GMT)
Date: Mon, 15 Apr 2019 08:04:18 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Chen Zhou <chenzhou10@huawei.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, ebiederm@xmission.com,
        catalin.marinas@arm.com, will.deacon@arm.com,
        akpm@linux-foundation.org, ard.biesheuvel@linaro.org,
        horms@verge.net.au, takahiro.akashi@linaro.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        kexec@lists.infradead.org, linux-mm@kvack.org,
        wangkefeng.wang@huawei.com
Subject: Re: [PATCH v3 3/4] arm64: kdump: support more than one crash kernel
 regions
References: <20190409102819.121335-1-chenzhou10@huawei.com>
 <20190409102819.121335-4-chenzhou10@huawei.com>
 <20190410130917.GC17196@rapoport-lnx>
 <137bef2e-8726-fd8f-1cb0-7592074f7870@huawei.com>
 <20190414121058.GC20947@rapoport-lnx>
 <b5206f0c-d711-427e-256a-98b2e30c1ab0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b5206f0c-d711-427e-256a-98b2e30c1ab0@huawei.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19041505-0016-0000-0000-0000026ECD39
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041505-0017-0000-0000-000032CB0FBF
Message-Id: <20190415050417.GB6167@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-15_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=676 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904150033
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Apr 15, 2019 at 10:05:18AM +0800, Chen Zhou wrote:
> Hi Mike,
> 
> On 2019/4/14 20:10, Mike Rapoport wrote:
> >>
> >> solution A: 	phys_addr_t start[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> >> 		phys_addr_t end[INIT_MEMBLOCK_RESERVED_REGIONS * 2];
> >> start, end is physical addr
> >>
> >> solution B: 	int start_rgn[INIT_MEMBLOCK_REGIONS], end_rgn[INIT_MEMBLOCK_REGIONS];
> >> start_rgn, end_rgn is rgn index		
> >>
> >> Solution B do less remove operations and with no warning comparing to solution A.
> >> I think solution B is better, could you give some suggestions?
> >  
> > Solution B is indeed better that solution A, but I'm still worried by
> > relatively large arrays on stack and the amount of loops :(
> > 
> > The very least we could do is to call memblock_cap_memory_range() to drop
> > the memory before and after the ranges we'd like to keep.
> 
> 1. relatively large arrays
> As my said above, the start_rgn, end_rgn is rgn index, we could use unsigned char type.

Let's stick to int for now

> 2. loops
> Loops always exist, and the solution with fewer loops may be just encapsulated well.

Of course the loops are there, I just hoped we could get rid of the nested
loop and get away with single passes in all the cases.
Apparently it's not the case :(

> Thanks,
> Chen Zhou
> 

-- 
Sincerely yours,
Mike.

