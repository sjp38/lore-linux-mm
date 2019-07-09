Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20CBAC606B0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 04:26:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4F172166E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 04:26:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ew4aZcCm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4F172166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5376F8E003D; Tue,  9 Jul 2019 00:26:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C2268E0032; Tue,  9 Jul 2019 00:26:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AE8C8E003D; Tue,  9 Jul 2019 00:26:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9988E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 00:26:49 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id u25so21462917iol.23
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 21:26:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=BmVuYRL/YC6C6PnxH4vV3jTMGA9VP+9lw/llQAyxkBg=;
        b=nZaacllsmLaGrv0fWFSLyyHrt2wzrDSdu1zH0J1I9eaC7t9dPk7w9YeYD690fkYL37
         mPRxjzz6uTh26Z5b9dYKCyWkVSO5IBh2npqp+L18gVrSYh8eZv+QEwB1LUeE3LZinSpb
         lQw93eTfBbh9FimPa21eR+8d9h6PuVR8RFDalUroCIReRElDCULvoN78vGRNHe5dxhF5
         vlsYeTdAhmC9etOqsCiQKRzTp0t6MM0jKYhGBH+kiaNDIuE6i7GMJhvC7JQ9edEYurSa
         8tdhvZtWU8m8P0RTttRa37lvX6OcihR2CzQ+nAcZILJ+BmacfF1EHtv6znMQuQ0Io3YO
         LrUA==
X-Gm-Message-State: APjAAAUSp5Mzwbif3axvSzIkQFPhnSBHhTuwmS9iC++OfKTspSC9xCQ2
	nM2xjj14+bVIxjXaSaVQ0gPDpRWCORIv5XKFO2Ge7ZbUn8ULbvNiqxB5FpX+FI2Nbr/blRptMJu
	L/aqsf08xUXzexOdb56lS3VU/mBct+XOpuKFs8kFmooN2XVjHjHEudLZtJeetSQ8VhQ==
X-Received: by 2002:a6b:7602:: with SMTP id g2mr5663415iom.82.1562646408872;
        Mon, 08 Jul 2019 21:26:48 -0700 (PDT)
X-Received: by 2002:a6b:7602:: with SMTP id g2mr5663374iom.82.1562646408108;
        Mon, 08 Jul 2019 21:26:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562646408; cv=none;
        d=google.com; s=arc-20160816;
        b=WX+Yv9BP5pOICLOWQ5zKkB607ZNJZAVEZ4SW1UZAtu6J54ix9+z3y24j06UU63/UPd
         WUqVwIwxDuW0uIRA73WTEWnBYO02ZxWBprMBFK67ElQb7Sp03TENrhXmWcE85CBiatP0
         MLCIllHCEKvXxNXc7uT2b/6lpYNJFSb2WPcbjOpZZb2YAO9EtdrEmeT4+hKcqG9xjlNk
         08MKKo8U2T3G6K/Oeqts+NgBugrAsfv8ivhQNbwVjLTXnYj/UDKFtDK5kgJr/h1+jLBd
         ZGBXsHHcbczesI663DxPTj/q6btthWnywOP+4J/2nzRD7ao4/CQgSLQUpu8rigMQaq40
         60vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=BmVuYRL/YC6C6PnxH4vV3jTMGA9VP+9lw/llQAyxkBg=;
        b=bNxahHc0Gniz84qYtNpBELJtgw46PhzD6/hQD2kC6ZJ9cVH1WxL/aECisZSgbXIBdO
         rPDoe4P9f7gqA34wHqFOeLgRdcdBTOQ4FpUjuCgP63Dm6fcQ6iWjG+fu3c9CDPwIwEAX
         CxjTlGGbiH/3dqyzFlViYwjXEde4q6qhZsT89l3P3JemJi7VJu8utJfSm2EZGITSgWWz
         MeiTZT09NiORkP3Na8H30skLx5olcCGg8YFyOM/y38qMpyxdtdHKyLDJSgyES8gYQBFC
         uVO+Xw8t79WEe+LNjHK8FubyP85HfzFGSzg/1s02++qnGAauxdP+34niF6FWBwKeBOQS
         5lpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ew4aZcCm;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor13861169ion.88.2019.07.08.21.26.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 21:26:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ew4aZcCm;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=BmVuYRL/YC6C6PnxH4vV3jTMGA9VP+9lw/llQAyxkBg=;
        b=ew4aZcCmpjGmFWDW8siF/BrPgX3FR5qAVzERtLgz8rRdcuR3idhlhNSMrgwGku0nx4
         xhZiQmKXiYXi7jS2m9xM1FocxBPmMXRNNXK5R2tGHqWhesDAn/25feA+AMh0X/L5Y51/
         bVH3VuiR9KQKKF8paUydvu8dtLu5r0QKnyJ3/snjs+jNTLs290JIfQxADm+6cm4uf+aZ
         42ETGgoPrvSB8Ai1C75ay+Vq48f46dYveS2qMraSkuPAobgqL2cH6ze/2byQkasTMhbz
         ug5ekuGqJ3NGRKO0MrsvSyuGs8uaQA7RD2HUTWydE0Hql1bvQbQSt4X3Eb6xkhfpFq5Z
         hyrQ==
X-Google-Smtp-Source: APXvYqyVYVFUVr/X3uVeEDff/cgHxGFpn0LdvW+6E+RG/yMcEOavu7GrtSViZnTYAOoXpWbAYswf/wl5BqyHT62FVS0=
X-Received: by 2002:a6b:4107:: with SMTP id n7mr342946ioa.12.1562646407823;
 Mon, 08 Jul 2019 21:26:47 -0700 (PDT)
MIME-Version: 1.0
References: <1562300143-11671-1-git-send-email-kernelfans@gmail.com>
 <1562300143-11671-2-git-send-email-kernelfans@gmail.com> <alpine.DEB.2.21.1907072133310.3648@nanos.tec.linutronix.de>
 <CAFgQCTvwS+yEkAmCJnsCfnr0JS01OFtBnDg4cr41_GqU79A4Gg@mail.gmail.com>
 <alpine.DEB.2.21.1907081125300.3648@nanos.tec.linutronix.de> <18D4CC9F-BC2C-4C82-873E-364CD1795EFB@amacapital.net>
In-Reply-To: <18D4CC9F-BC2C-4C82-873E-364CD1795EFB@amacapital.net>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 9 Jul 2019 12:26:36 +0800
Message-ID: <CAFgQCTvTB_QYANc4TJOUXVzeKhn4TXsgjRLrPuXkRxKjgGC6pA@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86/numa: instance all parsed numa node
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, x86@kernel.org, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, 
	Pavel Tatashin <pavel.tatashin@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Qian Cai <cai@lca.pw>, Barret Rhoden <brho@google.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 9, 2019 at 1:53 AM Andy Lutomirski <luto@amacapital.net> wrote:
>
>
>
> > On Jul 8, 2019, at 3:35 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> >
> >> On Mon, 8 Jul 2019, Pingfan Liu wrote:
> >>> On Mon, Jul 8, 2019 at 3:44 AM Thomas Gleixner <tglx@linutronix.de> wrote:
> >>>
> >>>> On Fri, 5 Jul 2019, Pingfan Liu wrote:
> >>>>
> >>>> I hit a bug on an AMD machine, with kexec -l nr_cpus=4 option. nr_cpus option
> >>>> is used to speed up kdump process, so it is not a rare case.
> >>>
> >>> But fundamentally wrong, really.
> >>>
> >>> The rest of the CPUs are in a half baken state and any broadcast event,
> >>> e.g. MCE or a stray IPI, will result in a undiagnosable crash.
> >> Very appreciate if you can pay more word on it? I tried to figure out
> >> your point, but fail.
> >>
> >> For "a half baked state", I think you concern about LAPIC state, and I
> >> expand this point like the following:
> >
> > It's not only the APIC state. It's the state of the CPUs in general.
> >
> >> For IPI: when capture kernel BSP is up, the rest cpus are still loop
> >> inside crash_nmi_callback(), so there is no way to eject new IPI from
> >> these cpu. Also we disable_local_APIC(), which effectively prevent the
> >> LAPIC from responding to IPI, except NMI/INIT/SIPI, which will not
> >> occur in crash case.
> >
> > Fair enough for the IPI case.
> >
> >> For MCE, I am not sure whether it can broadcast or not between cpus,
> >> but as my understanding, it can not. Then is it a problem?
> >
> > It can and it does.
> >
> > That's the whole point why we bring up all CPUs in the 'nosmt' case and
> > shut the siblings down again after setting CR4.MCE. Actually that's in fact
> > a 'let's hope no MCE hits before that happened' approach, but that's all we
> > can do.
> >
> > If we don't do that then the MCE broadcast can hit a CPU which has some
> > firmware initialized state. The result can be a full system lockup, triple
> > fault etc.
> >
> > So when the MCE hits a CPU which is still in the crashed kernel lala state,
> > then all hell breaks lose.
> >
> >> From another view point, is there any difference between nr_cpus=1 and
> >> nr_cpus> 1 in crashing case? If stray IPI raises issue to nr_cpus>1,
> >> it does for nr_cpus=1.
> >
> > Anything less than the actual number of present CPUs is problematic except
> > you use the 'let's hope nothing happens' approach. We could add an option
> > to stop the bringup at the early online state similar to what we do for
> > 'nosmt'.
> >
> >
>
> How about we change nr_cpus to do that instead so we never have to have this conversation again?
Are you interest in implementing this?

Thanks,
  Pingfan

