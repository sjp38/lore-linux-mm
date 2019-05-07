Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F21E9C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:38:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B515205C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 16:38:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=brauner.io header.i=@brauner.io header.b="TZqcIJFT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B515205C9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=brauner.io
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 330BA6B0005; Tue,  7 May 2019 12:38:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E2876B0007; Tue,  7 May 2019 12:38:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 182AC6B0008; Tue,  7 May 2019 12:38:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BDE246B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 12:38:46 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n23so14922293edv.9
        for <linux-mm@kvack.org>; Tue, 07 May 2019 09:38:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=L5mTg3IJOrwjhS+4cPOuegpeW4KFCpGlZhmjVpA3VdM=;
        b=sCwu/f3oud8phg/jXiFXttPawZ+wbOplTeFcVx5crS+3F+AHcDs3kWMgqTP71IAheJ
         N6jh9eTSYjS7jGkAvxgKAjwLi+Cjuj+o2WF3CxZ6voTDrQuOeZPgSwxEzvHr2FLvTCbR
         uPK0KS7+QJMrln9dXig987kPNObSlNezqCJ5XSscffklHr2wGragyLv1SlOI41dMeV5O
         xAFEUKikI+UxHEjQ6+KzkqvkEvvIXGfhpEanP56AlluWgRiqkU5Li+MrRxpwzKncMn2L
         c3xNHlXQsK/Hx9T62tovTkYrOwCKpZZDVlzKaXhUd/rL9wQBmHVx/oG36q3Z0lg/thJp
         /gwg==
X-Gm-Message-State: APjAAAVcngpS0g+8mCOLJVhZ9wGqP5mny1MDOZhzRsNWOKrX3ZeSCpB1
	1ub2+XCrlR/nczDjXJYCe1+XwWWuxRLk/yFgdluG6uK7ocvtxqfMftwa2/vfkmgRPZVPhG/ZGqN
	35zCvzJA7mZyi1cU67hN/NxQVhG8rhvEtt28SqB8BqNaYi1tvojAGpNl3cO1Vp6r5ow==
X-Received: by 2002:a17:906:1984:: with SMTP id g4mr1663250ejd.260.1557247126126;
        Tue, 07 May 2019 09:38:46 -0700 (PDT)
X-Received: by 2002:a17:906:1984:: with SMTP id g4mr1663183ejd.260.1557247125158;
        Tue, 07 May 2019 09:38:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557247125; cv=none;
        d=google.com; s=arc-20160816;
        b=qbuTlcN//VEXp11g+iO1gKNaZRWk8JvpqOntO2YAF4LSbN0MgkBQNjiQw722uuONPu
         hhX5hM0wPtKEMAeISlhkMYDI1iaEDd7o9q3HCgzYix7JbmMhq4bwyxDTIfOIor/9m5oW
         J1mgYZW2M5dilj8bGYHKbylt8OvwYMSW1RdcGFs8vSh+w6GQqpUuoaP+YEpMb0GOKATU
         AWim9tVQQnT6AkcrthTGxN/NSYQrthIu3odXDtjwq2S/q8fKZyuSXhZFR8+UykITd3PJ
         3P4wmPviRuQZ1RjKFEhEP6fTn8Ad49PsR3LwNA+jdjjU7Ze5e3waveAuvNn+5XrxOYgg
         4JPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=L5mTg3IJOrwjhS+4cPOuegpeW4KFCpGlZhmjVpA3VdM=;
        b=jiqdQASGPiayeJpmcr5aBGXcdMNuhMRyYdSYasG/nJO34saI0+ICHIVwILDIkFtaC3
         h0GiHhB7NWgxzpKe63+Zw9U1sIdGLcZBos83b8DhI2zeIbFo2hHOin6GpdRwu3whTJPu
         9pp8sWydXp1HThUcqdwb1BSQihwedaUitFJ44WZLb46Hbtn18EKuAcZ5YzI+7K6FVrfg
         nGldo1Xl7dqIzQtocGGTH4JGB0Gs7SKDD95ER8a/pb/2wLnXou0Fy6P1wYu/YFF6nZsZ
         XwXlCpVk+hRuhrX945R0YIfbPCutpITy+hJbn38yAdiRAo4VQxgIOOjG4IMye3UzeGvf
         v3MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=TZqcIJFT;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m27sor2781026eje.63.2019.05.07.09.38.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 09:38:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@brauner.io header.s=google header.b=TZqcIJFT;
       spf=pass (google.com: domain of christian@brauner.io designates 209.85.220.65 as permitted sender) smtp.mailfrom=christian@brauner.io
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=brauner.io; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=L5mTg3IJOrwjhS+4cPOuegpeW4KFCpGlZhmjVpA3VdM=;
        b=TZqcIJFTbUSo9Ua8ldXyHOWmYelZuh+ci+tG/uK+Auxsogv2R0GzFbnxM2ohTHrxkk
         BLJit9pSJmlGzSX7jOKNlYqSax5frQHIo5rZrO7H/spEV59QpPRFaHIdhGNOdsHChlKL
         PPGgWoaQB2X8a18GyvrnwTqKS77YLA0aTxpL4YziGX+jOGOwDy/oVxm7OSBhSv8lFf3M
         81UM8L+ulbjik4XbCKiDwnkOUH16HJMKcjJ1HBS51KbV35uZw18+6R5tdQayAKcKAq5b
         kvVslTyy4hgs6RdBUSCb7yoc5aGfnIvnd5/JP4YILmOZM8Qg/ef3RgJunaMicjznP1u+
         iuNg==
X-Google-Smtp-Source: APXvYqxqGfVOQLd9+OfqbkWi7vAXao7KwEDvX5FZFmc78pnVY4Z06OGLMC4o81qzLxEoDm36/lbipw==
X-Received: by 2002:a17:906:7c0b:: with SMTP id t11mr4919748ejo.100.1557247124621;
        Tue, 07 May 2019 09:38:44 -0700 (PDT)
Received: from brauner.io ([212.91.227.56])
        by smtp.gmail.com with ESMTPSA id n21sm260895eju.63.2019.05.07.09.38.43
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 07 May 2019 09:38:44 -0700 (PDT)
Date: Tue, 7 May 2019 18:38:42 +0200
From: Christian Brauner <christian@brauner.io>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Sultan Alsawaf <sultan@kerneltoast.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"open list:ANDROID DRIVERS" <devel@driverdev.osuosl.org>,
	Daniel Colascione <dancol@google.com>,
	Todd Kjos <tkjos@android.com>, Kees Cook <keescook@chromium.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Martijn Coenen <maco@android.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Tim Murray <timmurray@google.com>, Michal Hocko <mhocko@kernel.org>,
	linux-mm <linux-mm@kvack.org>,
	Arve =?utf-8?B?SGrDuG5uZXbDpWc=?= <arve@android.com>,
	Ingo Molnar <mingo@redhat.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Andy Lutomirski <luto@amacapital.net>,
	kernel-team <kernel-team@android.com>
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190507163841.45v4ym63ug2ni7pb@brauner.io>
References: <CAKOZuessqcjrZ4rfGLgrnOhrLnsVYiVJzOj4Aa=o3ZuZ013d0g@mail.gmail.com>
 <20190319231020.tdcttojlbmx57gke@brauner.io>
 <20190320015249.GC129907@google.com>
 <20190507021622.GA27300@sultan-box.localdomain>
 <20190507070430.GA24150@kroah.com>
 <20190507072721.GA4364@sultan-box.localdomain>
 <20190507074334.GB26478@kroah.com>
 <20190507081236.GA1531@sultan-box.localdomain>
 <20190507105826.oi6vah6x5brt257h@brauner.io>
 <CAJuCfpFeOVzDUq5O_cVgVGjonWDWjVVR192On6eB5gf==_uPKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAJuCfpFeOVzDUq5O_cVgVGjonWDWjVVR192On6eB5gf==_uPKw@mail.gmail.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 09:28:47AM -0700, Suren Baghdasaryan wrote:
> From: Christian Brauner <christian@brauner.io>
> Date: Tue, May 7, 2019 at 3:58 AM
> To: Sultan Alsawaf
> Cc: Greg Kroah-Hartman, open list:ANDROID DRIVERS, Daniel Colascione,
> Todd Kjos, Kees Cook, Peter Zijlstra, Martijn Coenen, LKML, Tim
> Murray, Michal Hocko, Suren Baghdasaryan, linux-mm, Arve Hjønnevåg,
> Ingo Molnar, Steven Rostedt, Oleg Nesterov, Joel Fernandes, Andy
> Lutomirski, kernel-team
> 
> > On Tue, May 07, 2019 at 01:12:36AM -0700, Sultan Alsawaf wrote:
> > > On Tue, May 07, 2019 at 09:43:34AM +0200, Greg Kroah-Hartman wrote:
> > > > Given that any "new" android device that gets shipped "soon" should be
> > > > using 4.9.y or newer, is this a real issue?
> > >
> > > It's certainly a real issue for those who can't buy brand new Android devices
> > > without software bugs every six months :)
> > >
> 
> Hi Sultan,
> Looks like you are posting this patch for devices that do not use
> userspace LMKD solution due to them using older kernels or due to
> their vendors sticking to in-kernel solution. If so, I see couple
> logistical issues with this patch. I don't see it being adopted in
> upstream kernel 5.x since it re-implements a deprecated mechanism even
> though vendors still use it. Vendors on the other hand, will not adopt
> it until you show evidence that it works way better than what
> lowmemorykilled driver does now. You would have to provide measurable
> data and explain your tests before they would consider spending time
> on this.
> On the implementation side I'm not convinced at all that this would
> work better on all devices and in all circumstances. We had cases when
> a new mechanism would show very good results until one usecase
> completely broke it. Bulk killing of processes that you are doing in
> your patch was a very good example of such a decision which later on
> we had to rethink. That's why baking these policies into kernel is
> very problematic. Another problem I see with the implementation that
> it ties process killing with the reclaim scan depth. It's very similar
> to how vmpressure works and vmpressure in my experience is very
> unpredictable.
> 
> > > > And if it is, I'm sure that asking for those patches to be backported to
> > > > 4.4.y would be just fine, have you asked?
> > > >
> > > > Note that I know of Android Go devices, running 3.18.y kernels, do NOT
> > > > use the in-kernel memory killer, but instead use the userspace solution
> > > > today.  So trying to get another in-kernel memory killer solution added
> > > > anywhere seems quite odd.
> > >
> > > It's even more odd that although a userspace solution is touted as the proper
> > > way to go on LKML, almost no Android OEMs are using it, and even in that commit
> >
> > That's probably because without proper kernel changes this is rather
> > tricky to use safely (see below).
> >
> > > I linked in the previous message, Google made a rather large set of
> > > modifications to the supposedly-defunct lowmemorykiller.c not one month ago.
> > > What's going on?
> 
> If you look into that commit, it adds ability to report kill stats. If
> that was a change in how that driver works it would be rejected.
> 
> > >
> > > Qualcomm still uses lowmemorykiller.c [1] on the Snapdragon 845. If PSI were
> > > backported to 4.4, or even 3.18, would it really be used? I don't really
> > > understand the aversion to an in-kernel memory killer on LKML despite the rest
> > > of the industry's attraction to it. Perhaps there's some inherently great cost
> > > in using the userspace solution that I'm unaware of?
> 
> Vendors are cautious about adopting userspace solution and it is a
> process to address all concerns but we are getting there.
> 
> > > Regardless, even if PSI were backported, a full-fledged LMKD using it has yet to
> > > be made, so it wouldn't be of much use now.
> >
> > This is work that is ongoing and requires kernel changes to make it
> > feasible. One of the things that I have been working on for quite a
> > while is the whole file descriptor for processes thing that is important
> > for LMKD (Even though I never thought about this use-case when I started
> > pitching this.). Joel and Daniel have joined in and are working on
> > making LMKD possible.
> > What I find odd is that every couple of weeks different solutions to the
> > low memory problem are pitched. There is simple_lkml, there is LMKD, and
> > there was a patchset that wanted to speed up memory reclaim at process
> > kill-time by adding a new flag to the new pidfd_send_signal() syscall.
> > That all seems - though related - rather uncoordinated.
> 
> I'm not sure why pidfd_wait and expedited reclaim is seen as
> uncoordinated effort. All of them are done to improve userspace LMKD.

If so that wasn't very obvious and there was some disagreement there as
well whether this would be the right solution.
In any case, the point is that LMKD seems to be the way forward and with
all of the arguments brought forward here this patchset seems like it's
going in the wrong direction.

Christian

> 
> > Now granted,
> > coordinated is usually not how kernel development necessarily works but
> > it would probably be good to have some sort of direction and from what I
> > have seen LMKD seems to be the most coordinated effort. But that might
> > just be my impression.
> >
> > Christian
> 
> Thanks,
> Suren.

