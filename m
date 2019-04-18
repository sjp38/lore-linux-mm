Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73C6EC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:52:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 142A7206B6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 14:52:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 142A7206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B1AA6B0005; Thu, 18 Apr 2019 10:52:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 75EB16B0006; Thu, 18 Apr 2019 10:52:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 626D36B0007; Thu, 18 Apr 2019 10:52:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2AB6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 10:52:16 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z24so2227281qto.7
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:52:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UJ0G9gEmfESTJQLoX1qgmdWz06MkmV1SWQsPisJNzDI=;
        b=Aq4k14z91bqRHE+GCkYGOvT5QwQOZz0ZFZ7/iLtuji6d7D4KX1lueJZcozv5yn1gWy
         aoHjaDaCsOR9z6I4iYRMI4Wh8Q31s8Ttu2MWrOgTudCwgq99ADWQ/yAvbveqNEtUIEvv
         U9+NTLZw8ccV3GgdkEJ66Hpbq9AMSww8RAEhysnl34wkExwi9Jvx4IlMgwP/3CQKgwMc
         HTPcFY/iRao3zQuubdbJK0kQhrYA81Uz5SNPIH1XbAGYAm9YAd5rCJqqF/Pgehh62A8x
         h//c9cNxYy6mjvMUTJUnm3coZIqUgSxCwi++f5A4o3fw3JNgcTjDSUkJotaA3NEpZACn
         nC4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV+EkdbQZi672GVEyKT/NI0fBObIdqyHYSp9kcNsq7Voz9M4HaG
	iPkA43X6cCuC4CUW0A29QmPWTANH5eCSKYWdaCrXUsPgxBzVhnG24eofAK3p8amtgczB1cy230d
	+rGNo31XYcMPMF60+jz8QzXn4BArGg3t+k0KzeJugpE2ExvJthWDUJOyj363oNGzZbQ==
X-Received: by 2002:aed:3fa7:: with SMTP id s36mr79246215qth.124.1555599135901;
        Thu, 18 Apr 2019 07:52:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCHDmN6+WVjfVe01dBkBGBxBuOqZGHDWc0n77vOU2yKF4C79LkLCbi9sxBpQMlRTT4k0ZL
X-Received: by 2002:aed:3fa7:: with SMTP id s36mr79246158qth.124.1555599135323;
        Thu, 18 Apr 2019 07:52:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555599135; cv=none;
        d=google.com; s=arc-20160816;
        b=kdMlqa5Q0uOh6oSytpA38lkYwL6vTBkumVZH7jWJjlXzm367zR7SuzIZEHYIL0JmF7
         c33vIS4wziTtMMjjWNK+a5EawXPLBDvdRxCs/yMPLOtFyUhLD9lhPxYRQBaBbvN/IUfW
         T0Re/Wml5q5cBQj8VzN8zX3Q8wDlDb+HoMANa3OOcPZxGo5p/W5kmeNeknNlf9E1kNV/
         acvgJtQ2l9kR9MuPKe5o5Ike6c/wTh5YTeJfmsMSX7hPZ/CIt51erzaSw9Mggh1XfuoK
         IjreEPK2aokVneiLEaYIHna/sLrVBTEvyyC3qTTRAXBURy07LY8oFHPPsnGY0io9Xpi4
         +gcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UJ0G9gEmfESTJQLoX1qgmdWz06MkmV1SWQsPisJNzDI=;
        b=pA2jca7yIab0NccvhyvF/nFH7tt1T/BW3T5zI0pOZ6y+ydKyUscCJ10A4QhUjVqM6o
         jORmNn5Enoop00nIVTvA5RkjVbfBqaRAmuvyEwXtpo2BIQHLb1tXwPwElIzvLkWDL4xw
         qso9l0fDtXmTICcTfDGWBwUAXhRiAYfQsMeyT7sDpHL+fptihMtk//JcS83FVEkmyxrr
         LherLy9nzOus+rb/DhWYLyP2gr8STbG67NgxrNilZMeDcwyG9mPaWQooZuwEOhs9N0D3
         hJz1c0V7gabCzXKLk9CUcFKIYYSW58aB14shpOnuWKoqd68k0dqiAyGDhw0+4SRJa+qK
         4ewg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s10si1547042qth.78.2019.04.18.07.52.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 07:52:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jpoimboe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jpoimboe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C39BB3078AD9;
	Thu, 18 Apr 2019 14:52:13 +0000 (UTC)
Received: from treble (ovpn-124-190.rdu2.redhat.com [10.10.124.190])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 518AE1001DC0;
	Thu, 18 Apr 2019 14:52:03 +0000 (UTC)
Date: Thu, 18 Apr 2019 09:52:01 -0500
From: Josh Poimboeuf <jpoimboe@redhat.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org,
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
Message-ID: <20190418145201.mjzyqbmkjcghqzex@treble>
References: <20190418084119.056416939@linutronix.de>
 <20190418084255.652003111@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190418084255.652003111@linutronix.de>
User-Agent: NeoMutt/20180716
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 18 Apr 2019 14:52:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:41:47AM +0200, Thomas Gleixner wrote:
> All architectures which support stacktrace carry duplicated code and
> do the stack storage and filtering at the architecture side.
> 
> Provide a consolidated interface with a callback function for consuming the
> stack entries provided by the architecture specific stack walker. This
> removes lots of duplicated code and allows to implement better filtering
> than 'skip number of entries' in the future without touching any
> architecture specific code.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: linux-arch@vger.kernel.org

This is a step in the right direction, especially if it allows us to get
rid of the 'skip' stuff.  But I'm not crazy about the callbacks.

Another idea I had (but never got a chance to work on) was to extend the
x86 unwind interface to all arches.  So instead of the callbacks, each
arch would implement something like this API:


struct unwind_state state;

void unwind_start(struct unwind_state *state, struct task_struct *task,
		  struct pt_regs *regs, unsigned long *first_frame);

bool unwind_next_frame(struct unwind_state *state);

inline bool unwind_done(struct unwind_state *state);


Not only would it avoid the callbacks (which is a nice benefit already),
it would also allow the interfaces to be used outside of the
stack_trace_*() interfaces.  That would come in handy in cases like the
ftrace stack tracer code, which needs more than the stack_trace_*() API
can give.

Of course, this may be more work than what you thought you signed up for
;-)

-- 
Josh

