Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9356DC43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:47:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39B372089E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 13:47:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39B372089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7ED56B0003; Fri, 26 Apr 2019 09:47:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2DB86B0005; Fri, 26 Apr 2019 09:47:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1C7A6B0006; Fri, 26 Apr 2019 09:47:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53D6E6B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:47:25 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 18so1570377eds.5
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 06:47:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JyVElu9d2UcuoITDXuegqggYW/29ppMUjVxkFJnZrEo=;
        b=BlB5XGrTQxUMeRaq4gTx3yb9Yl4+AvXetRdOmZ8V8UcMub1o3LFX/MLQ+uUPRXVPCG
         xW5893aua8d8+7SPLQo1VVcfYWqOpwfUauMdkj/FW3PuqMiOM6wLe6V4LVaUkvqWcXv+
         dUoOeTNBhCdOQCntBH3ClfpYhmjDK7eJ3md0xlRn/MyHTPTUFuKIPBiu3iXwghOteH6j
         T731wIWYWaHintOcncQBPAdrO7ZGt9b1M3hC+aG8xneh2DeDJIWQA7JoiyI0rO8pJElN
         lBO9b7DWhCyHIFc+pUgRYwhVnlciLdcYZB6bJv9QS9qwlFTlnwW93IwnP2DoOkzJMG8B
         D4yw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUcJoiGNhgsK8Ge1gZGv9d/xrOsWzacEo3Q2ryJRFPMTnxC/7B8
	EKKQH2jccV13IQ9tq5PXXASnm9lCXJcKUUQW0wpPWbqXdAAmZL1TvKep2BDpIaMxDyraX6I7qD3
	XmNtdDv9lCkIgvEIhcYXmr9tE/tmYlQnC+VWtL0W37mNSHyiaTinqJcCyPGVxWic=
X-Received: by 2002:a50:b78a:: with SMTP id h10mr28708794ede.65.1556286444863;
        Fri, 26 Apr 2019 06:47:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7bx08lYpYlbojxTKhWcCupUe81s9KEQ2+trLn8x9dTpdiv3pK+zCfw5H/8JR9VkmtfN+6
X-Received: by 2002:a50:b78a:: with SMTP id h10mr28708752ede.65.1556286443946;
        Fri, 26 Apr 2019 06:47:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556286443; cv=none;
        d=google.com; s=arc-20160816;
        b=Alo4B/5clQ64QnX0YqIQgr8Cb1Nuswoo4FK+DFXJ/4TKSqjDax9rsSv08BXVRKfxik
         cgMG0TluswuKT1zJHHjQvEJWVp2VyGOIhKJtK3JCxU35NLFYbIjYgXVVj1WebwOocqAj
         EyKSYWpa8+QmgFMInKj2puPxSs6/3r5w/tDGC+Wga7G/GF2nrgsrsz5wzt7gfMJX7lvO
         /WbU+UiQaZCX38lZfofIONFyI+3awEBo6elo2VNHjPuv8InlVbahlo0EBJMy+Ire3kdG
         lwVlD6loSGDdYdx181aG+XdebFxMbSVTUpy7/w+O8NfMyBTjGCTN5fd86vABusH5tPVT
         eErw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JyVElu9d2UcuoITDXuegqggYW/29ppMUjVxkFJnZrEo=;
        b=N4NnCs4EQ91cVpL+9bplYjsIAK9foJw4dijDdSRxPb5QKh4LZeRN135dJaXcEKB+ii
         LcQNPr/5DXsuOjW5Dbq3A+koT+/XlUSk9PcQjj4FF2O0mlymCgWApxysKjFl2F9pIvXS
         soHNaQaCm4hicAo686ScMISPHeigSMayPGfdbd6w5VB7kXNiufJDpbYHkNF/DmQoM5VG
         FCBpmmT5CDY6P7ZITccFJnxrSt2vXInOnzUFQJC/dYLIf57nIdd1q/683s7LaZYHmmNE
         U708pH21EvNV4sgVpuEk9wuERjzcrVD6829rL9u9mPXlg9546pu9WuwQ6dWuPPzsMjB8
         GHuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jr18si2211786ejb.22.2019.04.26.06.47.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 06:47:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EB0DDAFBF;
	Fri, 26 Apr 2019 13:47:22 +0000 (UTC)
Date: Fri, 26 Apr 2019 15:47:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Jann Horn <jannh@google.com>
Cc: Matthew Garrett <matthewgarrett@google.com>,
	Linux-MM <linux-mm@kvack.org>,
	kernel list <linux-kernel@vger.kernel.org>,
	Matthew Garrett <mjg59@google.com>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <20190426134722.GH22245@dhcp22.suse.cz>
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com>
 <20190425121410.GC1144@dhcp22.suse.cz>
 <CAG48ez0x6QiFpqXbimB9ZV-jS5UJJWhzg9XiAWncQL+phfKkPA@mail.gmail.com>
 <20190426053135.GC12337@dhcp22.suse.cz>
 <CAG48ez1MGyAd5tE=JLmjkFqou-VvsQHcJ5TU5f8_L43km9eoYA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez1MGyAd5tE=JLmjkFqou-VvsQHcJ5TU5f8_L43km9eoYA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 26-04-19 15:33:25, Jann Horn wrote:
> On Fri, Apr 26, 2019 at 7:31 AM Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 25-04-19 14:42:52, Jann Horn wrote:
> > > On Thu, Apr 25, 2019 at 2:14 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > [...]
> > > > On Wed 24-04-19 14:10:39, Matthew Garrett wrote:
> > > > > From: Matthew Garrett <mjg59@google.com>
> > > > >
> > > > > Applications that hold secrets and wish to avoid them leaking can use
> > > > > mlock() to prevent the page from being pushed out to swap and
> > > > > MADV_DONTDUMP to prevent it from being included in core dumps. Applications
> > > > > can also use atexit() handlers to overwrite secrets on application exit.
> > > > > However, if an attacker can reboot the system into another OS, they can
> > > > > dump the contents of RAM and extract secrets. We can avoid this by setting
> > > > > CONFIG_RESET_ATTACK_MITIGATION on UEFI systems in order to request that the
> > > > > firmware wipe the contents of RAM before booting another OS, but this means
> > > > > rebooting takes a *long* time - the expected behaviour is for a clean
> > > > > shutdown to remove the request after scrubbing secrets from RAM in order to
> > > > > avoid this.
> > > > >
> > > > > Unfortunately, if an application exits uncleanly, its secrets may still be
> > > > > present in RAM. This can't be easily fixed in userland (eg, if the OOM
> > > > > killer decides to kill a process holding secrets, we're not going to be able
> > > > > to avoid that), so this patch adds a new flag to madvise() to allow userland
> > > > > to request that the kernel clear the covered pages whenever the page
> > > > > reference count hits zero. Since vm_flags is already full on 32-bit, it
> > > > > will only work on 64-bit systems.
> > > [...]
> > > > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > > > index 21a7881a2db4..989c2fde15cf 100644
> > > > > --- a/mm/madvise.c
> > > > > +++ b/mm/madvise.c
> > > > > @@ -92,6 +92,22 @@ static long madvise_behavior(struct vm_area_struct *vma,
> > > > >       case MADV_KEEPONFORK:
> > > > >               new_flags &= ~VM_WIPEONFORK;
> > > > >               break;
> > > > > +     case MADV_WIPEONRELEASE:
> > > > > +             /* MADV_WIPEONRELEASE is only supported on anonymous memory. */
> > > > > +             if (VM_WIPEONRELEASE == 0 || vma->vm_file ||
> > > > > +                 vma->vm_flags & VM_SHARED) {
> > > > > +                     error = -EINVAL;
> > > > > +                     goto out;
> > > > > +             }
> > > > > +             new_flags |= VM_WIPEONRELEASE;
> > > > > +             break;
> > >
> > > An interesting effect of this is that it will be possible to set this
> > > on a CoW anon VMA in a fork() child, and then the semantics in the
> > > parent will be subtly different - e.g. if the parent vmsplice()d a
> > > CoWed page into a pipe, then forked an unprivileged child, the child
> >
> > Maybe a stupid question. How do you fork an unprivileged child (without
> > exec)? Child would have to drop priviledges on its own, no?
> 
> Sorry, yes, that's what I meant.

But then the VMA is gone along with the flag so why does it matter?

-- 
Michal Hocko
SUSE Labs

