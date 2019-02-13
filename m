Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6306C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:41:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9EF0E222C9
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 21:41:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9EF0E222C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F91F8E0003; Wed, 13 Feb 2019 16:41:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A93A8E0001; Wed, 13 Feb 2019 16:41:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 271FC8E0003; Wed, 13 Feb 2019 16:41:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF8358E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:41:29 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id n197so3324067qke.0
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 13:41:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=/O/5p2B2nIAa4Lyrp9Z14uj0PU+cqfT4uB92l+8ifHY=;
        b=LWyWXa4sHNaitt4jXB6WilgKi9vB4V7c/rHhBjnP4Bjmj7Z81Ccv1JwwmIr5JF24o2
         lLuUPvR721KSJoAXeDdBE8YOcOpMwTzyuk6uPl+XfDOrzYPxeIEJbOqXS3XFW3DnRD14
         s1khuS/Y1W31bmSd6kxRvLWwV+sb55/P/qEI4IJM5r1QdeY86MZ/JxYvuKSTNNwAwwG/
         Un+2XkSvX39cioS6zJTE8nnfD2KGfENjiws1yNRxONXTgNYWMRl3E3r9hOmL1lDvCyGg
         lnMDkWeRhprKTVXiLNUy6/rgYcjgSqN+9/6IKn4F/dp/BdshaeY4d65/sbbhfMgrvL6h
         3GmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAubqNczFrIJm+GD+VZN5avFIDZVr7xuOm8Od0CaLA2R2Bu57gNrQ
	paOqtqs/KJNa0kkm6HTBc2yOJkHmVZbltBpHmwF8kLUsBfOKi69i5NcntEmXzZ1MB/9Y0D+9AMc
	DU/F9x9z9BQCVp4tH1X3rwQIrMVEkT3ycT7yNGWALzu9qqZdtohCxPIevRJE4UexonQ==
X-Received: by 2002:aed:20a3:: with SMTP id 32mr254253qtb.9.1550094089734;
        Wed, 13 Feb 2019 13:41:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iazw/5aE8aeW7PQVrdNatemdwg/aSV95kpcYLIK3qtFh7w0zLjO++Y2JnOvbBxbXXVopEzs
X-Received: by 2002:aed:20a3:: with SMTP id 32mr254220qtb.9.1550094089016;
        Wed, 13 Feb 2019 13:41:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550094089; cv=none;
        d=google.com; s=arc-20160816;
        b=ZK522ByXfPG8+G5YB1Uem1015pZfBS6znd7zibkskSr+B5e2GqoAaQxYgUOuDexyo3
         ENffeHdRNyh7xsI0BqDO/T+WEEkebvJqPKv+fpkaWaiA96wIbfOVPkrqx9R3PJKITJbz
         9RMQXAis+wR75U2BlRfQc0aBaMXCDZfcoRI85Lyfb1fSlWeZIGhR1xRhNBX9OoKOBjxX
         Ro5f4BxkSowhe/yFiA8y4v9xtiZrw54inbADzNAZK6pSTwAWgrf47NLfJHuH7DV0pygS
         Vu8gHQZzIyDgTqcX2ARRNWi8ayWZWUxCcg3zwjedAYjbo45g2iJWqFVOZ+a/QV9PFmwO
         yuSQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=/O/5p2B2nIAa4Lyrp9Z14uj0PU+cqfT4uB92l+8ifHY=;
        b=G51QsMFICmARmsXyazxkemBADXnephWKS4DoR0KEGfUwKArcTnBBPHoGvANVgm2jC5
         yjeDsuc81ej7jn+fAimM0ch+h3kEIEcjsioNdeGEd93n/TrNIA7NHHHv4yiuoPRShx3S
         yuyudP95VEp0bF3OGQMGwG1evIOkskFYO0D71CfVFtZxLH3iJFVqRSwh3vjl4u0h3chL
         VwGt/Ndgduc/GvGfMPumCqeAh1iuwKePqACXGOv/Ge2GKmlbOn0g1RJbpXGy4yiULblh
         4oOgeveqi4VfwH1FP0VI0tB4SpCtkitpMM0u+Oy+mLbS1WdvQ/3QUFEjjJqMHS595JTf
         Za4w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e43si291591qve.151.2019.02.13.13.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 13:41:29 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1DLci4h019016
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:41:28 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qmsv7bs2k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:41:28 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 13 Feb 2019 21:41:22 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 13 Feb 2019 21:41:19 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1DLfIjG7471430
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 13 Feb 2019 21:41:18 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 564F511C050;
	Wed, 13 Feb 2019 21:41:18 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4200211C058;
	Wed, 13 Feb 2019 21:41:17 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.163])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed, 13 Feb 2019 21:41:17 +0000 (GMT)
Date: Wed, 13 Feb 2019 23:41:15 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Russell King <linux@armlinux.org.uk>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Will Deacon <will.deacon@arm.com>, Guan Xuetao <gxt@pku.edu.cn>,
        linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
        linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 7/8] initramfs: proide a generic free_initrd_mem
 implementation
References: <20190213174621.29297-1-hch@lst.de>
 <20190213174621.29297-8-hch@lst.de>
 <20190213184139.GC15270@rapoport-lnx>
 <20190213184448.GB20399@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213184448.GB20399@lst.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021321-0016-0000-0000-0000025622C8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021321-0017-0000-0000-000032B04C09
Message-Id: <20190213214114.GE15270@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-13_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902130142
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 07:44:48PM +0100, Christoph Hellwig wrote:
> On Wed, Feb 13, 2019 at 08:41:40PM +0200, Mike Rapoport wrote:
> > csky seems to open-code free_reserved_page with the only
> > difference that it's also increments totalram_pages for the freed pages,
> > which doesn't seem correct anyway...
> > 
> > That said, I suppose arch/csky can be also added to the party.
> 
> Yes, I noticed that.  But I'd rather move it over manually in
> another patch post rc1 or for the next merge window.

Fair enough.
 
> > > +void __weak free_initrd_mem(unsigned long start, unsigned long end)
> > > +{
> > > +	free_reserved_area((void *)start, (void *)end, -1, "initrd");
> > 
> > Some architectures have pr_info("Freeing initrd memory..."), I'd add it for
> > the generic version as well.
> 
> Well, if we think such a printk is useful it should probably be
> moved to the caller in init/initramfs.c instead.  I can include a
> patch for that in the next iteration of the series.

I found it useful during board bring ups, this gave some starting point
when everything hangs and you are out to catch the lion in the desert.

> > Another thing that I was thinking of is that x86 has all those memory
> > protection calls in its free_initrd_mem, maybe it'd make sense to have them
> > in the generic version as well?
> 
> Maybe.  But I'd rather keep it out of the initial series as it looks
> a little more complicated.  Having a single implementation
> of free_initrd_mem would be great, though.

Ok.

BTW, the memblock_free() arm64 does, seems to be relevant for architectures
with CONFIG_ARCH_DISCARD_MEMBLOCK=n.
On powerpc the freed initrd region shows up in
/sys/kernel/debug/memblock/reserved.

-- 
Sincerely yours,
Mike.

