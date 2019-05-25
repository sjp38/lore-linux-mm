Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E542C04AB0
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 08:45:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A739A2133D
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 08:45:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A739A2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D0176B0003; Sat, 25 May 2019 04:45:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0811D6B0005; Sat, 25 May 2019 04:45:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB2676B0007; Sat, 25 May 2019 04:45:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A10A26B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 04:45:54 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id b20so389544wmj.3
        for <linux-mm@kvack.org>; Sat, 25 May 2019 01:45:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RHlHDOqknjqNX23HPSqwaTpe2sMolI3Xi14OVUzSoOw=;
        b=pUyVyFPdRpUSqY11BKItZUSbonlzQ76ndYea1YvmPTCEtn++z5ZqKAoKcTf0cvlXL4
         g/1CNa0MNQXE1BlEnwIWCHscz+NV05vJdXa8YEke167mDImm3Izw0QybbRvEVuSM5sF7
         OhlPdJj8gHUpM3TkvnjQfQfgpqXqX6OI75MqDN0w+1kQu3C9mevUZQUKSw2aMNdbb0jK
         C8upuPouapWVAi52WpqpD4D3R4oOco8B4kITjcGv20AoYdKQte4n0AC4aHkfwNDoXjv3
         d1+3zvNe7AkTrzHZJQIHUBS8vjRkgU9S4dsG1eB2lj0Eby/U4CxynvcKQOx9IsnysjCY
         ZkWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
X-Gm-Message-State: APjAAAWWEjHJQQfYkCv9sW0KNNtpdLtiOpGHcRrJXmUtlMxF6E20bxKR
	TmED9C2Ts/W3/q+MmklWuq8MJSwI2cVRDLOuBV28pjdI9YXXYZp2mEZHvhQ1QjcV9QVOhX5M9dc
	9UQVMvi6hlPpxUGWvprq4jo6L5diq45sGTYuo3gGT1/XlmiSFkYRzZNkXTw5CDBQBDA==
X-Received: by 2002:a1c:6a07:: with SMTP id f7mr398443wmc.109.1558773954120;
        Sat, 25 May 2019 01:45:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfYk33yjNlhxVPJCISMoi/cVJncHAwWZppVqUshIlUxYAiRWcscOcDqRBmwdls6BsaBn4D
X-Received: by 2002:a1c:6a07:: with SMTP id f7mr398404wmc.109.1558773953117;
        Sat, 25 May 2019 01:45:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558773953; cv=none;
        d=google.com; s=arc-20160816;
        b=BtqcwwnozHbAjfKALVtR3H29V9ssmgZqFNZqed9/Vc31vtUsBcXg6FtdQ0XiZnKMN+
         ZK9lx4qptNOcKNs1znbB2tpdi4VhhVVbCMG3VCuJwMRrZk3m6oYLfqFIHfS15UfChm82
         fPnFzcayv+XkVgYZ0GDfjvfPJrtL3I8IOqfR3jJD45BoXf5mGdZE86cMDI5u/y5HAlhb
         hK8saIA9SZLXDhaecJHSZZU9xmacMVycCW+LfOHG6z3mkTYwxFBlYyJLXD94BC/H3huj
         9JeBrXaPQqvS3WtoDlvuejkcG6QAXU5ntXfW8HCOS/401RSOC56cv9IdEjsfQgaqKnwI
         C4AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RHlHDOqknjqNX23HPSqwaTpe2sMolI3Xi14OVUzSoOw=;
        b=nlPPquP3VT0AXbpSaLCholSYzhaWkK4r7u37ilWodL+hpJjJaOfODnCcmBq3KE4oda
         BsV/9/+76TrBifcdP0fakbqn3gpGY656W54B/4IDyXY01CsjgzvGJmUO5VO2zRL7LPoh
         FOJyAKbtvyVMuFugawnznG6k7En9404xmC45nQkH6GlOtkj4OQ6WGL3R57LS18wFRwsS
         Mob5pCXsERRqm7Z5xgShOrm3CuPN1wSbp1ss5zrJOhlcHvvaIvsBhUJmkEqMHIkOrY6H
         /hh1uHpzOYPkixo/ncG+ix0PoS3b+mQ6ijtbM5z6t+FlGlB66IWuu9m9vhqXUX1C5aTa
         okVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c14si4145117wrn.309.2019.05.25.01.45.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 25 May 2019 01:45:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of bigeasy@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=bigeasy@linutronix.de
Received: from bigeasy by Galois.linutronix.de with local (Exim 4.80)
	(envelope-from <bigeasy@linutronix.de>)
	id 1hUSJH-0001zt-6b; Sat, 25 May 2019 10:45:47 +0200
Date: Sat, 25 May 2019 10:45:46 +0200
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>,
	Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] mm/gup: continue VM_FAULT_RETRY processing event for
 pre-faults
Message-ID: <20190525084546.fap2wkefepeia22f@linutronix.de>
References: <1557844195-18882-1-git-send-email-rppt@linux.ibm.com>
 <20190522122113.a2edc8aba32f0fad189bae21@linux-foundation.org>
 <20190522194322.5k52docwgp5zkdcj@linutronix.de>
 <alpine.LSU.2.11.1905241429460.1141@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1905241429460.1141@eggly.anvils>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-05-24 15:22:51 [-0700], Hugh Dickins wrote:
> I've now run a couple of hours of load successfully with Mike's patch
> to GUP, no problem; but whatever the merits of that patch in general,
> I agree with Andrew that fault_in_pages_writeable() seems altogether
> more appropriate for copy_fpstate_to_sigframe(), and have now run a
> couple of hours of load successfully with this instead (rewrite to taste):

so this patch instead of Mike's GUP patch fixes the issue you observed?
Is this just a taste question or limitation of the function in general?

I'm asking because it has been suggested and is used in MPX code (in the
signal path but .mmap) and I'm not aware of any limitation. But as I
wrote earlier to akpm, if the MM folks suggest to use this instead I am
happy to switch.

> --- 5.2-rc1/arch/x86/kernel/fpu/signal.c
> +++ linux/arch/x86/kernel/fpu/signal.c
> @@ -3,6 +3,7 @@
>   * FPU signal frame handling routines.
>   */
>  
> +#include <linux/pagemap.h>
>  #include <linux/compat.h>
>  #include <linux/cpu.h>
>  
> @@ -189,15 +190,7 @@ retry:
>  	fpregs_unlock();
>  
>  	if (ret) {
> -		int aligned_size;
> -		int nr_pages;
> -
> -		aligned_size = offset_in_page(buf_fx) + fpu_user_xstate_size;
> -		nr_pages = DIV_ROUND_UP(aligned_size, PAGE_SIZE);
> -
> -		ret = get_user_pages_unlocked((unsigned long)buf_fx, nr_pages,
> -					      NULL, FOLL_WRITE);
> -		if (ret == nr_pages)
> +		if (!fault_in_pages_writeable(buf_fx, fpu_user_xstate_size))
>  			goto retry;
>  		return -EFAULT;
>  	}
> 
> (I did wonder whether there needs to be an access_ok() check on buf_fx;
> but if so, then I think it would already have been needed before the
> earlier copy_fpregs_to_sigframe(); but I didn't get deep enough into
> that to be sure, nor into whether access_ok() check on buf covers buf_fx.)

There is an access_ok() at the begin of copy_fpregs_to_sigframe(). The
memory is allocated from user's stack and there is (later) an
access_ok() for the whole region (which can be more than the memory used
by the FPU code).

> Hugh

Sebastian

