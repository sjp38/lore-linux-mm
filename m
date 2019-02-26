Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E40BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:57:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92A57218A1
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:57:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="mdcyZhjW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92A57218A1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=szeredi.hu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 287588E0003; Tue, 26 Feb 2019 15:57:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20CED8E0001; Tue, 26 Feb 2019 15:57:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FDE28E0003; Tue, 26 Feb 2019 15:57:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2FD58E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:57:01 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id h3so3282517itb.4
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:57:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=55zzPnyrnWUFKeC9LCdS8dxBYexmrWxKcTLd2Z5DwnA=;
        b=NvG482G14XjDOqX/Ltb0s7fTesSg2pC6UN1HaTz4MDtCe5nizC4uwW7vvTqmwFgZ8f
         gUFo7tQU4CW895T7OXXl1PszzOxUWJNGbsoPjpUImFynfGKPJNX7gOvvOifmtBGNyfd6
         5EsJ5M2YcENfalpKXVduJUT3jjvhbImh3QTdkQfl8trRR+dTrSkDPDOf9goX9jPuzULU
         vjxHzsGti9CLT5OsCw3bI+Ahgz2NNceMK6G8XzwTnMCWCBesqtrsZxiu9AITQQtIz5G5
         8qU8htsgOKd2nlDA0+Hlu7c54AtvdmWDvQZcksgMMrjDQpclMQ4X1XgkjZUJup73bQ2Z
         7dWg==
X-Gm-Message-State: AHQUAubhbifjaBRpoXo0tbDKtbzRmOMOJ9MLNekN7Ab4r6WqXB5yh+7j
	akicUuvKkQ39vvqLyvW5/pV8/Tce4QNm88G9tIi6C1Ak0zdP9dqSO5Sf0en9m4Eysqc+bbuxfT4
	dC3MvJll+G58eXMFc6FTI8J3Lmk7WZwkFTMCG+s1pVGLvigBWgzFOdnWkI+cmku/z6VelPN37C7
	fDtyhb/khsIzs/1A3W/gDed8yO5RHCl793u/Wfmx0RlNlRDoY8MUqQCKx1xuWUhbirUDg9ikxtG
	E9I+ESaTugk1SD7GABR/DPjDGl+jQ6UTHXi4ZmVjj7B8IcveWKxeLqaKyRs9j0kGhvKFyZcIzB9
	VztUtwV5nJJB2c12KrrT8fJbdNCewGOCgGXnN0HUdnbjT3ZLHj7V2K/joKvn5hVkwd8Q3EcIoK+
	T
X-Received: by 2002:a02:4fc7:: with SMTP id r68mr1819140jad.69.1551214621527;
        Tue, 26 Feb 2019 12:57:01 -0800 (PST)
X-Received: by 2002:a02:4fc7:: with SMTP id r68mr1819098jad.69.1551214620569;
        Tue, 26 Feb 2019 12:57:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551214620; cv=none;
        d=google.com; s=arc-20160816;
        b=yzFSmqWdLpVULE7YjKMFv5jlkfp9kqKNrkU5PEifo+Cfgaef8itZ5jRn1tqKjrPxzz
         KnMdPDjkbCph5Mk76NsAi8yh4cQ5rTJtDaE67y2IF0mkZ8T64sYxSxyTz/gfXYTKjEtj
         AfBqba3ZjTyBAZJqfxkEko0THCv2OHppaA5fQY3SD/k3WoQdUv/8Fnpgg7OFCJeHDxKE
         uDCD29VbOo09xSpTp3sDO3bh2J797nIGvfXpNufvbbUX0/z6YuonuNyZgaYbBHKq5m2D
         eU3TGisUaGCLL/X+5TKUTXAR4DLBDgrb+/MDtxGr1g7g5nCZuGKUxZlBeaV+5nJqvDhb
         1heQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=55zzPnyrnWUFKeC9LCdS8dxBYexmrWxKcTLd2Z5DwnA=;
        b=N09QMGZ6LklOiLmZO9IX6sEoeUChMF3+Q0HanU482LIa5Qrq3gKiSGqZSJALxElrc6
         /8I5oq09X3pDjfu9hWfvUqtaQoaek5Ogc2K0xo8K0LbGz+ZpxHnwsBaJ0OC0etNcn1o8
         /sCLwItDdpOZ9M+Sjp9Q22ivvcjTzm0zg8rdJh926IP+s65+qOUg/0mR5cXu5U/7gdce
         K2TOefNLOSUI3tj4VEiktynyvPFp7vmo31+ectjp+jJpH5K/0XbYyvOrmvp4N3Hc7Vjg
         AkfbaIXnv/XcW2woNkRIT3aRJK5z0K2ceRA0wjdIMpX0xHmxdpjTZX0WnKkF3PhU3kSK
         tpRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b=mdcyZhjW;
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor32263221jae.14.2019.02.26.12.57.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 12:57:00 -0800 (PST)
Received-SPF: pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b=mdcyZhjW;
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=55zzPnyrnWUFKeC9LCdS8dxBYexmrWxKcTLd2Z5DwnA=;
        b=mdcyZhjWJjftBkGRV2mvYiILAmnTaifmwHApKVZ2WZbrS0kxeDt9L/aDZ1N6QOyJeS
         oF+kue/daQbFXT8OOCwn+rl5lbqNjU0sLj4ANhwqqVqK5GRIrEJ1LJ0RubrW31fSNUay
         x0x1JLrR5yuOY/oCfsi6E84kEKQtK4YYn0NNA=
X-Google-Smtp-Source: AHgI3IZmF7nfO5kmw057DHQOL02MSH5lHz74DKKtDOoVypP0k6dhL852D+FKOmOg/b9wdFvROK/LSNveGsL6mNcn5I4=
X-Received: by 2002:a02:4084:: with SMTP id n126mr12956042jaa.78.1551214619865;
 Tue, 26 Feb 2019 12:56:59 -0800 (PST)
MIME-Version: 1.0
References: <87o998m0a7.fsf@vostro.rath.org> <CAJfpegtQic0v+9G7ODXEzgUPAGOz+3Ay28uxqbafZGMJdqL-zQ@mail.gmail.com>
 <87ef9omb5f.fsf@vostro.rath.org> <CAJfpegu_qxcaQToDpSmcW_ncLb_mBX6f75RTEn6zbsihqcg=Rw@mail.gmail.com>
 <87ef9nighv.fsf@thinkpad.rath.org> <CAJfpegtiXDgSBWN8MRubpAdJFxy95X21nO_yycCZhpvKLVePRA@mail.gmail.com>
 <87zhs7fbkg.fsf@thinkpad.rath.org> <8736ovcn9q.fsf@vostro.rath.org>
 <CAJfpegvjntcpwDYf3z_3Z1D5Aq=isB3ByP3_QSoG6zx-sxB84w@mail.gmail.com>
 <877ee4vgr4.fsf@vostro.rath.org> <878sy3h7gr.fsf@vostro.rath.org>
 <CAJfpeguCJnGrzCtHREq9d5uV-=g9JBmrX_c===giZB7FxWCcgw@mail.gmail.com>
 <CAJfpegu-QU-A0HORYjcrx3fM5FKGUop0x6k10A526ZV=p0CEuw@mail.gmail.com> <87bm2ymgnt.fsf@vostro.rath.org>
In-Reply-To: <87bm2ymgnt.fsf@vostro.rath.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 26 Feb 2019 21:56:48 +0100
Message-ID: <CAJfpegu+_Qc1LRJgBAU=4jHPkUGPdYnJBxvSvQ6Lx+1_Dj2R=g@mail.gmail.com>
Subject: Re: [fuse-devel] fuse: trying to steal weird page
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000005, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 9:35 PM Nikolaus Rath <Nikolaus@rath.org> wrote:
>
> [ Moving fuse-devel and linux-fsdevel to Bcc ]
>
> Hello linux-mm people,
>
> I am posting this here as advised by Miklos (see below). In short, I
> have a workload that reliably produces kernel messages of the form:
>
> [ 2562.773181] fuse: trying to steal weird page
> [ 2562.773187] page=3D<something> index=3D<something> flags=3D17ffffc0000=
0ad, count=3D1, mapcount=3D0, mapping=3D (null)
>
> What are the implications of this message? Is something activelly going
> wrong (aka do I need to worry about data integrity)?

Fuse is careful and basically just falls back on page copy, so it
definitely shouldn't affect data integrity.

The more interesting question is: how can page_cache_pipe_buf_steal()
return a dirty page?  The logic in remove_mapping() should prevent
that, but something is apparently slipping through...

>
> Is there something I can do to help debugging (and hopefully fixing)
> this?
>
> This is with kernel 4.18 (from Ubuntu cosmic).

One thought: have you tried reproducing with a recent vanilla
(non-ubuntu) kernel?

Thanks,
Miklos


>
> Best,
> -Nikolaus
>
>
> On Feb 26 2019, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > On Tue, Feb 26, 2019 at 1:57 PM Miklos Szeredi <miklos@szeredi.hu> wrot=
e:
> >>
> >> On Mon, Feb 25, 2019 at 10:41 PM Nikolaus Rath <Nikolaus@rath.org> wro=
te:
> >> >
> >> > On Feb 12 2019, Nikolaus Rath <Nikolaus@rath.org> wrote:
> >> > > On Feb 12 2019, Miklos Szeredi <miklos@szeredi.hu> wrote:
> >> > >> On Sun, Feb 10, 2019 at 11:05 PM Nikolaus Rath <Nikolaus@rath.org=
> wrote:
> >> > >>
> >> > >>> Bad news. I can now reliably reproduce the issue again.
> >> > >>
> >> > >> A reliable reproducer is always good news.   Are the messages exa=
ctly
> >> > >> the same as last time (value of flags, etc)?
> >> > >
> >> > > The flags, count, mapcount and mapping values are always the same.=
 The
> >> > > page and index is varying. So the general format is:
> >> > >
> >> > > [ 2562.773181] fuse: trying to steal weird page
> >> > > [ 2562.773187] page=3D<something> index=3D<something>
> >> > > flags=3D17ffffc00000ad, count=3D1, mapcount=3D0, mapping=3D (null)
> >> >
> >> > Is there anything else I can do to help debugging this?
> >>
> >> Could you please try the attached patch?
> >
> > Looking more, it's very unlikely to help.  remove_mapping() should
> > already ensure that the page count is 1.
> >
> > I think this bug report needs to be forwarded to the
> > <linux-mm@kvack.org> mailing list as this appears to be  a race
> > somewhere in the memory management subsystem and fuse is only making
> > it visible due to its sanity checking in the page stealing code.
> >
> > Thanks,
> > Miklos
> >
> >
> > --
> > fuse-devel mailing list
> > To unsubscribe or subscribe, visit https://lists.sourceforge.net/lists/=
listinfo/fuse-devel
>
>
> --
> GPG Fingerprint: ED31 791B 2C5C 1613 AF38 8B8A D113 FCAC 3C4E 599F
>
>              =C2=BBTime flies like an arrow, fruit flies like a Banana.=
=C2=AB

