Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67447C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:31:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27D862084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:31:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27D862084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0FD26B026D; Fri, 26 Apr 2019 01:31:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 997856B026E; Fri, 26 Apr 2019 01:31:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8391F6B026F; Fri, 26 Apr 2019 01:31:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2ECC96B026D
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:31:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f42so930035edd.0
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:31:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pLokakutnZIuZ75LtbduiMmabFTZGNAssEYKu5vYyto=;
        b=uHovSvcc2yib8m1zA73U/uj154BINITEq1mtp7iUvZzPX5GmGNWyW8fdV6oRsmsarq
         AsJHuEwH1imk8z3BREjj44JZLOfHkh5y9Z+vbkdqa2JcRam7+ZXnb49DdPQ1NIkfJAfO
         q/XK8SO9IOyaPdDrVcXHuEVrelC6/0OrFcFHKMp4oS6wKnDyWiG9SuKPp1cIVrCRPfVp
         dekpQtX5lVgBsDAtvmS4nxZYU5gW17IhuYb0XDG6g9m6ogUOpcD0VyK+Z1Kvkcz6DlnH
         2Gs9nfZX4zcVOvD+IwoyTGXqPKGiVW4TNKMLncP0JO5BKH62KDyl4i+d3KbhHNVrPgmT
         HH0Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWtS5RdtHq0oaYVB4OEm4FFtglGI6pT+j/yVARZ57BRQeKnybo9
	cCZl146/NQUseYmRrjE8ZKEvLt/wqCBHn+15E5EtRApCU4f79lvzw6yEHh3qUtf/V7+p1xg03bb
	dI44TuVZovKgwb4hfxISbDPJSydvyhV2yrDk0KFNgzLPS7vL2AnlCj00x7ReoVcE=
X-Received: by 2002:a50:b119:: with SMTP id k25mr27435526edd.240.1556256697714;
        Thu, 25 Apr 2019 22:31:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYAaBa47jKpUIum32VEOpzhyii6M9vdJRDAfnG/saoFUcqtjb7qDAC09Xi6e4bbcAUD8ZQ
X-Received: by 2002:a50:b119:: with SMTP id k25mr27435486edd.240.1556256696829;
        Thu, 25 Apr 2019 22:31:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556256696; cv=none;
        d=google.com; s=arc-20160816;
        b=G7RrOvvCMXBuQZFv5um/GKhYn1Zmmc/QzuS9NaWgmFUWy1XVqLn4Pq1t+T/T/bJNqg
         Ka5a5D2VicJcdly2uUEL+knAb/C8UKWYiVjeeYCOSChVEL3MFMEc1Kjrs58+VPecuKIM
         xS2yoTqhix8NpMUmhqpqXgwpziPKnN6YeAUDJTpX3CtCVSqgjFeuiZLKuTKz+2NL5PTG
         92ACDjbbQo91zAwP4+VD/wC54WWoW1vWIJIPMorxjzGUNW/mUdcTCxvt+rc2vM87mkrO
         ZsrA7ejyWB07tdL/86go8vbcscPwsmogSojpBfzlAqAb16DC1pNF9ft8YadaScWJJeWr
         lTrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pLokakutnZIuZ75LtbduiMmabFTZGNAssEYKu5vYyto=;
        b=0d+jPyRM3iKegYXYiap6MgRUMTaakN1+xZ6J6uY+YQTO2kzbrJ2dnC7YpKGnNYiUx1
         BMlx+Nq3s2Av3D+te5j00ajqVt2876rgjSsQ5/N+2daWiPAe8ShmJu2jogmOyOlhMohc
         eVtS7BDwYfvAt7cJcEm8xXudz3rkaxe0FoX7s63J4FtkxRTOoyG16IWIc5WHd1HpVRpb
         FfcUyiovqkdH/A3qCYRJd7moXhy/3N1V1CjTjQBtVVszvl53tNah99I+aQ+aVbOZLrRm
         Yvr1k//i90MvVoIO6chRbDwlXslvylNoG9NZhCuQfHH9bZHSuXEnX0HkWJEmQI9cGSg0
         kjRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m17si1824730ejs.241.2019.04.25.22.31.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 22:31:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DF8F9AD64;
	Fri, 26 Apr 2019 05:31:35 +0000 (UTC)
Date: Fri, 26 Apr 2019 07:31:35 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jann Horn <jannh@google.com>
Cc: Matthew Garrett <matthewgarrett@google.com>,
	Linux-MM <linux-mm@kvack.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	Matthew Garrett <mjg59@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <20190426053135.GC12337@dhcp22.suse.cz>
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com>
 <20190425121410.GC1144@dhcp22.suse.cz>
 <CAG48ez0x6QiFpqXbimB9ZV-jS5UJJWhzg9XiAWncQL+phfKkPA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez0x6QiFpqXbimB9ZV-jS5UJJWhzg9XiAWncQL+phfKkPA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 14:42:52, Jann Horn wrote:
> On Thu, Apr 25, 2019 at 2:14 PM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > On Wed 24-04-19 14:10:39, Matthew Garrett wrote:
> > > From: Matthew Garrett <mjg59@google.com>
> > >
> > > Applications that hold secrets and wish to avoid them leaking can use
> > > mlock() to prevent the page from being pushed out to swap and
> > > MADV_DONTDUMP to prevent it from being included in core dumps. Applications
> > > can also use atexit() handlers to overwrite secrets on application exit.
> > > However, if an attacker can reboot the system into another OS, they can
> > > dump the contents of RAM and extract secrets. We can avoid this by setting
> > > CONFIG_RESET_ATTACK_MITIGATION on UEFI systems in order to request that the
> > > firmware wipe the contents of RAM before booting another OS, but this means
> > > rebooting takes a *long* time - the expected behaviour is for a clean
> > > shutdown to remove the request after scrubbing secrets from RAM in order to
> > > avoid this.
> > >
> > > Unfortunately, if an application exits uncleanly, its secrets may still be
> > > present in RAM. This can't be easily fixed in userland (eg, if the OOM
> > > killer decides to kill a process holding secrets, we're not going to be able
> > > to avoid that), so this patch adds a new flag to madvise() to allow userland
> > > to request that the kernel clear the covered pages whenever the page
> > > reference count hits zero. Since vm_flags is already full on 32-bit, it
> > > will only work on 64-bit systems.
> [...]
> > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > index 21a7881a2db4..989c2fde15cf 100644
> > > --- a/mm/madvise.c
> > > +++ b/mm/madvise.c
> > > @@ -92,6 +92,22 @@ static long madvise_behavior(struct vm_area_struct *vma,
> > >       case MADV_KEEPONFORK:
> > >               new_flags &= ~VM_WIPEONFORK;
> > >               break;
> > > +     case MADV_WIPEONRELEASE:
> > > +             /* MADV_WIPEONRELEASE is only supported on anonymous memory. */
> > > +             if (VM_WIPEONRELEASE == 0 || vma->vm_file ||
> > > +                 vma->vm_flags & VM_SHARED) {
> > > +                     error = -EINVAL;
> > > +                     goto out;
> > > +             }
> > > +             new_flags |= VM_WIPEONRELEASE;
> > > +             break;
> 
> An interesting effect of this is that it will be possible to set this
> on a CoW anon VMA in a fork() child, and then the semantics in the
> parent will be subtly different - e.g. if the parent vmsplice()d a
> CoWed page into a pipe, then forked an unprivileged child, the child

Maybe a stupid question. How do you fork an unprivileged child (without
exec)? Child would have to drop priviledges on its own, no?

> set MADV_WIPEONRELEASE on its VMA, the parent died somehow, and then
> the child died, the page in the pipe would be zeroed out. A child
> should not be able to affect its parent like this, I think. If this
> was an mmap() flag instead of a madvise() command, that issue could be
> avoided.

With a VMA flag underneath, I think you can do an early CoW during fork
to prevent from that.

> Alternatively, if adding more mmap() flags doesn't work,
> perhaps you could scan the VMA and ensure that it contains no pages
> yet, or something like that?
> 
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index ab650c21bccd..ff78b527660e 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -1091,6 +1091,9 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
> > >                       page_remove_rmap(page, false);
> > >                       if (unlikely(page_mapcount(page) < 0))
> > >                               print_bad_pte(vma, addr, ptent, page);
> > > +                     if (unlikely(vma->vm_flags & VM_WIPEONRELEASE) &&
> > > +                         page_mapcount(page) == 0)
> > > +                             clear_highpage(page);
> > >                       if (unlikely(__tlb_remove_page(tlb, page))) {
> > >                               force_flush = 1;
> > >                               addr += PAGE_SIZE;
> 
> Should something like this perhaps be added in page_remove_rmap()
> instead? That's where the mapcount is decremented; and looking at
> other callers of page_remove_rmap(), in particular the following ones
> look interesting:

Well spotted!

-- 
Michal Hocko
SUSE Labs

