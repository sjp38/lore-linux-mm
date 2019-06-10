Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBBF9C282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:08:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 963C92082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 08:08:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 963C92082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B80B6B026C; Mon, 10 Jun 2019 04:08:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 041F16B026D; Mon, 10 Jun 2019 04:08:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E23906B026E; Mon, 10 Jun 2019 04:08:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id BB2AD6B026C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:08:36 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id d135so2400483ywd.0
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 01:08:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=PqgTQtSo0r9/Stq135Ovtox4oTWgCszvtem3gP5RVXM=;
        b=X7tOVQLB0RvbsoZCvii3kFo4F+/yRRj9tJyZ9clSXRBKGbmehVXttSnZ8+ylnLw7fN
         pt9Ey+zCeVz2b5Fds3s3sMJZx3KBnEj4ENXmzw5oAxCBMnw+EheoTTDDKvHbzDP7927j
         4ycyZ8jHRy87fArxICc6v/Nelmpu9ZHtwP5rvmQUOhnLEhE2jKbJg9qu9qJ5Zoq/gZO4
         shCn5HO8eRn2awSnfKf5Y8w4nyQka8caq9tQezEM0JP7E+4Os84bb182lJ8kxBeYub2R
         QB8H+Ponm3gd2Q1ml/lg9ZVJk9UpM554HOboBEhejKUvYFddnbpMbXKmWjmVk0ds41j+
         TeKg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of sathnaga@linux.vnet.ibm.com) smtp.mailfrom=sathnaga@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW+5UugVQbYdAsNSlOs8fkyV7eebJeQOdtA17B3zKXpSWdTz3ya
	en5FuSksnaq8dngV3OsJil0qyx7Rq6fJr2jqUD2j4bG0b8LL9gGZurbVygXo9wotVmLBXDMD16h
	8tfph4jN6APqCUYM5mSrthUQ5f40WMNKagJHuTrdOlw8C1KDLXLVS9rd7IPh8uYo=
X-Received: by 2002:a81:a682:: with SMTP id d124mr24346112ywh.302.1560154116506;
        Mon, 10 Jun 2019 01:08:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCecNNPvDUDcmYt+hnoepT4EMqXhixC13HyCBKdalSgRZwqccmeZRwKfiqI+BVFocyhO7a
X-Received: by 2002:a81:a682:: with SMTP id d124mr24346087ywh.302.1560154115807;
        Mon, 10 Jun 2019 01:08:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560154115; cv=none;
        d=google.com; s=arc-20160816;
        b=r7dBoL7nTVw9FGOoa1MuSVo/UCmLEOFl6z2wHwimTqWrTFIZhemxKKN2fF746mhkyI
         x19S8YWZENMxPQu6rpaEBgylPcZKXU/BiIZb5CN4YpngfrtLFeQva22uAXVIvUSJulX+
         RKzQMpD38kCZ7PVjdDNMYr6een5+e3J29SDcOFgB+0Kj3g0T809Fvp9GzdXxnboz8pnP
         ds4KbgHgbGN5ClIYDL83Gg0Qgd4DINwGfhZa8KUCPkowZawhAfdP+Ni6dne60Y/KPjGB
         5LfrY/PMYzEw1ZKsQvNZIMuqcSAmMPnHvzLyGNForMvcGXI8RrRfaPlYMwEmYMAqHZmB
         5JtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=PqgTQtSo0r9/Stq135Ovtox4oTWgCszvtem3gP5RVXM=;
        b=BozJYCCYStdD5xOSR9dgscy9dP1g06uG4FVjwZgJmFz3fAOTLrVGn+ajrzCsKxRYLe
         RrKED11N1cwRjTBKAvGMcog+OyqmwncUQ8Dw17TNfwqT0DHr/dPMhqrfqMDrLtKK1l0j
         s8W0GaU7SwCazMVEdXghj7RCjo92zkV7sbI7BqKxtgIUqNxeuW8YAimARs1yDYzXyJTv
         jecxXQJ1e8b+2XN/Q5dPtJoEDsdzOnsJ33amZm7U5I/fuFZyeNZusDTExHVw+Vr54Ppc
         mkyS6oHmixBKH5p4VyrtsSZo56MmFyd9gYz2eHSiHeL4Da9EHf+Hwg+G0fD+a7Tp4q6X
         VsGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of sathnaga@linux.vnet.ibm.com) smtp.mailfrom=sathnaga@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v84si3131458ywa.314.2019.06.10.01.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 01:08:35 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of sathnaga@linux.vnet.ibm.com) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.158.5 is neither permitted nor denied by best guess record for domain of sathnaga@linux.vnet.ibm.com) smtp.mailfrom=sathnaga@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5A86gan052088
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:08:35 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t1h9j5mdv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 04:08:34 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sathnaga@linux.vnet.ibm.com>;
	Mon, 10 Jun 2019 09:08:32 +0100
Received: from b06avi18626390.portsmouth.uk.ibm.com (9.149.26.192)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 10 Jun 2019 09:08:30 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06avi18626390.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5A88N4l28639566
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 10 Jun 2019 08:08:23 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B3098A4054;
	Mon, 10 Jun 2019 08:08:29 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2F757A405F;
	Mon, 10 Jun 2019 08:08:28 +0000 (GMT)
Received: from sathnaga86 (unknown [9.85.68.20])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 10 Jun 2019 08:08:27 +0000 (GMT)
Date: Mon, 10 Jun 2019 13:38:25 +0530
From: Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
        linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
Reply-To: Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>
References: <20190610043838.27916-1-npiggin@gmail.com>
 <20190610043838.27916-4-npiggin@gmail.com>
 <1560145722.obq2bpepl8.astroid@bobo.none>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1560145722.obq2bpepl8.astroid@bobo.none>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-TM-AS-GCONF: 00
x-cbid: 19061008-0012-0000-0000-00000326DB75
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061008-0013-0000-0000-0000215FCCDC
Message-Id: <20190610080825.GA11397@sathnaga86>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-10_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=703 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906100058
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 03:49:48PM +1000, Nicholas Piggin wrote:
> Nicholas Piggin's on June 10, 2019 2:38 pm:
> > +static int vmap_hpages_range(unsigned long start, unsigned long end,
> > +			   pgprot_t prot, struct page **pages,
> > +			   unsigned int page_shift)
> > +{
> > +	BUG_ON(page_shift != PAGE_SIZE);
> > +	return vmap_pages_range(start, end, prot, pages);
> > +}
> 
> That's a false positive BUG_ON for !HUGE_VMAP configs. I'll fix that
> and repost after a round of feedback.

Sure, Crash log for that false positive BUG_ON on Power8 Host.

[    0.001718] pid_max: default: 163840 minimum: 1280
[    0.010437] ------------[ cut here ]------------
[    0.010461] kernel BUG at mm/vmalloc.c:473!
[    0.010471] Oops: Exception in kernel mode, sig: 5 [#1]
[    0.010481] LE PAGE_SIZE=64K MMU=Hash SMP NR_CPUS=2048 NUMA PowerNV
[    0.010491] Modules linked in:
[    0.010503] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 5.2.0-rc3-ga7ee9421d #1
[    0.010515] NIP:  c00000000034dbd8 LR: c00000000034dc80 CTR: 0000000000000000
[    0.010527] REGS: c0000000015bf9a0 TRAP: 0700   Not tainted  (5.2.0-rc3-ga7ee9421d)
[    0.010537] MSR:  9000000002029033 <SF,HV,VEC,EE,ME,IR,DR,RI,LE>  CR: 22022422  XER: 20000000
[    0.010559] CFAR: c00000000034dc88 IRQMASK: 0
[    0.010559] GPR00: c00000000034dc80 c0000000015bfc30 c0000000015c2f00 c00c000001fd0e00
[    0.010559] GPR04: 0000000000000000 0000000000002322 0000000000000000 0000000000000040
[    0.010559] GPR08: c000000ff9080000 0000000000000400 0000000000000400 0000000000000100
[    0.010559] GPR12: 0000000042022422 c0000000017a0000 00000001035ae7d8 0000000000000400
[    0.010559] GPR16: 0000000004000000 800000000000018e c000000000ee08c8 0000000000000000
[    0.010559] GPR20: 0000000000010000 0000000000002b22 0000000000000b20 0000000000000022
[    0.010559] GPR24: c0000007f92c7880 0000000000000b22 0000000000010000 c00a000000000000
[    0.010559] GPR28: c008000000000000 0000000004000000 ffffffffffffffff 0000000000000b20
[    0.010664] NIP [c00000000034dbd8] __vmalloc_node_range+0x1f8/0x410
[    0.010677] LR [c00000000034dc80] __vmalloc_node_range+0x2a0/0x410
[    0.010686] Call Trace:
[    0.010695] [c0000000015bfc30] [c00000000034dc80] __vmalloc_node_range+0x2a0/0x410 (unreliable)
[    0.010711] [c0000000015bfd30] [c00000000034de40] __vmalloc+0x50/0x60
[    0.010724] [c0000000015bfda0] [c00000000101e54c] alloc_large_system_hash+0x200/0x304
[    0.010738] [c0000000015bfe60] [c0000000010235bc] vfs_caches_init+0xd8/0x138
[    0.010752] [c0000000015bfee0] [c000000000fe428c] start_kernel+0x5c4/0x668
[    0.010767] [c0000000015bff90] [c00000000000b774] start_here_common+0x1c/0x528
[    0.010777] Instruction dump:
[    0.010785] 60000000 7c691b79 418200dc e9180020 79ea1f24 7d28512a 40920170 8138002c
[    0.010803] 394f0001 794f0020 7c095040 4181ffbc <0fe00000> 60000000 3f400001 4bfffedc
[    0.010826] ---[ end trace dd0217488686d653 ]---
[    0.010834]
[    1.010946] Kernel panic - not syncing: Attempted to kill the idle task!
[    1.011061] Rebooting in 10 seconds..

Regards,
-Satheesh.
> 
> Thanks,
> Nick
> 
> 

