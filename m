Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8B8ACC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 495092084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 495092084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCDED6B0003; Fri, 26 Apr 2019 10:08:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7EE16B0005; Fri, 26 Apr 2019 10:08:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B44F16B0006; Fri, 26 Apr 2019 10:08:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 637486B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:08:44 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r48so1581965eda.11
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:08:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Gl4pDgsoTjXGZqZThKkrLaFex7Lx0Ph2eAdPNhjxdlM=;
        b=mhSN3GJdqfX6M56ABTcbIS9ev8NCs/TXn/v1/V4N/r6RNEiHGgM0WOkUCGvL79qvT2
         IXJtjkXSgNmlb1V4BMosKNzBYQCkn0ZRS3gg3XVGnlOqdBO/0dsBVNHzsmXrFuxeS/Fx
         f/M+qsbfSexdWm2MmLjAAZoksH8gh+Dil+3N+oJi5GxdjHCcTPDQtL583ie3hmiEhDcn
         pY827K/s5UWi4hlhgVR1p+dJ6q4jM05amZ97tVj5490YWN33kTRxjDrybkDKD329j5lC
         DsWripPSWIjWfytFza7Z1uiwn8Ui7KyaGv2tFmkfwEFeaPm13+RC5O4K/MsitPZw6dwP
         QvjA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXzni29DWuh4zfpWBTlaHzt3yYVw7sDQjHBo9jNg31sfjZGZ+as
	gqPDA9gIo9EtgTDdpeV9lt9wCSw7D6jSfnRBYo7ojQrZzQLdUNYkvzK2biz9Ihw9nNAg9vtx1dY
	Ir5DlMBSPi+lJrc86hyt4wSJOLykqmMrQO698lQVlYM5FrsspBM4eoRjdcGtr6aI=
X-Received: by 2002:a50:8bbd:: with SMTP id m58mr28601632edm.42.1556287723955;
        Fri, 26 Apr 2019 07:08:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/wdPxgcl0QvJgAniQchu7mr2+0NrcwD5p6F6tMWsLiROYWje9tTlc+tQoAU6q71EjmjXU
X-Received: by 2002:a50:8bbd:: with SMTP id m58mr28601562edm.42.1556287722905;
        Fri, 26 Apr 2019 07:08:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556287722; cv=none;
        d=google.com; s=arc-20160816;
        b=Zw7/8tV/3c/HYjJCZZTAMKAj9CnV4MPNxL2Z3icW1YrlKHmoNjeXxPE8gXvJm2znSM
         /DJZhZdEtTpgT5ZXr0Sx2LUm5jHjwEihF/wOPgR8N7ni4Tfky73Zi0i2FU98EVChabHj
         5sA7waoXienCs56PxuvJ7U8iRhgri0BXfxPSr8yL5h695wosGOMydYo61YmbjArodot3
         rQw0lFQpT0xUAiQTYGbujQnTdnByKr/57fI7PFVZGRLNhoehT2mnI531BARrNSaXFcZ2
         6T/NOp4QuFKU46A9EuaUHh1ZIndtKAdEpXfF4Lt0B+wtdD3F2SmsozwIORsFTBD5nThq
         s5Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Gl4pDgsoTjXGZqZThKkrLaFex7Lx0Ph2eAdPNhjxdlM=;
        b=XrMofL3lgrggTKmmFphSYgBP6HbZGRkSEEH/++EM7euntlOoIqsw8DdnliwcNQhL9f
         luYA79/Yub/KMAPxGNZSAhuOLujn88cygmFrgai8itHyLMv0RwTSAANRpHQ6We8pYmOZ
         7rMSr0fCUyKkeFhRvETZ2fHlXuskNzP2C/EUUV/aPG6X3S1vtWXSy5DcGViwP3jVdXnZ
         GOKtfQ7aS0H1Pu3ASjd7ErQ14na2q6VYFWD3t/dZrkDvrxzNM+LYVet5+dOLB85uvIWa
         BpNztrWzveZkwwGBwVi7EfakjKGxSzTeu8D1SSSXQbO3ptPbqbehGLfpUHuExy8Y6VSF
         hnSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si9686257ejh.79.2019.04.26.07.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 07:08:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 725D0AFFB;
	Fri, 26 Apr 2019 14:08:42 +0000 (UTC)
Date: Fri, 26 Apr 2019 16:08:41 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jann Horn <jannh@google.com>
Cc: Matthew Garrett <matthewgarrett@google.com>,
	Linux-MM <linux-mm@kvack.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	Matthew Garrett <mjg59@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <20190426140841.GK22245@dhcp22.suse.cz>
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com>
 <20190425121410.GC1144@dhcp22.suse.cz>
 <CAG48ez0x6QiFpqXbimB9ZV-jS5UJJWhzg9XiAWncQL+phfKkPA@mail.gmail.com>
 <20190426053135.GC12337@dhcp22.suse.cz>
 <CAG48ez1MGyAd5tE=JLmjkFqou-VvsQHcJ5TU5f8_L43km9eoYA@mail.gmail.com>
 <20190426134722.GH22245@dhcp22.suse.cz>
 <CAG48ez1OS7DeeEtv5jhO6wtMA2M2A_Bp3-ndS+sP=UoFuMiREw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez1OS7DeeEtv5jhO6wtMA2M2A_Bp3-ndS+sP=UoFuMiREw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-04-19 16:03:26, Jann Horn wrote:
> On Fri, Apr 26, 2019 at 3:47 PM Michal Hocko <mhocko@kernel.org> wrote:
> > On Fri 26-04-19 15:33:25, Jann Horn wrote:
> > > On Fri, Apr 26, 2019 at 7:31 AM Michal Hocko <mhocko@kernel.org> wrote:
> > > > On Thu 25-04-19 14:42:52, Jann Horn wrote:
> > > > > On Thu, Apr 25, 2019 at 2:14 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > > [...]
> > > > > > On Wed 24-04-19 14:10:39, Matthew Garrett wrote:
> > > > > > > From: Matthew Garrett <mjg59@google.com>
> > > > > > >
> > > > > > > Applications that hold secrets and wish to avoid them leaking can use
> > > > > > > mlock() to prevent the page from being pushed out to swap and
> > > > > > > MADV_DONTDUMP to prevent it from being included in core dumps. Applications
> > > > > > > can also use atexit() handlers to overwrite secrets on application exit.
> > > > > > > However, if an attacker can reboot the system into another OS, they can
> > > > > > > dump the contents of RAM and extract secrets. We can avoid this by setting
> > > > > > > CONFIG_RESET_ATTACK_MITIGATION on UEFI systems in order to request that the
> > > > > > > firmware wipe the contents of RAM before booting another OS, but this means
> > > > > > > rebooting takes a *long* time - the expected behaviour is for a clean
> > > > > > > shutdown to remove the request after scrubbing secrets from RAM in order to
> > > > > > > avoid this.
> > > > > > >
> > > > > > > Unfortunately, if an application exits uncleanly, its secrets may still be
> > > > > > > present in RAM. This can't be easily fixed in userland (eg, if the OOM
> > > > > > > killer decides to kill a process holding secrets, we're not going to be able
> > > > > > > to avoid that), so this patch adds a new flag to madvise() to allow userland
> > > > > > > to request that the kernel clear the covered pages whenever the page
> > > > > > > reference count hits zero. Since vm_flags is already full on 32-bit, it
> > > > > > > will only work on 64-bit systems.
> > > > > [...]
> > > > > > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > > > > > index 21a7881a2db4..989c2fde15cf 100644
> > > > > > > --- a/mm/madvise.c
> > > > > > > +++ b/mm/madvise.c
> > > > > > > @@ -92,6 +92,22 @@ static long madvise_behavior(struct vm_area_struct *vma,
> > > > > > >       case MADV_KEEPONFORK:
> > > > > > >               new_flags &= ~VM_WIPEONFORK;
> > > > > > >               break;
> > > > > > > +     case MADV_WIPEONRELEASE:
> > > > > > > +             /* MADV_WIPEONRELEASE is only supported on anonymous memory. */
> > > > > > > +             if (VM_WIPEONRELEASE == 0 || vma->vm_file ||
> > > > > > > +                 vma->vm_flags & VM_SHARED) {
> > > > > > > +                     error = -EINVAL;
> > > > > > > +                     goto out;
> > > > > > > +             }
> > > > > > > +             new_flags |= VM_WIPEONRELEASE;
> > > > > > > +             break;
> > > > >
> > > > > An interesting effect of this is that it will be possible to set this
> > > > > on a CoW anon VMA in a fork() child, and then the semantics in the
> > > > > parent will be subtly different - e.g. if the parent vmsplice()d a
> > > > > CoWed page into a pipe, then forked an unprivileged child, the child
> > > >
> > > > Maybe a stupid question. How do you fork an unprivileged child (without
> > > > exec)? Child would have to drop priviledges on its own, no?
> > >
> > > Sorry, yes, that's what I meant.
> >
> > But then the VMA is gone along with the flag so why does it matter?
> 
> But in theory, the page might still be used somewhere, e.g. as data in
> a pipe (into which the parent wrote it) or whatever. Parent
> vmsplice()s a page into a pipe, parent exits, child marks the VMA as
> WIPEONRELEASE and exits, page gets wiped, someone else reads the page
> from the pipe.
> 
> Yes, this is very theoretical, and you'd have to write some pretty
> weird software for this to matter. But it doesn't seem clean to me to
> allow a child to affect the data in e.g. a pipe that it isn't supposed
> to have access to like this.
> 
> Then again, this could probably already happen, since do_wp_page()
> reuses pages depending on only the mapcount, without looking at the
> refcount.

OK, now I see your point. I was confused about the unprivileged child.
You are right that this looks weird but we have traditionally trusted
child processes to not do a harm. I guess this falls down to the same
bucket. An early CoW on these mapping should solve the problem AFAICS.

-- 
Michal Hocko
SUSE Labs

