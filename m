Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3164C282CE
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:27:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79E082146F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 16:27:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=amacapital-net.20150623.gappssmtp.com header.i=@amacapital-net.20150623.gappssmtp.com header.b="Axi4fAqr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79E082146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amacapital.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 04D3F6B0010; Fri,  5 Apr 2019 12:27:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3F716B0266; Fri,  5 Apr 2019 12:27:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2E636B0269; Fri,  5 Apr 2019 12:27:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAF7E6B0010
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 12:27:11 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d10so4512856plo.12
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 09:27:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=Ysh9Mrjjsf5KUobUQGzy35ckMcQFsSqKm4VSGfPwcIc=;
        b=DOzdBR5r6G3x1RYsGSTx2osQZRxcGzyJp7DqxH4r/ROidxhULFbLt6SPXERmaGyazn
         ALHWYs/IIOSmLV0uZzEXIOeIPeNW1mSxiiDRp2zVAoKRecBLiIvpJtq70jZ+1d1DOz3Z
         AYvi0/6nMrco4IFAcbFiyyN9+BLxJ30v9ZBmkIpSYskW7LComfLCIsSR21Z+dyiusHYP
         39b8pPe8HQGIxpwxffs+NGr8l5IWf9Ukleen428lxIRkc4GEH+KnmezkQ3DTMiTulmL2
         Qsj9kg8y3Gh5+TR8a3B8u+7eLvVsTfd6s4IuYrWTrSp5BVwINd1JUyw2RzsuhbAF/eqa
         HL5w==
X-Gm-Message-State: APjAAAXr1zwIFfPmE8wm17eCKavQ0nMOfx9O7qH/W6gMduWv87vrQpmw
	u+NtnKvhHVCHn6X4HaaER8Guy36euNMX+zpNdtkd1jMCLXmHlOekl6ORAuYkbWsI1t+5SZ216+V
	LQNJfB+ZgAu99hGJKZ5NJXCI+kRgcfZLL3zGnfHOELF9kdaDFGLFNwr03txlk/WjlFA==
X-Received: by 2002:a62:4351:: with SMTP id q78mr13858575pfa.86.1554481631210;
        Fri, 05 Apr 2019 09:27:11 -0700 (PDT)
X-Received: by 2002:a62:4351:: with SMTP id q78mr13858504pfa.86.1554481630380;
        Fri, 05 Apr 2019 09:27:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554481630; cv=none;
        d=google.com; s=arc-20160816;
        b=zINeEVpn69GadhE/YdznGLLM9M8BUZhhzuDhzvJoMCnpT4H9AJiohutwwQNthSQ8Hq
         U3MFU55IF5T2wqxyNuiqSywyOsTrfUWaq5hYeSifulLTNhw4iyHx1Eqtu0jgnidrgErG
         PvPlDA9JjQTAoVKWmaXSKhChpbt/00Ypv2JgeREX1HbwzWwS2C+pLS7YiuJVg/bKza+D
         qhDn5MsTDIJDdqjNcKVve+S/FYtodCYCb7a8+yOed4fxSjlWkX4OzdZ43m+fFyH9gvhn
         BrU/qDpZI1fnIPLHZ7lSKJ9hNdQ3YmGeadhvFYRGjAipuNqsCnmzXyXv7G2zTMke9EI2
         b4bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=Ysh9Mrjjsf5KUobUQGzy35ckMcQFsSqKm4VSGfPwcIc=;
        b=gLvGbhYmF3tf1cajZ0shDMBrs+nakRN5ISdHUUDoYsFRKq3AqgDGUfWNTVFoL0WsLN
         VoWtovVU0Mc/RegtDQFEnUsezcgOi+4peJpgoaTlH8AWQXnJMtiduKKnBXrI+ps/VLvd
         6HvB0hc/XPeuyfLr6kDs79WLjBsHWQZYK5Np0kEuksePVdjC7pAL8cFJgdjB2N9GD6n4
         h4lmWbBLHY7AK7n1bX4fUAOoRMGv96IrERI+lWYTDKULwidpwsLQZNkYtjunAy5i1wPo
         FUJTyT0Wn8VnFjXYxMQHaq/aR5L/KxL5roRyM9NzSjq11+/OdKqb0NN8nrl+0jfvmGAi
         FT+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Axi4fAqr;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a37sor24908954pgl.72.2019.04.05.09.27.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Apr 2019 09:27:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amacapital-net.20150623.gappssmtp.com header.s=20150623 header.b=Axi4fAqr;
       spf=pass (google.com: domain of luto@amacapital.net designates 209.85.220.65 as permitted sender) smtp.mailfrom=luto@amacapital.net
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amacapital-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=Ysh9Mrjjsf5KUobUQGzy35ckMcQFsSqKm4VSGfPwcIc=;
        b=Axi4fAqr2bS9Bwzw1Irlq12HPKbspntoYaZJJuLovmIBMQ2xArZLYze4QwgYBVDKDn
         zL/9SdwLZ1xGc5XCaHsXf/ApMEn//V1nydmtLvcjew8Z18vhi26OGDOcLOfmUM8EiWM/
         GbiWUxAJCqHKRFQ0BIaeWLdjOXOUWjqOQAd2uKYIvKnPZZbcnGIVlfXyA8VffZimBSKk
         aAWBRBWbtr03KHwGhrXpYDj4bqK2qmLN7qHg0wUUMOhbOpU5gTa/AN+LfafZ+GXxWJjn
         nd3KBNGDuQXGpaZtogKzMvSbt6Fd5dDqeOYzUDHMqAWYARvtA+nx6frZBvNPLc5TC5NJ
         X1Zw==
X-Google-Smtp-Source: APXvYqygZiTN+T87sxq85RkOULmkYm62y61sBAXlwRhci93Kw+o/kR8k8BWdCBaKxI+XOmVfuk4mnw==
X-Received: by 2002:a63:cc0a:: with SMTP id x10mr12528292pgf.179.1554481629724;
        Fri, 05 Apr 2019 09:27:09 -0700 (PDT)
Received: from ?IPv6:2600:100e:b12a:ccdd:512d:55a6:36a5:bcd4? ([2600:100e:b12a:ccdd:512d:55a6:36a5:bcd4])
        by smtp.gmail.com with ESMTPSA id g73sm41439912pfd.185.2019.04.05.09.27.08
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 09:27:08 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v9 12/13] xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
From: Andy Lutomirski <luto@amacapital.net>
X-Mailer: iPhone Mail (16D57)
In-Reply-To: <36b999d4-adf6-08a3-2897-d77b9cba20f8@intel.com>
Date: Fri, 5 Apr 2019 10:27:05 -0600
Cc: Thomas Gleixner <tglx@linutronix.de>,
 Khalid Aziz <khalid.aziz@oracle.com>, Andy Lutomirski <luto@kernel.org>,
 Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>,
 jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com,
 Kees Cook <keescook@google.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>,
 Tyler Hicks <tyhicks@canonical.com>,
 "Woodhouse, David" <dwmw@amazon.co.uk>,
 Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com,
 Joao Martins <joao.m.martins@oracle.com>,
 Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com,
 John Haxby <john.haxby@oracle.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com,
 Laura Abbott <labbott@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Aaron Lu <aaron.lu@intel.com>, Andrew Morton <akpm@linux-foundation.org>,
 alexander.h.duyck@linux.intel.com, Amir Goldstein <amir73il@gmail.com>,
 Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com,
 anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org,
 Ben Hutchings <ben@decadent.org.uk>,
 Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl,
 Catalin Marinas <catalin.marinas@arm.com>,
 Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org,
 Daniel Vetter <daniel.vetter@ffwll.ch>,
 Dan Williams <dan.j.williams@intel.com>,
 Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, James Morse <james.morse@arm.com>,
 Jann Horn <jannh@google.com>, Juergen Gross <jgross@suse.com>,
 Jiri Kosina <jkosina@suse.cz>, James Morris <jmorris@namei.org>,
 Joe Perches <joe@perches.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>,
 Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
 Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com,
 Mark Rutland <mark.rutland@arm.com>,
 Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>,
 Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de,
 "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
 pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>,
 richard.weiyang@gmail.com, Rik van Riel <riel@surriel.com>,
 David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>,
 Steven Rostedt <rostedt@goodmis.org>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
 "Serge E. Hallyn" <serge@hallyn.com>, Steve Capper <steve.capper@arm.com>,
 thymovanbeers@gmail.com, Vlastimil Babka <vbabka@suse.cz>,
 Will Deacon <will.deacon@arm.com>, Matthew Wilcox <willy@infradead.org>,
 yaojun8558363@gmail.com, Huang Ying <ying.huang@intel.com>,
 zhangshaokun@hisilicon.com, iommu@lists.linux-foundation.org,
 X86 ML <x86@kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
 LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
 LSM List <linux-security-module@vger.kernel.org>,
 Khalid Aziz <khalid@gonehiking.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <E0BBD625-6FE0-4A8A-884B-E10FAFC3319E@amacapital.net>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <4495dda4bfc4a06b3312cc4063915b306ecfaecb.1554248002.git.khalid.aziz@oracle.com> <CALCETrXMXxnWqN94d83UvGWhkD1BNWiwvH2vsUth1w0T3=0ywQ@mail.gmail.com> <91f1dbce-332e-25d1-15f6-0e9cfc8b797b@oracle.com> <alpine.DEB.2.21.1904050909520.1802@nanos.tec.linutronix.de> <26b00051-b03c-9fce-1446-52f0d6ed52f8@intel.com> <DFA69954-3F0F-4B79-A9B5-893D33D87E51@amacapital.net> <36b999d4-adf6-08a3-2897-d77b9cba20f8@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 5, 2019, at 10:01 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>=20
> On 4/5/19 8:24 AM, Andy Lutomirski wrote:
>>> Sounds like we need a mechanism that will do the deferred XPFO TLB=20
>>> flushes whenever the kernel is entered, and not _just_ at context
>>> switch time.  This permits an app to run in userspace with stale
>>> kernel TLB entries as long as it wants... that's harmless.
> ...
>> I suppose we could do the flush at context switch *and*
>> entry.  I bet that performance still utterly sucks, though =E2=80=94 on m=
any
>> workloads, this turns every entry into a full flush, and we already
>> know exactly how much that sucks =E2=80=94 it=E2=80=99s identical to KPTI=
 without
>> PCID.  (And yes, if we go this route, we need to merge this logic
>> together =E2=80=94 we shouldn=E2=80=99t write CR3 twice on entry).
>=20
> Yeah, probably true.
>=20
> Just eyeballing this, it would mean mapping the "cpu needs deferred
> flush" variable into the cpu_entry_area, which doesn't seem too awful.
>=20
> I think the basic overall concern is that the deferred flush leaves too
> many holes and by the time we close them sufficiently, performance will
> suck again.  Seems like a totally valid concern, but my crystal ball is
> hazy on whether it will be worth it in the end to many folks
>=20
> ...
>> In other words, I think that ret2dir is an insufficient justification
>> for XPFO.
>=20
> Yeah, other things that it is good for have kinda been lost in the
> noise.  I think I first started looking at this long before Meltdown and
> L1TF were public.
>=20
> There are hypervisors out there that simply don't (persistently) map
> user data.  They can't leak user data because they don't even have
> access to it in their virtual address space.  Those hypervisors had a
> much easier time with L1TF mitigation than we did.  Basically, they
> could flush the L1 after user data was accessible instead of before
> untrusted guest code runs.
>=20
> My hope is that XPFO could provide us similar protection.  But,
> somebody's got to poke at it for a while to see how far they can push it.
>=20
> IMNHO, XPFO is *always* going to be painful for kernel compiles.  But,
> cloud providers aren't doing a lot of kernel compiles on their KVM
> hosts, and they deeply care about leaking their users' data.

At the risk of asking stupid questions: we already have a mechanism for this=
: highmem.  Can we enable highmem on x86_64, maybe with some heuristics to m=
ake it work well?=

