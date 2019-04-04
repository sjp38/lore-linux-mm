Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9FB6C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 01:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 473E02082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 01:42:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="J7FKQDS6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 473E02082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tycho.ws
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93E176B0006; Wed,  3 Apr 2019 21:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EEA66B0007; Wed,  3 Apr 2019 21:42:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 768B76B0008; Wed,  3 Apr 2019 21:42:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 513616B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 21:42:46 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id y127so897088itb.1
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 18:42:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KxKL8Giu39W2ONA+1Mtcf0S0OEk5moXXr6HorpnAn5U=;
        b=FsU2igkDL/qnVllm7WzMpkQEYYSqik6Lx/SZ9Lzu9o7jrnrUeEUMOWJ0m3PzmDJGlB
         gJtcLkY0jJtNpxThIaYAwVmUsfT7cnVVOnHEjjwCO0685NsVLurAysEXRY9nsz9iTXpn
         P0KSXAJh2iGpC1LMjRpwtPjdrx2yZk9cxaKhTomKSGOT9e9TwcJDpyhtBwwgbgvAIZpW
         JYVjtWgZFzTlEtfY7czkHiwe2YAayklhrjbkkx7YGyyCYUfY8HsqIm//DE2PNS2fOaIa
         XSMrErub5h+arX/12wUopj3RJe6RhzWC9w3lHySrrDv2pyUIkQRyNd4nGyX2F/awvmkW
         jpGw==
X-Gm-Message-State: APjAAAWc2io9HhwC464rU3SAgpIiQ758t6FdUZR8KQz38epULB5PeQuK
	ans2zqlGjKyF06CksLht7HGAVidpiJLlR9wOLd6Mzd2O2p/vWraMbcSk+cf6WGLkFmVyyQRjXWH
	W9A/3ZZP2OFglGUuCRhdmUwGRAGtbKWIuM9GhMisPOrV33Y06QQDXje4P/8/L5tdJwQ==
X-Received: by 2002:a05:660c:4c2:: with SMTP id v2mr2844932itk.71.1554342166086;
        Wed, 03 Apr 2019 18:42:46 -0700 (PDT)
X-Received: by 2002:a05:660c:4c2:: with SMTP id v2mr2844911itk.71.1554342165384;
        Wed, 03 Apr 2019 18:42:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554342165; cv=none;
        d=google.com; s=arc-20160816;
        b=VOonx3izrusie2kI4mA4PMjgaP0iZov/rW3ZmAu+scpjoHOXjf+FirMTj9oUoFiVoA
         SgozHGnvDM1Wu6+yJt7eXNbebEBG+HEfeDzkn3/33C6J1/AbZ2yGFN/uzBCEvdR65PIe
         HBKOiPYgz4D2gvPDJ/GfvojTBlm89dry8RgLb9prAc7guILnBJY43Bq8PcU9A2d5C8dB
         l9mxGlubzXRu7gqagUGH3txiJdmc66gSiO8NgKxnGvZrFtysB6SZ9INuGGOovI3xRJ3N
         C8+KjHlL301aWUeYdZ7YsETZSri6tx3/ZFqcn9rRHh8IC9K6THWd9+GLlGuWnzd8NKla
         iPHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=KxKL8Giu39W2ONA+1Mtcf0S0OEk5moXXr6HorpnAn5U=;
        b=t7vgAbdqWStAdpvmtCfnOEIlwv+qbLZ58EwiwkhjES3GZ91Bkk1jFnMoecsIMjejPY
         5JCtGqnuugBk9TgUcZIZTGfuNHWypcd9r8wUOulnxlG2QygEviodfqUw0nSCYsD89fRL
         A/akoCaGLpG9UfQ2cPpDqS3y4JPcvI9wAFBX8HIoTkzhVgCYqDdYXLpTmq5Ja9hemrsR
         fJkV8iazMUt55gTaWBidF24Ox7tvH9YrJzVhRaz1uDOguY9fl6lFc5PuHgtHRVuUMYtW
         P5TvwaJLgbdH1WnpQdYT5mnho+9NKBtUGC5H3G/z/Xcu+pvgSP7+DWJ0neCJqJKCkIp4
         Wvcw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=J7FKQDS6;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a16sor11409135ioh.59.2019.04.03.18.42.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 18:42:45 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tycho-ws.20150623.gappssmtp.com header.s=20150623 header.b=J7FKQDS6;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of tycho@tycho.ws) smtp.mailfrom=tycho@tycho.ws
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KxKL8Giu39W2ONA+1Mtcf0S0OEk5moXXr6HorpnAn5U=;
        b=J7FKQDS6IFB06MCSVgBOmHad3DlpaBIGP6ZmDDxn9AuMvo8/6kTZHNU14bZ04vuWCN
         VdSAJUwTsBQf6TzN/QV24JZVLd7vHULvID0ejgsjb9tUoNDDYfptZ2RyCNjtqDV1jReG
         3TOUR7u3Lz4HY8V+9+HU8ZRdi0vkIWXuyNFaAd14Efp+PMoKfbaM+dYBgxlfvF5lIGO3
         hwFdGGWJ7zJ/qOhk3qybTRYxbkNwA7dQxOj0ST93sAq/KWbWhL7WPv3KXv4bGETHJF+l
         CT/2zlu3EdrSFk50HB4WyvHrz7vRzJt8HODZT254CNA6w/5XfML/clZjYXdIlCiN5O8n
         EMvA==
X-Google-Smtp-Source: APXvYqwDmxaB1BPltbx3UZQGyvu48vC6AKstQcHzBZ0tOJUlpousD+N/Ri7kupXCA50cz7suk/aDjg==
X-Received: by 2002:a5e:981a:: with SMTP id s26mr2460715ioj.90.1554342164803;
        Wed, 03 Apr 2019 18:42:44 -0700 (PDT)
Received: from cisco ([2601:282:901:dd7b:38ae:7ccc:265c:2d2c])
        by smtp.gmail.com with ESMTPSA id s10sm7380298ioc.54.2019.04.03.18.42.40
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Apr 2019 18:42:43 -0700 (PDT)
Date: Wed, 3 Apr 2019 19:42:39 -0600
From: Tycho Andersen <tycho@tycho.ws>
To: Andy Lutomirski <luto@kernel.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>,
	Juerg Haefliger <juergh@gmail.com>, jsteckli@amazon.de,
	Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
	Kees Cook <keescook@google.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
	Tyler Hicks <tyhicks@canonical.com>,
	"Woodhouse, David" <dwmw@amazon.co.uk>,
	Andrew Cooper <andrew.cooper3@citrix.com>,
	Jon Masters <jcm@redhat.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	kanth.ghatraju@oracle.com, Joao Martins <joao.m.martins@oracle.com>,
	Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
	John Haxby <john.haxby@oracle.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
	Laura Abbott <labbott@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Aaron Lu <aaron.lu@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	alexander.h.duyck@linux.intel.com,
	Amir Goldstein <amir73il@gmail.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
	Ben Hutchings <ben@decadent.org.uk>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
	Catalin Marinas <catalin.marinas@arm.com>,
	Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Dan Williams <dan.j.williams@intel.com>,
	Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	James Morse <james.morse@arm.com>, Jann Horn <jannh@google.com>,
	Juergen Gross <jgross@suse.com>, Jiri Kosina <jkosina@suse.cz>,
	James Morris <jmorris@namei.org>, Joe Perches <joe@perches.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
	Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
	Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
	Mark Rutland <mark.rutland@arm.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Michal Hocko <mhocko@suse.com>, Michal Hocko <mhocko@suse.cz>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Ingo Molnar <mingo@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
	richard.weiyang@gmail.com, "Serge E. Hallyn" <serge@hallyn.com>,
	iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 02/13] x86: always set IF before oopsing from page
 fault
Message-ID: <20190404013956.GA3365@cisco>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com>
 <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 05:12:56PM -0700, Andy Lutomirski wrote:
> On Wed, Apr 3, 2019 at 10:36 AM Khalid Aziz <khalid.aziz@oracle.com> wrote:
> >
> > From: Tycho Andersen <tycho@tycho.ws>
> >
> > Oopsing might kill the task, via rewind_stack_do_exit() at the bottom, and
> > that might sleep:
> >
> 
> 
> > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > index 9d5c75f02295..7891add0913f 100644
> > --- a/arch/x86/mm/fault.c
> > +++ b/arch/x86/mm/fault.c
> > @@ -858,6 +858,12 @@ no_context(struct pt_regs *regs, unsigned long error_code,
> >         /* Executive summary in case the body of the oops scrolled away */
> >         printk(KERN_DEFAULT "CR2: %016lx\n", address);
> >
> > +       /*
> > +        * We're about to oops, which might kill the task. Make sure we're
> > +        * allowed to sleep.
> > +        */
> > +       flags |= X86_EFLAGS_IF;
> > +
> >         oops_end(flags, regs, sig);
> >  }
> >
> 
> 
> NAK.  If there's a bug in rewind_stack_do_exit(), please fix it in
> rewind_stack_do_exit().

[I trimmed the CC list since google rejected it with E2BIG :)]

I guess the problem is really that do_exit() (or really
exit_signals()) might sleep. Maybe we should put an irq_enable() at
the beginning of do_exit() instead and fix this problem for all
arches?

Tycho

