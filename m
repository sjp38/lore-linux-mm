Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D87FC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 041E621743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 11:54:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 041E621743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 912DA6B0007; Fri,  9 Aug 2019 07:54:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C2D96B0008; Fri,  9 Aug 2019 07:54:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73C306B000A; Fri,  9 Aug 2019 07:54:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35C2A6B0007
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 07:54:13 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g18so57331932plj.19
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 04:54:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :message-id;
        bh=XYzo8ta1SQfPXc3PL52prdzNrsiUCZYQyCVossBJwZ4=;
        b=HXnKXHQo1SS1FpoU4USTZeIxeOHFVk2DwEzVKwap7hsUALKFKLs5jQl3OU9z/9cbvg
         bAHwd1v0SqsraQd6PCOggWz/m7Mta3XQibgZGkyFNnr/qXNSpRG27u2DzzKtDhZoAAAO
         vo3RQ2rfbmHcAwwCPr58W95FaehtdyBxe6QOtQ10xTcVyOAb3sO8xVOk715UnLIw5FQG
         Seo3P/qDfwRCGVwIf3Fc5ODhIFAO9E3IFSedSKPs6k5QGhKoEasmop/m2l+Q4KhCLB1A
         NrIa0pWxBzGOXZ9EIqyCD6aGM7YwAxAISXqKZ+5wWzw359E/XQtua/gqSC8y/f16GeJx
         b3GQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of gor@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gor@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXrOativdb20+4IzmNI2mSrFRYP77DG3mTPVZkrqyzR5MLVgbdM
	qJ2w+JlVJy5IKbTpfu4/NENvd05GJXMHbRoh5GuFomPx48GT1iJGg/89CtiVdjmP3t25BTMVffm
	bxJTGHWMb4cFfCaFptFua3hCg95CGIh0k3Eh+maFsOrGXV9ysygt7AP19jHOcbwYMEA==
X-Received: by 2002:a17:90a:a609:: with SMTP id c9mr1729862pjq.46.1565351652817;
        Fri, 09 Aug 2019 04:54:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysEgqCEHx825YWnNv5lc1/hTmT0H24D/sa5cLkoOSrYQCpo6dRVGrDZN2xeew572NPpOAH
X-Received: by 2002:a17:90a:a609:: with SMTP id c9mr1729811pjq.46.1565351651958;
        Fri, 09 Aug 2019 04:54:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565351651; cv=none;
        d=google.com; s=arc-20160816;
        b=VoK4ii9z1TWMjEeveXt4U+PGjsD8lZ1Dh7zAVZFs9IN9Q6V/B8BnM8/c3nzNgJxTEX
         yUffhqNtpecxdkU7PpPeFhHPG0MALXgH/NjthELncCUDei98AupsxK/UzcrA96f8wLN0
         K/YB40piIVFatMZILdyfiA3TGYcC/Fqlj5Y8pttzUiy05K6l7psemaMtjD1rlKhRCVCd
         Y9WsI4LFs0jkycNowvDy0d8E8F2nbwZ5wbrOExCBnmeftM2hs1sErfUoJq80N/VbkGTA
         g0rFSVHSCIUWk5zQ8kv1El6Kj8boUDUbeOPwXciFzoMGm5PdJ8NR34o3ukc24b9fInju
         jrOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:in-reply-to:content-disposition:mime-version:references
         :subject:cc:to:from:date;
        bh=XYzo8ta1SQfPXc3PL52prdzNrsiUCZYQyCVossBJwZ4=;
        b=exZk6FSAUzNhFM0i2cOxMqSKrKyM0r/v86pInEsc1958bV1DfFvtXzmlLIhOa3QZUx
         ouKqHydxOlpUmdSmyNackLNa2uXIWuR+o37R8kusLdMobw0kBTDRIcETc/1z4Mfw4Y5/
         tWuvFOGUWOSpmcedPWsaEhs1lUVZu5Z22VKH+cRoD0tAntjG0hSWJGtQOVKLEIp8/4+/
         uXG2ZfiPLf/9tCeAeiGdctiKxFIY/6ChMsV41WlBkuJe8R73eHIPX019RcuHb/fp6qvp
         pZWwwOIsA9LeRGDrxnCMrg7FhBv/7i9UYAWM5HOdj0ckLBwFt3EfEc2Dc0TkB3AwamDm
         csDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of gor@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gor@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u3si50479861plz.201.2019.08.09.04.54.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 04:54:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of gor@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of gor@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=gor@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x79BqBhD131359
	for <linux-mm@kvack.org>; Fri, 9 Aug 2019 07:54:11 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u95b07nq2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Aug 2019 07:54:11 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gor@linux.ibm.com>;
	Fri, 9 Aug 2019 12:54:08 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 9 Aug 2019 12:54:05 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x79Bs4oh50659394
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 9 Aug 2019 11:54:04 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BDF844C046;
	Fri,  9 Aug 2019 11:54:04 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6CA394C059;
	Fri,  9 Aug 2019 11:54:04 +0000 (GMT)
Received: from localhost (unknown [9.152.212.24])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri,  9 Aug 2019 11:54:04 +0000 (GMT)
Date: Fri, 9 Aug 2019 13:54:03 +0200
From: Vasily Gorbik <gor@linux.ibm.com>
To: Daniel Axtens <dja@axtens.net>
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, x86@kernel.org,
        aryabinin@virtuozzo.com, glider@google.com, luto@kernel.org,
        linux-kernel@vger.kernel.org, mark.rutland@arm.com, dvyukov@google.com
Subject: Re: [PATCH v3 1/3] kasan: support backing vmalloc space with real
 shadow memory
References: <20190731071550.31814-1-dja@axtens.net>
 <20190731071550.31814-2-dja@axtens.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190731071550.31814-2-dja@axtens.net>
X-TM-AS-GCONF: 00
x-cbid: 19080911-0028-0000-0000-0000038DB433
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19080911-0029-0000-0000-0000244FB9F1
Message-Id: <your-ad-here.call-01565351643-ext-1834@work.hours>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-09_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908090124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 05:15:48PM +1000, Daniel Axtens wrote:
> Hook into vmalloc and vmap, and dynamically allocate real shadow
> memory to back the mappings.
> 
> Most mappings in vmalloc space are small, requiring less than a full
> page of shadow space. Allocating a full shadow page per mapping would
> therefore be wasteful. Furthermore, to ensure that different mappings
> use different shadow pages, mappings would have to be aligned to
> KASAN_SHADOW_SCALE_SIZE * PAGE_SIZE.
> 
> Instead, share backing space across multiple mappings. Allocate
> a backing page the first time a mapping in vmalloc space uses a
> particular page of the shadow region. Keep this page around
> regardless of whether the mapping is later freed - in the mean time
> the page could have become shared by another vmalloc mapping.
> 
> This can in theory lead to unbounded memory growth, but the vmalloc
> allocator is pretty good at reusing addresses, so the practical memory
> usage grows at first but then stays fairly stable.
> 
> This requires architecture support to actually use: arches must stop
> mapping the read-only zero page over portion of the shadow region that
> covers the vmalloc space and instead leave it unmapped.
> 
> This allows KASAN with VMAP_STACK, and will be needed for architectures
> that do not have a separate module space (e.g. powerpc64, which I am
> currently working on). It also allows relaxing the module alignment
> back to PAGE_SIZE.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=202009
> Signed-off-by: Daniel Axtens <dja@axtens.net>
> 
> ---
Acked-by: Vasily Gorbik <gor@linux.ibm.com>

I've added s390 specific kasan init part and the whole thing looks good!
Unfortunately I also had to make additional changes in s390 code, so
s390 part would go later through s390 tree. But looking forward seeing
your patch series upstream.

