Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3598C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:43:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 789D920679
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:43:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YTEL7lcX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 789D920679
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 587E26B0003; Thu, 25 Apr 2019 08:43:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53A866B0010; Thu, 25 Apr 2019 08:43:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 428B66B0266; Thu, 25 Apr 2019 08:43:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1589B6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:43:21 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id q15so12431297otl.8
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bXgqURV3byj3cYEdSZNf6ZaP2flQvEPyxHp20vNGNFo=;
        b=LFWJO4xZ8CLb6auv3kaUqB0N5jYbLkn2GYf3uZaGefbp+Kmq+rfWnxmfQVBnEWZVyo
         J7qKDHKH//1zz6KfX9aNnz1ZVEmfjKNP4bv20+XDXW/0AmbSZlhp53Az+cXxspT+lsIw
         thw/FPrDKSnau3/0mmrjSuOrvanjmANWT7rj7j+YplyW7LgMOh53OS1LMc940yD9VxO4
         PD8WPUogPU07KalUlthS5pQ8kR9tYo2WYVDUPoBzlWAR/Zln+gG9jb+Je0vSreujbNoV
         YDUpJbyMjtYZGOqj8jdLFTBAOwO8N8bqPHjdd+vILuHUlF2krbCu5G/UfLDvAr2aH//o
         lfHA==
X-Gm-Message-State: APjAAAUWrhYHYmz1ZeQ+2Wt4w1dnjaK9hxr5DdG3Lq36Ijy6qO0H8qFo
	bPjDCGYwMIr7ly46T2m5o6WnQVRzjuPLgm08rB3ZuARbshmkNEX0fVtRbEn2IqAl3ORgJELyYSC
	j+YC+qAzYmRt70J2zl7vfGYOy5yz3YqdmMLMvWrDEJqvML6WnwHn33Yn55kAnDQDsHw==
X-Received: by 2002:aca:5f88:: with SMTP id t130mr3176839oib.19.1556196200547;
        Thu, 25 Apr 2019 05:43:20 -0700 (PDT)
X-Received: by 2002:aca:5f88:: with SMTP id t130mr3176802oib.19.1556196199815;
        Thu, 25 Apr 2019 05:43:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556196199; cv=none;
        d=google.com; s=arc-20160816;
        b=FGUCDUMwe3KhiJudp9oFYiSVm8zIwsWvsh2ucw2GmDiNIIxSRjg3RGIOuqvahyMUQn
         cyzQtb95lHSLzM262qKTAYjOKh6Rpc/s4KHjMJ5y4fgDVPbC7VepPY5RXN3+WEfS3UHp
         2uovZ8Tl46gewgWva9cxNqSiLbDuVIdkal9rl1swlJNrdADTHc1mzyV/WBjnVilA1xIj
         j8lMixIHvfS0+2/QWzUYmctrIyZeDvGGizA65FvTT/4COAfKctg5bnxBb8U7QLsJjKYv
         o5SLJDX0RXaeJYXv/7dHS1ojC/lvEVJxieyJj3H6/B6+NiD2CNxKFXQgFJPJUba+Dj3r
         I5vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bXgqURV3byj3cYEdSZNf6ZaP2flQvEPyxHp20vNGNFo=;
        b=v46csomnHZnsxfJacZ+++WIiwphcdzF1WY27vTH80pQeqdcr0Tk7NtoWt+D2vebVqs
         HcuivRVD5el9diGGMMXvHxfxV6ovuZx2bjSXwR1n4OQ8+87OCPgJM3R8doTE+OUUsDv3
         mGvGPREvdLOmLjJ+ccnxxHO8SomHmuzf0jmfbyIJiIl6V3Qfdqj2R1k8K6vCdO3sHODa
         sSyz94vEEESnv3ySGgLFgLgm07GLBY7dRtxbNpOxwxNZx+sKv9KHiDZN+Fa5jQMYtHGn
         sMOqSOk7RKZwsQtlPvt9g7CX5LI1txYk+wlYuqCT+WQeDunTaE4kOrJR/NHO3Fkv0dGY
         AfGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YTEL7lcX;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z31sor2690027otb.44.2019.04.25.05.43.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 05:43:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YTEL7lcX;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bXgqURV3byj3cYEdSZNf6ZaP2flQvEPyxHp20vNGNFo=;
        b=YTEL7lcX1b8/OtmLyct2lZre+5wMQQQI6B1dICt0ZW3Kbaog1YmCeYwf1gHyOlV5bS
         XE1yVqlxhZtqALK+Iyh7u1l9XffWkEhM0+3V4f70zgstTgIs68CD9plXvmJZ9pi8KVye
         XVT5GEAJzA+JuSKdM27WhrsKU3oVwTkLxojaRASvPzPCBbFi1zbxWnUoBvGfH0CuFaAN
         TR+Br9nLRVfE8BMbyl4lgA63ehL7UJdFHGAc9yCz4QaGA7VkkpfwDMcHhnsFJdReAWFU
         rjZ/nzOt3YV3EzXQYl9I3BFPpbCCwg0RaklU16hKCngkz42TCwNlfSyU4ecbMd/WCjCd
         aAbg==
X-Google-Smtp-Source: APXvYqyO4UUmMXYBm7UvTINmNgFQslxkKkbn/GniIAn3Jb72SxdCwuR5c637iFcVfaQIFg0OUac6aBiPdhsliABJzGE=
X-Received: by 2002:a9d:7095:: with SMTP id l21mr24116770otj.35.1556196198973;
 Thu, 25 Apr 2019 05:43:18 -0700 (PDT)
MIME-Version: 1.0
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com> <20190425121410.GC1144@dhcp22.suse.cz>
In-Reply-To: <20190425121410.GC1144@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Thu, 25 Apr 2019 14:42:52 +0200
Message-ID: <CAG48ez0x6QiFpqXbimB9ZV-jS5UJJWhzg9XiAWncQL+phfKkPA@mail.gmail.com>
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

On Thu, Apr 25, 2019 at 2:14 PM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> On Wed 24-04-19 14:10:39, Matthew Garrett wrote:
> > From: Matthew Garrett <mjg59@google.com>
> >
> > Applications that hold secrets and wish to avoid them leaking can use
> > mlock() to prevent the page from being pushed out to swap and
> > MADV_DONTDUMP to prevent it from being included in core dumps. Applications
> > can also use atexit() handlers to overwrite secrets on application exit.
> > However, if an attacker can reboot the system into another OS, they can
> > dump the contents of RAM and extract secrets. We can avoid this by setting
> > CONFIG_RESET_ATTACK_MITIGATION on UEFI systems in order to request that the
> > firmware wipe the contents of RAM before booting another OS, but this means
> > rebooting takes a *long* time - the expected behaviour is for a clean
> > shutdown to remove the request after scrubbing secrets from RAM in order to
> > avoid this.
> >
> > Unfortunately, if an application exits uncleanly, its secrets may still be
> > present in RAM. This can't be easily fixed in userland (eg, if the OOM
> > killer decides to kill a process holding secrets, we're not going to be able
> > to avoid that), so this patch adds a new flag to madvise() to allow userland
> > to request that the kernel clear the covered pages whenever the page
> > reference count hits zero. Since vm_flags is already full on 32-bit, it
> > will only work on 64-bit systems.
[...]
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 21a7881a2db4..989c2fde15cf 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -92,6 +92,22 @@ static long madvise_behavior(struct vm_area_struct *vma,
> >       case MADV_KEEPONFORK:
> >               new_flags &= ~VM_WIPEONFORK;
> >               break;
> > +     case MADV_WIPEONRELEASE:
> > +             /* MADV_WIPEONRELEASE is only supported on anonymous memory. */
> > +             if (VM_WIPEONRELEASE == 0 || vma->vm_file ||
> > +                 vma->vm_flags & VM_SHARED) {
> > +                     error = -EINVAL;
> > +                     goto out;
> > +             }
> > +             new_flags |= VM_WIPEONRELEASE;
> > +             break;

An interesting effect of this is that it will be possible to set this
on a CoW anon VMA in a fork() child, and then the semantics in the
parent will be subtly different - e.g. if the parent vmsplice()d a
CoWed page into a pipe, then forked an unprivileged child, the child
set MADV_WIPEONRELEASE on its VMA, the parent died somehow, and then
the child died, the page in the pipe would be zeroed out. A child
should not be able to affect its parent like this, I think. If this
was an mmap() flag instead of a madvise() command, that issue could be
avoided. Alternatively, if adding more mmap() flags doesn't work,
perhaps you could scan the VMA and ensure that it contains no pages
yet, or something like that?

> > diff --git a/mm/memory.c b/mm/memory.c
> > index ab650c21bccd..ff78b527660e 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -1091,6 +1091,9 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
> >                       page_remove_rmap(page, false);
> >                       if (unlikely(page_mapcount(page) < 0))
> >                               print_bad_pte(vma, addr, ptent, page);
> > +                     if (unlikely(vma->vm_flags & VM_WIPEONRELEASE) &&
> > +                         page_mapcount(page) == 0)
> > +                             clear_highpage(page);
> >                       if (unlikely(__tlb_remove_page(tlb, page))) {
> >                               force_flush = 1;
> >                               addr += PAGE_SIZE;

Should something like this perhaps be added in page_remove_rmap()
instead? That's where the mapcount is decremented; and looking at
other callers of page_remove_rmap(), in particular the following ones
look interesting:

 - do_huge_pmd_wp_page()/do_huge_pmd_wp_page_fallback() might be
relevant in the case where a forking process contains transparent
hugepages?
 - zap_huge_pmd() is relevant when transparent hugepages are used, I
think (otherwise transparent hugepages might not be wiped?)
 - there are various callers related to migration; I think this is
relevant on a NUMA system where memory is moved between nodes to
improve locality (moving memory to a new page and freeing the old one,
in which case you'd want to wipe the old page)

I think all the callers have a reference to the VMA, so perhaps you
could add a VMA parameter to page_remove_rmap() and then look at the
VMA in there?

