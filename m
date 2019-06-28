Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0DB9C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 14:22:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 681C62086D
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 14:22:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="aOPp1i7+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 681C62086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCA406B0005; Fri, 28 Jun 2019 10:22:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7C3D8E0003; Fri, 28 Jun 2019 10:22:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B69E18E0002; Fri, 28 Jun 2019 10:22:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9621E6B0005
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 10:22:58 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e39so6191137qte.8
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 07:22:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=WVmn8V88QNGADn+4BzJOKwnY0rFHsOXAlq7BOgZNCGc=;
        b=hfHlJLkIAk4VacNhpR1xVGLvmoiJeIztirYVsCg48xSpY38DTIyX0VAyRLNa7yPHs/
         +AHB+HAHIgI3NsszA4p5ST4MJCf7oJ7X0iiEscnT9QbdiPCy4S+HFu83iM9f9/AsM0d7
         L9+YVddhvQ7PiaSQkEsOvb3Nat6pq4sIfU7UxkAZeGfmZgTPlrekky3SNZD+xLC/HmEg
         CuGpRvaBxKRCQcX1GZvZEDk3FjHm993njqE+vcjQ4+7cn8AY6f35OWjB7hH/98Yc5keb
         RRlYMJctA5nFcNOPZVZPIvDbqd3FqcZt4U+Lc5vBlFuCFw1ZrYOVyw+kStdcb/R8tCuH
         Jkrw==
X-Gm-Message-State: APjAAAWzAvCVJhe06Ev9a2QW8+tdWuEV43PWouj8FEuQJdux0Co+ftgj
	VJPDWT9vtNdlzXgHXC8DH2TeaWqeLO5tmr39Fn2DyAdWFNZQruiyXj6UVT0LUPqHWduwPSIMvSA
	THp/XhE7Cs6EArxlFcWTin0vMPU+XhnEQyB6Fm3j7ve/gEs4fjCusqD4vR1BNBjx54A==
X-Received: by 2002:ae9:ed8f:: with SMTP id c137mr9082046qkg.471.1561731778294;
        Fri, 28 Jun 2019 07:22:58 -0700 (PDT)
X-Received: by 2002:ae9:ed8f:: with SMTP id c137mr9081970qkg.471.1561731777334;
        Fri, 28 Jun 2019 07:22:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561731777; cv=none;
        d=google.com; s=arc-20160816;
        b=uRqpE77FNPWkyrLRMLzJuyEFSzEGkIxVCR4UW7f4HXYTFLIEpGaJRmHoKVUglln9sm
         +oY98nyzMjUR/buw1AYE3qs5bn7y5ctWAycQm5Mfdt1I9fXe8/ivHyA2Nrj3jekaSdbj
         A3vZXAEPYmqWQJzgYQ3nDQr7t7x236fI/23qe1i8qCyAJfRdGbrAqDh0Lwk03tqMU4tk
         u/la/zRYk0ZWSZbIb6D/ymC+63h46u/njgtEB5Duv6FQ9PxYHj0G+FncCoY6XvsnExg8
         oxCY/tZHCecL4YLXY/kbY7fMdwtyZ1UK9QkXgwjbIF2oE8C8ihwQ8pXMRhRFc886r6FL
         GDfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=WVmn8V88QNGADn+4BzJOKwnY0rFHsOXAlq7BOgZNCGc=;
        b=prQQRbTXwsUhbG3g9OQ87voiF0h9HIwYrpIoQHGmAATOGgLHsCANn2r1L9OF3LxhzU
         1lDmR4bKvvG1dDYcGsbMGY2h3cPtremahM0ayexFahNHjy4Ivp8jAe7h08aZStUsJg4W
         vtC7ZULlRDuOjns1rqN8sC/6xTmu2ziYBaKNKzo4ZodmVFaPq8efwhTQ/lNr5xOgVdeP
         U+jcjnqDwjePQJDtjwzlbDZM4hJS9LZjsDF+FQlZKRTyVZBC1C5pC13K6BTLyG30QBG0
         KZMAuHXUKfBCyFyWHfMJcfIkX58aeK9OXQBOpWzHX057m513h/EUXH2Wsj4sIv9/k1mT
         GYUA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=aOPp1i7+;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d50sor3519155qtc.5.2019.06.28.07.22.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 07:22:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=aOPp1i7+;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=WVmn8V88QNGADn+4BzJOKwnY0rFHsOXAlq7BOgZNCGc=;
        b=aOPp1i7+egoyuX5dPs0fEwpuD7ncaPsKMaTb1fJp8cn029yB84Cj38CXVf1K4HPO4m
         krk0DXWdBm48vEnib3lJ9PqOpql7Ei1s0A/1v8zu9VR0yqF2cFObMA+mxywr/6B3Rm2O
         tdSuJRsaGxJqDExu234qVW3Y/4KtiQ7+a+wY3I2ERadQD79lz8xKYQhi6xQ2Qsi5rNOJ
         qSQT3jk9apBhR+XgkF94YcowU2zU1m4lrnwKy4HXqzHIyEQo69uoV6QhrWXESQhqlaqZ
         EQlOfVcrLWqq5Q83LbfyVq7+xFnyE8uJBirXQHeY7ZfeByGsXRD9k0uf4i1lhCmNojoZ
         XkOA==
X-Google-Smtp-Source: APXvYqwlKuuePWTEY5Qzqm6s281P+8lxu1QGtHORWcJsC2Yq1uv3z28Uf6CKqeoG1nDZmsyvrE+hiA==
X-Received: by 2002:ac8:2ae8:: with SMTP id c37mr8359022qta.267.1561731774569;
        Fri, 28 Jun 2019 07:22:54 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id x205sm1049020qka.56.2019.06.28.07.22.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 28 Jun 2019 07:22:53 -0700 (PDT)
Date: Fri, 28 Jun 2019 10:22:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Kuo-Hsin Yang <vovoy@chromium.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>, Sonny Rao <sonnyrao@chromium.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] mm: vmscan: fix not scanning anonymous pages when
 detecting file refaults
Message-ID: <20190628142252.GA17212@cmpxchg.org>
References: <20190619080835.GA68312@google.com>
 <20190627184123.GA11181@cmpxchg.org>
 <20190628065138.GA251482@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190628065138.GA251482@google.com>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Minchan,

On Fri, Jun 28, 2019 at 03:51:38PM +0900, Minchan Kim wrote:
> On Thu, Jun 27, 2019 at 02:41:23PM -0400, Johannes Weiner wrote:
> > On Wed, Jun 19, 2019 at 04:08:35PM +0800, Kuo-Hsin Yang wrote:
> > > Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> > > Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
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

Look at the patch again. The parameter was only added to retain
existing behavior. We *always* did file-only reclaim while thrashing -
all the way back to the two commits I mentioned below.

> So, Fixes: 2a2e48854d70 ("mm: vmscan: fix IO/refault regression in cache workingset transition")
> would make sense to me since it introduces the parameter.

What is the observable behavior problem that this patch introduced?

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

Hm? The problematic behavior is that we force-scan file while file is
thrashing. We can obviously only solve this in kernels that can
actually detect thrashing.

