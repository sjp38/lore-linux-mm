Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A2FAC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 15:51:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4946222CE
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 15:51:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4946222CE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C0156B0003; Fri, 19 Apr 2019 11:51:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36ECF6B0006; Fri, 19 Apr 2019 11:51:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25CB16B0007; Fri, 19 Apr 2019 11:51:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04A566B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 11:51:00 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id p3so4541408qkj.18
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 08:50:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PSPU8KC13m0ibHlVgdRBUJT8IhE7UKk+UFO5xgfsf+s=;
        b=cI9qmwQWULGi2Yb4J6elvathoqwZPr76HuWbWxgVW59yH1w/Kr/pcuVlS4h/l3647t
         mwVQNq8CfqFtaLGr4t4SB+rrJuqdqU61HeDcRfGLPF0IRupAobiNNXqI714NEhxA55B/
         47fKEtma9qUcAjvuIJdt0fM1Fo6Ar1jt8wq7CCksNguw2JA81e/UL5bUx8EcLVQa5nXf
         oiBSbGhPW+zgq1dOT12kI5VtBjOnE9yLtSNjpQUPuGxBeY7UUBDJg3ToEZZ4V2hDh/cF
         NbN50ROMyPqojF4Jrqaj9aFIzc4u/Mgh8a0Vp5pM4QBfKJVpjce20mANxvkTGARq5/Jd
         w81Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW7xVomhO4dcVxzyhbECkfmu6ORsPih1KiwwuF6FtO0enlucCcS
	6oKn0K2yJYAePiWDxxY7jErOUAvRbqgPg/auSbcVJOsVlVCB71YPCYIry9FytoHZDiWkwWjdEnK
	8E/fAp4kCdnJTlJd50jNmO7hs6iN7cO4p3kq6/l5FrfokSDHI/sjEG2KAoMda6seCMQ==
X-Received: by 2002:ac8:674f:: with SMTP id n15mr3974972qtp.289.1555689059775;
        Fri, 19 Apr 2019 08:50:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCXIuUMKVLC8R4AfQFVACo/p8ArfO+GVHD2x3giKpPYEkMhUgerVgSJOO2zcNa9OmRyHmP
X-Received: by 2002:ac8:674f:: with SMTP id n15mr3974934qtp.289.1555689059011;
        Fri, 19 Apr 2019 08:50:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555689059; cv=none;
        d=google.com; s=arc-20160816;
        b=fothrWGDBnWpVDl6dOnjXSaZMfDj/ERg1d770jIJ8sxy80i4BY6M7Zq0CurCsa5D9q
         hBorw54VTiEporl/63clv+jtMnDp1QvlXrI7qRkaD7r3jKy5EqcZAxJVRz+gUHHJm3Nw
         39KCF4smxC44+PcJibZDXtuJBoZyzxy+VuGx21A1LlvMp49LSR8pUxwmMCJ3XhDYSOfk
         ChF3hyupf0vzmpLhwCt4JNS/rpx6q1l1fk239MYwPrnB2sGEQ9I4tBieh3F8iZn/0ieX
         47dyTe2xY3ibScS4/GIQzOGeRkY7J0VTjW5hjlkq4xDP7TvHvlGCRqQB/+lvb4GufqbN
         Dk1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PSPU8KC13m0ibHlVgdRBUJT8IhE7UKk+UFO5xgfsf+s=;
        b=UPM7f1hRcQ/aVhQC6GSzf+nXVTCH3DppsqeMWPj7UmVca0nZ/vT6n+RCT5MS6TuqcD
         7X1yfSdB8SHXoc+dTCWIjKoUMmy1lQ5ioY7OPFfOoFPMm/tvvZVPnpEUAnSEx+FpchmT
         gGwNFg+6W6hO2NZQgQdCvNpFPu6Fv6D4ceIcCCiMnoI2pGjwjZ51K+9MmNOWML1L7E7M
         7l2Tgw8Ld3M5SzsgIEWiiOwL2dYPWox+5XK9GjVM/JHpbc+7JRTrY0VE1A1NxXLhqZi5
         fF0RVRgt05MBFkJIqNKe7vTG1vt1LNsQSkE9oUDoIb5KAPJ8JeuSpUSSl3f4d1kcd2y7
         nhDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y9si3474484qtk.389.2019.04.19.08.50.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 08:50:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A13B13076C9E;
	Fri, 19 Apr 2019 15:50:57 +0000 (UTC)
Received: from treble (ovpn-124-190.rdu2.redhat.com [10.10.124.190])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 485F819C58;
	Fri, 19 Apr 2019 15:50:46 +0000 (UTC)
Date: Fri, 19 Apr 2019 10:50:44 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>,
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
Message-ID: <20190419155044.2uch7eaj4vzg47w6@treble>
References: <20190418084119.056416939@linutronix.de>
 <20190418084255.652003111@linutronix.de>
 <20190418145201.mjzyqbmkjcghqzex@treble>
 <alpine.DEB.2.21.1904181734200.3174@nanos.tec.linutronix.de>
 <20190419070211.GL4038@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190419070211.GL4038@hirez.programming.kicks-ass.net>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 19 Apr 2019 15:50:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 09:02:11AM +0200, Peter Zijlstra wrote:
> On Thu, Apr 18, 2019 at 05:42:55PM +0200, Thomas Gleixner wrote:
> > On Thu, 18 Apr 2019, Josh Poimboeuf wrote:
> 
> > > Another idea I had (but never got a chance to work on) was to extend the
> > > x86 unwind interface to all arches.  So instead of the callbacks, each
> > > arch would implement something like this API:
> 
> > I surely thought about that, but after staring at all incarnations of
> > arch/*/stacktrace.c I just gave up.
> > 
> > Aside of that quite some archs already have callback based unwinders
> > because they use them for more than stacktracing and just have a single
> > implementation of that loop.
> > 
> > I'm fine either way. We can start with x86 and then let archs convert over
> > their stuff, but I wouldn't hold my breath that this will be completed in
> > the forseeable future.
> 
> I suggested the same to Thomas early on, and I even spend the time to
> convert some $random arch to the iterator interface, and while it is
> indeed entirely feasible, it is _far_ more work.
> 
> The callback thing OTOH is flexible enough to do what we want to do now,
> and allows converting most archs to it without too much pain (as Thomas
> said, many archs are already in this form and only need minor API
> adjustments), which gets us in a far better place than we are now.
> 
> And we can always go to iterators later on. But I think getting the
> generic unwinder improved across all archs is a really important first
> step here.

Fair enough.

-- 
Josh

