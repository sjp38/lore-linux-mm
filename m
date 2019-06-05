Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6970FC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:27:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35C2F2086A
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 13:27:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35C2F2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B433D6B000D; Wed,  5 Jun 2019 09:27:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF3896B000E; Wed,  5 Jun 2019 09:27:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E23B6B0010; Wed,  5 Jun 2019 09:27:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 527E16B000D
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 09:27:32 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id w4so9680507wrv.11
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 06:27:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8UF6IKh1oi+AJKntkp2Avzsj99+2nJ602b//xWwwYMo=;
        b=BYLg+RREw+0Mw+fygKhI/xawE04EPwrQRKElYf9jxiKWg88WtftytFuoD5GzuEAYNm
         J6cc9RE2u9jwhsLfsaAuXSLsZCiHjL17LyyvVXAKVxW3kyH2T5jbgl9tfNni8RyhUBwb
         GtQKByG7HxtjEFj/6I93xZeRX4h4i7HPOPn29fkhajz5ZFDMNXjN4t4EPEvHzWVoJyUu
         sqMel0ARuDdK6eRiVNyyQEF5iIkojzv5SDyPWWwLdZR8ue2IBe0QtQZynwW+rZw3R79h
         +w3OMSR42O38j+xhPtZ5nns4GamT/JEVpVMr61FvgraKzR+kO2KD1WUJ/7XX2fBvxX1o
         iRtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXkUKBTtET+vGPx2dLSbSXcwAWxG0EV0iPrMiX/N+65SJ/JZX2N
	sNWXiwF8t86h1kdrkVYdqtf/55xbIKOzfaKsvrmlhmpt0ijpSQIVSMTN73QKP1LOWoRyFNirUQ3
	Bmhz1MTMvWHEASEIwU6DwDSZlhHxTFyaZbGeZib79yWifGGpyRNldtiPI3u20b/alKw==
X-Received: by 2002:adf:8385:: with SMTP id 5mr11038283wre.194.1559741251864;
        Wed, 05 Jun 2019 06:27:31 -0700 (PDT)
X-Received: by 2002:adf:8385:: with SMTP id 5mr11038221wre.194.1559741250788;
        Wed, 05 Jun 2019 06:27:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559741250; cv=none;
        d=google.com; s=arc-20160816;
        b=ENEg3e1+1qnzUx7lxoU+PaN6NlGAZpTgBTsUOchV4apuYQLT0ed6ivFjoDLG6P2ZUZ
         3RNp8vxPxPWmuVqXy5/VP+SmilZx82uOWSPaTaYREX7AaRFI7rMv1XKsmqy5N1fbzhd0
         I1yoFJJ4dnbir9fyiftpRUjE9jckLDzqjmLnezRBmtuX/MarxyzJiqQR915Y/j8WK9Gg
         Pr497KhqtBjggGI84V+1fJUnGHXe/M4tNoys/elFpxeSB4eFotFaLLb4hUELHAQwMCGs
         IdFiDFMXCKcLWQaVX+0W//y30kfeBCtjvvF2JfxMOZ8RlHn82UDde6HejZP5rve3Og9U
         xkUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8UF6IKh1oi+AJKntkp2Avzsj99+2nJ602b//xWwwYMo=;
        b=qiJwSfJiQq6sCmBX1nC9LZfazHLo3o2Yg9/RG9e2VoKDrzzg9GWujla5+r5eP+7Xlp
         Tpl1knIQJLNBA9YVQ8A3BXMqIib5UXlB6Cu0/lOPFmslyuf6JCJvP8GT+bxL07FGw74P
         BtgHZ5r3SDxOAnZBdDyy5aAeF9/046sMVnlEy0W4Eln3sXIzKFEaz76ZpBsVu2N/Eral
         sELE6vWxT74OLscR0o2MOjzBqWNRkYHz3jemRe/fHkHBebRaEhHUP55yGXb3xW4Zcm5o
         eKHqf2srQBrrcXFINiH2MovVqbPUOP+UElRKjfEX6CCcS6RQrLwQq7C3Ao4mLBiq6KOu
         2w7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p19sor3623630wre.45.2019.06.05.06.27.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Jun 2019 06:27:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzO7CgrYTcvyVtelP3nLeZ+Ekw3IsfgEuQ6as9WNjO7Znl9iRR9QfVOYT+MaOhBlZ3QYIBaSg==
X-Received: by 2002:adf:e4d2:: with SMTP id v18mr10605225wrm.189.1559741250343;
        Wed, 05 Jun 2019 06:27:30 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id u205sm24193031wmu.47.2019.06.05.06.27.29
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 05 Jun 2019 06:27:29 -0700 (PDT)
Date: Wed, 5 Jun 2019 15:27:28 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, jannh@google.com,
	oleg@redhat.com, christian@brauner.io, hdanton@sina.com
Subject: Re: [RFCv2 4/6] mm: factor out madvise's core functionality
Message-ID: <20190605132728.mihzzw7galqjf5uz@butterfly.localdomain>
References: <20190531064313.193437-1-minchan@kernel.org>
 <20190531064313.193437-5-minchan@kernel.org>
 <20190531070420.m7sxybbzzayig44o@butterfly.localdomain>
 <20190531131226.GA195463@google.com>
 <20190531143545.jwmgzaigd4rbw2wy@butterfly.localdomain>
 <20190531232959.GC248371@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531232959.GC248371@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Sat, Jun 01, 2019 at 08:29:59AM +0900, Minchan Kim wrote:
> > > > > /* snip a lot */
> > > > >
> > > > >  #ifdef CONFIG_MEMORY_FAILURE
> > > > >  	if (behavior == MADV_HWPOISON || behavior == MADV_SOFT_OFFLINE)
> > > > > -		return madvise_inject_error(behavior, start, start + len_in);
> > > > > +		return madvise_inject_error(behavior,
> > > > > +					start, start + len_in);
> > > > 
> > > > Not sure what this change is about except changing the line length.
> > > > Note, madvise_inject_error() still operates on "current" through
> > > > get_user_pages_fast() and gup_pgd_range(), but that was not changed
> > > > here. I Know you've filtered out this hint later, so technically this
> > > > is not an issue, but, maybe, this needs some attention too since we've
> > > > already spotted it?
> > > 
> > > It is leftover I had done. I actually modified it to handle remote
> > > task but changed my mind not to fix it because process_madvise
> > > will not support it at this moment. I'm not sure it's a good idea
> > > to change it for *might-be-done-in-future* at this moment even though
> > > we have spotted.
> > 
> > I'd expect to have at least some comments in code on why other hints
> > are disabled, so if we already know some shortcomings, this information
> > would not be lost.
> 
> Okay, I will add some comment but do not want to fix code piece until
> someone want to expose the poisoning to external process.

Fair enough.

> > > > >  	write = madvise_need_mmap_write(behavior);
> > > > >  	if (write) {
> > > > > -		if (down_write_killable(&current->mm->mmap_sem))
> > > > > +		if (down_write_killable(&mm->mmap_sem))
> > > > >  			return -EINTR;
> > > > 
> > > > Do you still need that trick with mmget_still_valid() here?
> > > > Something like:
> > > 
> > > Since MADV_COLD|PAGEOUT doesn't change address space layout or
> > > vma->vm_flags, technically, we don't need it if I understand
> > > correctly. Right?
> > 
> > I'd expect so, yes. But.
> > 
> > Since we want this interface to be universal and to be able to cover
> > various needs, and since my initial intention with working in this
> > direction involved KSM, I'd ask you to enable KSM hints too, and once
> > (and if) that happens, the work there is done under write lock, and
> > you'll need this trick to be applied.
> > 
> > Of course, I can do that myself later in a subsequent patch series once
> > (and, again, if) your series is merged, but, maybe, we can cover this
> > already especially given the fact that KSM hinting is a relatively easy
> > task in this pile. I did some preliminary tests with it, and so far no
> > dragons have started to roar.
> 
> Then, do you mind sending a patch based upon this series to expose
> MADV_MERGEABLE to process_madvise? It will have the right description
> why you want to have such feature which I couldn't provide since I don't
> have enough material to write the motivation. And the patch also could
> include the logic to prevent coredump race, which is more proper since
> finally we need to hold mmap_sem write-side lock, finally.
> I will pick it up and will rebase since then.

Sure, I can. Would you really like to have it being based on this exact
revision, or I should wait till you deal with MADV_COLD & Co and re-iterate
this part again?

Thanks.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

