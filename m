Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EA52C10F01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 11:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06C5E20C01
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 11:49:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06C5E20C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 838A88E000B; Wed, 20 Feb 2019 06:49:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E8B08E0002; Wed, 20 Feb 2019 06:49:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AFE48E000B; Wed, 20 Feb 2019 06:49:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 46F238E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 06:49:03 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id b40so7279632qte.1
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 03:49:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=V0iuDU4IsqrFz64zAaeLKYipjVrIaC1qy0c6xmlJW8M=;
        b=SNeJMgmd2OxhpN4xRh1A+T7OMC97YbK305USpgXw5AY2oNpf9fBpqZSCuIa9LQ0zoD
         9ZMfM7XE6RP7Sh4OOzW848ueFwMY9q0dXn+4a9yBNwskxr03ZtdSr3mm2SxEfqLnXTpg
         1ueDbQw7uc80hI54NOSUd58GRq3EOtHxb1hQ6v2NRjUP8yJxED1+BPDsIMDRflKxJtIz
         M7fkx/yyJcwqOaf6lJjzqWObijYWgDPFFl/z4Pt9L2ZvE+LN59G6EHOfM4V0IxL6Vaob
         SMwHxICoxAOsh9L/JReBg1fOL1pQcNSZRITHxTTDTsTCSt/rkDWzvlcTcXHzI0agGtcK
         u78Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYnY8NQTmzOofoTr1KIaglUtgUMLp+7/IMZWB5NgP85qinNnNf1
	IIPDi4l19NjDI/wNNL+o5lWoZfh3dPtVrSgEVw6ns3nxqbXSZQpcTSqJXxhoLfh3fjmqbbfCwJ4
	qsjux7Rx5VcsfVjYPwwh5MNW4sBhPIxoDLkvUzBC4gjBjBcNGN/3SvBQjsbiVBc7G2g==
X-Received: by 2002:ae9:ebd5:: with SMTP id b204mr884943qkg.37.1550663343064;
        Wed, 20 Feb 2019 03:49:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6a405NwuNvj0wdXnkNmXqirCPkoGwovq0RLMbwNrWdumD0bmUkh7RuYEzVDvPcnrSagUj
X-Received: by 2002:ae9:ebd5:: with SMTP id b204mr884918qkg.37.1550663342412;
        Wed, 20 Feb 2019 03:49:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550663342; cv=none;
        d=google.com; s=arc-20160816;
        b=bkuOfpbq8tcJTCo55+Q6eLMFF6HXjjcRuQRJG7lnTrPM0YUNRNXYNGkVItIIu7qUJ+
         jpk3miM8kWkfBGQE75+FuU6Pwih/howg8fWEEOJbhrsUKtHCYJysu08/81UrViUy77eV
         Vxr9cdJqYH4m7d495cSiSy6M9TMjvw5Vd0bJL+bgXHctVswhuTUTozyq11I9LPqVJV1d
         Y34HleLpcpeRbjvwGjSmkm/a2rCMHB3vt+FCQJWLdvmzU0ENsHJuEKAQ6TNFyDOmlaHO
         wMN+x7NnM50U5gd3lMEnr4L3zHmWWEjIdSN/KuCpxbiroa9gJW/iHAnluYEelax26zUY
         XC5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=V0iuDU4IsqrFz64zAaeLKYipjVrIaC1qy0c6xmlJW8M=;
        b=KW1NYf2f2tz/zDi8syRDFan9hj0JR4ZieuFxfKRa7eIqFlKNP1V3UAczYpm/KAX7Dm
         0xlDwDBRCgfziowQ53/Nay8LglAy/GZ+jRMC1RJV1lqvu8xlTYhlr5HV0e7VJPatb2+9
         K3XqQ7keZ2BWoONEJVhIFVprlXfpdMFCnymdE24PVwnDFnfY9VEes8MHMd+aZQs5JSER
         9gvnYhteOGqDaKL2wgS7xILP/cVdeD8u4yweqmtLD3fud5yhBsco0Tp2ApiP7UQDMM57
         RKyPPwuJbfWKRHBq3qLx8ECfajJS5f7SkYtDFGn4c0t2Bmt/Ew4SeENUO6KnoihP+vHm
         dCQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p187si3134607qkd.58.2019.02.20.03.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 03:49:02 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2DC215945B;
	Wed, 20 Feb 2019 11:49:01 +0000 (UTC)
Received: from xz-x1 (ovpn-12-37.pek2.redhat.com [10.72.12.37])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5ACAB17B15;
	Wed, 20 Feb 2019 11:48:52 +0000 (UTC)
Date: Wed, 20 Feb 2019 19:48:49 +0800
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>, Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 04/26] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190220114849.GA4060@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-5-peterx@redhat.com>
 <20190213033444.GD11247@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190213033444.GD11247@xz-x1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 20 Feb 2019 11:49:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 11:34:44AM +0800, Peter Xu wrote:
> On Tue, Feb 12, 2019 at 10:56:10AM +0800, Peter Xu wrote:
> 
> [...]
> 
> > @@ -1351,7 +1351,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
> >  int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
> >  			 unsigned int flags)
> >  {
> > -	if (flags & FAULT_FLAG_ALLOW_RETRY) {
> > +	if (!flags & FAULT_FLAG_TRIED) {
> 
> Sorry, this should be:
> 
>         if (!(flags & FAULT_FLAG_TRIED))

Ok this is problematic too...  Because we for sure allow the page
fault flags to be both !ALLOW_RETRY and !TRIED (e.g., when doing GUP
and when __get_user_pages() is with locked==NULL and !FOLL_NOWAIT).
So current code will fall through the if condition and call
up_read(mmap_sem) even if above condition happened (while we shouldn't
because the GUP caller would assume the mmap_sem should be still
held).  So the correct check should be:

  if ((flags & FAULT_FLAG_ALLOW_RETRY) && !(flags & FAULT_FLAG_TRIED))

To make things easier, I'll just repost this single patch later.
Sorry for the noise.

Regards,

-- 
Peter Xu

