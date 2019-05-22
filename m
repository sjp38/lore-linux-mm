Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6115C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 16:01:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C5D420879
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 16:01:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="scYBgQFy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C5D420879
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 072266B0008; Wed, 22 May 2019 12:01:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 021886B000A; Wed, 22 May 2019 12:01:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7AFA6B000C; Wed, 22 May 2019 12:01:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6AD96B0008
	for <linux-mm@kvack.org>; Wed, 22 May 2019 12:01:46 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id a6so603323uah.3
        for <linux-mm@kvack.org>; Wed, 22 May 2019 09:01:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RSdosCg7CAf5I4ACWla5jsLhMewb72YTSpe4zJkcCao=;
        b=iAJYlPXcaS5HbhVLTGKLxWASIV9y2SOiWFVNdn3FxFvY3v7Zx01lvBc/J4KcfBxlKd
         97o1nqBQKrXBgREvCsz4+/3bWm7p9DIi5KPfMzZGCYDHk1M5ozMhihR8tWu0QdfkIB5o
         X9czSF/29rbOaMOJkuCcgsx1v9UnH0xulKHp+vF0vycYP0YFAP7WBaN9c8V1K+cYh744
         f4j+YWyJc3hkmsB3kak/T6wnbdsQAlTqmlGvFJOo+TO3jVpmm/lz3EpGV7Vqyocw1yQ8
         RkDwDDuQuqf71HfBlLMsbvKBvDAgVzP1XMe/Haa6cB0aIuLec05PxGIkv3uIl5kyqTCG
         FffQ==
X-Gm-Message-State: APjAAAV/qj+vgw7/B+6SahQGD55NOyabPpgJ+72TSWe5wLdzFRzekTeC
	Tpyf2MW8CvYSfw+JQ2eT60RpnU/N0+aKCXO0mMVXhPi9+PH2yau+gRXaPBwYvwlf7aJqPauKhED
	W8p6FzCIrg9Y/sk+aHjduoZvUbMINkylwv6tL66F28GGwz+4NeQUJNz9GdoEpgqSrdw==
X-Received: by 2002:a1f:1102:: with SMTP id 2mr15721943vkr.90.1558540906543;
        Wed, 22 May 2019 09:01:46 -0700 (PDT)
X-Received: by 2002:a1f:1102:: with SMTP id 2mr15721902vkr.90.1558540905899;
        Wed, 22 May 2019 09:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558540905; cv=none;
        d=google.com; s=arc-20160816;
        b=eAoqilQHlzo2IAEztUH5pgrbe67RC/xnPZ42l+5iXBqCK7wszKwOsCKY0DIwy3iNoH
         9Jww1o4qPIJj2NsP2T68sr12wCWoCBHPrDXT2Y1R8LxBcHsmnZXpRnxcD29/ZfhcOd/U
         JXcQ4tSKg359mO81psLaCocFOPP4hxzdyM9Vkfl8nrzeFfSai4KOuX6bfog9e5mCJj66
         ztdHcQ9iJvVv3BOuoCOMHH5ms1llU8CjhtaFLkTTmYowf5CV2H/g9yNSlwGV++w+6kmg
         KjTwz9wX8oSFNCFb8CyBvPpDEk3rt99TXBeqUIJn+87mySkTeK9xd/yV3X6vVPd3Ld+b
         koLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RSdosCg7CAf5I4ACWla5jsLhMewb72YTSpe4zJkcCao=;
        b=yYiYdfD+2midg3nTwA98n8UBl0FAeOvxq+wQOVscivspeYYXajpAqKcoK2a0AmHgVh
         DV541RBwuAkTbf4LgyrQ6FcITRTOxmAwyMQlj9uzm97F7z+4uy+9eJdFslW5gsXY8l3y
         ZxIb+3wrxCwWtUeCz2a9WpXvl0iVAdkPYATzNEPL3XK0iSvVwQhOQmrTn6C2nSVtT0aT
         jMmVObhqRatyUhSgceBegCpLHUYqb66SKZHzirLnj6GrrXE2UoXu25pz4fdqn/88HlTy
         gHWDf9+q/RVeQAqSb5Q6aHBzriVAQ+Bl56v6t7kXYvTJAoIHVFe34jtFU5v0sujPsTRI
         9XTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=scYBgQFy;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x15sor3798460uan.25.2019.05.22.09.01.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 09:01:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=scYBgQFy;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RSdosCg7CAf5I4ACWla5jsLhMewb72YTSpe4zJkcCao=;
        b=scYBgQFym9ROAnpR66sReozWPRXNqJVUFlss1Ng44ycb9HpxOlw8L7UQ1Va7t73uvb
         DFN4rwIbWJsovtJ2lO1jCcCjsv/llpFZh7teYPx3c/Yc+JplddZXqxpVfZbwzI5Xn/LU
         9roGRSVSkxgW4wDuxlB1LMucxNvX0+5VadelX4+ew/Ov8rX4CgCIijza9KX9Fco3/Nm2
         8SL7c5IzGLvFUIvWKZDylrdng3FZ1T4GjMPVuy0qw+C2IfwG28lOU6P6EUI6IMf2Wcqr
         rEI5XiismRDtzA7X6wixbeBYQUnhz83yCAmnWShusLcB2rHnAQpp3dkFTdpQFJWPHfmz
         Odiw==
X-Google-Smtp-Source: APXvYqxi2BZoiCj8jAFjAAZIHHrwShReaS6FEKzT0Pw5Kh4Zsg7Q1dxxKPve5INSlH18g3XyBmOg6fU4xTfpOx2B+bU=
X-Received: by 2002:ab0:1051:: with SMTP id g17mr10254083uab.41.1558540905237;
 Wed, 22 May 2019 09:01:45 -0700 (PDT)
MIME-Version: 1.0
References: <20190521110552.GG219653@google.com> <20190521113029.76iopljdicymghvq@brauner.io>
 <20190521113911.2rypoh7uniuri2bj@brauner.io> <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
 <CAHrFyr6iuoZ-r6e57zp1rz7b=Ee0Vko+syuUKW2an+TkAEz_iA@mail.gmail.com>
 <CAKOZueupb10vmm-bmL0j_b__qsC9ZrzhzHgpGhwPVUrfX0X-Og@mail.gmail.com>
 <20190522145216.jkimuudoxi6pder2@brauner.io> <CAKOZueu837QGDAGat-tdA9J1qtKaeuQ5rg0tDyEjyvd_hjVc6g@mail.gmail.com>
 <20190522154823.hu77qbjho5weado5@brauner.io> <CAKOZuev97fTvmXhEkjb7_RfDvjki4UoPw+QnVOsSAg0RB8RyMQ@mail.gmail.com>
 <20190522160108.l5i7t4lkfy3tyx3z@brauner.io>
In-Reply-To: <20190522160108.l5i7t4lkfy3tyx3z@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 22 May 2019 09:01:33 -0700
Message-ID: <CAKOZuevR2WTbeFdvpx8K9jJj0Sc=wpNJKr24ePWsvE_WS5wgNw@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Christian Brauner <christian@brauner.io>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 9:01 AM Christian Brauner <christian@brauner.io> wrote:
>
> On Wed, May 22, 2019 at 08:57:47AM -0700, Daniel Colascione wrote:
> > On Wed, May 22, 2019 at 8:48 AM Christian Brauner <christian@brauner.io> wrote:
> > >
> > > On Wed, May 22, 2019 at 08:17:23AM -0700, Daniel Colascione wrote:
> > > > On Wed, May 22, 2019 at 7:52 AM Christian Brauner <christian@brauner.io> wrote:
> > > > > I'm not going to go into yet another long argument. I prefer pidfd_*.
> > > >
> > > > Ok. We're each allowed our opinion.
> > > >
> > > > > It's tied to the api, transparent for userspace, and disambiguates it
> > > > > from process_vm_{read,write}v that both take a pid_t.
> > > >
> > > > Speaking of process_vm_readv and process_vm_writev: both have a
> > > > currently-unused flags argument. Both should grow a flag that tells
> > > > them to interpret the pid argument as a pidfd. Or do you support
> > > > adding pidfd_vm_readv and pidfd_vm_writev system calls? If not, why
> > > > should process_madvise be called pidfd_madvise while process_vm_readv
> > > > isn't called pidfd_vm_readv?
> > >
> > > Actually, you should then do the same with process_madvise() and give it
> > > a flag for that too if that's not too crazy.
> >
> > I don't know what you mean. My gut feeling is that for the sake of
> > consistency, process_madvise, process_vm_readv, and process_vm_writev
> > should all accept a first argument interpreted as either a numeric PID
> > or a pidfd depending on a flag --- ideally the same flag. Is that what
> > you have in mind?
>
> Yes. For the sake of consistency they should probably all default to
> interpret as pid and if say PROCESS_{VM_}PIDFD is passed as flag
> interpret as pidfd.

Sounds good to me!

