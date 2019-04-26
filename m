Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54267C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:33:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBD4F208C3
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:33:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="uQ/gZaik"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBD4F208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E7A76B0003; Fri, 26 Apr 2019 09:33:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 396E46B0005; Fri, 26 Apr 2019 09:33:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 25F626B0006; Fri, 26 Apr 2019 09:33:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E7C496B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:33:53 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id j202so1403467oih.23
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:33:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=6tej5jESshTVv0aym01xqA2/I/b4wPINcqNXZwVn3us=;
        b=jta+dP7T4H68Hlkrb/XeGLrVBkywVOI05QbE0y8IThOkVRqEyBz4QZbT2cZJtiskng
         +63Ik2P8YxNqX6aI18yCwXY5HSiw/25fMN08BTrIxlU2cz6v13y69vGEaKpbcq/zrTAW
         OaepBgQkr/mnFJeMtYIMTSpN1rq+BLUfreiKugbkAEwSqXH3PXGSbV7T78Ahz+AvN8D3
         yFjWEKkw9YRS1lBod4/0sCy18n6IWFx6A2l5Xaro7IwZQAdTMHbE6RIQDQTVBvpd75pw
         Gf5dPEDOVuLzfCFgVzNVobhvo/KTem8T+Cggv2yD+8rd0hK8yjYzLq7XJc3TTQT03JnP
         CQrA==
X-Gm-Message-State: APjAAAVHJ9RlDNQHtW34AaRTpvbxcvrpRNBakx0bJCKAlymMdsc0bExw
	hL+D5ThvNHrD6KwfM97uaYbVVI20zcqLB1jhd799m+//qj2wX0Z9tp/v4bn67SWPeplBnW4lCrK
	tZzK+erWNTOAWxkhTIDAKuQllKBN0bBV6f7o72+iMocy14Jr0vdtheikVYIoTWyOBMw==
X-Received: by 2002:aca:483:: with SMTP id 125mr6740896oie.118.1556285633503;
        Fri, 26 Apr 2019 06:33:53 -0700 (PDT)
X-Received: by 2002:aca:483:: with SMTP id 125mr6740832oie.118.1556285632702;
        Fri, 26 Apr 2019 06:33:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556285632; cv=none;
        d=google.com; s=arc-20160816;
        b=Of8tFg/NiAkSbr0vzimR72v+NiUpmAghs2PnILYXxq5WY7eEkADVhekb5Kx29qDY2a
         QXT8g38qIlxpD36WkQHmq+uXZ3u4sDpwgWgK1Q8o5Gqa4zdcl6Fu8kmCcii1LEJ96W1v
         tzQgL5sWXf14/+8P3kSqsqrx/M6CdRYbDVmyCJQ8b689+BxWUnXcydn+A3Q1d05tMJYu
         0OI+FLD3EThA86I/dHwVWGubS4OgzKjMHpECPpJBKV/qKpjQPk/BIIS5M+pX/E8xgvR4
         8y8CM7sElzuePzqByIYesWdoXhPeDbSnDoIYa79+IOJW+XIprX+s9dWsHhctRMfDHsa5
         Jvvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=6tej5jESshTVv0aym01xqA2/I/b4wPINcqNXZwVn3us=;
        b=JMoTzWXx4laTbx7U6D/vodHF5I/sUNrf2KgM8hqqaVTGKJcMT11tSPQQDDacUdptZc
         f+pIyelfag+lNfAIRJSsXmcTwWoLZIO128PKxN1IuTAYrr6N41q1pfvYjtkPdm0wck9G
         8gJ72nZAXE/2/CHtcnp7ttH6P4VCoBq5S4jtox/bGyjZ4wbJ2H98W6TFIucJOFGe2t4q
         NnXolq07wgl8+EY9adtuQk3O7ZQkY/lwbN8YlpVyF/q9jLKAt/v/CVjAH9qABVsAa4se
         wsUirOamz72AJ6ZqN3j/gdLO11C9DtWq1MTapgwhljMaLN+fr0hILfRUBZ4r3N46KEGc
         k04Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="uQ/gZaik";
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p3sor11904171otk.116.2019.04.26.06.33.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 06:33:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="uQ/gZaik";
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=6tej5jESshTVv0aym01xqA2/I/b4wPINcqNXZwVn3us=;
        b=uQ/gZaikg/ajGneKizm6XgTmI0RD3bZasUlUCaqWvuv3O3tS8ZBfFwf33o0Asl/OOW
         seIqin7ynG3eEUvz0Znn9051GpjNVUvGNQ4mDDKShussZxDy9ruJPQOn6Wz7Fh/oNUCi
         xcgG6LhZ1nmD1xNwu1JVjfI7BasXG9tB9BEP2O508BRfjJwX12FOnK6RJt1sl003DSbA
         f562iu6AqopYyCpnmBjH17DUhjnRAcl76yE8X9WpHXz9aiZzr289L6lPKyiE2vuogHi9
         klzE2XIKl+uBsNXlRksrkMYWQGfJ6Ptygkf6NRc5BXdhFsW8P4qLsAvn1JgZT4L0i/Co
         BC6w==
X-Google-Smtp-Source: APXvYqzss1Tgb5LK8ctZch+oggVhP88l0MqGw69vrusNMhysIF2cuvTumrXqJyUZE73hrMa6+hA57OM79yEn6XWqevI=
X-Received: by 2002:a9d:7a54:: with SMTP id z20mr1752200otm.230.1556285631958;
 Fri, 26 Apr 2019 06:33:51 -0700 (PDT)
MIME-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com> <20190425121410.GC1144@dhcp22.suse.cz>
 <CAG48ez0x6QiFpqXbimB9ZV-jS5UJJWhzg9XiAWncQL+phfKkPA@mail.gmail.com> <20190426053135.GC12337@dhcp22.suse.cz>
In-Reply-To: <20190426053135.GC12337@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Fri, 26 Apr 2019 15:33:25 +0200
Message-ID: <CAG48ez1MGyAd5tE=JLmjkFqou-VvsQHcJ5TU5f8_L43km9eoYA@mail.gmail.com>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Garrett <matthewgarrett@google.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Matthew Garrett <mjg59@google.com>, 
	Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 7:31 AM Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 25-04-19 14:42:52, Jann Horn wrote:
> > On Thu, Apr 25, 2019 at 2:14 PM Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> > > On Wed 24-04-19 14:10:39, Matthew Garrett wrote:
> > > > From: Matthew Garrett <mjg59@google.com>
> > > >
> > > > Applications that hold secrets and wish to avoid them leaking can use
> > > > mlock() to prevent the page from being pushed out to swap and
> > > > MADV_DONTDUMP to prevent it from being included in core dumps. Applications
> > > > can also use atexit() handlers to overwrite secrets on application exit.
> > > > However, if an attacker can reboot the system into another OS, they can
> > > > dump the contents of RAM and extract secrets. We can avoid this by setting
> > > > CONFIG_RESET_ATTACK_MITIGATION on UEFI systems in order to request that the
> > > > firmware wipe the contents of RAM before booting another OS, but this means
> > > > rebooting takes a *long* time - the expected behaviour is for a clean
> > > > shutdown to remove the request after scrubbing secrets from RAM in order to
> > > > avoid this.
> > > >
> > > > Unfortunately, if an application exits uncleanly, its secrets may still be
> > > > present in RAM. This can't be easily fixed in userland (eg, if the OOM
> > > > killer decides to kill a process holding secrets, we're not going to be able
> > > > to avoid that), so this patch adds a new flag to madvise() to allow userland
> > > > to request that the kernel clear the covered pages whenever the page
> > > > reference count hits zero. Since vm_flags is already full on 32-bit, it
> > > > will only work on 64-bit systems.
> > [...]
> > > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > > index 21a7881a2db4..989c2fde15cf 100644
> > > > --- a/mm/madvise.c
> > > > +++ b/mm/madvise.c
> > > > @@ -92,6 +92,22 @@ static long madvise_behavior(struct vm_area_struct *vma,
> > > >       case MADV_KEEPONFORK:
> > > >               new_flags &= ~VM_WIPEONFORK;
> > > >               break;
> > > > +     case MADV_WIPEONRELEASE:
> > > > +             /* MADV_WIPEONRELEASE is only supported on anonymous memory. */
> > > > +             if (VM_WIPEONRELEASE == 0 || vma->vm_file ||
> > > > +                 vma->vm_flags & VM_SHARED) {
> > > > +                     error = -EINVAL;
> > > > +                     goto out;
> > > > +             }
> > > > +             new_flags |= VM_WIPEONRELEASE;
> > > > +             break;
> >
> > An interesting effect of this is that it will be possible to set this
> > on a CoW anon VMA in a fork() child, and then the semantics in the
> > parent will be subtly different - e.g. if the parent vmsplice()d a
> > CoWed page into a pipe, then forked an unprivileged child, the child
>
> Maybe a stupid question. How do you fork an unprivileged child (without
> exec)? Child would have to drop priviledges on its own, no?

Sorry, yes, that's what I meant.

