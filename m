Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A0F4C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 18:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7FD42175B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 18:32:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="X9sR/kLV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7FD42175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 689496B0005; Fri, 22 Mar 2019 14:32:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 63B6C6B0006; Fri, 22 Mar 2019 14:32:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 552526B0007; Fri, 22 Mar 2019 14:32:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 234EB6B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:32:26 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id b10so1599817oti.21
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 11:32:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CZvs5mYWn4e28+5uqtuggdqZURPu2axz//pTmg1YgmQ=;
        b=VGp8Q3ByKRvU3Rfv+bIShOebNS8dLB7UJwtXxPpZycWhj4hBnjzVVp85iy6WYs98CA
         ENePacHfqRRQ0lhF4GILBuPnkvlVPc6bzFU2qBmPONUfXtmyPFvkjQ+yc/yRo3cHuoGl
         2PlcmHq8M8RmRTI+JGZTl1NDgDOsV7RtCNJjdRwMRhDnqJGeg0rHsluJ+Su6Y2/wC+g7
         RL6GNvvhFkKNRsU4XGI9J+hbDcqkYMhDI2TFc9JD6bZT+H6HHjBlhempzUE1esAEgmE0
         9yAuClBxzX61jABB9DlRwk+nf3tAx6jofGjDSIJUrv2DcWXdYTVD0oLliyotsi+SmRtQ
         2Jvg==
X-Gm-Message-State: APjAAAX4jPCzAX0q9GdbOS89alxNA0yzdKJ4ElVqNNp4JA06hT/mDLJN
	+5VyPRQ3kPy+eveTpi6Cs62vWHiHUgVI0wCrE1wibNYsfFy0dA7Nl+KkNiZqnII/sVdT0B7jJ9R
	wHB+8rVhu0dyzS/sYWVbltgS3wKm5HN5pjZYkFxBnC7ye6JpS1psRD6rs4SV7epFMeA==
X-Received: by 2002:aca:3a57:: with SMTP id h84mr2728590oia.162.1553279545804;
        Fri, 22 Mar 2019 11:32:25 -0700 (PDT)
X-Received: by 2002:aca:3a57:: with SMTP id h84mr2728524oia.162.1553279544498;
        Fri, 22 Mar 2019 11:32:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553279544; cv=none;
        d=google.com; s=arc-20160816;
        b=UoYszPSmPo+HscUFyrVOayIfqG4LgUkYNQjKvvkcXV6uh28S9K3n8JVj+JfV5bhtb7
         +FE2XEFChT2/gVXGPpnd5RsOtjI96iSyQ+Y776rn9ZawHjKXZzKWA1YeAfuXPXExGlKG
         aMHB6KVszz0KSF38TGcXmOiW7GuV8H4/ITQKJGDqAUJRawC8AyW74pzEHhZUeSYDbK5k
         o19mUe5joHqA9P7NYC2V6TtTdBf6PClnZC4d9nkRMDF+m3wI1n2CtSCCkBrMzuIT+rtX
         uVFMu7YPlvIDffvw6/SD2ssMi8hKN06Vee7Qs5w79opZdZap4VzSrRPYDkapwjhLm0oH
         RmJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CZvs5mYWn4e28+5uqtuggdqZURPu2axz//pTmg1YgmQ=;
        b=XuAclloBIrllYjUQe1vLqC4WE0fjhDdrBrULO04EUHJGp+TrVcbUPKSQB/N2JDW1ep
         16jcabUaGeXPQUc2uqX1sByzrlMjtWoq/Riop7DTcNrYopS9mdlbCne0FjB8cS0SM35b
         6/RLQql/4zMSmgJQadXCvLPfhfo5e7HjyQ/1gWm9g1MzwUMyYr5cMvhUci0nfnHY01qS
         u3HZHzNFjbHkZddOAOAermdrBvjXP/fX6iRLa236h0T0qsZJf86AavM1fASleCpW8FY9
         njtx7KQfek6NKkktH1LX1VWQBoqoe8nJvS79moF+U0JMFeto93p2ZhNCepjVDfwbH7CD
         w1ng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="X9sR/kLV";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d131sor5188742oia.142.2019.03.22.11.32.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 11:32:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="X9sR/kLV";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CZvs5mYWn4e28+5uqtuggdqZURPu2axz//pTmg1YgmQ=;
        b=X9sR/kLVxAcxdmZN0UHPrNa633koQxEqpcG4gb12JmwQY3vBk42a9KgW1LkdMtdgBG
         eMoQOF6YmegccpR0Hhgp3eFAPD95IRdoXuDo8sAHmyxHI4Rog1V+a1tY1dKws79id/S4
         p8kW+FyRvbTx5gSJSvS0W1v3zwdNXa1RRBQV0LDtTEymfbYstYB3XRhJhdJrGFSfxh0s
         ehhv0LG572q2+yLHW64XnApRdbJ0hrb3XDZpR66bCEHVMCz0kodunpDBFpnX8+fdQ5aJ
         Fc7mVerDbgMnaslHPTPPO4gzXV8T7TZJ9CoMobC4gnNrI42+F051nTe9j+5MgCsA+Z2S
         wIpw==
X-Google-Smtp-Source: APXvYqyaxjmVYHMVmLnKbIoKtJ57Ezo1AXsNqWoTxJs1xvATGCnbzouZ9oBArTEcuig8G7tdpluUOvbw8FvdPq1n7O0=
X-Received: by 2002:aca:aa57:: with SMTP id t84mr2925042oie.149.1553279543830;
 Fri, 22 Mar 2019 11:32:23 -0700 (PDT)
MIME-Version: 1.0
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz>
In-Reply-To: <20190322180532.GM32418@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Mar 2019 11:32:11 -0700
Message-ID: <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 11:06 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 22-03-19 09:57:54, Dan Williams wrote:
> > Changes since v4 [1]:
> > - Given v4 was from March of 2017 the bulk of the changes result from
> >   rebasing the patch set from a v4.11-rc2 baseline to v5.1-rc1.
> >
> > - A unit test is added to ndctl to exercise the creation and dax
> >   mounting of multiple independent namespaces in a single 128M section.
> >
> > [1]: https://lwn.net/Articles/717383/
> >
> > ---
> >
> > Quote patch7:
> >
> > "The libnvdimm sub-system has suffered a series of hacks and broken
> >  workarounds for the memory-hotplug implementation's awkward
> >  section-aligned (128MB) granularity. For example the following backtrace
> >  is emitted when attempting arch_add_memory() with physical address
> >  ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
> >  within a given section:
> >
> >   WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
> >   devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
> >   [..]
> >   Call Trace:
> >     dump_stack+0x86/0xc3
> >     __warn+0xcb/0xf0
> >     warn_slowpath_fmt+0x5f/0x80
> >     devm_memremap_pages+0x3b5/0x4c0
> >     __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
> >     pmem_attach_disk+0x19a/0x440 [nd_pmem]
> >
> >  Recently it was discovered that the problem goes beyond RAM vs PMEM
> >  collisions as some platform produce PMEM vs PMEM collisions within a
> >  given section. The libnvdimm workaround for that case revealed that the
> >  libnvdimm section-alignment-padding implementation has been broken for a
> >  long while. A fix for that long-standing breakage introduces as many
> >  problems as it solves as it would require a backward-incompatible change
> >  to the namespace metadata interpretation. Instead of that dubious route
> >  [2], address the root problem in the memory-hotplug implementation."
> >
> > The approach is taken is to observe that each section already maintains
> > an array of 'unsigned long' values to hold the pageblock_flags. A single
> > additional 'unsigned long' is added to house a 'sub-section active'
> > bitmask. Each bit tracks the mapped state of one sub-section's worth of
> > capacity which is SECTION_SIZE / BITS_PER_LONG, or 2MB on x86-64.
>
> So the hotplugable unit is pageblock now, right?

No, with this patchset the hotplug unit is 2MB.

> Why is this sufficient?

2MB is sufficient because it allows mapping a namespace at PMD
granularity and there is no practical need to go smaller.

> What prevents new and creative HW to come up with alignements that do not fit there?

There is a resource in hardware memory controllers called
address-decode-registers that control the mapping granularity. The
minimum granularity today is 64MB and the pressure as memory sizes
increases is to make that granularity larger, not smaller. So the
hardware pressure is going in the opposite direction of your concern,
at least for persistent memory.

User-defined memory namespaces have this problem, but 2MB is the
default alignment and is sufficient for most uses.

PCI Address BARs that are also mapped with devm_memremap_pages are
aligned to their size and there is no expectation to support smaller
than 2MB.

All that said, to support a smaller sub-section granularity, just add
more bits to the section-active bitmask.

> Do not get me wrong but the section
> as a unit is deeply carved into the memory hotplug and removing all those
> assumptions is a major undertaking

Right, as stated in the cover letter, this does not remove all those
assumptions, it only removes the ones that impact
devm_memremap_pages(). Specifying that sub-section is only supported
in the 'want_memblock=false' case to arch_add_memory().

> and I would like to know that you are
> not just shifting the problem to a smaller unit and a new/creative HW
> will force us to go even more complicated.

HW will not do this to us. It's software that has the problem.
Namespace creation is unnecessarily constrained to 128MB alignment.

I'm also open to exploring lifting the section alignment constraint
for the 'want_memblock=true', but first things first.

> What is the fundamental reason that pmem sections cannot be assigned
> to a section aligned memory range? The physical address space is
> quite large to impose 128MB sections IMHO. I thought this is merely a
> configuration issue.

1) it's not just hardware that imposes this, software wants to be able
to avoid the constraint

2) the flexibility of the memory controller initialization code is
constrained by address-decode-registers. So while it is simple to say
"just configure it to be aligned" it's not that easy in practice
without throwing away usable memory capacity.

> How often this really happens and how often it is unavoidable.

Again, software can cause this problem at will. Multiple shipping
systems expose this alignment problem in physical address space, for
example: https://github.com/pmem/ndctl/issues/76

> > The implication of allowing sections to be piecemeal mapped/unmapped is
> > that the valid_section() helper is no longer authoritative to determine
> > if a section is fully mapped. Instead pfn_valid() is updated to consult
> > the section-active bitmask. Given that typical memory hotplug still has
> > deep "section" dependencies the sub-section capability is limited to
> > 'want_memblock=false' invocations of arch_add_memory(), effectively only
> > devm_memremap_pages() users for now.
>
> Does this mean that pfn_valid is more expensive now? How much?

Negligible, the information to determine whether the sub-section is
valid for a given pfn is in the same cacheline as the section-valid
flag.

> Also what about the section life time?

Section is live as long as any sub-section is active.

> Who is removing section now?

Last arch_remove_memory() that removes the last sub-section clears out
the remaining sub-section active bits.

> I will probably have much more question, but it's friday and I am mostly
> offline already. I would just like to hear much more about the new
> design and resulting assumptions.

Happy to accommodate this discussion. The section alignment has been
an absolute horror to contend with. So I have years worth of pain to
share for as deep as you want to go on probing why this is needed.

