Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 040B66B0259
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 18:13:30 -0500 (EST)
Received: by mail-wm0-f46.google.com with SMTP id u63so1926571wmu.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 15:13:29 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c15si14537996wjx.246.2015.12.09.15.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 15:13:29 -0800 (PST)
Date: Wed, 9 Dec 2015 15:13:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memcontrol: only manage socket pressure for
 CONFIG_INET
Message-Id: <20151209151326.f7efba4e5697e1b0f212ea34@linux-foundation.org>
In-Reply-To: <20151209230505.GA16610@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
	<2564892.qO1q7YJ6Nb@wuerfel>
	<7343206.sFybcLLUN2@wuerfel>
	<20151209185858.GA2342@cmpxchg.org>
	<20151209142836.e81260567879110f319c01a4@linux-foundation.org>
	<20151209230505.GA16610@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 9 Dec 2015 18:05:05 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Dec 09, 2015 at 02:28:36PM -0800, Andrew Morton wrote:
> > On Wed, 9 Dec 2015 13:58:58 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > The calls to tcp_init_cgroup() appear earlier in the series than "mm:
> > > memcontrol: hook up vmpressure to socket pressure". However, they get
> > > moved around a few times so fixing it earlier means respinning the
> > > series. Andrew, it's up to you whether we take the bisectability hit
> > > for !CONFIG_INET && CONFIG_MEMCG (how common is this?) or whether you
> > > want me to resend the series.
> > 
> > hm, drat, I was suspecting dependency issues here, but a test build
> > said it was OK.
> > 
> > Actually, I was expecting this patch series to depend on the linux-next
> > cgroup2 changes, but that doesn't appear to be the case.  *should* this
> > series be staged after the cgroup2 code?
> 
> Code-wise they are independent. My stuff is finishing up the new memcg
> control knobs, the cgroup2 stuff is changing how and when those knobs
> are exposed from within the cgroup core. I'm not relying on any recent
> changes in the cgroup core AFAICS, so the order shouldn't matter here.

OK, thanks.

> > Regarding this particular series: yes, I think we can live with a
> > bisection hole for !CONFIG_INET && CONFIG_MEMCG users.  But I'm not
> > sure why we're discussing bisection issues, because Arnd's build
> > failure occurs with everything applied?
> 
> Arnd's patches apply to the top of the stack, but they address issues
> introduced early in the series and the problematic code gets touched a
> lot in subsequent patches. E.g. the first build breakage is in ("net:
> tcp_memcontrol: simplify linkage between socket and page counter")
> when the tcp_init_cgroup() and tcp_destroy_cgroup() function calls get
> moved around and lose the CONFIG_INET protection.

Yeah, this is a pain.  I think I'll fold Arnd's fix into
mm-memcontrol-introduce-config_memcg_legacy_kmem.patch (which is staged
after all the other MM patches and after linux-next) and will pretend I
didn't know about the issue ;)

> Anyway, if we can live with the bisection caveat then Arnd's fixes on
> top of the kmem series look good to me. Depending on what Vladimir
> thinks we might want to replace the CONFIG_SLOB fix with something
> else later on, but that shouldn't be a problem, either.

I don't have a fix for the CONFIG_SLOB&&CONFIG_MEMCG issue yet.  I
agree that it would be best to make the combination work correctly
rather than banning it, but that does require a bit of runtime testing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
