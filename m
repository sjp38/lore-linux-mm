Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74E42C072B1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:04:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F9A4206C1
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 15:04:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bgq/F8b/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F9A4206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3E7C6B0276; Tue, 28 May 2019 11:04:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EE356B0279; Tue, 28 May 2019 11:04:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6C96B027A; Tue, 28 May 2019 11:04:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 623976B0276
	for <linux-mm@kvack.org>; Tue, 28 May 2019 11:04:58 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id z11so6895148otk.7
        for <linux-mm@kvack.org>; Tue, 28 May 2019 08:04:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=G9vBM5THlG8pywNzVbsKIK8sbELnMUDNM7aCaLdslP0=;
        b=qCwNjPRBkG91JXt/TKW0MhfIv7Q7vkg0Cn/JSFq2MvHrpDzHIfyTadycPp8GpqHnl/
         K4vJKdjw1xopSEJV5VTTUqmdhclPbNhINuP8aFr6hb88c2IWy9zlQ9lCXO4Lx0pOKWQu
         6T/vKpkRhe26Rqhi5KO/N7cgGiKW5kOZtA0gXGrgnCee2YdcDzr6YK4BmTj9inD3Zu42
         Lb+xNIwnr9dpzyd6OGowvaoep7+Sk4yoMvrGc0aOjuiYnm2YN/Qmrs6yi8ipRuKOLzQS
         +doFgm2wFnTrGbB30aMxyHaudLUOcj/XSyN7nBKq4WboYnPEI87ksykjOgow5DRkffaA
         whiA==
X-Gm-Message-State: APjAAAWkNZdxaAnA/Z3LkrYxw0jBEcI+hZKmXdRR+Ppgric1gJl4YKtK
	xwRhcJra8l6riiEH6wCpV74YddOGBSVepVECt6B5gXoJ/bPdUnTcx90Yhsn7gMWvEcXZNBdBreX
	C/9tcq7lc9xM2/HIU1UxhKUGJo3JQ5intYLNym4kg6/jQqpP1Tam38J8JmCvOogji8A==
X-Received: by 2002:a9d:480f:: with SMTP id c15mr69720488otf.255.1559055898028;
        Tue, 28 May 2019 08:04:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9q2PYRespLS4ZYaLYxMbMaAPDlyyT177BrsGL18FtioHoy3YlbK8886Uas8+pezNK/xgt
X-Received: by 2002:a9d:480f:: with SMTP id c15mr69720441otf.255.1559055897420;
        Tue, 28 May 2019 08:04:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559055897; cv=none;
        d=google.com; s=arc-20160816;
        b=xoB9wPrvqUHDw4qG94MQAAhIAmDolp5LPU0C68MWevoOaHqUqLSosg4jl44n7gn60/
         kJceTI91Jpe03fTcfTHt4SCLQILk6GNWen0GqPe26pLF5aWmel6N9zyvOA/GQzWcD40q
         5dFcHx9JmiP9Ztl10a9p3gIVGDai8nWLrL9DPHbcc83m//49mmYGTMjk8VANgdrsEv10
         i3fJFmzfxQuNyCQnJlBCxuQOByhs7PliZeRqXyMk5/e2mOsE/o2T6wI0GLM7n8dasvug
         dV37WOhUxkNf/vha2C72zRKJTfxp8r0wS3lNqEntTjA8DlrTS7Q9fDiKwKoY9Ezl6c0u
         xdvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=G9vBM5THlG8pywNzVbsKIK8sbELnMUDNM7aCaLdslP0=;
        b=V54UhuT/9JHUUq8Ofuxg18wxz9okVT2B+tPaOXWUyDgQwNlQcKgFwldVyvoOyd/fEw
         9WUPXOiaj7E3QG4ykC/Jx4CzSnQGFiM9wYHKVfXAUXECzA9eSgJfQZRYqmkSI/ChvPqR
         T+Y7iO8q/VZg1b/b6nKlW3m7CRDFKBf/aWKuMji73TcIc3uUhq33vn+rh1KkPeIKezET
         phRvilwJnUaRGgUipizso7XJwefeJVKjuB0S39HnofyoWYr1WDe6lIS4ivZSriXZnP+5
         2PdPvzfnm5xUoVtPww+XgEfPI/2VaTCBd/6H3NHoGQqqOD7xp3VckAg2h+C9KfJeWdfe
         Iz8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="bgq/F8b/";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j15si7216618otq.62.2019.05.28.08.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 08:04:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="bgq/F8b/";
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4SF4QUp083027;
	Tue, 28 May 2019 15:04:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=G9vBM5THlG8pywNzVbsKIK8sbELnMUDNM7aCaLdslP0=;
 b=bgq/F8b/2xwUVXMlsJqTT/j8YvUXLiDeS1H4MJ+nX4NOQ5xuZxuO5UeAXzVEoTG1w3bf
 iu6Ce7E+Lhxw9casXB7xzxnF/LglbRQEC8Hux6StMYE/xjblB+T7bJ8nOxdBonl07JjK
 i4LWZr8dbuD44I3nkitg/rpMislB3CGkymXU4mlpDIqIm+8/2CgEmV0kh75+vCfvC2L4
 Z8Adu0/Y0OQ8FReXSRrA1zB1u+Z7W4E2Dt6b4GdDgXE31SyMNMgBPdc0LZpdUzdIuZHh
 ka4eUEOZ3WXQdsjyQL6SgjVs8mBV0FmA9pPrU0yOOD7DKhfxFyHFYXk1s/ronu4hv6Mr 7g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2spw4tbtqn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 15:04:39 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4SF3Kh9017458;
	Tue, 28 May 2019 15:04:39 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3030.oracle.com with ESMTP id 2ss1fmwp16-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 28 May 2019 15:04:38 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4SF4OV0025272;
	Tue, 28 May 2019 15:04:24 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 28 May 2019 08:04:24 -0700
Date: Tue, 28 May 2019 11:04:24 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>,
        Alexey Kardashevskiy <aik@ozlabs.ru>, Alan Tull <atull@kernel.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Jason Gunthorpe <jgg@mellanox.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>,
        Steve Sistare <steven.sistare@oracle.com>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: add account_locked_vm utility function
Message-ID: <20190528150424.tjbaiptpjhzg7y75@ca-dmjordan1.us.oracle.com>
References: <de375582-2c35-8e8a-4737-c816052a8e58@ozlabs.ru>
 <20190524175045.26897-1-daniel.m.jordan@oracle.com>
 <20190525145118.bfda2d75a14db05a001e49ad@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190525145118.bfda2d75a14db05a001e49ad@linux-foundation.org>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9270 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=18 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905280098
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9270 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=18 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905280098
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 25, 2019 at 02:51:18PM -0700, Andrew Morton wrote:
> On Fri, 24 May 2019 13:50:45 -0400 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
> 
> > locked_vm accounting is done roughly the same way in five places, so
> > unify them in a helper.  Standardize the debug prints, which vary
> > slightly, but include the helper's caller to disambiguate between
> > callsites.
> > 
> > Error codes stay the same, so user-visible behavior does too.  The one
> > exception is that the -EPERM case in tce_account_locked_vm is removed
> > because Alexey has never seen it triggered.
> > 
> > ...
> >
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1564,6 +1564,25 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
> >  int get_user_pages_fast(unsigned long start, int nr_pages,
> >  			unsigned int gup_flags, struct page **pages);
> >  
> > +int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
> > +			struct task_struct *task, bool bypass_rlim);
> > +
> > +static inline int account_locked_vm(struct mm_struct *mm, unsigned long pages,
> > +				    bool inc)
> > +{
> > +	int ret;
> > +
> > +	if (pages == 0 || !mm)
> > +		return 0;
> > +
> > +	down_write(&mm->mmap_sem);
> > +	ret = __account_locked_vm(mm, pages, inc, current,
> > +				  capable(CAP_IPC_LOCK));
> > +	up_write(&mm->mmap_sem);
> > +
> > +	return ret;
> > +}
> 
> That's quite a mouthful for an inlined function.  How about uninlining
> the whole thing and fiddling drivers/vfio/vfio_iommu_type1.c to suit. 
> I wonder why it does down_write_killable and whether it really needs
> to...

Sure, I can uninline it.  vfio changelogs don't show a particular reason for
_killable[1].  Maybe Alex has something to add.  Otherwise I'll respin without
it since the simplification seems worth removing _killable.

[1] 0cfef2b7410b ("vfio/type1: Remove locked page accounting workqueue")

