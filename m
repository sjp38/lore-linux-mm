Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98083C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:21:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5223D20863
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 08:21:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5223D20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E40546B0003; Tue, 21 May 2019 04:21:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCA366B0005; Tue, 21 May 2019 04:21:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1C8D6B0006; Tue, 21 May 2019 04:21:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 863846B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:21:28 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d12so11890160pfn.9
        for <linux-mm@kvack.org>; Tue, 21 May 2019 01:21:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=2MV4p7qbjQ5LJkr2qPo04SkJ6SPq8NqO6v9FPo3ZFFU=;
        b=kHRW1uMzH/rzANb/Lwkdzh0HhAsugH2n5WPh0fMIzy8tkELPZVKS9h13iHl5GXqYNa
         s5HNU2rXiwBlstjEdd+vAnN5EFWEtjhXszUxhnWiA7bQYTWc13PFMHcXvlNYnzdW8HDF
         LQxRL6zFMpSRK+tryrXnXTQuRJ31md09NtSYs7qar8RMqpSrSCd0xADFH1GFOCvV+mFL
         FXyMDD+dBxYcOYRkjnBmlC0eWBWYIP6E0j+ayy/ahRUUGN0JkGtdwX/xcSGrMe20AbmW
         UMNIRIoVqqNIf9pvH/7uWvAWSxG/C1bEd89WTUVbpHh5L5wusvaZx80fhIPsq5woSxo0
         eFnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWTzKAdo7ta375NM0D/9RmgYjk5n1bxQOax1hozdPGfkgb2Xos7
	jJvvlgZZBgIoUCbdfesZ4LmSqjd/7IX2w6pjWFtdqea1Gxis43fPlGKaMvzqL6rrhAgLMaX4n9e
	w0yIWe+L2j7piM+LolE9804SbJMayCqX40N2ppb3VefLks/vt6UhDcaVxyzbA/AvfuA==
X-Received: by 2002:a65:6116:: with SMTP id z22mr81083370pgu.50.1558426888196;
        Tue, 21 May 2019 01:21:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZBhCYQafi3Q5zjJC44YPG5yPgMkRbrrKp7ZGZQFb5hLkYqmwUM2jCM4l7vc8zAB/IA9E8
X-Received: by 2002:a65:6116:: with SMTP id z22mr81083313pgu.50.1558426887441;
        Tue, 21 May 2019 01:21:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558426887; cv=none;
        d=google.com; s=arc-20160816;
        b=nbgC8GSDnv2TkgcFpBVS7hnoBLkpVxY7pgny9z6xtTSoFFy8GpvKoy8SJ1/OHRjmo5
         ge5FRl9AzUQu2BkK3zBxpiKD6I6fP48dw/HYlvt5pnqL8d7sYo6KStyfxWcSxyw9DSKC
         9HHMdRHfULlNjGvnY/xZclkBwOzX61PYGGrSXauOBAyJ14ybbf8tlRFY+8AKG5wVD/ox
         VX61NYECNC+qzOXln/bssF5sbHlmcPPftyAJYOGFaLnk0To+GFKtaswPpEe3fUBDPO2J
         STddg0myH5lRH2wdDtyTAfplfpA7rF6dI+GpNe+qzrnU21EF+ToA6A5cqtJOGj4wUIJb
         RsJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=2MV4p7qbjQ5LJkr2qPo04SkJ6SPq8NqO6v9FPo3ZFFU=;
        b=GsaxXFGtX2NqNrxQY55lhYxKPlu2bHG+R7ONcNezurxpVYjQPPf8lUjqi+fCtGG+nL
         9v3H9+ZIUPCL6PF5oHwMExhZt8bo1sGSpHVd3bCOmB7/9p4nvEGGuDyQ3fRNKxTwleqA
         FYZNs0+1Zwq+3tvi53PFOju1A8mTHT5ZFn9NINxNL1z4Fr0DaKVFX+SMvGhLUbvIxzSu
         g4mvlmU3LR2ylBv/7yPMEREyR/WYJrzKn50g7AYJH0ntNB1SFQpYZp4PpxtPeqZfX9Jf
         wkmDtRUzp3pxYC5wp+ts4E3iwG9U3Rw0xTjc02WL5rw50ndFNTnN7rbjcXX/EQ41dgrV
         B+Cw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 2si17858040pla.437.2019.05.21.01.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 01:21:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4L8FX4p104003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:21:26 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2smdj0ggbu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 04:21:25 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 21 May 2019 09:21:23 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 21 May 2019 09:21:21 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4L8LKmk62259236
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 08:21:20 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7C45AA405F;
	Tue, 21 May 2019 08:21:20 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 15BEAA405B;
	Tue, 21 May 2019 08:21:20 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 21 May 2019 08:21:19 +0000 (GMT)
Date: Tue, 21 May 2019 11:21:18 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm: fix Documentation/vm/hmm.rst Sphinx warnings
References: <c5995359-7c82-4e47-c7be-b58a4dda0953@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c5995359-7c82-4e47-c7be-b58a4dda0953@infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19052108-0008-0000-0000-000002E8D8D2
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052108-0009-0000-0000-000022558DF5
Message-Id: <20190521082118.GC3589@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=655 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210054
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 02:24:01PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix Sphinx warnings in Documentation/vm/hmm.rst by using "::"
> notation and inserting a blank line.  Also add a missing ';'.
> 
> Documentation/vm/hmm.rst:292: WARNING: Unexpected indentation.
> Documentation/vm/hmm.rst:300: WARNING: Unexpected indentation.
> 
> Fixes: 023a019a9b4e ("mm/hmm: add default fault flags to avoid the need to pre-fill pfns arrays")
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

> ---
>  Documentation/vm/hmm.rst |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> --- lnx-52-rc1.orig/Documentation/vm/hmm.rst
> +++ lnx-52-rc1/Documentation/vm/hmm.rst
> @@ -288,15 +288,17 @@ For instance if the device flags for dev
>      WRITE (1 << 62)
> 
>  Now let say that device driver wants to fault with at least read a range then
> -it does set:
> -    range->default_flags = (1 << 63)
> +it does set::
> +
> +    range->default_flags = (1 << 63);
>      range->pfn_flags_mask = 0;
> 
>  and calls hmm_range_fault() as described above. This will fill fault all page
>  in the range with at least read permission.
> 
>  Now let say driver wants to do the same except for one page in the range for
> -which its want to have write. Now driver set:
> +which its want to have write. Now driver set::
> +
>      range->default_flags = (1 << 63);
>      range->pfn_flags_mask = (1 << 62);
>      range->pfns[index_of_write] = (1 << 62);
> 
> 

-- 
Sincerely yours,
Mike.

