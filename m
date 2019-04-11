Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 310D3C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:28:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3C382073F
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 20:28:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="G8uviIkL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3C382073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6550C6B0269; Thu, 11 Apr 2019 16:28:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 629686B026A; Thu, 11 Apr 2019 16:28:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F1D46B026B; Thu, 11 Apr 2019 16:28:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0279A6B0269
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:28:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h27so3638610eda.8
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:28:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=woVzfZGcSwnBxxuUFWVwRSs3kH2EYlIWop6DF6lHv4A=;
        b=eRdXqDeLXszMFhPG6zv/c16Cfcr2L6UOvHEgZ1slEBtiNqOVaRYz9s0+APqsG6MPj1
         x+pj6i6oxSlzwhZcpLw893xSRvVCbKca9m/4Tl6/+MBoFuJG4xM9z6rZvdmLMnSmtXZd
         N1vujWS7VfpQLC5+kj51TPCmowQJpJtg8RyvMANXMGbFHjLtDEGBEuPaXmEZrSM7rpoF
         SyVnSAM6BVnBrfG2HUEbZLokzTE7S5yYYBnraUERdgYCbXSJyAxtiQwULSijfZj3aifE
         z4WlOXG6ZZwLR2jcM+1khpK9dMes9i65yzZWJEf7u4yfCVeGXtLZJb0XMAQJ+NFZ71+I
         d8bQ==
X-Gm-Message-State: APjAAAU32V0u0av3CP+Oer8gmF41bcKMdkXlarN1EAzHtIEe4CXL7LEq
	asd0eeUjuy60+AN9lDtBmyGdq5V/MoaO8Ct0Z9hIeUwhY/lEvixL8IRfLqH9MZRt/C6LmPzGgCR
	30eIRXKV1Y8RMd/8aVTNnfCCg1uYsJeAwJaQZ/ZJT+3+HfLfGgrXKKiDd9flfwJcj7Q==
X-Received: by 2002:a17:906:5949:: with SMTP id g9mr28299072ejr.15.1555014492473;
        Thu, 11 Apr 2019 13:28:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLrbrlG+BdnoF9RhULcYskdBsqEtki4f2dQp/guI3dHoQsUUati8gnv831R+PzHdxFyEHs
X-Received: by 2002:a17:906:5949:: with SMTP id g9mr28298994ejr.15.1555014490402;
        Thu, 11 Apr 2019 13:28:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555014490; cv=none;
        d=google.com; s=arc-20160816;
        b=eHFcpbwG14+nRFdhxyB6aP9UMM1xMWnRureVy2hGmWIytuXPiZWERRdHEn7wTUcS6+
         Gh3qIbA7sWYMzEDlK/+7u1SaC2VMNZuM8QniLY474W5hi1OGhsTrSfDik0VIBeMfYrQ8
         EhPj1RYC+HVPrtcqKDFjEfcSkOvH9coA0tn9GdEJoLrv0mHRWAgSNrerx5MItv9a7RJl
         /KxkJRn2wG2PIUx2+vLZ+KE6vhebNp7YZoBDdHwogKn44UoZ7ZenehwUZaVkK6DK19Ne
         PPNrEd7mXAEeHf+MrsMU0xpGuOTCapFlbPlefAmNaDmcEvaZKNMr+bdegg1jfAQOOV0l
         C4eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=woVzfZGcSwnBxxuUFWVwRSs3kH2EYlIWop6DF6lHv4A=;
        b=lNnYwlSp3ZjlhIbKf+CkOfSo6ZGrRJzk/xLnTuR6rkTI6XlisWOITAeLWGmEubPmnw
         foc6M6LCAJ5nI5LL/umk4shhZrPorILwAh8zDJz+fAwLBQk958+iKNkB6R9eQT0/NmZj
         Zq5KUn6oQNoqKRAVl9Wre/cBtsepkE5hgHlVt5udPOBhwjn+F51P4cilNNMLjf85MTof
         itKLd4CN4mAgLLgkoaihm1A0MqdRu13Oq2mH61j5pRUBsSNR4Fq8p9KBMfZIPR8n7XC3
         +OPa/QUy3S+1aQ81bvLQTPPFgwqmiItxBx4py0znvSD0yo2pWaJlDKUUuYO5Dm/BRyTs
         0R+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=G8uviIkL;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h21si2057410edj.48.2019.04.11.13.28.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 13:28:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=G8uviIkL;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3BK9esF173636;
	Thu, 11 Apr 2019 20:27:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=woVzfZGcSwnBxxuUFWVwRSs3kH2EYlIWop6DF6lHv4A=;
 b=G8uviIkLAA9Z4UISLkf/C4W8xdBmwKfeekBgf+eUf/T5l7j3aBysnlTWaWmUuNpMucs9
 1/Xw5m4YJisDnkHWyx0hLuB6TE92uqt0brXoo7VB0MhawF7UH6Olx59SC+IGyGdj6/Lg
 dAIEQDF2iVN82OwwzNmODFuBqQ3uKmOO0BQUigXwCAp6krbDL1QyEB/VL5llFQgynlGK
 KQyE7Ba+3NE4HA4uNTIp4IWevgLZUJV5vmEP0hn+vWzuG1/MEbPHc9ZTSftVo5oqttk7
 tt4g+WH1/b82cIp/1eAyFcHj5O2mpMG7O3pjLbU6wSEVHsRZ5mhvxnITl7B5aNRNeXyZ fg== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2rphmeuat5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 20:27:53 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3BKRf6p072214;
	Thu, 11 Apr 2019 20:27:52 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2rt9upu0ak-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 20:27:52 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3BKRix9020217;
	Thu, 11 Apr 2019 20:27:44 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 11 Apr 2019 13:27:43 -0700
Date: Thu, 11 Apr 2019 16:28:07 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
        Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        Alan Tull <atull@kernel.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
Message-ID: <20190411202807.q2fge33uoduhtehq@ca-dmjordan1.us.oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
 <20190402204158.27582-2-daniel.m.jordan@oracle.com>
 <614ea07a-dd1e-2561-b6f4-2d698bf55f5b@ozlabs.ru>
 <20190411095543.GA55197@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411095543.GA55197@lakrids.cambridge.arm.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=18 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=867
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904110133
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=18 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=894 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904110133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:55:43AM +0100, Mark Rutland wrote:
> On Thu, Apr 11, 2019 at 02:22:23PM +1000, Alexey Kardashevskiy wrote:
> > On 03/04/2019 07:41, Daniel Jordan wrote:
> 
> > > -	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %ld/%ld%s\n", current->pid,
> > > +	dev_dbg(dev, "[%d] RLIMIT_MEMLOCK %c%ld %lld/%lu%s\n", current->pid,
> > >  		incr ? '+' : '-', npages << PAGE_SHIFT,
> > > -		current->mm->locked_vm << PAGE_SHIFT, rlimit(RLIMIT_MEMLOCK),
> > > -		ret ? "- exceeded" : "");
> > > +		(s64)atomic64_read(&current->mm->locked_vm) << PAGE_SHIFT,
> > > +		rlimit(RLIMIT_MEMLOCK), ret ? "- exceeded" : "");
> > 
> > 
> > 
> > atomic64_read() returns "long" which matches "%ld", why this change (and
> > similar below)? You did not do this in the two pr_debug()s above anyway.
> 
> Unfortunately, architectures return inconsistent types for atomic64 ops.
> 
> Some return long (e..g. powerpc), some return long long (e.g. arc), and
> some return s64 (e.g. x86).

Yes, Mark said it all, I'm just chiming in to confirm that's why I added the
cast.

Btw, thanks for doing this, Mark.

