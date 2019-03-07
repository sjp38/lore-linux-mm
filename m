Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C223C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 05:46:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3B1E20851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 05:46:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JnpI9P7J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3B1E20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24E748E0003; Thu,  7 Mar 2019 00:46:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FF798E0002; Thu,  7 Mar 2019 00:46:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0EF498E0003; Thu,  7 Mar 2019 00:46:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id C17AB8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 00:46:08 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id o38so15021838pgb.6
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 21:46:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=hVbymYoSRu2oLMeB8gDg+j1RGrwnXBAbOJznDFzNjik=;
        b=K2fkZ//Zsz3sBMoIwBgqdaJObIm8iXBsY3L8JbVJB4pU3y38jXM7UZgxh4kb9+UsfS
         HVUfKPF0/g9yHbnUcn1dXrmZEW9LIaChuKMmwVxjL1Xfe0u0hGjT/9ax6WeBqJcIxGtu
         LQxHRZ85rgB80wprZYOS/CwKGfIOaSBJ/SF7ki4cQz/ueZsT63x4GKxSpJK7Ysrxcgk/
         qdsSol0AibsGxlzY8vAqyALcpQjLDaPV+qG5pubs3nhqVVqRv5r9xd/o7bDAykl/kM0H
         t7nIZkQC2YPUdo7bWoTAZkqkHfTk+JTYK3RVy2ZAOjzHjABt4SyACcigDm18HHdnhz8s
         25ug==
X-Gm-Message-State: APjAAAX9zJZc25x50L7+1xA5MLIxd5QazTJpLCz5egSC49Xy3qgNxZwT
	nDWXQQLz4MRAnLpjxYLkIF22WlU4huIiDzxKZFPbcQ1JmTA/pYGyHFJf3AjcwO1rgtWWSl4sD7P
	uKO+oeWEkC5+7L/zYR9fkrcsNu0xafLbkL2ZZksMgPKE5pLG8o+CUswPj/F9NxkRnhA==
X-Received: by 2002:a17:902:622:: with SMTP id 31mr11147229plg.31.1551937568198;
        Wed, 06 Mar 2019 21:46:08 -0800 (PST)
X-Google-Smtp-Source: APXvYqxvM5I/LID3yr2SW0tcqLApPDIjCEDGPlfm+wYIGCs76MU/v3dipZ1AmLf6qL0eHgOjq4TO
X-Received: by 2002:a17:902:622:: with SMTP id 31mr11147167plg.31.1551937567238;
        Wed, 06 Mar 2019 21:46:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551937567; cv=none;
        d=google.com; s=arc-20160816;
        b=mwVT97bhd/0Ci6tj5tMQ45MZjk9ZGTAX1WlvbelsYGplzzg4g778Z/puPtgLb7bxmE
         k0qFIZkRpgtqD+k/LYr/KtMr1MOyLHX785CR6V2H7IWsqG9GPHP1AD6EzEXdo2xGGJnf
         lNbt8H20fKzoNJqKVWOtSCSN3gkqlrGNOqgq6i7n7vRm8yOIqyy7kCw0ifX4quMkRWMf
         vZef/s+mNzsl9A6eGDgQQMccCK22Blh1p2xcA1FE6fyIvu1yusT7Lc1DDmfuLUUpGj+R
         5UISqhMJa/r/tyVIbDkT7i2ETlHH1BKxml0ZM0pvhNltVAZWjev74bQHVfM+Rci1wxLr
         7Row==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=hVbymYoSRu2oLMeB8gDg+j1RGrwnXBAbOJznDFzNjik=;
        b=CQe7BuwnlUWocVwDrHxSl5Wkqk6Wn1LebDLaNxksLe7cCIAmbsUT3/O+KQMtEv6EpS
         UnN3jnez6LY5Gchis2Lkj8m3/kQ7eGU6eZBAa7Ozwg2BORC6Z+RElzyw0wz0RFr4Yhzr
         viCX/8HJdacBiYhUDpFfi6dIcCM6ASCXHi1eiJTbNUKmhEEsGpb+ZiJcvphpRyGlnqEV
         e8YTi6F/FpAZf99WnqZSCZf4qW2xttY3KLwGicP7NHgY09OlE+cegd648XPoNNX/V5Yt
         Baz84ii3zgn5avq8NIEfFQbe0P3RkpFk90kIZ+teT18xQBRdugtiXq/YDEXzxU51ZVGH
         tCWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JnpI9P7J;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d10si3515082pla.42.2019.03.06.21.46.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 21:46:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JnpI9P7J;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 47BE920835;
	Thu,  7 Mar 2019 05:46:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551937566;
	bh=woS8eJdF9WhN4ajNoBXAip9dtR/2dJRhAAKFISudxNA=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=JnpI9P7JZvwsGbKHOcx2/JGhPR4vyJd/ZcnCjfwjYyMtNLhlCRy9CwMVhuNuQC9jZ
	 k+M7DQS2Z6GhDz7L7A7ychx/sNNQ7Uj8dW/doLFzVkZazEc8s7GKodp1OXF6z717H+
	 lA8f3sfTnF8sP3Dj2+wfATWll6jNd1aOxje5dJiQ=
Date: Thu, 7 Mar 2019 06:46:00 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Dominique Martinet <asmadeus@codewreck.org>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Vlastimil Babka <vbabka@suse.cz>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>
Subject: Re: [PATCH 1/3] mm/mincore: make mincore() more conservative
In-Reply-To: <20190307004036.GA16785@nautica>
Message-ID: <nycvar.YFH.7.76.1903070643560.19912@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-2-vbabka@suse.cz> <20190306151351.f8ae1acae51ccad1a3537284@linux-foundation.org> <nycvar.YFH.7.76.1903070047360.19912@cbobk.fhfr.pm>
 <20190307004036.GA16785@nautica>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Mar 2019, Dominique Martinet wrote:

> > > 
> > > 	addr = 4095
> > > 	vma->vm_end = 4096
> > > 	pages = 1000
> > > 
> > > then `end' is 4096 and `(end - addr) << PAGE_SHIFT' is zero, but it
> > > should have been 1.
> > 
> > Good catch! It should rather be something like
> > 
> > 	unsigned long pages = (end >> PAGE_SHIFT) - (addr >> PAGE_SHIFT);
> 
> That would be 0 for addr = 0 and vma->vm_end = 1; I assume we would
> still want to count that as one page.

Yeah, that was bogus as well, ETOOTIRED yesterday, sorry for the noise. 
Both the variants are off.

> I'm not too familiar with this area of the code, but I think there's a
> handy macro we can use for this, perhaps
>   DIV_ROUND_UP(end - addr, PAGE_SIZE) ?
> 
> kernel/kexec_core.c has defined PAGE_COUNT() which seems more
> appropriate but I do not see a global equivalent
> #define PAGE_COUNT(x) (((x) + PAGE_SIZE - 1) >> PAGE_SHIFT)

I'll fix that up when doing the other changes requested by Andrew.

Thanks,

-- 
Jiri Kosina
SUSE Labs

