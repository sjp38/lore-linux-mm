Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D53E0C48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:24:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DFE92089E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 15:24:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Orrh03bf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DFE92089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13FAA6B0007; Fri, 21 Jun 2019 11:24:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CA8B8E0003; Fri, 21 Jun 2019 11:24:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF9A98E0001; Fri, 21 Jun 2019 11:24:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id C67636B0007
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 11:24:34 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id a200so2314983vsd.8
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 08:24:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=amUyKy/Lgb0XxSBaEjjhtM0Eo45SjaPoxv+deIw86VE=;
        b=O9FXa/JcMglIRFiMsemqpdKzG185wHpfLkjO2dgTzQqqRHZqj0d1rRASI0GSb0e6NH
         5Uokg3ELq8owJbrBJNEKXi6ngw3lmYMGLvM1EMmKM4+HVZJ2zzQmAjwSRiO6TWsrhkJa
         +MjxxnO5c3liozuACgdFjQGks59PAiE8b4J5fV/2hp79JCwsm80jW7rz1JoxIy3eBIno
         0fnSKSNFX7pNhFcK3WoegMfBr64H9yb79DeEiisEn32AuVKpQXNk9tOUqmxQmdonLVGV
         Q1gftzGEhulEX/cY5+Lw7FmolRn+oa5LhQ4ceLBTR+XVEAN9k37T1WSNsrEKWKvjIllj
         UGsg==
X-Gm-Message-State: APjAAAVCSVYW4eZHwDMc6Q3icJcSGPcXrSHLfyHaUbM5Jpm4lg6jjKod
	ynylhT6FNk0GqJDpjKkzfbtK2ukHHC84xO52mUKZBfoeIRg9BkV1ZdkPm6fM7qOM98hxFCTZ1nh
	Mk6T1C3bxdits5Gx/Rdzy2ifjO2HECBAU/VWEDSsBtSJ97LcWAdyy1ZqHV0bndNR+zg==
X-Received: by 2002:a05:6102:458:: with SMTP id e24mr5180419vsq.31.1561130674543;
        Fri, 21 Jun 2019 08:24:34 -0700 (PDT)
X-Received: by 2002:a05:6102:458:: with SMTP id e24mr5180384vsq.31.1561130673952;
        Fri, 21 Jun 2019 08:24:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561130673; cv=none;
        d=google.com; s=arc-20160816;
        b=wt3hltt83S09jz4RkXTX7lYVseVGzc9rIUcRVeA9z345ldvdM38cWYT5NtptzkxV4p
         U1BJ9wk1bIuvPOSGeLCrCGL206NAhGLhOeizYeCe1KuGPGm7CDTitvh7AlMciVef0LTT
         QR9E5USTOuF9yoR1PnDUSOp9H0gUzUsHps6++5Z6830bPPUdwuWIFVT/5uKQmG4SZlcI
         c66GBv4AK/RqkoBlbqhBxk3RCnuYENzcOdfg5tbkO35KAkZKe2MBz78HPJuelkur1W2N
         w1kSMVW3MP3pD3QwbpNFEQVnRBn5sl0Pjp8p/3MLEN6UZ3gJsObYAnagraPFmmPwRMFz
         PdAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=amUyKy/Lgb0XxSBaEjjhtM0Eo45SjaPoxv+deIw86VE=;
        b=u0C0YvD6jLx0Sy4Gc1IkkOzlFSJOGSLfFY1/NX6F51sxjrQsFKSq5VmLEa5ECfmCSE
         Z3+up1zsqvNZn6BFpnwSfuyKRrR2T7cw95xwuS/ngt4t/BtcseHveXwSC5awbsuUFw7d
         Xsb4SB23Ks0vWgKqG/xy4Vuu4SVZabVrbvEWW7s5sq3kkZ8Gmy0+fcqqCZYLg7XoqgIp
         mT/yY5Ua7heUG+cF5M/CrvlMe25Dmr2LsElJv+M0m2Ey7WyuNrv1/Qk4Xvp9hMktkqDu
         juJ0YIEhK20/NZSzPFtGwOTYVmffhKn9foBU8PXy2zgd5ba0lgIW2Lpy20sSLXoQ8c4E
         hSag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Orrh03bf;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l2sor1817205ual.49.2019.06.21.08.24.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 08:24:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Orrh03bf;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=amUyKy/Lgb0XxSBaEjjhtM0Eo45SjaPoxv+deIw86VE=;
        b=Orrh03bfO4aJYjMke+4LWCWkC5w7vaywjOm7sMgTDaogBQJkmp4uomtEoruNeHvXd2
         wrFFjNZjkg9BjWHJ022RdUhZHglEuVmdtxZhRx0tOMqawEIBURchGPgfPlRj+a8uxPhP
         JX7n4iiDXIP+0JEApmdlwKD/3M2IK7LKVFDrSVbORdw5UYpwP33WvmSo1xgIQ1mF8URV
         CpjrlFZib0+riIcxhJsF+r9Q6aor+CUCS5+r6W5oWWyhoNk2kahaBYe+zmaLbLSfArA9
         tIFjs3SCWMUiX9Z3BF0xEM+M/Z+AdXOT++bJRk7DdW0a9XEcD1YrbOeecsxWtuTYKrTv
         5l5A==
X-Google-Smtp-Source: APXvYqya9eZAEQgsoWb9uXlO3KmWacfsgpndqCO4dX8FLhHaJ4fELI+m+POxQSeCWNXsEFT6mpjddhLn9tBh04jJ7r0=
X-Received: by 2002:ab0:30a3:: with SMTP id b3mr12857232uam.3.1561130673280;
 Fri, 21 Jun 2019 08:24:33 -0700 (PDT)
MIME-Version: 1.0
References: <20190617151050.92663-1-glider@google.com> <20190617151050.92663-2-glider@google.com>
 <20190621070905.GA3429@dhcp22.suse.cz> <CAG_fn=UFj0Lzy3FgMV_JBKtxCiwE03HVxnR8=f9a7=4nrUFXSw@mail.gmail.com>
 <CAG_fn=W90HNeZ0UcUctnbUBzJ=_b+gxMGdUoDyO3JPoyy4dGSg@mail.gmail.com> <20190621151210.GF3429@dhcp22.suse.cz>
In-Reply-To: <20190621151210.GF3429@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Fri, 21 Jun 2019 17:24:21 +0200
Message-ID: <CAG_fn=W2fm5zkAUW8PcTYpfH57H89ukFGAoBHUOmyM-S1agdZg@mail.gmail.com>
Subject: Re: [PATCH v7 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 5:12 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 21-06-19 16:10:19, Alexander Potapenko wrote:
> > On Fri, Jun 21, 2019 at 10:57 AM Alexander Potapenko <glider@google.com=
> wrote:
> [...]
> > > > > diff --git a/mm/dmapool.c b/mm/dmapool.c
> > > > > index 8c94c89a6f7e..e164012d3491 100644
> > > > > --- a/mm/dmapool.c
> > > > > +++ b/mm/dmapool.c
> > > > > @@ -378,7 +378,7 @@ void *dma_pool_alloc(struct dma_pool *pool, g=
fp_t mem_flags,
> > > > >  #endif
> > > > >       spin_unlock_irqrestore(&pool->lock, flags);
> > > > >
> > > > > -     if (mem_flags & __GFP_ZERO)
> > > > > +     if (want_init_on_alloc(mem_flags))
> > > > >               memset(retval, 0, pool->size);
> > > > >
> > > > >       return retval;
> > > >
> > > > Don't you miss dma_pool_free and want_init_on_free?
> > > Agreed.
> > > I'll fix this and add tests for DMA pools as well.
> > This doesn't seem to be easy though. One needs a real DMA-capable
> > device to allocate using DMA pools.
> > On the other hand, what happens to a DMA pool when it's destroyed,
> > isn't it wiped by pagealloc?
>
> Yes it should be returned to the page allocator AFAIR. But it is when we
> are returning an object to the pool when you want to wipe the data, no?
My concern was that dma allocation is something orthogonal to heap and
page allocator.
I also don't know how many other allocators are left overboard, e.g.
we don't do anything to lib/genalloc.c yet.

> Why cannot you do it along the already existing poisoning?
I can sure keep these bits.
Any idea how the correct behavior of dma_pool_alloc/free can be tested?
> --
> Michal Hocko
> SUSE Labs



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

