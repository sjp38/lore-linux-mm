Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A4E6C10F0E
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:10:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1B3B2186A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 14:10:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Ut+BU82T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1B3B2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 707376B0010; Fri, 12 Apr 2019 10:10:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68D506B026A; Fri, 12 Apr 2019 10:10:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52D4B6B026B; Fri, 12 Apr 2019 10:10:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 052166B0010
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 10:10:22 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id j63so7033897wmj.7
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 07:10:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=90DhyNOjYKUio3/9dm7oyIW5bfCoyTnkGuxR/xjlLUQ=;
        b=lwrYBDb+hQY3wBqX9V89vrXZ5wytrki8zU2iZ8r3cb5t43nxCWyhLRt/oo77cvJszB
         u/X98DphM/WGxbDRiQgKwrjizbQy+HCqAm/sMTYo48+lcfJeH884xjNwsUJwr1LAr806
         lBlLcJqltoW01cyizD2BRmijlCdbfz/3uKx+xmhOYv10bAaKnwi8ThFsLqioqaHOW1TL
         Yf2QQwUh5p4IblvRce6WcG6I3J+5oTWVKb8u1J1UWySE9csbu63Tqs6w2KLBWViioyW2
         AjPGsGfuIWZGVijhKYH/xqDLPfqp3K3wWKb3WXSYJULvs2Ur8Qs35tZRxAbwqLMzYEW8
         T2pw==
X-Gm-Message-State: APjAAAX7g2+p8EemptA5r8lFrgcYCBSkFIR7+tz86AgF6t6DCUg8HUIg
	5q1qO0LAEXgxGyCGZS3ADdFuxKO3KXlsgCi3lsPLKCbh2P0D+/CSOFp0vaTSJGTnQ+ZeNM3A/gl
	SRgDJXMVVjN67P12K52SfbqHvbsnzKIlX2Bx6AMrxJXRVwlmpdYBDXlo9nuI6ZsuPpQ==
X-Received: by 2002:a1c:9cd1:: with SMTP id f200mr11481353wme.91.1555078221394;
        Fri, 12 Apr 2019 07:10:21 -0700 (PDT)
X-Received: by 2002:a1c:9cd1:: with SMTP id f200mr11481280wme.91.1555078220329;
        Fri, 12 Apr 2019 07:10:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555078220; cv=none;
        d=google.com; s=arc-20160816;
        b=ORsBSPo+LLg4vOcAdjcTe3v0seaGpjstJAqs36Sp6XaTsq7fZUrPX/oMJKOEOnPgYO
         MqDl4E74C66umUBVYjMFJ1Et+zubKQYlgJhR0M0+QAWiS932gqTl2vUMg8jdly6LeThr
         KADOaHanynCrJxaTPzw8PwlI1PkzClv0qt2ey5Bide4nuc9VZky08BPha9u+C1IRrlSU
         qiVwP7gtDALllkeqORMq8A4PkW2zAXwXvLe/EbsfCecJkhFxwTdBOy6iQaeVyhRyXnv6
         bw1HoRrN7g6KeJsx43tVwIomcDD696HKdV4WD1glskjLK91GrFXwS8kzhlsqXZnY90/B
         Jh6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=90DhyNOjYKUio3/9dm7oyIW5bfCoyTnkGuxR/xjlLUQ=;
        b=Yhf5H+nlz0tORYp8BoMpx25ntuYa5eJP9zONZVGvVhIUwQbb23SuGzIJp9wAvgKm38
         Qf3WzA2kYdHQ6cnz38IdZhdQPnC90h6ZyWg+zWICiJVN8nKmGmi0eqvcRUTza3i7VSr9
         vEhcdpi/TTm4WkXC4TU4Gi+hoFUuI7Rh1CZHeg3LvdXZmF+lF+tn4m4aY24aOtJMeyQ4
         GtB3W/Gco2lNtz2zAlk5UQSoGnuRoixgJXQr8kjy17jPH06wAhw9cSsZqKoWaIcJn7QW
         b9VqSwPPAXwXQWpY7YJSVH8X6bAENoyJPU+cTvQLVfB8LX0JTyWIgjbimBCI2YaFKDkc
         /KwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ut+BU82T;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b10sor31014544wrq.36.2019.04.12.07.10.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 07:10:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Ut+BU82T;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=90DhyNOjYKUio3/9dm7oyIW5bfCoyTnkGuxR/xjlLUQ=;
        b=Ut+BU82ToY63AFh0Jd7IVp0QYUoXU6aJ4Jqho2HFukbN68H9nrlT6/uWhys/uEdm9P
         0OeJeAOWj5z4jTcZRBdqYosDVq0aAhb0nJD6k2HCLVVDOG3O8hTl33pidDWNP41+el4z
         CZgzBAAtmKUfThyobUgavdz2MroFuP9chylGrkQvLRAMXcCpZLN7dopM/s5b4pcKKTdI
         xqgmHMq5aqXE9T38aLG7t3KX3FV5tRDXuU2oKtGApG+Gk9crSchMAXHFhknZqQkDhq8Q
         patpTm9UYpR+tzj4k4bPRO/4hQeLsrG2EHTiSXPmEGp8zDYiCXJzyCFOi2EdlMQQa2l/
         RQ8Q==
X-Google-Smtp-Source: APXvYqy5NJ9ngzb1u4JggWfV4gOmQq/6oqsf69m9MuREST1uBrvQU/t0WRYKCnMBeC7HsJ526lrP4r7d0JC3VxMiK7I=
X-Received: by 2002:adf:f98d:: with SMTP id f13mr36647579wrr.98.1555078219540;
 Fri, 12 Apr 2019 07:10:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <20190412065314.GC13373@dhcp22.suse.cz>
In-Reply-To: <20190412065314.GC13373@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 12 Apr 2019 07:10:08 -0700
Message-ID: <CAJuCfpHzfci6ztBA_c5=DUnfaLQJTphj1UfckN_LZ7w9qi4kAw@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	David Rientjes <rientjes@google.com>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Daniel Colascione <dancol@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, 
	lsf-pc@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 11:53 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 11-04-19 08:33:13, Matthew Wilcox wrote:
> > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > victim process. The usage of this flag is currently limited to SIGKIL=
L
> > > signal and only to privileged users.
> >
> > What is the downside of doing expedited memory reclaim?  ie why not do =
it
> > every time a process is going to die?
>
> Well, you are tearing down an address space which might be still in use
> because the task not fully dead yeat. So there are two downsides AFAICS.
> Core dumping which will not see the reaped memory so the resulting
> coredump might be incomplete. And unexpected #PF/gup on the reaped
> memory will result in SIGBUS. These are things that we have closed our
> eyes in the oom context because they likely do not matter. If we want to
> use the same technique for other usecases then we have to think how much
> that matter again.
>

Sorry, resending with corrected settings...
After some internal discussions we realized that there is one
additional downside of doing reaping unconditionally. If this async
reaping is done on a more efficient and energy hungrier CPU
irrespective of urgency of the kill it should end up costing more
power overall (I=E2=80=99m referring here to assimetric architectures like =
ARM
big.LITTLE). Obviously quantifying that cost is not easy as it depends
on the usecase and a particular system but it won=E2=80=99t be zero. So I
think we will need some gating condition after all.

> --
> Michal Hocko
> SUSE Labs
>
> --
> You received this message because you are subscribed to the Google Groups=
 "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to kernel-team+unsubscribe@android.com.
>

