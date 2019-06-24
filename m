Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8F7CC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:22:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 574FC208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:22:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="km7JeQ3v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 574FC208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA40F8E0003; Mon, 24 Jun 2019 10:22:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2F2E8E0002; Mon, 24 Jun 2019 10:22:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA8848E0003; Mon, 24 Jun 2019 10:22:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 805488E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:22:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id b10so9454679pgb.22
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:22:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gAszyd6Rkh0AyBVnY2MGQeafDGFV/B/Xjwc7nOHGBTU=;
        b=aN6oux/rvoK/h5xRNsny38l3QAPSaZ2M9hKPFqyRO3e42kfOWYY3DAJo+psdFWLsjX
         HBzXHWA+wa9pyl1f0vPskEly68idAsizfMbYoE+HJm2zcmKsUFkkMLdQOxNlP7hPGoq3
         veELuX6FtEFAySQyPRUcucG9cTgv2EX7npJLAcl7FKqmwHxnrPH7UTcYBGBPjzh4YmKE
         1YqnvT8a+pRdL7OWkB9SAWhebrHTOISV2NxXykOmWWXturnPx0khIXmsG0aqP/E69/1g
         NMTxxflUaSdyaOtAb1sKlTcHi4gtzVo29ASU/qMFtbnXeKJ5A/wczKPDDdfYGrqrXI/G
         ADFQ==
X-Gm-Message-State: APjAAAUN9xvxlTJ5eHKLBGoq7VUenwqL0zb7Ba28BHfM0XR0PsJrLusp
	r+7/t5ixNfAKw+iIWFVqvik8RylI+QDaXs6C+QfAJ5396uCAnIhO9nrTJlHKyrWBjLUupGJBS6j
	QaSbNxGwa3J7OabhUA9F+MgfP/nSZx+mtNk2QzYSwQbrz6uBTyg+njeU7EXykYghqXw==
X-Received: by 2002:a63:f146:: with SMTP id o6mr32453017pgk.179.1561386166926;
        Mon, 24 Jun 2019 07:22:46 -0700 (PDT)
X-Received: by 2002:a63:f146:: with SMTP id o6mr32452966pgk.179.1561386166011;
        Mon, 24 Jun 2019 07:22:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386166; cv=none;
        d=google.com; s=arc-20160816;
        b=SV3fM7/W1VIDn89J2fvOsjv2pl2LgSREJELHcjrKhWfi7UMSXyCnxFOFMIDpTpNjKp
         v2juCUe6fFlAXMK8C2g1fJl21IbCtMlePdBIwy3WZfx85Ep9pVzoDMWAxcDno/PkhJl5
         H/CUFPafuhk9j5vb+NP9+mkVZjly8oHVrcR/Ge/UqLwKm9yAxm/6L26+ubNEe11FhQNg
         /D+xTTTNfLWisyko5nTdDcgEJzXikfdq4gx1rv05Zd6Dx9rkiWESEKRQ8fJrpJIsYUBt
         Cxgk35OCon4NLv9oUkLr4iiZHY5lnqjI6TMOqDUKEWNcYYY40MIWdHLAfu7fRohWiKQp
         G03Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gAszyd6Rkh0AyBVnY2MGQeafDGFV/B/Xjwc7nOHGBTU=;
        b=YRkpK5wGsadSYflLaS3AwXaNXmX2tOIZWCKV+EIMEBxsU2k7mkdB5s/ixyRoN1TaGZ
         Y/Sz9Cgdp2h9Ba2UP/3uu4FsJBIVPLs1YRGohxRkyyUTrI05/kgHNJoFkva035bFSppj
         mLBHW60ndHtpaA6mMWnzyat7bSqVN7+uRrorJQ6PVdHYp7hTtUgLAzORo7OeAAOajd5M
         iadaQT1e8F0S9VJlV8+1tcRXRT4VuU8Mz/XJEzIX5MJPDLjQcfUbSwKVAPB+dRrgV0bq
         vjBJ/LzuvA/haHrrA5yMu9Dvs56/Y5fsjaoUbg+j4jRAxgq0Dr+/kFPxK/dknrTw+JFu
         N38A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=km7JeQ3v;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a8sor12978001ple.44.2019.06.24.07.22.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:22:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=km7JeQ3v;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gAszyd6Rkh0AyBVnY2MGQeafDGFV/B/Xjwc7nOHGBTU=;
        b=km7JeQ3vyTD2UtwSHCAAp4q4at1sY/ltJPO5wzrrkqMzNLeQZPjXSnOQ7VtkWA81dl
         HEFVLO9l5VlkdkocDhA+ezC7dKtBn4IeaF4UZLWnOmGq0Ok4r2E9GR7Hoa79HLNOGJVe
         0AHZ3EJWZEjcDwF6xOVW5nBJXR6vOtRMH7oBaouWSEKGFrWAIrbWb9kQA+Hlo7SIhUEB
         uGLPh5fQQfh1ibByxQrZM4UE+cDk+UJmRIBMFqrJwcIDdYtIIT+tU41CsIi86+tplFna
         0qMXAZhS5viMtSm5pwtZ6YrDben3dB8l27s4Hd+Xtz7mclZlxhwdWOJHEC5Ft/EzKQyl
         VZSQ==
X-Google-Smtp-Source: APXvYqx/7NbeFZuwI48tclTUh11xegUV5UsdKc2ldTOnN03zOVYnpDOwlkZEMuzBYRoM7kFvSzXnjLxRZwjrOwVDnPw=
X-Received: by 2002:a17:902:4183:: with SMTP id f3mr32179784pld.336.1561386165165;
 Mon, 24 Jun 2019 07:22:45 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com> <f9b50767d639b7116aa986dc67f158131b8d4169.1560339705.git.andreyknvl@google.com>
 <a5e0e465-89d5-91d0-c6a4-39674269bbf2@oracle.com> <c4bdd767-eb3f-6668-0f49-4aaf4bc7689d@oracle.com>
In-Reply-To: <c4bdd767-eb3f-6668-0f49-4aaf4bc7689d@oracle.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 24 Jun 2019 16:22:34 +0200
Message-ID: <CAAeHK+zceAZ0Mqhz3t6Ob71-Dgk4DNHRrzr72r+qEsUugwzTsg@mail.gmail.com>
Subject: Re: [PATCH v17 04/15] mm, arm64: untag user pointers passed to memory syscalls
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Felix Kuehling <Felix.Kuehling@amd.com>, 
	Alexander Deucher <Alexander.Deucher@amd.com>, Christian Koenig <Christian.Koenig@amd.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, Leon Romanovsky <leon@kernel.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 6:46 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> On 6/19/19 9:55 AM, Khalid Aziz wrote:
> > On 6/12/19 5:43 AM, Andrey Konovalov wrote:
> >> This patch is a part of a series that extends arm64 kernel ABI to allow to
> >> pass tagged user pointers (with the top byte set to something else other
> >> than 0x00) as syscall arguments.
> >>
> >> This patch allows tagged pointers to be passed to the following memory
> >> syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
> >> mremap, msync, munlock, move_pages.
> >>
> >> The mmap and mremap syscalls do not currently accept tagged addresses.
> >> Architectures may interpret the tag as a background colour for the
> >> corresponding vma.
> >>
> >> Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
> >> Reviewed-by: Kees Cook <keescook@chromium.org>
> >> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> >> ---
> >
> > Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> >
> >
>
> I would also recommend updating commit log for all the patches in this
> series that are changing files under mm/ as opposed to arch/arm64 to not
> reference arm64 kernel ABI since the change applies to every
> architecture. So something along the lines of "This patch is part of a
> series that extends kernel ABI to allow......."

Sure, will do in v18, thanks!

>
> --
> Khalid
>
>
> >>  mm/madvise.c   | 2 ++
> >>  mm/mempolicy.c | 3 +++
> >>  mm/migrate.c   | 2 +-
> >>  mm/mincore.c   | 2 ++
> >>  mm/mlock.c     | 4 ++++
> >>  mm/mprotect.c  | 2 ++
> >>  mm/mremap.c    | 7 +++++++
> >>  mm/msync.c     | 2 ++
> >>  8 files changed, 23 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/mm/madvise.c b/mm/madvise.c
> >> index 628022e674a7..39b82f8a698f 100644
> >> --- a/mm/madvise.c
> >> +++ b/mm/madvise.c
> >> @@ -810,6 +810,8 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
> >>      size_t len;
> >>      struct blk_plug plug;
> >>
> >> +    start = untagged_addr(start);
> >> +
> >>      if (!madvise_behavior_valid(behavior))
> >>              return error;
> >>
> >> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> >> index 01600d80ae01..78e0a88b2680 100644
> >> --- a/mm/mempolicy.c
> >> +++ b/mm/mempolicy.c
> >> @@ -1360,6 +1360,7 @@ static long kernel_mbind(unsigned long start, unsigned long len,
> >>      int err;
> >>      unsigned short mode_flags;
> >>
> >> +    start = untagged_addr(start);
> >>      mode_flags = mode & MPOL_MODE_FLAGS;
> >>      mode &= ~MPOL_MODE_FLAGS;
> >>      if (mode >= MPOL_MAX)
> >> @@ -1517,6 +1518,8 @@ static int kernel_get_mempolicy(int __user *policy,
> >>      int uninitialized_var(pval);
> >>      nodemask_t nodes;
> >>
> >> +    addr = untagged_addr(addr);
> >> +
> >>      if (nmask != NULL && maxnode < nr_node_ids)
> >>              return -EINVAL;
> >>
> >> diff --git a/mm/migrate.c b/mm/migrate.c
> >> index f2ecc2855a12..d22c45cf36b2 100644
> >> --- a/mm/migrate.c
> >> +++ b/mm/migrate.c
> >> @@ -1616,7 +1616,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
> >>                      goto out_flush;
> >>              if (get_user(node, nodes + i))
> >>                      goto out_flush;
> >> -            addr = (unsigned long)p;
> >> +            addr = (unsigned long)untagged_addr(p);
> >>
> >>              err = -ENODEV;
> >>              if (node < 0 || node >= MAX_NUMNODES)
> >> diff --git a/mm/mincore.c b/mm/mincore.c
> >> index c3f058bd0faf..64c322ed845c 100644
> >> --- a/mm/mincore.c
> >> +++ b/mm/mincore.c
> >> @@ -249,6 +249,8 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
> >>      unsigned long pages;
> >>      unsigned char *tmp;
> >>
> >> +    start = untagged_addr(start);
> >> +
> >>      /* Check the start address: needs to be page-aligned.. */
> >>      if (start & ~PAGE_MASK)
> >>              return -EINVAL;fixup_user_fault
> >> diff --git a/mm/mlock.c b/mm/mlock.c
> >> index 080f3b36415b..e82609eaa428 100644
> >> --- a/mm/mlock.c
> >> +++ b/mm/mlock.c
> >> @@ -674,6 +674,8 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
> >>      unsigned long lock_limit;
> >>      int error = -ENOMEM;
> >>
> >> +    start = untagged_addr(start);
> >> +
> >>      if (!can_do_mlock())
> >>              return -EPERM;
> >>
> >> @@ -735,6 +737,8 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
> >>  {
> >>      int ret;
> >>
> >> +    start = untagged_addr(start);
> >> +
> >>      len = PAGE_ALIGN(len + (offset_in_page(start)));
> >>      start &= PAGE_MASK;
> >>
> >> diff --git a/mm/mprotect.c b/mm/mprotect.c
> >> index bf38dfbbb4b4..19f981b733bc 100644
> >> --- a/mm/mprotect.c
> >> +++ b/mm/mprotect.c
> >> @@ -465,6 +465,8 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
> >>      const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
> >>                              (prot & PROT_READ);
> >>
> >> +    start = untagged_addr(start);
> >> +
> >>      prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
> >>      if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
> >>              return -EINVAL;
> >> diff --git a/mm/mremap.c b/mm/mremap.c
> >> index fc241d23cd97..64c9a3b8be0a 100644
> >> --- a/mm/mremap.c
> >> +++ b/mm/mremap.c
> >> @@ -606,6 +606,13 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
> >>      LIST_HEAD(uf_unmap_early);
> >>      LIST_HEAD(uf_unmap);
> >>
> >> +    /*
> >> +     * Architectures may interpret the tag passed to mmap as a background
> >> +     * colour for the corresponding vma. For mremap we don't allow tagged
> >> +     * new_addr to preserve similar behaviour to mmap.
> >> +     */
> >> +    addr = untagged_addr(addr);
> >> +
> >>      if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
> >>              return ret;
> >>
> >> diff --git a/mm/msync.c b/mm/msync.c
> >> index ef30a429623a..c3bd3e75f687 100644
> >> --- a/mm/msync.c
> >> +++ b/mm/msync.c
> >> @@ -37,6 +37,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
> >>      int unmapped_error = 0;
> >>      int error = -EINVAL;
> >>
> >> +    start = untagged_addr(start);
> >> +
> >>      if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
> >>              goto out;
> >>      if (offset_in_page(start))
> >>
> >
> >
>
>

