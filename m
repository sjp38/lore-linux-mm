Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6357C4151A
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 03:35:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A41821905
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 03:35:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A41821905
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15F368E0002; Tue, 12 Feb 2019 22:35:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E5F58E0001; Tue, 12 Feb 2019 22:35:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC9918E0002; Tue, 12 Feb 2019 22:35:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC8988E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 22:35:01 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id m34so963049qtb.14
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:35:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=zQNBbhIUaECzB0XvTX/4hgo8e7ZuVxQZ1n67UeWESwo=;
        b=hb7rwF+uUpAdOZmiochK6Q/53b06UsclB3hSeAw8nw7DgyHAAHu4tQaO4DWFXTrv1k
         fmKCYN5HRVKiBBdFTm0vCVGp6W5hjMw0HGSLCpxIbNOVgFPCz6QnW/lq5EPQpxrCYVGb
         xhv35LEUJi08fQLms5EKygfrhqGGzDo6ElwU/at+YTKq293nGIMlmbP6PUAQaUZ9pfuU
         vAhnGQUkkda8Y2qxNjh9F9zZkBslTgJ+owJBLetPrpJfXpApPt1Q2n4BY/VZgy3X7mg/
         EgP7wOLaR2Ak1TFCA9s7Ca+XB7WebMwWyUclo/TtORry9ydy5HCcn3GLoqGKCkFP5EFf
         Pu6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZfcZm8V+xlBHxArF3uifUV1IFNZblQJ5R9P9AKGF1hlyuWOSZD
	IDW3KxMERV5ZL5wGMEcHcLefpJJxQPU8Dc850JxffQPO3jyoox6WkatQDBZ/MGEmaAxibXuc5Om
	M9vqsws0LEpb7p/Hy5SXkMXDfDRi1k1NoOQpFY9b1LK68sBX2bwGYMxsH4gcoILXiMQ==
X-Received: by 2002:a0c:e1c9:: with SMTP id v9mr5391496qvl.186.1550028901457;
        Tue, 12 Feb 2019 19:35:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbhYt8zGjM0R0dsoiSt3kayTRyMpfx/dnr13NPF1lgPqHjd/UmdiYP1qhlUkAVqJ+nh0ex4
X-Received: by 2002:a0c:e1c9:: with SMTP id v9mr5391479qvl.186.1550028901027;
        Tue, 12 Feb 2019 19:35:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550028901; cv=none;
        d=google.com; s=arc-20160816;
        b=HOtuCChOJvF7o5aKtpO4iPV5PaRnVC9ISgzFZbu/HOXNUl32je13AeiAllMG/KXuVD
         +iriHhDF9ewYrTBfwpbSzRXRrU72lRslcGbyRiKYG7mQ4jjELvx2NmclmnAlDO1+LI+1
         8HwJeKRhADMNcsOKP/6V/LWFPOjNeUzEcojkYu/VOTKsX7aZcxaceqczy2IWE3PFIHdu
         A7o4D14N7wvMINkvT6hHTOgvDzK2HRgPJqODgD9qarvVFGArkWa06D6HLhYtnfIwR6tE
         C3R9NG6H4hSJy/aBtKsbtFpQPRqnVUCbs+pTvz5Oo6S0q+0zEip4q/8VUiJP+OXFcejl
         MPTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=zQNBbhIUaECzB0XvTX/4hgo8e7ZuVxQZ1n67UeWESwo=;
        b=nEUhS7M7EiQxLPaXvC4iF6gJsC3QFchGeL0VADfSfVMf/lbvzSMM5eHFS/NNlVyWlb
         5nyeGF8OrDSUfag4uLkgSNUg9qym6hEIbzGgLDTbTdePP0Tole8b16KakzCKRF32V/i7
         AbFMUoeb8m4mW4lUoEJ3zjmnaRwqmYNrA1LPclIBNmC5U1Iw46fJHGGNkYVMfQArE8Jx
         2cY6bG2IcsuAB5Wkl3Tbk4vaaw+hd/7IW7FfF9WCRGxi3hy9PkxsvpysSZO1O5PAuuyU
         CWRmCSv51ZnTsXfkSMBR3cMBJHBF2V0oJQJFnWZk2HqllAZSh1W1qMJzxfc4RhkXP/6+
         OR+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t18si5145537qvm.58.2019.02.12.19.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 19:35:01 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 05BDC8535C;
	Wed, 13 Feb 2019 03:34:59 +0000 (UTC)
Received: from xz-x1 (ovpn-12-100.pek2.redhat.com [10.72.12.100])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 547F45D962;
	Wed, 13 Feb 2019 03:34:48 +0000 (UTC)
Date: Wed, 13 Feb 2019 11:34:44 +0800
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
Message-ID: <20190213033444.GD11247@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-5-peterx@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190212025632.28946-5-peterx@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 13 Feb 2019 03:35:00 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:56:10AM +0800, Peter Xu wrote:

[...]

> @@ -1351,7 +1351,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
>  int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
>  			 unsigned int flags)
>  {
> -	if (flags & FAULT_FLAG_ALLOW_RETRY) {
> +	if (!flags & FAULT_FLAG_TRIED) {

Sorry, this should be:

        if (!(flags & FAULT_FLAG_TRIED))

It escaped from tests, but I spotted it when I compile the tree on
another host.

-- 
Peter Xu

