Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 638F9C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 04:10:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3F8C2133D
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 04:10:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="L/SLPOie"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3F8C2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 683E96B0007; Thu,  4 Apr 2019 00:10:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60CD96B0008; Thu,  4 Apr 2019 00:10:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AD066B000D; Thu,  4 Apr 2019 00:10:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0BCDF6B0007
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 00:10:46 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2so706202pge.16
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 21:10:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/Azuha6DiK4iW7u6ZlG02YZIB9WXfWKZPUN5iJiXr0M=;
        b=Rwfa1IvxpFvcJYdcqIWD3faCj6yW1rfN6Q2IvLhDaxGiQ4dNJx1XC6kg82LdK5uS+8
         PVapIue62I9LmD/KA31Bnoa6K2wOBlf+KebOvH3IcAeRGwEN1MJpeIXUHkyJJeWrS22S
         yjhGhGp11RAQnuGqRrHYmJdSoxGTIO+T4Y1C45aDzfwIuPPXz8y3SPavz6b28qD1QJG/
         K76MInsF1keYZ5nsJyxBrqmP9K//OXtzahxdEBG5alYvWRy4RZXn8oLslr7lmPCB31fZ
         rW66YsC7sI+9S566fj3A06aKsrEYufbh00wz566dcrHblw9nlHfQ45iVPuSn4934LnTR
         ITRg==
X-Gm-Message-State: APjAAAXxui0y6ZncAlFdgYXiquu4N4oYxU7lKzJkOVOnJ3UAxrfmeAgv
	eJ4GcR0+0rGrwzh7sbq/4MuJOuXY/4mKou3kapMMfdjEc34AsOqh1oQKgROIroV4QA2ossMGIxZ
	HzadMfzTQH/WP6WC9vOr3YrgWDs1UCzeHDmmEunUDNFBl+HP5XCDpUb79dekIqZU8Ig==
X-Received: by 2002:a65:5ac3:: with SMTP id d3mr3689400pgt.168.1554351045556;
        Wed, 03 Apr 2019 21:10:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWWx2qsFHcXtEQq8ydD+rfB+5DNCOczyIGwP/wMxxxn1NKBK/lCcSbk33KkhTgRPFYjyuQ
X-Received: by 2002:a65:5ac3:: with SMTP id d3mr3689353pgt.168.1554351044686;
        Wed, 03 Apr 2019 21:10:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554351044; cv=none;
        d=google.com; s=arc-20160816;
        b=fJQIrkUNGOK3Ayk33/CrORIXivyRZrrptgs4bxwWtsj0obzCFqro+vo5w2f3T7guDQ
         zciBZdIt9o6Jq4fWh8jtb+R20BrRo8bMWriHfp6p/DWGtxdoib1w8QH/oDcjT6yQkscH
         9++kVLHjeGIbI2GwTzkmD+fsIVmGM4V84hGajAXFpJvW6U3NzR8aHO7lyQSvLJ5lawGU
         Ew1DMZrdSSUrgjlVyYepu+JezGmwTDTipaSnK4xntV7TnjVIC/CUhpz1+tOFDNohRRuP
         tcVhEdVFsTskOfSDP41kA3BaX2/AKA+Y4g0dp9YreUGj8RH4F3r4QmmZAkykD/MEbaBb
         ZqWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/Azuha6DiK4iW7u6ZlG02YZIB9WXfWKZPUN5iJiXr0M=;
        b=zYoHm5Ic7BCAVVeeVa9tGgfdBnBBwGOfz9gk9f8ciprl615OcsttJkoIamDvw0rG2d
         oBzZ7ExTjA1r3mZirtGm+Q3dlLQ2v48DdC51EP0h00ncAQjCXaApC9Fnn+8mPeY6cw3t
         tACJt9JIvZv1KMQkYCo4/H67tHTagCgRvsnNbedSkNWleWsf7P1Fc/hTEYac08x4nqF+
         z0Yfu8HxAkyZFHvq9/lZQT1i4PYfw8v0CZZJtsbTwY6lgkogf1yaUAGq4UGXpTrvH1Bv
         dtS7y3syzJ6CqyFHqjrO4jDZPu08iYF/KH5isbWYwZN06EaxEfwpTjmipMFdrOzps5l5
         BS4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="L/SLPOie";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r184si14878949pgr.24.2019.04.03.21.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 21:10:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="L/SLPOie";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f52.google.com (mail-wr1-f52.google.com [209.85.221.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D32C621915
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 04:10:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1554351044;
	bh=HX0C5suuVm0rYTkGKcmAZLyJBvn4rZemHJs0m1aWRG0=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=L/SLPOieczoPGHlEwe9OluxIaRnMgvWm/8PxZ9me4/1iDKFfAW0H3EiA2lFN8STyk
	 ym6NASjWWWlGrRHvIZH7VM2OP2fvXOsQmz2htOfapN+DHojzOIjaohvVW7k/N/Csb7
	 93fUOpwAfKgIhSJNBwdsdWav/YFEkE37mFgremz4=
Received: by mail-wr1-f52.google.com with SMTP id k17so1656814wrx.10
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 21:10:43 -0700 (PDT)
X-Received: by 2002:adf:ebd2:: with SMTP id v18mr2213160wrn.108.1554351034995;
 Wed, 03 Apr 2019 21:10:34 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
In-Reply-To: <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 3 Apr 2019 21:10:23 -0700
X-Gmail-Original-Message-ID: <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com>
Message-ID: <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com>
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current
 CPUs (x86 only)
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, 
	Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com, Kees Cook <keescook@google.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, 
	chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, 
	"Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, 
	Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, 
	Joao Martins <joao.m.martins@oracle.com>, Jim Mattson <jmattson@google.com>, 
	pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, 
	Thomas Gleixner <tglx@linutronix.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, Laura Abbott <labbott@redhat.com>, 
	Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Aaron Lu <aaron.lu@intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, alexander.h.duyck@linux.intel.com, 
	Amir Goldstein <amir73il@gmail.com>, Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com, 
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
	Rik van Riel <riel@surriel.com>, David Rientjes <rientjes@google.com>, 
	Robin Murphy <robin.murphy@arm.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Steve Capper <steve.capper@arm.com>, thymovanbeers@gmail.com, 
	Vlastimil Babka <vbabka@suse.cz>, Will Deacon <will.deacon@arm.com>, 
	Matthew Wilcox <willy@infradead.org>, yang.shi@linux.alibaba.com, yaojun8558363@gmail.com, 
	Huang Ying <ying.huang@intel.com>, zhangshaokun@hisilicon.com, 
	iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>, 
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, LSM List <linux-security-module@vger.kernel.org>, 
	Khalid Aziz <khalid@gonehiking.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 3, 2019 at 10:36 AM Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> XPFO flushes kernel space TLB entries for pages that are now mapped
> in userspace on not only the current CPU but also all other CPUs
> synchronously. Processes on each core allocating pages causes a
> flood of IPI messages to all other cores to flush TLB entries.
> Many of these messages are to flush the entire TLB on the core if
> the number of entries being flushed from local core exceeds
> tlb_single_page_flush_ceiling. The cost of TLB flush caused by
> unmapping pages from physmap goes up dramatically on machines with
> high core count.
>
> This patch flushes relevant TLB entries for current process or
> entire TLB depending upon number of entries for the current CPU
> and posts a pending TLB flush on all other CPUs when a page is
> unmapped from kernel space and mapped in userspace. Each core
> checks the pending TLB flush flag for itself on every context
> switch, flushes its TLB if the flag is set and clears it.
> This patch potentially aggregates multiple TLB flushes into one.
> This has very significant impact especially on machines with large
> core counts.

Why is this a reasonable strategy?

> +void xpfo_flush_tlb_kernel_range(unsigned long start, unsigned long end)
> +{
> +       struct cpumask tmp_mask;
> +
> +       /*
> +        * Balance as user space task's flush, a bit conservative.
> +        * Do a local flush immediately and post a pending flush on all
> +        * other CPUs. Local flush can be a range flush or full flush
> +        * depending upon the number of entries to be flushed. Remote
> +        * flushes will be done by individual processors at the time of
> +        * context switch and this allows multiple flush requests from
> +        * other CPUs to be batched together.
> +        */

I don't like this function at all.  A core function like this is a
contract of sorts between the caller and the implementation.  There is
no such thing as an "xpfo" flush, and this function's behavior isn't
at all well defined.  For flush_tlb_kernel_range(), I can tell you
exactly what that function does, and the implementation is either
correct or incorrect.  With this function, I have no idea what is
actually required, and I can't possibly tell whether it's correct.

As far as I can see, xpfo_flush_tlb_kernel_range() actually means
"flush this range on this CPU right now, and flush it on remote CPUs
eventually".  It would be valid, but probably silly, to flush locally
and to never flush at all on remote CPUs.  This makes me wonder what
the point is.

