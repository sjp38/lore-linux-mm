Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6436C04AA8
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 05:40:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72CF521734
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 05:40:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72CF521734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2D126B0005; Wed,  1 May 2019 01:40:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB6616B0006; Wed,  1 May 2019 01:40:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D302C6B0007; Wed,  1 May 2019 01:40:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 95AB16B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 01:40:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id l13so10413056pgp.3
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 22:40:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=ij5rHLn+el6/0FGN/guCdrcNXtc0XAmZz/TXApywyII=;
        b=aXj2AS0riY33BRZ/M1I+Vu0d2/GmE50/XGEK+M34z10f4IqlLUnaSiox6MR5D9naoW
         TdnjGz3KQb0JJ8qYDpMW6d+bnFpwv4CoKOoHL5wZApgClU6MreMWvs7c/u8o91E+ZZb5
         u30MJw4Dr7zvLjHdrEZ0IjhKSgeVyC4/deEy4TKqe3GlBkqRfwNxDazNd56WniW+P2xf
         SLWk+/nYLi7jykYwhp9PV0zQzKH8QnovxPM/eIq3VYALBKSIDJDZdPh6/9BULl/eO+2m
         O6H05ceYbtbfsnpqsrreEwM5Baglv2GpCRgLw1595RB0iCUakPLhlQ7hv/4OJj/QxA7p
         zfnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUT5f1kHU5WcG9v39z6Hx0Q90xBNao3TMxNti3/Za/xJKKFRjNw
	7tp0dMNeWZgeRPOOM4BISB9sZo0bi2NOGg6cP90IN86nKv+Xta+Gm6K3rxN2eKeoJKq8Y8/VCqz
	fQZE6kK3I6jS6CyggTFkVlq7HQYR4soyaQX7WeBTY6C0kJx2LNUZFaNCWHs5No/voBQ==
X-Received: by 2002:a65:6282:: with SMTP id f2mr22776671pgv.152.1556689212252;
        Tue, 30 Apr 2019 22:40:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymk5B01My90N+Yp771DTc/sKUW/PDOuLF6lBYZg6sZGunKIECtsNDTSbBiVbI2t5cb2ttG
X-Received: by 2002:a65:6282:: with SMTP id f2mr22776627pgv.152.1556689211345;
        Tue, 30 Apr 2019 22:40:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556689211; cv=none;
        d=google.com; s=arc-20160816;
        b=ow2BYRP8YZ3c8lykjBliWX/hmKrCQT5P9qERKWP466XuMEZ362jFXIIbxsg7YV9PYn
         xKGASXRKh7SQVnIOojIxaVuQ3CKk9NrhGGjYHHd2KkxeMEIAPP2aoVuT2kP30QBDDt+v
         pw+yDUiZn9U7cRHu6HKeVus06VeXMCryrNF6wOZlZ2o0niqi3TDPOCoWWNoDhU5OwbbP
         9R4toKOdoZsr82n78zA1UYw0EHvqD3JxmQWZ+JFlP7wXNk05MYrrpeJ28Xtj+6IBz7Ie
         +3Y1aOQER3emxFAAn/65asNR4gUBoy6yk9DmNm6M3vHNyBTG6Z++J1lvPrRu7D7RVJfH
         LfIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=ij5rHLn+el6/0FGN/guCdrcNXtc0XAmZz/TXApywyII=;
        b=SM7RWd2kET/FvZl35wrB8+MIg8KteXFWYuBitPKOetAoVpKfalUy/0I9KQ2vg/gR8s
         O6VcfVGe3D4vR4HuMfwsFOlHY2n+TZs+TvDcZjQ7/4RxqZmYeBdgt0MbvvnlP6opQI9/
         EN8qUwPOvXG7WKqJ4ASteUHllpmnvsgKD155+vhvUP/fzyzCL3vkBPzqT/rsmDOMnT6/
         Ay5E8ZuXSxX0B+nk6GyE1ITpGScEb1KaCFjtonZFWaldRhPNCfYdpEWGd+7lWKEMVZv2
         lesJOnkWLVImJwdgJkp/FH9tWM0Dtagg+lliUKD3ql1EQ+2MCra1nk7ubrr3ks3xh90g
         jl/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e6si33562570pga.251.2019.04.30.22.40.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 22:40:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x415RKgs065643
	for <linux-mm@kvack.org>; Wed, 1 May 2019 01:40:10 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s750x0xrv-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 May 2019 01:40:10 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 1 May 2019 06:40:07 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 1 May 2019 06:40:03 +0100
Received: from d06av22.portsmouth.uk.ibm.com (d06av22.portsmouth.uk.ibm.com [9.149.105.58])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x415e23k61276382
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 1 May 2019 05:40:02 GMT
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6021D4C050;
	Wed,  1 May 2019 05:40:02 +0000 (GMT)
Received: from d06av22.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 389484C058;
	Wed,  1 May 2019 05:40:01 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.112])
	by d06av22.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  1 May 2019 05:40:01 +0000 (GMT)
Date: Wed, 1 May 2019 08:39:59 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>,
        Alexandre Chartre <alexandre.chartre@oracle.com>,
        Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
        Paul Turner <pjt@google.com>, Thomas Gleixner <tglx@linutronix.de>,
        Linux-MM <linux-mm@kvack.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        X86 ML <x86@kernel.org>
Subject: Re: [RFC PATCH 5/7] x86/mm/fault: hook up SCI verification
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
 <1556228754-12996-6-git-send-email-rppt@linux.ibm.com>
 <20190426074223.GY4038@hirez.programming.kicks-ass.net>
 <20190428054711.GD14896@rapoport-lnx>
 <CALCETrWrtRo1PqdVmJQQ95J8ORy9WBkUraJCqL6JNmmAkw=H0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWrtRo1PqdVmJQQ95J8ORy9WBkUraJCqL6JNmmAkw=H0w@mail.gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19050105-0020-0000-0000-000003381EA9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050105-0021-0000-0000-0000218AA112
Message-Id: <20190501053958.GA3877@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-01_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=406 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905010038
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 09:44:09AM -0700, Andy Lutomirski wrote:
> On Sat, Apr 27, 2019 at 10:47 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > On Fri, Apr 26, 2019 at 09:42:23AM +0200, Peter Zijlstra wrote:
> > > On Fri, Apr 26, 2019 at 12:45:52AM +0300, Mike Rapoport wrote:
> > > > If a system call runs in isolated context, it's accesses to kernel code and
> > > > data will be verified by SCI susbsytem.
> > > >
> > > > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > > > ---
> > > >  arch/x86/mm/fault.c | 28 ++++++++++++++++++++++++++++
> > > >  1 file changed, 28 insertions(+)
> > >
> > > There's a distinct lack of touching do_double_fault(). It appears to me
> > > that you'll instantly trigger #DF when you #PF, because the #PF handler
> > > itself will not be able to run.
> >
> > The #PF handler is able to run. On interrupt/error entry the cr3 is
> > switched to the full kernel page tables, pretty much like PTI does for
> > user <-> kernel transitions. It's in the patch 3.
> >
> >
> 
> PeterZ meant page_fault, not do_page_fault.  In your patch, page_fault
> and some of error_entry run before that magic switchover happens.  If
> they're not in the page tables, you double-fault.

The entry code is in sci page tables, just like in user-space page tables
with PTI.
 
> And don't even try to do SCI magic in the double-fault handler.  As I
> understand it, the SDM and APM aren't kidding when they say that #DF
> is an abort, not a fault.  There is a single case in the kernel where
> we recover from #DF, and it was vetted by microcode people.
> 

-- 
Sincerely yours,
Mike.

