Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04AEAC04AA8
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 20:46:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1C7F20656
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 20:46:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1C7F20656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CD566B0005; Wed,  1 May 2019 16:46:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 557136B0006; Wed,  1 May 2019 16:46:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D0B26B0007; Wed,  1 May 2019 16:46:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 132006B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 16:46:28 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id t82so548192ywf.23
        for <linux-mm@kvack.org>; Wed, 01 May 2019 13:46:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=vUHQdgyXjVhAkI61jgcSVdra0Z04c9YtAiiciAFt1ag=;
        b=CskBd41VKLDHrcsSn/x+TkCDIQDUusY5EwNB51FDxS8PvdZKpahqU9dIWGDn5ntr0G
         YoGjTsfntxI2roDTYVn+AdzXjgqmVSNvnnhA11Te74Y+fU+HBpw0UO5fhcrzcEjuV1Q0
         uNJ1EQNsgK58jgmcS7oz7YMHbOltxP7VjBWXrfBZitGR2ynsDBVT96Y/HOjOqNdJNYsL
         qhcZqJNtdfRpaqBrFw02xk+ViqUnPdqjgGsM4bioSK1Ahy8LCsvg5Iqo5I2eboYalfb+
         OYIjfuWj52VtxJayyUKu49hT6WLZvEDYqzb3/jsUeBHwWDWjYJtE1YxlIwksH94uRmtA
         yuSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWZc2o02UbH7+JYATSc7fcSRuKgvgPhGXzLfh9G1/NaXArzuKph
	Pf7DmDUs/pOm2B4H8gGg1oZw7HOL2bJ2g0qPHMbG+jPloqujwlYaSwB+S2DP560SekUs22WoJgO
	BLLInJe7ftgtTgBz3fY43JTY2u/QS01cd90+Oda0JgcRT34l3xAhWRR/TUJy2Dw5yQg==
X-Received: by 2002:a0d:ead6:: with SMTP id t205mr29982305ywe.399.1556743587816;
        Wed, 01 May 2019 13:46:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXYRbMCpGHhvXX4uH/PjDN7s6krqtkDvOzBsF0fclhwC8eNpMYJU4HKsJTLBxJ6DuJF6+v
X-Received: by 2002:a0d:ead6:: with SMTP id t205mr29982257ywe.399.1556743586941;
        Wed, 01 May 2019 13:46:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556743586; cv=none;
        d=google.com; s=arc-20160816;
        b=ZvcKq1M63nstsAroTLCknUWwYQ4SSXs35L6XUU96FKGOcqxab4hwB1MTRe3dqrgGFw
         Oakgp8ontwhDUthtdr+DoM09/cZxMov/ldpOEUK46CelRHF+gsWeb3BBic0M3K1KuBcv
         hiw8sU+vFCBW9zZ2gMNoyC8hAHmVnRzoYf7ULn8sI6RQuUP4uQmG3qv0HtYzpgDVtnxc
         /QKSjQKuYerZMiOSyhHZdwRhf5r60WI8avlIo/N2BVXGi/n6ZgysSzFhZZ6bWstAFDzx
         +nZPZNxw5djXK6KsHENNW+6QFqVOSVMDCNEOQRrFLzDuzMSwCjzD565CVX1zHJoMXb1D
         +KOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=vUHQdgyXjVhAkI61jgcSVdra0Z04c9YtAiiciAFt1ag=;
        b=khOvvSglBUpupqTW3T+vXAOgtRXyTWn0+LdgRqyj5CTudW6ETNonA2FinQ9AFABR+G
         NsYsC7ZUvJnI4Z2VXtdQFBBKNLPD5bFYJW07StXERHW4lrYngxQIo5QrGOvm7adBGQeH
         tX1GK2fJsaE0+9yz/Zvnc3MgbLYNqHQR2Zhiy8PuRzvnyPp5YfRxnDNEY/DZmqzRV+ie
         NPiovfruqVS/FTdgyOqYTBRKehNNZR5z/cIRYg/x/njby/o406KIB/nRzt0bxlrDIEE0
         8gIA+juYXrtkE0rSXFrkx7S59x5Cpx+DXYJ/iELkjuzZzqsQijMFaa8tRXGL78qJXeP/
         +meQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x31si28831946ybh.261.2019.05.01.13.46.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 13:46:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x41Kgddu132596
	for <linux-mm@kvack.org>; Wed, 1 May 2019 16:46:26 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s7es9262w-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 May 2019 16:46:26 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 1 May 2019 21:46:24 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 1 May 2019 21:46:21 +0100
Received: from d06av24.portsmouth.uk.ibm.com (d06av24.portsmouth.uk.ibm.com [9.149.105.60])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x41KkK9W62324976
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 1 May 2019 20:46:20 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7CBCA42042;
	Wed,  1 May 2019 20:46:20 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 538C74203F;
	Wed,  1 May 2019 20:46:19 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.205.12])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  1 May 2019 20:46:19 +0000 (GMT)
Date: Wed, 1 May 2019 23:46:17 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mgorman@techsingularity.net>,
        Matthew Wilcox <willy@infradead.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mikulas Patocka <mpatocka@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        linux-parisc@vger.kernel.org, linux-mm@kvack.org,
        Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>,
        linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190421063859.GA19926@rapoport-lnx>
 <20190421132606.GJ7751@bombadil.infradead.org>
 <20190421211604.GN18914@techsingularity.net>
 <20190423071354.GB12114@infradead.org>
 <20190424113352.GA6278@rapoport-lnx>
 <20190428081107.GA30901@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190428081107.GA30901@infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19050120-0008-0000-0000-000002E24E29
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050120-0009-0000-0000-0000224EBA0A
Message-Id: <20190501204616.GB6135@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-01_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905010128
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 28, 2019 at 01:11:07AM -0700, Christoph Hellwig wrote:
> On Wed, Apr 24, 2019 at 02:33:53PM +0300, Mike Rapoport wrote:
> > On Tue, Apr 23, 2019 at 12:13:54AM -0700, Christoph Hellwig wrote:
> > > On Sun, Apr 21, 2019 at 10:16:04PM +0100, Mel Gorman wrote:
> > > > 32-bit NUMA systems should be non-existent in practice. The last NUMA
> > > > system I'm aware of that was both NUMA and 32-bit only died somewhere
> > > > between 2004 and 2007. If someone is running a 64-bit capable system in
> > > > 32-bit mode with NUMA, they really are just punishing themselves for fun.
> > > 
> > > Can we mark it as BROKEN to see if someone shouts and then remove it
> > > a year or two down the road?  Or just kill it off now..
> > 
> > How about making SPARSEMEM default for x86-32?
> 
> Sounds good.
> 
> Another question:  I always found the option to even select the memory
> models like a bad tradeoff.  Can we really expect a user to make a sane
> choice?  I'd rather stick to a relativelty optimal choice based on arch
> and maybe a few other parameters (NUMA or not for example) and stick to
> it, reducing the testing matrix.

I've sent patches that remove ARCH_SELECT_MEMORY_MODEL from arm, s390 and
sparc where it anyway has no effect [1].

That leaves arm64, ia64, parisc, powerpc, sh and i386.

I'd say that for i386 selecting between FLAT and SPARSE based on NUMA
sounds reasonable.

I'm not familiar enough with others to say if such enforcement makes any
sense.

Probably powerpc and sh can enable the preferred memory model in
platform/board part of their Kconfig, just like arm.

[1] https://lore.kernel.org/lkml/1556740577-4140-1-git-send-email-rppt@linux.ibm.com

-- 
Sincerely yours,
Mike.

