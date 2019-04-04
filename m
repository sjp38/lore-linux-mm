Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F42EC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 04:12:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1005D2171F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 04:12:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PuiPZq2O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1005D2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2C6D6B0007; Thu,  4 Apr 2019 00:12:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DBDB6B0008; Thu,  4 Apr 2019 00:12:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A36E6B000D; Thu,  4 Apr 2019 00:12:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 477036B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 00:12:38 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id m37so939879plg.22
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 21:12:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FbHJbgXLlmAIjnYfX9OPEYTYbW0UaSxBHYPLP/4p09Q=;
        b=t427GxEUC4TCe4xKeORoM8W1iGdUyhiuZdKoaXhENCyRCW2KpGmQPXOht9Resepm1Y
         cvJ8qwkJ5spS5wNDrofagYWmEC8kMezg6rMtlIvfMAfTcP1W76sML6Ew5Ee0jKpOoRvQ
         7vUFoHhvETSbwdsyAyEFNgTt7O+7ttk/vFvgEPjYGWW24wFqvUvB3rdGzUk/wJXH6Qwo
         nSW91n4Xpcw0KKvIGxwc1HkDCbx0YIUcPuP6bHEaL4oxe42OmPR6yXMwiydlV1hW9Jo9
         /f0Fg3k2C574IoWRoPHf2n9pbbtQzY+CRO2MwysxkDN5IO6tnLGa7XeglchDO5HapI73
         XmKg==
X-Gm-Message-State: APjAAAVEJWo+8Y2OryBANXL8/vt7MSL3uiyYUSQ+GIyFhfh6PLok7NE3
	Ejg2WvGCgU1u0KkBhL71vqU6KmSq4RSCzLxHvVgf2/lN2IwIAUPCgVSIKJT1McbnSUG/lQlcaAe
	3SPLgZH9dRAWKXoeK+frusk8IRqFFHEZccyPQIhSaaADF2pPXIktwk2VwVAHsr1jrnw==
X-Received: by 2002:a65:430a:: with SMTP id j10mr3386665pgq.143.1554351157908;
        Wed, 03 Apr 2019 21:12:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ/byJ5MiYdqeJZtsxL7E9RzTjsO4o0xD/prOH2uhPAVctXgvrpD7Vk0fS3b7DUzRqik84
X-Received: by 2002:a65:430a:: with SMTP id j10mr3386615pgq.143.1554351157107;
        Wed, 03 Apr 2019 21:12:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554351157; cv=none;
        d=google.com; s=arc-20160816;
        b=EahXEQz/AJoo25ihyvaHuI7GhLUsLoSwwmQDNKSrsOmSaO0PLu2Hq0rGAKJMxQkhQF
         Iq4xdqf1tb8Gawniuxw1cC3DpLdxX+zO+YEbw/zV+61oU2I9H0fTpWr2qyYfpd9KXEc1
         GZDpf6PMYRw6oYfV7kulCNKctaa83b8cQDhklxhWs7gsqdW3Jk0a7H42+IVZvxMm31Dx
         WP0lbYxLQExSGWAZNa2TLzkdJi+q02M0vWtXlrhPu16axDmDbxpWuH5+B41Gly4GuSqr
         5E8XzQNhFFPQYKNfnFic/shHu8dYnlIyFqVltYz95guDwjG4g7y0DBOAPl8r0ki5clsC
         dRPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FbHJbgXLlmAIjnYfX9OPEYTYbW0UaSxBHYPLP/4p09Q=;
        b=J+YoMo9clgS6CTV5/MosqILT82oDsePMRXH710n+ncG0Xy7/z7tuWTqbEbjxDtUpX1
         QtXxzMo+JeMNNGGtZy2H/PfHAJjqOu4fhoxDZu4YsJ8KDoTRMkuXAZc66HVwqQZ1ZLEh
         ti/mrz9gOLYSY5+2LutZyW0Ody1Ftr1oGSnagXJZlKg9TNgRLnB2bE5T0umFQtO9lcw4
         x7t8+dCZKk20GpwNgRel5dHMnXZ4GL3KW37A72LDh9d3TGS8a3Qo4PL9PYoBve4NLXll
         fmBOdlANGap98vLKFFdG5gGU1AJPp8PnCb3ZU3AFa0j6nqoExsL0/Ya/XaTMRF0Q0RLU
         Ncnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PuiPZq2O;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 31si15811801plk.398.2019.04.03.21.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 21:12:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PuiPZq2O;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com [209.85.221.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 87F1E21741
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 04:12:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554351156;
	bh=8olT3SzX/tOLFLcs0oupddwKsSWKr8XaKQpK/Wcq1+Q=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=PuiPZq2OrJa7eloBQMWbdmjA6KgMkA/XFxtgIPSbrAxTA9cJ6wWFy7V4AhpX35OWQ
	 eP75gvZugp0fyhdkj2bzOaiHy0roKC4C0+QglfiQAbLvGAofV1Y83fhgA3Y5WLrOTa
	 IFAUMknyScL1SRab6E8K+VnAySM+fO97624tueWc=
Received: by mail-wr1-f43.google.com with SMTP id w10so1716032wrm.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 21:12:36 -0700 (PDT)
X-Received: by 2002:a5d:4606:: with SMTP id t6mr2082188wrq.43.1554351147909;
 Wed, 03 Apr 2019 21:12:27 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com> <20190404013956.GA3365@cisco>
In-Reply-To: <20190404013956.GA3365@cisco>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 3 Apr 2019 21:12:16 -0700
X-Gmail-Original-Message-ID: <CALCETrVp37Xo3EMHkeedP1zxUMf9og=mceBa8c55e1F4G1DRSQ@mail.gmail.com>
Message-ID: <CALCETrVp37Xo3EMHkeedP1zxUMf9og=mceBa8c55e1F4G1DRSQ@mail.gmail.com>
Subject: Re: [RFC PATCH v9 02/13] x86: always set IF before oopsing from page fault
To: Tycho Andersen <tycho@tycho.ws>
Cc: Andy Lutomirski <luto@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, 
	Juerg Haefliger <juergh@gmail.com>, jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, 
	liran.alon@oracle.com, Kees Cook <keescook@google.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, 
	chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, 
	"Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, 
	Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, 
	Joao Martins <joao.m.martins@oracle.com>, Jim Mattson <jmattson@google.com>, 
	pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, 
	Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, Laura Abbott <labbott@redhat.com>, 
	Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, 
	Aaron Lu <aaron.lu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	alexander.h.duyck@linux.intel.com, Amir Goldstein <amir73il@gmail.com>, 
	Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com, 
	anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org, Ben Hutchings <ben@decadent.org.uk>, 
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl, 
	Catalin Marinas <catalin.marinas@arm.com>, Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org, 
	Daniel Vetter <daniel.vetter@ffwll.ch>, Dan Williams <dan.j.williams@intel.com>, 
	Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	James Morse <james.morse@arm.com>, Jann Horn <jannh@google.com>, Juergen Gross <jgross@suse.com>, 
	Jiri Kosina <jkosina@suse.cz>, James Morris <jmorris@namei.org>, Joe Perches <joe@perches.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Joerg Roedel <jroedel@suse.de>, 
	Keith Busch <keith.busch@intel.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
	Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com, 
	Mark Rutland <mark.rutland@arm.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Michal Hocko <mhocko@suse.com>, Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, 
	Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, 
	Marek Szyprowski <m.szyprowski@samsung.com>, Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de, 
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, pavel.tatashin@microsoft.com, 
	Randy Dunlap <rdunlap@infradead.org>, richard.weiyang@gmail.com, 
	"Serge E. Hallyn" <serge@hallyn.com>, iommu@lists.linux-foundation.org, 
	X86 ML <x86@kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, LSM List <linux-security-module@vger.kernel.org>, 
	Khalid Aziz <khalid@gonehiking.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 6:42 PM Tycho Andersen <tycho@tycho.ws> wrote:
>
> On Wed, Apr 03, 2019 at 05:12:56PM -0700, Andy Lutomirski wrote:
> > On Wed, Apr 3, 2019 at 10:36 AM Khalid Aziz <khalid.aziz@oracle.com> wrote:
> > >
> > > From: Tycho Andersen <tycho@tycho.ws>
> > >
> > > Oopsing might kill the task, via rewind_stack_do_exit() at the bottom, and
> > > that might sleep:
> > >
> >
> >
> > > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > > index 9d5c75f02295..7891add0913f 100644
> > > --- a/arch/x86/mm/fault.c
> > > +++ b/arch/x86/mm/fault.c
> > > @@ -858,6 +858,12 @@ no_context(struct pt_regs *regs, unsigned long error_code,
> > >         /* Executive summary in case the body of the oops scrolled away */
> > >         printk(KERN_DEFAULT "CR2: %016lx\n", address);
> > >
> > > +       /*
> > > +        * We're about to oops, which might kill the task. Make sure we're
> > > +        * allowed to sleep.
> > > +        */
> > > +       flags |= X86_EFLAGS_IF;
> > > +
> > >         oops_end(flags, regs, sig);
> > >  }
> > >
> >
> >
> > NAK.  If there's a bug in rewind_stack_do_exit(), please fix it in
> > rewind_stack_do_exit().
>
> [I trimmed the CC list since google rejected it with E2BIG :)]
>
> I guess the problem is really that do_exit() (or really
> exit_signals()) might sleep. Maybe we should put an irq_enable() at
> the beginning of do_exit() instead and fix this problem for all
> arches?
>

Hmm.  do_exit() isn't really meant to be "try your best to leave the
system somewhat usable without returning" -- it's a function that,
other than in OOPSes, is called from a well-defined state.  So I think
rewind_stack_do_exit() is probably a better spot.  But we need to
rewind the stack and *then* turn on IRQs, since we otherwise risk
exploding quite badly.

