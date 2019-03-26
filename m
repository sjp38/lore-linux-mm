Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F0E8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:54:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C2BB20823
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 13:54:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C2BB20823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC9856B0003; Tue, 26 Mar 2019 09:54:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D51D86B0007; Tue, 26 Mar 2019 09:54:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCD886B000A; Tue, 26 Mar 2019 09:54:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 812E56B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:54:33 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d15so11842507pgt.14
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 06:54:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=7RmVOpZbmZqzBk0/1pYVkfPyBPRDW9iVkAFkengbAQ0=;
        b=C7ityVDrQnnypFioQP8W9AuJjbKRrAnCoFUzySjP8x/SyrqU5mEbhk44ShrMDWGYTl
         eIAtMO1XEG+UrsWJ25eyPQljM+52jSO4oYpsFJ40j9tQIu+PFPvvCs9bTtHZAQGYquoT
         LCNNm58V6UUrIp7D5yJYp0I25/CMvt49JjYqS3iOhJHK2vmxr2CJLtGL0snGHwtYF9WR
         qEq+KT0qx1gG3guRvBNcDio5ymA9/3vf89eleg9V2+VBuHJcW9ogW27PflSySlouzJ7P
         zuH3uOKNUZoCE81/CLU78cIwrhGa+bUstgGlzjJbCtrSgIRq12BP211GkSEfo7arCp00
         W+KQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXGibZ6QQOWzvSLL/kTavpTekJvIonA9aIz0c62XLBNyKzr6NXY
	wzoWqIb/tTkGdEBR292RnMcFgCPNKEKHYT8ZOHkZ+SbEscBcSivQd7WKS1XgwO6sDvzFiDHi+WJ
	3zxgQIeGeA0Mon1SvN3Tnea0Z+xW2oKbkE4zmkVVf//2r6po1IVM+3F0FtfKBoebMJw==
X-Received: by 2002:a17:902:bcc9:: with SMTP id o9mr17769278pls.65.1553608473213;
        Tue, 26 Mar 2019 06:54:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfKYTui0dLSu+hA5eEiJ2T7LM8CsFYFH9O7RFtBjT8ARJ7C9iP/tBio3TBAd5+sQBxrxbO
X-Received: by 2002:a17:902:bcc9:: with SMTP id o9mr17769233pls.65.1553608472582;
        Tue, 26 Mar 2019 06:54:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553608472; cv=none;
        d=google.com; s=arc-20160816;
        b=PRQrj4yjkUKEt2fgfg7PI6khW7Q7FACqij1ka/6W9YywQbq/C3o0nOUMsOLOshSGy8
         lExfAU+x/G0HmPjfuPKDvUzE8LlbSB+bFzOchDOOzGC7ve+WK2TM9t3c61pLa8NquUPi
         l0nYNVcP57h1KXU1oYvn6HzLSQ2YnQJwlhxiCr/EfO7o4D9Wk2yYoOKwmUOc/9wsU9dj
         NNvsGKPPLMvZTT1zGv/zEmNiVBJ5Zi2Pu6LsfxWhVbTf1zS5W8tmxgG3ytCb0Uq8Yw28
         xn6uWvIk+CwnKwUy+Q8psPr7c62nGp62HJBZirCmBIN3x+FtanWDafoLKj0W5j6anQV0
         6awA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=7RmVOpZbmZqzBk0/1pYVkfPyBPRDW9iVkAFkengbAQ0=;
        b=wh1+2fHEumaT5cwvWXlqg1Stuylw3gl8wt9kCRSn1qRewZov8Y2f261oCO2/Btxft/
         JQKkMGyaE2k5xC9s4XzT/Voa9LSYEcpKUMlgn4TWiXarFanJsCnENtdwR7yxup66AMFD
         ctSs9YwZrIkg/QOvvjCkshdX0dbb0Tmn7WSZJYngQkSuoM+4hseP2mxY90noL1Fg2GIW
         8F+nyYfuaXrUkW9fgcpVEYZjvpvH2u4hBOxW2LjM9DnUaVfD21IXaGzXYnoF5PPCwbih
         ThAKGSg1+Ob15LX/hvykd0/4o/Lj1kGwji1qRZ3VdRUT4yfKaS+qXixbFjZ1KzhPB5dG
         rreQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y9si392318pgg.15.2019.03.26.06.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 06:54:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2QDsCQn079007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:54:32 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rfmpgt2ey-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:54:31 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 26 Mar 2019 13:54:29 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp03.uk.ibm.com (192.168.101.133) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 26 Mar 2019 13:54:25 -0000
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2QDsOpU47841348
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 26 Mar 2019 13:54:24 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 18E654C046;
	Tue, 26 Mar 2019 13:54:24 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 2A4894C040;
	Tue, 26 Mar 2019 13:54:23 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.52])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 26 Mar 2019 13:54:23 +0000 (GMT)
Date: Tue, 26 Mar 2019 15:54:21 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
        Vladimir Murzin <vladimir.murzin@arm.com>,
        Tony Luck <tony.luck@intel.com>,
        Dan Williams <dan.j.williams@intel.com>
Subject: Re: early_memtest() patterns
References: <7da922fb-5254-0d3c-ce2b-13248e37db83@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7da922fb-5254-0d3c-ce2b-13248e37db83@arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032613-0012-0000-0000-0000030750B4
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032613-0013-0000-0000-0000213E796B
Message-Id: <20190326135420.GA23024@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-26_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=478 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903260098
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 01:39:14PM +0530, Anshuman Khandual wrote:
> Hello,
> 
> early_memtest() is being executed on many platforms even though they dont enable
> CONFIG_MEMTEST by default. Just being curious how the following set of patterns
> got decided. Are they just random 64 bit patterns ? Or there is some particular
> significance to them in detecting bad memory.
> 
> static u64 patterns[] __initdata = {
>         /* The first entry has to be 0 to leave memtest with zeroed memory */
>         0,
>         0xffffffffffffffffULL,
>         0x5555555555555555ULL,
>         0xaaaaaaaaaaaaaaaaULL,
>         0x1111111111111111ULL,
>         0x2222222222222222ULL,
>         0x4444444444444444ULL,
>         0x8888888888888888ULL,
>         0x3333333333333333ULL,
>         0x6666666666666666ULL,
>         0x9999999999999999ULL,
>         0xccccccccccccccccULL,
>         0x7777777777777777ULL,
>         0xbbbbbbbbbbbbbbbbULL,
>         0xddddddddddddddddULL,
>         0xeeeeeeeeeeeeeeeeULL,
>         0x7a6c7258554e494cULL, /* yeah ;-) */
> };
> 
> BTW what about the last one here.

It's 'LINUXrlz' ;-)
 
> - Anshuman
> 

-- 
Sincerely yours,
Mike.

