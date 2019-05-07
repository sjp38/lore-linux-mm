Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C28E3C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 11:09:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78A1E2087F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 11:09:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="sOR88QRt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78A1E2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 056D06B0005; Tue,  7 May 2019 07:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F22146B0006; Tue,  7 May 2019 07:09:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9C496B0007; Tue,  7 May 2019 07:09:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B74C6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 07:09:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id t1so10043704pfa.10
        for <linux-mm@kvack.org>; Tue, 07 May 2019 04:09:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=IBDzNJDE3KICGo7Chy4TW8Yhyq/GbcnFBxKSltwgcR0=;
        b=k0XjtOWwOs9MlDBHuq/Qeg980rbBLU9Zr09arWO42H+5OH5yZBcAQStpGlW1DhWBJB
         QuWfNYhsLWZL5sP/teOGxqqBnMcfpjDxQ4cV/J0q1Es/bfDYajR7vH5wVWcLX9P2Dcut
         U/bNuvfVrrOacKjRrxuQG76inQb0MJjKDbW3aghlUyJLZce8eVqptUlnMUIAnRh34dtl
         /pidjgWBmDk0QfN3ia38f+wB49SVfEOgc/H3wsdRCKIU0DzVLR2/NqQDm8jZLa4wcKVD
         iMlLEsej35S1vMoL5pgtQphLf2W4NE6ARzdpVQn9hUtUOmtwhAQtWAzt0b2nO5cVlSXh
         S8uQ==
X-Gm-Message-State: APjAAAXXVldmtzDm/PKl5oDyDwMTf0rNCCPFgxkXc3/azQQtxjX4tASD
	v6BN9LuAqVWgSej5wcLLK9FpL3icPpgHEEsz2cDhaFcgv74wz4RcZzVQbQHRnXSQF5s1NgLBQ4S
	CPC5bigs9vFYTJUzgjhwtkRK/j/VLFwpulKHgdaF7xei/aL8o8DIPOyPJchurp5jP5w==
X-Received: by 2002:a63:2ace:: with SMTP id q197mr38297851pgq.371.1557227364677;
        Tue, 07 May 2019 04:09:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyaV1bwbNaK+gfSG7JGNfkXLZHWXLowMbYyWkVHjVHirwXv2RjxHEivpKfwWw665GKRA5Cf
X-Received: by 2002:a63:2ace:: with SMTP id q197mr38297770pgq.371.1557227363769;
        Tue, 07 May 2019 04:09:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557227363; cv=none;
        d=google.com; s=arc-20160816;
        b=NFgmRrM/XSvJdJ2aHO2Dyn4RBPXBZ5fPpmVnS0+8+8cNaMU1XcJOqOz1ROH1BbH35g
         7I+zp4grH+IseI2fnEreXq9NlUwPiRdhZVIfrhrFao+kVl7FRU5u7r+UXC3nkCbjKrd+
         z/snbP1pP+zE9o5+5unrCXgVk7MB0mRhZ65exjmyFK2hNYUzfHSxd6quu7eyjbnbGwoD
         Wfya38Aj7CRTufQDJ753WEcSTSFNf9axuZF/ud+a4K4kjoGveZO+HkF/MvCeLi7ndzFb
         vNEM+HN4SUDBDTY5y09fyq//wTNYebg+r7/of1qWGoae3Ja2qNvLCUs3KBhSYkUcsaP2
         +rjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=IBDzNJDE3KICGo7Chy4TW8Yhyq/GbcnFBxKSltwgcR0=;
        b=hqQAf+3Z4lQrWTjcXh14r9y+UynTAsvmHfOxhHZ+jjFQ9KFOdtQC0B2tC4X6g3ZkyN
         JOn/HoDrVvsNCBq+214l1Tf1e6AdiOrIolXTskLOenF9h6wa7R2hnAMlEXXvoPDSnVyk
         OywVaHxSy8MndTZ5OdD3XIXMFiNVmcZfaY+77CWRxmol9vatzRUGHk6WLItIgY+/Q6jt
         wXNR0Tgu3LRRYjPDEZkaCNttas40gfvaLrOCfdH4nnnnEHFrnVHlhZQChhhFTgqrLrLR
         Fokkt+yygxR/3L4JJBKAJuGOi3uPREq4h1a4/QjtOxAecNPuLL+ZFpeTSjyqTC6IvFl2
         3YXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sOR88QRt;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d15si5297591plj.91.2019.05.07.04.09.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 04:09:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=sOR88QRt;
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B0C2420825;
	Tue,  7 May 2019 11:09:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557227363;
	bh=lH6zDECW23fQQmezy1wEZakHblsm5N0Cv80tHjWVNCc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=sOR88QRttf7cjAkI3eaLJvcyuSDmHQ1qjgDydZzWSVyPd9M9JC19/WtjAWBZWLubr
	 f+UE6Pt1H11AOiDsTKtWprMz1kZ3IkqTZNIcPGlWUmF6tRAMSgJ9qZUBzgkZWyiER3
	 Rk2qbQJj3O1NasgjA5/lculWTtaWpGs1D1JA91xo=
Date: Tue, 7 May 2019 13:09:21 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: "open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	Daniel Colascione <dancol@google.com>,
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Martijn Coenen <maco@android.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	Suren Baghdasaryan <surenb@google.com>,
	linux-mm <linux-mm@kvack.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Andy Lutomirski <luto@amacapital.net>,
	kernel-team <kernel-team@android.com>,
	Christian Brauner <christian@brauner.io>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507110921.GA32210@kroah.com>
References: <20190318235052.GA65315@google.com>
 <20190319221415.baov7x6zoz7hvsno@brauner.io>
 <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain>
 <20190507074334.GB26478@kroah.com>
 <20190507081236.GA1531@sultan-box.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507081236.GA1531@sultan-box.localdomain>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 01:12:36AM -0700, Sultan Alsawaf wrote:
> On Tue, May 07, 2019 at 09:43:34AM +0200, Greg Kroah-Hartman wrote:
> > Given that any "new" android device that gets shipped "soon" should be
> > using 4.9.y or newer, is this a real issue?
> 
> It's certainly a real issue for those who can't buy brand new Android devices
> without software bugs every six months :)

Heh.

But, your "new code" isn't going to be going into any existing device,
or any device that will come out this year.  The soonest it would be
would be next year, and by then, 4.9.y is fine.

> > And if it is, I'm sure that asking for those patches to be backported to
> > 4.4.y would be just fine, have you asked?
> >
> > Note that I know of Android Go devices, running 3.18.y kernels, do NOT
> > use the in-kernel memory killer, but instead use the userspace solution
> > today.  So trying to get another in-kernel memory killer solution added
> > anywhere seems quite odd.
> 
> It's even more odd that although a userspace solution is touted as the proper
> way to go on LKML, almost no Android OEMs are using it, and even in that commit
> I linked in the previous message, Google made a rather large set of
> modifications to the supposedly-defunct lowmemorykiller.c not one month ago.
> What's going on?

"almost no"?  Again, Android Go is doing that, right?

And yes, there is still some 4.4 android-common work happening in this
area, see this patch that just got merged:
	https://android-review.googlesource.com/c/kernel/common/+/953354

So, for 4.4.y based devices, that should be enough, right?

> Qualcomm still uses lowmemorykiller.c [1] on the Snapdragon 845.

Qualcomm should never be used as an example of a company that has any
idea of what to do in their kernel :)

> If PSI were backported to 4.4, or even 3.18, would it really be used?

Why wouldn't it, if it worked properly?

> I don't really understand the aversion to an in-kernel memory killer
> on LKML despite the rest of the industry's attraction to it. Perhaps
> there's some inherently great cost in using the userspace solution
> that I'm unaware of?

Please see the work that went into PSI and the patches around it.
There's also a lwn.net article last week about the further work ongoing
in this area.  With all of that, you should see how in-kernel memory
killers are NOT the way to go.

> Regardless, even if PSI were backported, a full-fledged LMKD using it has yet to
> be made, so it wouldn't be of much use now.

"LMKD"?  Again, PSI is in the 4.9.y android-common tree, so the
userspace side should be in AOSP, right?

thanks,

greg k-h

