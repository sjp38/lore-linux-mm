Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF7DCC43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 18:46:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A5DB217F5
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 18:46:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="GoUxsewU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A5DB217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 306DF8E0099; Thu,  3 Jan 2019 13:46:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B6E68E0002; Thu,  3 Jan 2019 13:46:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A64E8E0099; Thu,  3 Jan 2019 13:46:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D09A68E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 13:46:32 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 82so35385583pfs.20
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 10:46:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MgzV5dTndps76ADDi/niLj9jnEoksetg/kN5EQSE/zM=;
        b=BtGOKu1LU7S4gZIQCBNCLXrnFOEp7yyjy3VWd73O5v2ASeRX1QbVMASXlZhEQZMZwQ
         HNYncexAYYS6Bqism5BSZ2cOov7TJZor4TRwD7z51OqZucxEicL+60oiR6q6caNDsOE2
         UE+6rDasPhRL+gvoZAhlLvx1Wc+ju0tSQdse7a9+KU8h4ilGvj2T0w02wXTGxPW03a42
         mYhtacB/j09MEN2qoDNPkTYdwdg8QwlFhyboxBhYYBcOVBK3wetBD8V/f4cNUc8jCTLg
         JXI/o8/FtXbit0pCj2U1xJHZbvWQORM7YcVbHEwmv14fIkKSIn5jxkXTpFe8X/PC3Ut2
         mOvQ==
X-Gm-Message-State: AA+aEWbUHhutZ214PIZfzLs+gDFhKcWdr6IB2vN7jZtAkPaKweMIYfDC
	DwlpVUIdRzm6xO8OOSWAA+uBvWiwkzI/RS2lOL3n3dQqL0kwSWq8StqG8Vh+ujRKHQz4qYhjC6g
	BIUcAmrJaQEHF4jyQWAt1/rDoXNsG2KU9L98dEjOQz+dRF3pwIZi61ibGpGp+m/oBgwBihYhmWm
	FHie+ozNh7wWgvqDzEg8tRdRJV5vYSP0TfEgajt5i+rOWrjX9rdiojeUQtv5aiDE4tIgIt2p6tD
	dcqbbWFUW0ePVT//c0bc4/Y/6sNWlszwrKrmDuYd/I8xy2S4Z1678AZf84aEpz7v72NSnbknGD7
	kxflamjnGaDKqWbA/QUbUQ1jnYx0eQPYaoYGUWKG3yGhspt/5x1q7qa3PEfSATOLkovX1I2IUNV
	K
X-Received: by 2002:a62:d0c1:: with SMTP id p184mr48934821pfg.245.1546541192507;
        Thu, 03 Jan 2019 10:46:32 -0800 (PST)
X-Received: by 2002:a62:d0c1:: with SMTP id p184mr48934786pfg.245.1546541191874;
        Thu, 03 Jan 2019 10:46:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546541191; cv=none;
        d=google.com; s=arc-20160816;
        b=TaPTMX285UXZLjilLEHcD9L5pJ3jBwUFJ7BYx53bq9OjtNAjAPTDviKM9ZMf9qApGr
         8PFdxhA/yS+L4njMlA2phmBy7rYWPY2Rm2rHo1ECBsJ9Kx9/gHpkV+X3J2ybkAnaVt8r
         ZntFcQW8KOl0D8+hJNj3+m26TptH7HymfbFbsjW9RAkaT3PCbjgvJcPYs0YgRdGttCYr
         DEdeHSvM3EJWez2ohbh/B6fovydlYlpjObFWYQnRJRKQGz5PxeA31TeXlb7MU3jdsNy/
         l6ETT3+ej6DHivF+qgqGKyQP9LXLpjPr91bD8IVAgu1PHOSjp7/cfxw7lClaamyvEl2b
         Oeaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MgzV5dTndps76ADDi/niLj9jnEoksetg/kN5EQSE/zM=;
        b=Tn41UAJ4jORH0LsBWBUIKmd8W1g1pzSNhK9Woq1kzRkMPpXrXoxXpcVtufahnWuWb4
         CYRahDONttdOssRctKO7eu9OGjp+Yn9xYBnf1b6KKhRnOe4Yw68MS1Oume3GqUeSV9sI
         /TJ8c5G82ftsKA1k3qiKFDIGATM9qu2wpmkpXBwa3pRKv/8XqJt+n9GPjCCaLDFw84YJ
         s55znG3NIKD/+93r5MMwVBm6XsAjBXFF1umqNlLg+rAmRDR8JFkbfHUDffsXDksLFBNX
         6I6q643fCYHCdvZ2ohopMyG6nYuIuM9T61jbKCIXG4sSsyBtmibU39ncGtSjKQeaNl4b
         gDJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GoUxsewU;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor24372923pgq.34.2019.01.03.10.46.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 10:46:31 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=GoUxsewU;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MgzV5dTndps76ADDi/niLj9jnEoksetg/kN5EQSE/zM=;
        b=GoUxsewUnTYsCM77AWfGlQfTgMINGlA35HpX38hrx1dskXw4mI65zWLT8zB5BYj6e8
         dWsAYaoSKabJNGNo9wQ7kiRDOy+0ey1nWiWJLIWcYQN0z+K9h3DYz2J59oKlX+nzSTTa
         aT57NflI4m5PdSfbXZIhK5emMEoGtqL0F3zjVt4kHv7srAa90A8KpUyo/X4pRSfnHe45
         mAT04CkeOtEEc/W2zJ2MdjjmkeoXPYwO94z4+bpJzerWLi7x1dNRRviz0FSvXA89Biog
         sYyO53jbmfC2HT0on1mg+NJMYZHuZQNJAPTRUv2ZWXjRpBcxKkAu8FFYEp88Z0s/Fqyd
         5EJA==
X-Google-Smtp-Source: ALg8bN5SinAEs0gYR2nS6mwrBbNs6CaZLdp3j4CHwOgZ9jildDr4wOzb2uxGWuD9JrGMv17tlykPD+ZozUjLDh+fs1c=
X-Received: by 2002:a65:560e:: with SMTP id l14mr18036989pgs.168.1546541191326;
 Thu, 03 Jan 2019 10:46:31 -0800 (PST)
MIME-Version: 1.0
References: <cover.1546450432.git.andreyknvl@google.com> <b16c90197bb2c06c780e6e981c40345e03fda465.1546450432.git.andreyknvl@google.com>
 <20190102121436.5c2b72d1b0ec49affadc9692@linux-foundation.org>
In-Reply-To: <20190102121436.5c2b72d1b0ec49affadc9692@linux-foundation.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 3 Jan 2019 19:46:20 +0100
Message-ID:
 <CAAeHK+yE38g0dSbL7LiVPSgECgdcJ5w7+kwaiBaRYr5YkHtbjQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] kasan, arm64: use ARCH_SLAB_MINALIGN instead of
 manual aligning
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, 
	Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	"Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, 
	Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, 
	Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, 
	Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Vishwath Mohan <vishwath@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103184620.JE8NtY-euYR2_2H14DZmdd2EbvWE9m8KtiTWO7USG-A@z>

On Wed, Jan 2, 2019 at 9:14 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed,  2 Jan 2019 18:36:06 +0100 Andrey Konovalov <andreyknvl@google.com> wrote:
>
> > Instead of changing cache->align to be aligned to KASAN_SHADOW_SCALE_SIZE
> > in kasan_cache_create() we can reuse the ARCH_SLAB_MINALIGN macro.
> >
> > ...
> >
> > --- a/arch/arm64/include/asm/kasan.h
> > +++ b/arch/arm64/include/asm/kasan.h
> > @@ -36,6 +36,10 @@
> >  #define KASAN_SHADOW_OFFSET     (KASAN_SHADOW_END - (1ULL << \
> >                                       (64 - KASAN_SHADOW_SCALE_SHIFT)))
> >
> > +#ifdef CONFIG_KASAN_SW_TAGS
> > +#define ARCH_SLAB_MINALIGN   (1ULL << KASAN_SHADOW_SCALE_SHIFT)
> > +#endif
> > +
> >  void kasan_init(void);
> >  void kasan_copy_shadow(pgd_t *pgdir);
> >  asmlinkage void kasan_early_init(void);
> > diff --git a/include/linux/slab.h b/include/linux/slab.h
> > index 11b45f7ae405..d87f913ab4e8 100644
> > --- a/include/linux/slab.h
> > +++ b/include/linux/slab.h
> > @@ -16,6 +16,7 @@
> >  #include <linux/overflow.h>
> >  #include <linux/types.h>
> >  #include <linux/workqueue.h>
> > +#include <linux/kasan.h>
> >
>
> This still seems unadvisable.  Like other architectures, arm defines
> ARCH_SLAB_MINALIGN in arch/arm/include/asm/cache.h.
> arch/arm/include/asm64/cache.h doesn't define ARCH_SLAB_MINALIGN
> afaict.
>
> If arch/arm/include/asm64/cache.h later gets a definition of
> ARCH_SLAB_MINALIGN then we again face the risk that different .c files
> will see different values of ARCH_SLAB_MINALIGN depending on which
> headers they include.
>
> So what to say about this?  The architecture's ARCH_SLAB_MINALIGN
> should be defined in the architecture's cache.h, end of story.  Not in
> slab.h, not in kasan.h.

Done in v3, thanks!

>
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190102121436.5c2b72d1b0ec49affadc9692%40linux-foundation.org.
> For more options, visit https://groups.google.com/d/optout.

