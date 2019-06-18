Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2104C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 06:13:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A9C5214AF
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 06:13:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A9C5214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E1138E0002; Tue, 18 Jun 2019 02:13:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 990598E0001; Tue, 18 Jun 2019 02:13:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 859108E0002; Tue, 18 Jun 2019 02:13:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 671688E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:13:12 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id b63so14601244ywc.12
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 23:13:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=JMNoa2iPMFTBFloOwUSc7EOmzk+3UZMT3/IA/IITpLQ=;
        b=EuyJSsbhZ/7/rLCeBLEXd2WX4Wlox0zw9PE8UhtboJ8kw4gJIM59cJ8BoQF+h8VUK8
         P4gs8WH4dYopOqUnLMZ8Kz+GMxxtr4sOltUDd9tStufOnsZcggvEjXVwrUPu0scVZBqM
         EMrCjIrH98PGup36jlqt+tmK5v+o9v9bARAxaz0CkHDMaEiC8qThzzU6ATpD7SSKvh/1
         /TqZbErVuOU5kZ5FivwrWyYeF0mOpsGpOiTjV0qVxg0WaDhpbOJb1abrOSzKIg5LyWt+
         d8ZvrXKDJtwsa0pejZmGCWLZkAzztNkiyN5iSBxax/IWrINvMj8aLVM+RYrP4qOynzzN
         +HpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUuU8X7XXiVBr3X1W1XLObPg1pQlpFk3xOhcFM1T6BDfyNeOf+W
	bWVFw3xG3V94/y5FyFCRnGhbAbW6Q32UPemceF0l5QolEV2Ye4IL78fFvKh5dVbqc2th74PN7ze
	BDNDX4fpl5XVZMvxb75obwWswkKlays0eim0RTJ8WmsFkaGaxxHyqtAdnTEXM8LXvgA==
X-Received: by 2002:a81:6ad4:: with SMTP id f203mr50436691ywc.196.1560838392064;
        Mon, 17 Jun 2019 23:13:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3Ff2P5V+Sfk/UuUyOki9wpCrywz14uUuVAmoGbzYSWubRfyMUZpW4lek+Xrh9NJsdbFhD
X-Received: by 2002:a81:6ad4:: with SMTP id f203mr50436669ywc.196.1560838391363;
        Mon, 17 Jun 2019 23:13:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560838391; cv=none;
        d=google.com; s=arc-20160816;
        b=oRQXvA10/AYgxsUFCkLXOBaM/uJLIQN242zMLk3gwGxWJMtWw47CQxkKQo39+3WxuJ
         2xOcPmMkNrd8P4+fMOAT5ce9bdkqK7t39LjHx3ZUlZt/G6fsCRKoq0EL9nQTMEvUaH8g
         Lv4c9HLyVFY323imKUWFq74W6UIgWbSBV+poiBiEmvL0qxgNzEeBo9xGtRS+5nCzOsi4
         bhZUp+zFOjyqQYL7B8PdCIhZnHwjAAmef3fztIN6W4sdCYXlS2lHfyOBnrMK8YMtgB7/
         ER3un9ufZHfo81DKhUODeZT3dD1XaaX4HX9f6GTcKlIetme7V4fq0/NxNHmyt6D7rECj
         LzTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=JMNoa2iPMFTBFloOwUSc7EOmzk+3UZMT3/IA/IITpLQ=;
        b=VFvpbbudm/cWgQHMOIW/kzHOI0nH01XS347X+GzfjuncpOLt/asuIQNu+AwDhpRrYW
         H1CUPThduEuweqtrlt4StQZZjMVjAW694j0naOLggbhaenPDJLvpRkdUL681O9PGr1FI
         F0qwo5eCNX7JhYtEh6qg+gWbYR1XVEsE5fRsetCbX3pdrZPpBoTLjhxGDwb287ybT++b
         50bvhQMH9AOySrSQ4v+mB8r15ne8KBfOutJ0Jd5yXS0hWNwMGTcAdrTNj51HEbKvbWFd
         Lo/TTxUGb75Gij46pK6JcwkUaLpXC33dKg6xrZiK4l/IjkBMJylTQEYhiNd9ORYMORnf
         rcuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l2si4263781ybm.249.2019.06.17.23.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 23:13:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5I67Hvn018354
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:13:10 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t6s532mra-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:13:10 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 18 Jun 2019 07:13:08 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 18 Jun 2019 07:13:03 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5I6D2jD61210840
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 18 Jun 2019 06:13:02 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 79475A4040;
	Tue, 18 Jun 2019 06:13:02 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7A0E8A4051;
	Tue, 18 Jun 2019 06:13:01 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 18 Jun 2019 06:13:01 +0000 (GMT)
Date: Tue, 18 Jun 2019 09:12:59 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Qian Cai <cai@lca.pw>,
        akpm@linux-foundation.org, Roman Gushchin <guro@fb.com>,
        catalin.marinas@arm.com, linux-kernel@vger.kernel.org,
        mhocko@kernel.org, linux-mm@kvack.org, vdavydov.dev@gmail.com,
        hannes@cmpxchg.org, cgroups@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190610114326.GF15979@fuggles.cambridge.arm.com>
 <1560187575.6132.70.camel@lca.pw>
 <20190611100348.GB26409@lakrids.cambridge.arm.com>
 <20190613121100.GB25164@rapoport-lnx>
 <20190617151252.GF16810@rapoport-lnx>
 <20190617163630.GH30800@fuggles.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190617163630.GH30800@fuggles.cambridge.arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19061806-0008-0000-0000-000002F4A996
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061806-0009-0000-0000-00002261BF41
Message-Id: <20190618061259.GB15497@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-18_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=947 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906180050
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 05:36:30PM +0100, Will Deacon wrote:
> Hi Mike,
> 
> On Mon, Jun 17, 2019 at 06:12:52PM +0300, Mike Rapoport wrote:
> > Andrew, can you please add the patch below as an incremental fix?
> > 
> > With this the arm64::pgd_alloc() should be in the right shape.
> > 
> > 
> > From 1c1ef0bc04c655689c6c527bd03b140251399d87 Mon Sep 17 00:00:00 2001
> > From: Mike Rapoport <rppt@linux.ibm.com>
> > Date: Mon, 17 Jun 2019 17:37:43 +0300
> > Subject: [PATCH] arm64/mm: don't initialize pgd_cache twice
> > 
> > When PGD_SIZE != PAGE_SIZE, arm64 uses kmem_cache for allocation of PGD
> > memory. That cache was initialized twice: first through
> > pgtable_cache_init() alias and then as an override for weak
> > pgd_cache_init().
> > 
> > After enabling accounting for the PGD memory, this created a confusion for
> > memcg and slub sysfs code which resulted in the following errors:
> > 
> > [   90.608597] kobject_add_internal failed for pgd_cache(13:init.scope) (error: -2 parent: cgroup)
> > [   90.678007] kobject_add_internal failed for pgd_cache(13:init.scope) (error: -2 parent: cgroup)
> > [   90.713260] kobject_add_internal failed for pgd_cache(21:systemd-tmpfiles-setup.service) (error: -2 parent: cgroup)
> > 
> > Removing the alias from pgtable_cache_init() and keeping the only pgd_cache
> > initialization in pgd_cache_init() resolves the problem and allows
> > accounting of PGD memory.
> > 
> > Reported-by: Qian Cai <cai@lca.pw>
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  arch/arm64/include/asm/pgtable.h | 3 +--
> >  arch/arm64/mm/pgd.c              | 5 +----
> >  2 files changed, 2 insertions(+), 6 deletions(-)
> 
> Looks like this actually fixes caa841360134 ("x86/mm: Initialize PGD cache
> during mm initialization") due to an unlucky naming conflict!
> 
> In which case, I'd actually prefer to take this fix asap via the arm64
> tree. Is that ok?

I suppose so, it just won't apply as is. Would you like a patch against the
current upstream?

> Will

-- 
Sincerely yours,
Mike.

