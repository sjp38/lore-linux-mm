Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FSL_HELO_FAKE,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B4A7C5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 08:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0F5E2083B
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 08:45:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="NJhiRaFT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0F5E2083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 871DE8E0002; Fri, 28 Jun 2019 04:45:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 821FE6B0006; Fri, 28 Jun 2019 04:45:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 739328E0002; Fri, 28 Jun 2019 04:45:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC426B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 04:45:01 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 30so2840230pgk.16
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 01:45:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=9cCBNQ/DLgtpUPdtAQUtvcyuKyE7Z8O611WKPmcesJs=;
        b=nWUG6szSaco6CZF3XJUJjIg38TukajBsztzTfA+Bt3eiJS51DbQd26T8cF+N/uukgB
         qhMtNT6NqYILzmMdxWNq7BQzbIsUUlZA1hrvEUfwa6P8sgIFCE/e87oT/Q4AgND7aKlJ
         mcgx+PIM/eCJVmZYLQ2S1XOeVyZypzVh9lrGjLgWH0WbH8PaDZaowiw8QUtFmpLPDTks
         umjENBgpnK46x0+5pQdMXaS8Hw6BrXKFcO7O4A/e2Ji+G/2bQFimXWob6y65WTrjTNEn
         ikfzWfG2hHRz/n/GcjyY5kPSku6PigTeUUWHbd7j2iGu1zwMDTNAoagEczGkx5s142mI
         lAnA==
X-Gm-Message-State: APjAAAW7O9dmGx2Bamk1nq5PlH5MHh2MkzgrTLitksUM/N0lG4pTcDIb
	v1GkghhaEXlRHWaYq3+zcRounsWLPSiQb6eNrIxuS62qeWzrp5mtbdOVKPfsiUqZeeZBF+PJztW
	EhxCp/10y7x9C+cdRNhgBNTyWRDvM6XaElIR+OjztyH7T6xFGoW/w0H/K8j8XSjVyJw==
X-Received: by 2002:a17:902:a414:: with SMTP id p20mr9619780plq.187.1561711500808;
        Fri, 28 Jun 2019 01:45:00 -0700 (PDT)
X-Received: by 2002:a17:902:a414:: with SMTP id p20mr9619723plq.187.1561711500037;
        Fri, 28 Jun 2019 01:45:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561711500; cv=none;
        d=google.com; s=arc-20160816;
        b=Lp68DEggu+cbaFvy87ZhMHTkuCV51kG4XtI42QDDMJfBdVFnJq8tRwnGQNwxF52HZ8
         +TpG0jAmru0GDrrnt8oCIqqare3Y2w92FfKhtVXcSy4y9/sgsUW+J2p1+WCNBzA1epBN
         lyzmsUTSVVtHNAvvw+Q7WaH84Sj4CXrLGt08+VBAjTk64Vw/C9G3aNoP7LzmcE8nR4QE
         sDQIP6X3UkkVgEpFjWsGZlSH2EpW+ZJL18Gq90IELRjqQk/u+w0UTSmdcqvoddVeNbCK
         bi961gG6uoWuMKbyNYSDL85vHta2sB9RLPjOmB23CvxQLoDFtq7kPIJw02g/uKKnhsAp
         f3sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=9cCBNQ/DLgtpUPdtAQUtvcyuKyE7Z8O611WKPmcesJs=;
        b=hxvalf49fLac0qMbOv6tuV5XDieX8KeLoZmV7Gevmlrdgu0SODqE+XQbjjUhXtrgf/
         IlJAsXKsSQWOYm2Cy3tICd6rPIAxZL6dIqk/vV1kbL8+b4GGXmZqdjsPju1Tcug9ftaf
         VWu2nZFbU8kx7HxmAKo65qpwdpVspoZ1vZjzo/MaV3qEc7mO0JELDqff3ZhaorIMKNON
         lWKmt2bZzgmh6+WMUq0rLf3esUTN+cvthxt0sTxl4wnGWeiAHoT5/hQ6xMlsQB0GNHET
         r61LxIfvwAqYuSZSXX3xAeW1EzuP/rqtBQQAPBGx3G7d8OUAuTKdNlZNJb8RCg/8OMuH
         X0wg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=NJhiRaFT;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u13sor1614991pjx.25.2019.06.28.01.44.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 01:45:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=NJhiRaFT;
       spf=pass (google.com: domain of vovoy@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=vovoy@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=9cCBNQ/DLgtpUPdtAQUtvcyuKyE7Z8O611WKPmcesJs=;
        b=NJhiRaFTwbXgWwYMuOKzcTTAPu8tvSUXftkWjd2iiLgQl4WJT7WRsvULRO5tF8PluC
         Nn+xvF88SuY6E/ZeAT3axrY8RuBSq8aQZRGAiy3DZuNjp2jnGcFdj/vf3GXwc4KU26Zj
         mspXga43P9yxdB55hXqpNtLBeXU2cevRPgdoY=
X-Google-Smtp-Source: APXvYqzcWsGydcd1oia93mChuGAQogjZoToWpbbXL8r2Y5MYqx/PPB/llrSa3dFB1zoTvtb0iZ0Rew==
X-Received: by 2002:a17:90a:b104:: with SMTP id z4mr11674941pjq.102.1561711499289;
        Fri, 28 Jun 2019 01:44:59 -0700 (PDT)
Received: from google.com ([2401:fa00:1:b:d89e:cfa6:3c8:e61b])
        by smtp.gmail.com with ESMTPSA id s20sm670784pfe.169.2019.06.28.01.44.57
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 28 Jun 2019 01:44:58 -0700 (PDT)
Date: Fri, 28 Jun 2019 16:44:55 +0800
From: Vovo Yang <vovoy@chromium.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190628084455.GA59379@google.com>
References: <20190619080835.GA68312@google.com>
 <20190627184123.GA11181@cmpxchg.org>
 <20190628065138.GA251482@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628065138.GA251482@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 03:51:38PM +0900, Minchan Kim wrote:
> Hi Johannes,
> 
> On Thu, Jun 27, 2019 at 02:41:23PM -0400, Johannes Weiner wrote:
> > 
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > Your change makes sense - we should indeed not force cache trimming
> > only while the page cache is experiencing refaults.
> > 
> > I can't say I fully understand the changelog, though. The problem of
> 
> I guess the point of the patch is "actual_reclaim" paramter made divergency
> to balance file vs. anon LRU in get_scan_count. Thus, it ends up scanning
> file LRU active/inactive list at file thrashing state.
> 
> So, Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> would make sense to me since it introduces the parameter.
> 

Thanks for the review and explanation, I will update the changelog to
make it clear.

> > forcing cache trimming while there is enough page cache is older than
> > the commit you refer to. It could be argued that this commit is
> > incomplete - it could have added refault detection not just to
> > inactive:active file balancing, but also the file:anon balancing; but
> > it didn't *cause* this problem.
> > 
> > Shouldn't this be
> > 
> > Fixes: e9868505987a ("mm,vmscan: only evict file pages when we have plenty")
> > Fixes: 7c5bd705d8f9 ("mm: memcg: only evict file pages when we have plenty")
> 
> That would affect, too but it would be trouble to have stable backport
> since we don't have refault machinery in there.

