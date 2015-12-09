Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 784AD6B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 17:28:39 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id c201so6671244wme.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 14:28:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b20si14291314wjr.226.2015.12.09.14.28.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 14:28:38 -0800 (PST)
Date: Wed, 9 Dec 2015 14:28:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: memcontrol: only manage socket pressure for
 CONFIG_INET
Message-Id: <20151209142836.e81260567879110f319c01a4@linux-foundation.org>
In-Reply-To: <20151209185858.GA2342@cmpxchg.org>
References: <1449588624-9220-1-git-send-email-hannes@cmpxchg.org>
	<2564892.qO1q7YJ6Nb@wuerfel>
	<7343206.sFybcLLUN2@wuerfel>
	<20151209185858.GA2342@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, netdev@vger.kernel.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 9 Dec 2015 13:58:58 -0500 Johannes Weiner <hannes@cmpxchg.org> wrote:

> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 6faea81e66d7..73cd572167bb 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -4220,13 +4220,13 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
> >  	if (ret)
> >  		return ret;
> >  
> > +#ifdef CONFIG_INET
> >  #ifdef CONFIG_MEMCG_LEGACY_KMEM
> >  	ret = tcp_init_cgroup(memcg);
> >  	if (ret)
> >  		return ret;
> >  #endif
> 
> The calls to tcp_init_cgroup() appear earlier in the series than "mm:
> memcontrol: hook up vmpressure to socket pressure". However, they get
> moved around a few times so fixing it earlier means respinning the
> series. Andrew, it's up to you whether we take the bisectability hit
> for !CONFIG_INET && CONFIG_MEMCG (how common is this?) or whether you
> want me to resend the series.

hm, drat, I was suspecting dependency issues here, but a test build
said it was OK.

Actually, I was expecting this patch series to depend on the linux-next
cgroup2 changes, but that doesn't appear to be the case.  *should* this
series be staged after the cgroup2 code?

Regarding this particular series: yes, I think we can live with a
bisection hole for !CONFIG_INET && CONFIG_MEMCG users.  But I'm not
sure why we're discussing bisection issues, because Arnd's build
failure occurs with everything applied?

> Sorry about the trouble. I don't have a git tree on kernel.org because
> we don't really use git in -mm, but the downside is that we don't get
> the benefits of the automatic build testing for all kinds of configs.
> I'll try to set up a git tree to expose series to full build coverage
> before they hit -mm and -next.

This sort of thing happens quite rarely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
