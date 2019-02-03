Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F02D1C169C4
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 11:39:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84947217D6
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 11:39:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84947217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE34A8E001F; Sun,  3 Feb 2019 06:39:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D93048E001C; Sun,  3 Feb 2019 06:39:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5BC88E001F; Sun,  3 Feb 2019 06:39:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7138E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 06:39:26 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 68so9960467pfr.6
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 03:39:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=kuoFM4NYb2aQW9g13jwc2sI8lLwIQO4SbDbb0MQIoJY=;
        b=nSUTwnViWG+nrXQVMvlIJ6Xc04q9OWq76vmUFdpeBKC4kB1BgV/348W4lql0RfFfZM
         ORCOK1CBJJaDwAzCB31p7r7bW+mkyWPHD2g13Hjxz6WKZIKpIpkiHjxhai5P81p/iVgM
         wl/SEqDt7e3kzG9AZzGzd5KYnjrLriH3sZsPDVFuq57EXw5qBl/zPHdJkNixWbLznZzi
         MFhre91sOCBQ1eKAA3ptuFo2ncd6Thnh2hMZNP47lpM+ZDrFzfPP0DIOCb2mOGxAvXoc
         UK795mQzb7jdo8/HUssJy/QP25uL8ZSYCqXL/B6+cG8L0emVlJmpLID/8Crs8rHBY99B
         rLig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukf7W3Y+4tC2NFCC9txMKSfxdIhaPvxTdY7iv24ugMPPMy5nDMRD
	aMrtFhVoS1JtxIdx0YdNKqA9OUNaYD9WBwr8UgFZPc+9iJPQSg7SoiuCo6TFFFxGGTywV4mFmEC
	VUSvB7isootwRBCwuX63K6sS8qLeUhSfK0Xl81IwUeCXmuFSHw1PDLcLYIBKaVwWcBg==
X-Received: by 2002:a17:902:3124:: with SMTP id w33mr47786309plb.241.1549193966080;
        Sun, 03 Feb 2019 03:39:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4PNdQMRK0MBSAxptl4+d505qNc2+E76nDKW4H0Z0H4bduCoZyoKhvSKSJiU2QpY9T77XUB
X-Received: by 2002:a17:902:3124:: with SMTP id w33mr47786267plb.241.1549193965212;
        Sun, 03 Feb 2019 03:39:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549193965; cv=none;
        d=google.com; s=arc-20160816;
        b=FYr55a5OXgdG1PhOnLb6T1BSyhx3bYVM0aYaqroXu4liT6Sg8U9wqutpE0hFHJvHmg
         ul4SjTaF2l5mwhdURlJgyu2Gv4Ma7isQqDk8cDlk738Cyh3qrft+vt1Zaaey7A/h2m1n
         GEsk7OgNCG8/x0M3ODN3gTpaYsvtL96Mk/NllkGdVyBrrw7Ew4EE2S2AsZtRVq/PEJxn
         34CB4FvSh/57QhparMu8wER8jGudFIqPG6aHIhQVZSkbE45IrT/Tq4N8SDR9GVj1dIF7
         7RkcNGsgSb+g408LT2L4Dg2UaJXs9BIYgujxMEUx6hoshdY0Suctj7ULAoaRS1qecdiT
         92GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=kuoFM4NYb2aQW9g13jwc2sI8lLwIQO4SbDbb0MQIoJY=;
        b=lyWOwqmkv2kyth3IE3vmH9ruusMN2L10xQPEs7QjlqgxQjf+IWNTQ4Xl5JLhAHJ9pn
         hksgf4lYZ0CYiZBy4nwBoGliJa4o3Qjo46sEeZEeOA673lRcFt6+MOvSHYH1Se9mVYd3
         ElL7Rn7zuYQvA0rNe90sBGv40HcgiOsdivff4JLYRfyE6fXFQk48PoUb8CUVfd2sunO3
         82WpTS/5JAsuqimBpaxwCxWJBKpwCPhpxsi6C1QqINFMLqPGrHqREVYOeoCHFJejE1Zy
         b33psN0HUTPn/C2n6iFOOp51lLRgWgeMCwPWm02W0WQnvTvHKq04rwiBv2/zdA2mWWmF
         lT8A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 14si8026060pga.219.2019.02.03.03.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 03:39:25 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x13Bd07p080244
	for <linux-mm@kvack.org>; Sun, 3 Feb 2019 06:39:24 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qdsccu97f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 03 Feb 2019 06:39:24 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sun, 3 Feb 2019 11:39:22 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 3 Feb 2019 11:39:18 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x13BdHAj42467394
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Sun, 3 Feb 2019 11:39:18 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D985311C050;
	Sun,  3 Feb 2019 11:39:17 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6476F11C04C;
	Sun,  3 Feb 2019 11:39:17 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.84])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sun,  3 Feb 2019 11:39:17 +0000 (GMT)
Date: Sun, 3 Feb 2019 13:39:15 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2 10/21] memblock: refactor internal allocation functions
References: <1548057848-15136-1-git-send-email-rppt@linux.ibm.com>
 <1548057848-15136-11-git-send-email-rppt@linux.ibm.com>
 <87ftt5nrcn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ftt5nrcn.fsf@concordia.ellerman.id.au>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19020311-0016-0000-0000-000002507A7F
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19020311-0017-0000-0000-000032AA7DAA
Message-Id: <20190203113915.GC8620@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-03_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902030099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

(dropped most of 'CC)

On Sun, Feb 03, 2019 at 08:39:20PM +1100, Michael Ellerman wrote:
> Mike Rapoport <rppt@linux.ibm.com> writes:
> 
> > Currently, memblock has several internal functions with overlapping
> > functionality. They all call memblock_find_in_range_node() to find free
> > memory and then reserve the allocated range and mark it with kmemleak.
> > However, there is difference in the allocation constraints and in fallback
> > strategies.
> >
> > The allocations returning physical address first attempt to find free
> > memory on the specified node within mirrored memory regions, then retry on
> > the same node without the requirement for memory mirroring and finally fall
> > back to all available memory.
> >
> > The allocations returning virtual address start with clamping the allowed
> > range to memblock.current_limit, attempt to allocate from the specified
> > node from regions with mirroring and with user defined minimal address. If
> > such allocation fails, next attempt is done with node restriction lifted.
> > Next, the allocation is retried with minimal address reset to zero and at
> > last without the requirement for mirrored regions.
> >
> > Let's consolidate various fallbacks handling and make them more consistent
> > for physical and virtual variants. Most of the fallback handling is moved
> > to memblock_alloc_range_nid() and it now handles node and mirror fallbacks.
> >
> > The memblock_alloc_internal() uses memblock_alloc_range_nid() to get a
> > physical address of the allocated range and converts it to virtual address.
> >
> > The fallback for allocation below the specified minimal address remains in
> > memblock_alloc_internal() because memblock_alloc_range_nid() is used by CMA
> > with exact requirement for lower bounds.
> 
> This is causing problems on some of my machines.
> 
> I see NODE_DATA allocations falling back to node 0 when they shouldn't,
> or didn't previously.
> 
> eg, before:
> 
> 57990190: (116011251): numa:   NODE_DATA [mem 0xfffe4980-0xfffebfff]
> 58152042: (116373087): numa:   NODE_DATA [mem 0x8fff90980-0x8fff97fff]
> 
> after:
> 
> 16356872061562: (6296877055): numa:   NODE_DATA [mem 0xfffe4980-0xfffebfff]
> 16356872079279: (6296894772): numa:   NODE_DATA [mem 0xfffcd300-0xfffd497f]
> 16356872096376: (6296911869): numa:     NODE_DATA(1) on node 0
> 
> 
> On some of my other systems it does that, and then panics because it
> can't allocate anything at all:
> 
> [    0.000000] numa:   NODE_DATA [mem 0x7ffcaee80-0x7ffcb3fff]
> [    0.000000] numa:   NODE_DATA [mem 0x7ffc99d00-0x7ffc9ee7f]
> [    0.000000] numa:     NODE_DATA(1) on node 0
> [    0.000000] Kernel panic - not syncing: Cannot allocate 20864 bytes for node 16 data
> [    0.000000] CPU: 0 PID: 0 Comm: swapper Not tainted 5.0.0-rc4-gccN-next-20190201-gdc4c899 #1
> [    0.000000] Call Trace:
> [    0.000000] [c0000000011cfca0] [c000000000c11044] dump_stack+0xe8/0x164 (unreliable)
> [    0.000000] [c0000000011cfcf0] [c0000000000fdd6c] panic+0x17c/0x3e0
> [    0.000000] [c0000000011cfd90] [c000000000f61bc8] initmem_init+0x128/0x260
> [    0.000000] [c0000000011cfe60] [c000000000f57940] setup_arch+0x398/0x418
> [    0.000000] [c0000000011cfee0] [c000000000f50a94] start_kernel+0xa0/0x684
> [    0.000000] [c0000000011cff90] [c00000000000af70] start_here_common+0x1c/0x52c
> [    0.000000] Rebooting in 180 seconds..
> 
> 
> So there's something going wrong there, I haven't had time to dig into
> it though (Sunday night here).

Yeah, I've misplaced 'nid' and 'MEMBLOCK_ALLOC_ACCESSIBLE' in
memblock_phys_alloc_try_nid() :(

Can you please check if the below patch fixes the issue on your systems?
 
> cheers
> 

From 5875b7440e985ce551e6da3cb28aa8e9af697e10 Mon Sep 17 00:00:00 2001
From: Mike Rapoport <rppt@linux.ibm.com>
Date: Sun, 3 Feb 2019 13:35:42 +0200
Subject: [PATCH] memblock: fix parameter order in
 memblock_phys_alloc_try_nid()

The refactoring of internal memblock allocation functions used wrong order
of parameters in memblock_alloc_range_nid() call from
memblock_phys_alloc_try_nid().
Fix it.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 mm/memblock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memblock.c b/mm/memblock.c
index e047933..0151a5b 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1402,8 +1402,8 @@ phys_addr_t __init memblock_phys_alloc_range(phys_addr_t size,
 
 phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t align, int nid)
 {
-	return memblock_alloc_range_nid(size, align, 0, nid,
-					MEMBLOCK_ALLOC_ACCESSIBLE);
+	return memblock_alloc_range_nid(size, align, 0,
+					MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 }
 
 /**
-- 
2.7.4


-- 
Sincerely yours,
Mike.

