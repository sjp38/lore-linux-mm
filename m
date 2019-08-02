Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99090C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 01:19:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DB53206A3
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 01:19:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bTRX3vnb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DB53206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E384A6B0006; Thu,  1 Aug 2019 21:19:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE9316B0008; Thu,  1 Aug 2019 21:19:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD8236B000A; Thu,  1 Aug 2019 21:19:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 800EE6B0006
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 21:19:20 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id u5so36274688wrp.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 18:19:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=hYkecIBjzROR5NsLeOwFUoMJIb/qPM7Hd2+NHJCx9T0=;
        b=Xys5IBjc8IFasczENdJrfjKCs7mFDY2LV4q8E/3RU2k6pBiM8Vo3JsYWzT2daLaPSf
         2aUGDfFowBQ+QkvaHQ9qmJeB2yZctaT+++pgpxzDph12GeWQa7YKrNUA4F1cUHZKedta
         36TmTmgxDmqwow+lFmj68f5vmCUtOmtmtI0GbkVT60sqJ4MjyR934KsytZfva+QjgByh
         +8F3vlbkDBDc986xFqmVYlA1yNUXRBgDKm2n6mtIe4Tcsadh53GSP0YuIAAGmewz6YFF
         LUjWpcb0cCnQz7lLKrfQMxsMaW4eQ+voHklahrWFZbzgWZZhopeXlwmF4CYhSyGBC7sD
         0Vrg==
X-Gm-Message-State: APjAAAV9HM1s46tkmTZGK6vGGu4O60KTnuQ+5LrYyhUzrWQtsrjZ32RI
	tPm72OA5pFe44qPlRD/BiSVcSzz0P/WuPz2Rda1vmpq4JCgm2JOfmYtZsGILWqqblGgA0NFkr+Q
	rIe5UEM2sfw3oAnXLr+Grtvwg/VBBlRWEEKusuQkq3q1QHFfOJWqPluenmGTrYLSDRA==
X-Received: by 2002:adf:f281:: with SMTP id k1mr55614914wro.154.1564708760104;
        Thu, 01 Aug 2019 18:19:20 -0700 (PDT)
X-Received: by 2002:adf:f281:: with SMTP id k1mr55614819wro.154.1564708759246;
        Thu, 01 Aug 2019 18:19:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564708759; cv=none;
        d=google.com; s=arc-20160816;
        b=nHWj2NjVLJdNCG+PBcJgCUeANuDQ/j3fw9gSf0WE895FuBhd8oOafQIbMx5JONBYJM
         Mybyy1Dy9zg8uRIQIyTACr3bPTOLUn6x9iCi8ic1T0Dy3s7REkeibXHBmdb2PfwLcoF7
         9OmfcjoPc+2M1kSFmuHVAxoXmgnq+O2yCdlIWqMGCxPd4bVONdtS6kp9PYpM93kdCVUd
         8eiCYBsI7CGVoYokwxLeZO/ym2Zun3M2FgNK5RD0Xb5OSyhOd6Fcl7JpwvkOol4MF+Rx
         eRynG6HANRIgZ6+SdPCNU9NJQoagAwDKOJtIjGAPVxPO9BFgaznlUibIBuwE36JjB2nr
         lDRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=hYkecIBjzROR5NsLeOwFUoMJIb/qPM7Hd2+NHJCx9T0=;
        b=MzbasGAM1rbom/pRgTZSr6vX8aI9u3lA9rcFQ9y8jywul80f0P7nR/6D4Fm5lzzeq1
         qYX2/VTY7QGuXbCSgsXs5+qFggFbusggn7HTqBzOF/0FG05HKnUpBFIHGKPxbSbRb7HX
         E+5vnu7kzsN9TB8QeaLFhPVPhVDmRBFLt2mFjHKXGR8cdGaVjNb0UAls+k3CrWYQ/URk
         6Ac2JTCTparJ20d9MB34/Bobgl0HUFFvS+hjQVnwqKtXHI4MOAiJ49TnXLVs6YTJILkh
         J9tBvBkZA4eqsi+syEtmSAeeh8I4f9rZzciRI7ftfQkvbSK+ZVPuAvJ/yW2QGBZvdJda
         rl9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bTRX3vnb;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s129sor41467141wmf.18.2019.08.01.18.19.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 18:19:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=bTRX3vnb;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=hYkecIBjzROR5NsLeOwFUoMJIb/qPM7Hd2+NHJCx9T0=;
        b=bTRX3vnbUBvVzMx3EnZMIFrwYtFIhquzKtu5cZFrCSlpDg9eHRpK79SeMK722L58Lx
         suLi8IuxYepKjTtwrQeaYVw3UCa8TC07WWhpnjqVI5obNgp88fmw8vBOPXJUZGQpRn3B
         Kek3LyGyDmhXd3x80/nb19A+dxuaSEOgzwEGFICIugHC5OjNurwiPLEhR0Qt6mgoLXjA
         FwAFPVU6P6CA6yRutdDhbVYbVWw7/HfTbgfyb0533DmsKVM2ZZ8vsVGIHrd5KmAOQN+i
         lCgtdD3z/Vn3GnJDL/vFmRcjQkREp3QDDU0DEVt09uQ5KrxVEQpbGvpFaA2UDavihbW/
         kt1w==
X-Google-Smtp-Source: APXvYqzhOtoCy4Rhyi1dtBv4uO4BEfsQUkH57i/KR8+jcXqr7blW2/4PVm+qncKQu2ijKNfJDcK5/BaT+O4JpGxbK+Q=
X-Received: by 2002:a1c:1f41:: with SMTP id f62mr1061380wmf.176.1564708758410;
 Thu, 01 Aug 2019 18:19:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190730013310.162367-1-surenb@google.com> <20190730081122.GH31381@hirez.programming.kicks-ass.net>
 <CAJuCfpH7NpuYKv-B9-27SpQSKhkzraw0LZzpik7_cyNMYcqB2Q@mail.gmail.com>
 <20190801095112.GA31381@hirez.programming.kicks-ass.net> <CAJuCfpHGpsU4bVcRxpc3wOybAOtiTKAsB=BNAtZcGnt10j5gbA@mail.gmail.com>
 <20190801215904.GC2332@hirez.programming.kicks-ass.net>
In-Reply-To: <20190801215904.GC2332@hirez.programming.kicks-ass.net>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 1 Aug 2019 18:19:07 -0700
Message-ID: <CAJuCfpHEhK_g5pDhJ3JEu+ioE0xKME56Vs5xmPiUtXH4M0umog@mail.gmail.com>
Subject: Re: [PATCH 1/1] psi: do not require setsched permission from the
 trigger creator
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, lizefan@huawei.com, 
	Johannes Weiner <hannes@cmpxchg.org>, axboe@kernel.dk, Dennis Zhou <dennis@kernel.org>, 
	Dennis Zhou <dennisszhou@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	linux-mm <linux-mm@kvack.org>, linux-doc@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>, 
	Nick Kralevich <nnk@google.com>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 1, 2019 at 2:59 PM Peter Zijlstra <peterz@infradead.org> wrote:
>
> On Thu, Aug 01, 2019 at 11:28:30AM -0700, Suren Baghdasaryan wrote:
> > > By marking it FIFO-99 you're in effect saying that your stupid
> > > statistics gathering is more important than your life. It will preempt
> > > the task that's in control of the band-saw emergency break, it will
> > > preempt the task that's adjusting the electromagnetic field containing
> > > this plasma flow.
> > >
> > > That's insane.
> >
> > IMHO an opt-in feature stops being "stupid" as soon as the user opted
> > in to use it, therefore explicitly indicating interest in it. However
> > I assume you are using "stupid" here to indicate that it's "less
> > important" rather than it's "useless".
>
> Quite; PSI does have its uses. RT just isn't one of them.

Sorry about messing it up in the first place.
If you don't see any issues with my patch replacing
sched_setscheduler() with sched_setscheduler_nocheck(), would you mind
taking it too? I applied it over your patch onto Linus' ToT with no
merge conflicts.
Thanks,
Suren.

> --
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

