Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E509C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:02:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C243D217FA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:02:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="i1Hy/GRW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C243D217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 302FF6B000A; Fri, 19 Apr 2019 03:02:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B1006B000C; Fri, 19 Apr 2019 03:02:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1541B6B000D; Fri, 19 Apr 2019 03:02:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC06D6B000A
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 03:02:34 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v9so2891610pgg.8
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 00:02:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=L7eq8Aug6+D0Uzgmn7vgZITr6hThHMPewFsEW47cNZg=;
        b=TCZW2xDqmhPtpdeN1b3WJ1Gk72asKp2bFKyv75WHnU2b4wPAe2ZLfLIBxGb0jNz0iL
         zTtljIHQCtyjFehdP7oVSR0zSbgaK7VVzRhSBOaQIbzHlxWaXWAp8DqHI+QiHoicRM7a
         zrZdkq491KVv/1ZJJP723NuCq08xXCLyc/uSBuNeixh6NmANWWl8fBwh4bPLPI4FUOUT
         ze/kzvTr4Q0Ue/oGYifhpRqexfYQm4QQXItjtZuslNzaEZI1mEGt3G0dhtWC8A57BOde
         GN7NzhYbLATWh69oAZkDdc+OYEODAHg26/o9ePov7KFkpOZW4XQQxUPbaKZFtaVnhauW
         CtoQ==
X-Gm-Message-State: APjAAAWuKD6z9pRYX4ocmiryM3JU+zuA/z6xvfjJhGPQhwg7O0xfoDhH
	LKr7wwEjtAaSCvXFa1GxKBd5suANbGXQVJsm7vv2mNDx/j76JoNDYdsPqykWoeM5L62EyLg7sNU
	fkRpjrUSjwb3YxJExrzM5UOInpYNU6qUXeD/V2vxr9Pjps3IB5Gw/6TPeK8/ujtIxrQ==
X-Received: by 2002:a17:902:2862:: with SMTP id e89mr2157536plb.203.1555657354067;
        Fri, 19 Apr 2019 00:02:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyiVXapdRzVJFNGkIsUKd6WWIjKtvT1+LW43A4YkPVL6EGhUSWPmeHrZQHfIWCBdLKOF5Af
X-Received: by 2002:a17:902:2862:: with SMTP id e89mr2157469plb.203.1555657353182;
        Fri, 19 Apr 2019 00:02:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555657353; cv=none;
        d=google.com; s=arc-20160816;
        b=T+oXMlCcQJBGen85FlEkpJ8ys0KX2zP9qp4nF5/KPzwuQ8yrkjETtFmigV4zWJCq/T
         2ptGABHZi9T6LC1HQTPCUKSPGShTW895viQja3fU8KJszDJL2yeHLoAu+Qv4XqA0C3vc
         jhZK8fVkHGBUl1COwFjLHObqndjOpB2JGOoDCu81eim2D62ND6oMefRUfBuWqcN0uJYO
         k7UGsqwuY6oMTZlmX8MB3qsmtlY9odU2aAlOSTZha8Er4hUyi8AbR6d7ubg8jJKSovQ6
         HISySvIpjYFRGvaUsIVZaamGOrU9At7ibllP5us8HF0uDp4n3EvLTi6PDriQCopKPoNc
         iGJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=L7eq8Aug6+D0Uzgmn7vgZITr6hThHMPewFsEW47cNZg=;
        b=A25dZ6x1dNwIzEris7TIM5OfQsH7YeEf278b8OH6EVqyY9Sn46v7P+k7MzWwUwvmGS
         o/5Eh9lm9v4RZ1KEBOvIC82/ogbjClxtzaXswyBsD6HWgoOUA2ykiWTbMZapQ+ZfiKAy
         TyIxG4NKa4/2BtCEjZn7dAJSUYjon8gm3kffd+kp5Am4eKfyb+rQtrUy6sVYRtOcw4Tr
         /yZoYMCEd3qpX+RUk0ebn+p/ObDsR4P+dZWzawqPkXmCfTk4ZpFrVnAt42jood5qULr8
         Dmd/TucIVVuPuiiqa7Jnk1NjJqc8MQtk5W/lHogFCofvXZKUNzSLt1JEuwNoibvPorKx
         qGhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="i1Hy/GRW";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id r63si4789241pfc.183.2019.04.19.00.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 00:02:33 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="i1Hy/GRW";
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=L7eq8Aug6+D0Uzgmn7vgZITr6hThHMPewFsEW47cNZg=; b=i1Hy/GRW9HiWiapoFoRTCdgu1
	cUt7Er7sr71bgd43+dYv+n0Lv5GqnvJ+fSpYP2kjtQcZK4KSH9eqZMuPMywNyKvmhH64/AJZF28Kd
	AlhoxD9/xO4V7UsOg/7MAE2EeVnrnoWM0Pi7ybOHHUHP44EMSsIwE6Jwu+NXpJ/AgQnIsAxNgPdAJ
	Ota/ejkQQY1W48qZZdy3Q4RNzTzjM7hk86diK53SIfg/s2qF6MI2J0OScfSmfawFdDLDzngU6/tDG
	13MF/x52A68J+MK67YWX2NX2H2bIpQcWWr4GQXNqFjTBedeNIaoV6M4g88Nvr+yKVzWJBaI25hvyv
	9aVlwsorw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hHNXI-00007w-SC; Fri, 19 Apr 2019 07:02:13 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 5B5DB29B52F42; Fri, 19 Apr 2019 09:02:11 +0200 (CEST)
Date: Fri, 19 Apr 2019 09:02:11 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>, linux-arch@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Daniel Vetter <daniel@ffwll.ch>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>
Subject: Re: [patch V2 28/29] stacktrace: Provide common infrastructure
Message-ID: <20190419070211.GL4038@hirez.programming.kicks-ass.net>
References: <20190418084119.056416939@linutronix.de>
 <20190418084255.652003111@linutronix.de>
 <20190418145201.mjzyqbmkjcghqzex@treble>
 <alpine.DEB.2.21.1904181734200.3174@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1904181734200.3174@nanos.tec.linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 05:42:55PM +0200, Thomas Gleixner wrote:
> On Thu, 18 Apr 2019, Josh Poimboeuf wrote:

> > Another idea I had (but never got a chance to work on) was to extend the
> > x86 unwind interface to all arches.  So instead of the callbacks, each
> > arch would implement something like this API:

> I surely thought about that, but after staring at all incarnations of
> arch/*/stacktrace.c I just gave up.
> 
> Aside of that quite some archs already have callback based unwinders
> because they use them for more than stacktracing and just have a single
> implementation of that loop.
> 
> I'm fine either way. We can start with x86 and then let archs convert over
> their stuff, but I wouldn't hold my breath that this will be completed in
> the forseeable future.

I suggested the same to Thomas early on, and I even spend the time to
convert some $random arch to the iterator interface, and while it is
indeed entirely feasible, it is _far_ more work.

The callback thing OTOH is flexible enough to do what we want to do now,
and allows converting most archs to it without too much pain (as Thomas
said, many archs are already in this form and only need minor API
adjustments), which gets us in a far better place than we are now.

And we can always go to iterators later on. But I think getting the
generic unwinder improved across all archs is a really important first
step here.

