Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44B61C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:13:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1F3F20866
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 16:13:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="NwGeY6c5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1F3F20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C8318E0002; Thu, 13 Jun 2019 12:13:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67AFA8E0001; Thu, 13 Jun 2019 12:13:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5683D8E0002; Thu, 13 Jun 2019 12:13:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3338E0001
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 12:13:34 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so14763191pfo.22
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:13:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=VUCobDtgsQKsDZfTD8TRRYQF1OCtIvBSiZWqVce9tQ4=;
        b=ECHh3e8L1YvUXK6/CHlDzVMDk4V041EwfzUVbD+ShsSgWNLqak0WAeV5b5OLtcKwMs
         /BvRD3NxiEYI51OqOlHp01Ye7dubt0/n3hrFJSt2a6BMexttrZLEyhWDUuinEO5cEIQ/
         05aMWyvxdJ/Ty/7nN0Mxo5oukp6izDFTPLBfS1ENtR1ns5Kj50rl1CTZTAWpGFJ237Hj
         KpYsmz7oLAP4OQwwc8lSLfisnJI0xR6KAuU86Q4FXbzDWx35SS4brgcw27+VyYORohPw
         lB21mwj+jiZwDhSqe9WNdz+poCWgyqhL7uB/yG28QJkdFM3WGZSx1rf/XSmaxGv5g+xG
         CFkg==
X-Gm-Message-State: APjAAAVOS16Gab1rHZgmojJ8w5/mqSk5iHQ9yXZ3MIqDXScjZzNZk5VB
	zTc8kN7o0LzKhbd9IMfZxrAqFap5CxCb+gukJhRRhJtalYU/xohLaaI1TaST/n16ZcKczLyvAaB
	nVl7uPXywwPUsTo94/ZL2VcJ698hLzi62wwqNSQXunH/PYYtvOOpWC1LJzSm/TvlvqA==
X-Received: by 2002:a63:684:: with SMTP id 126mr26118488pgg.401.1560442413517;
        Thu, 13 Jun 2019 09:13:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMjQmlzT4l1SUvB5pLI6uVV7GKWnUgbwRan4iH6NuDhBxAKaiHciCcouXjddSIzdQOMxrk
X-Received: by 2002:a63:684:: with SMTP id 126mr26118432pgg.401.1560442412481;
        Thu, 13 Jun 2019 09:13:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560442412; cv=none;
        d=google.com; s=arc-20160816;
        b=OdP7vpiUQSaeI1IrPj+N6Uk2asEorT8hPyehklqryoJVmqFR6nS6Z//C/PeQ0RWKdU
         YdJ3x+LYH7LhR6H5ZS4m88M3Z2B+Z9v+6bo0GiJlqE2oyn70v6dgFNc2Ka9B7V1lzKbg
         IaSADZYdCg0evSYDc97jHkzXKnYsJCnsk09hNo+IdbZcj8KhOcubKrYNw/fpQNDJusbb
         EPotq38XRAk/sXjl5SRE5QBV3qx+vS0n1jTT+yBcSorscE52PS2ymPTZpYMxxNXog71n
         lox9CWPo8qvs7mdGmddBCNb1h6bBEuq7DHzuhSomfJ3EKFmRUywJpIxlq3YUTxT1yapO
         4wcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=VUCobDtgsQKsDZfTD8TRRYQF1OCtIvBSiZWqVce9tQ4=;
        b=kKyZITzvvjW8zduJIveYs6OyD8EvA5G4sYqbbc8C+UYdOwDQKMFaeHWXTjgq7Z01lz
         6xTzSRlmrmRu1ziLifALGM638Ht3cranve8QBbN3+3dKxkCcBPAR8Io/jBhEo62F7YoI
         XjCRHvgHPRAfIFugKn4fnu0ur3Jhf2GO+WqU27QfmShOXwkHrujKedAj1BbnZrA7EmPj
         aD80l2Kdf8hnBn2a+rniSnpGT6VeWxglqWSKJcg2yD0Zyfb2ox5A78wyZ7EJ26Wk4bJJ
         1FufLiAKFeoAKcZmfk9i2Q9aKF6AjeC/HAeGpQnTP/tR8HQ1OA7fpkgo5cXQc8WtPNuI
         eTdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NwGeY6c5;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a123si33200pfd.114.2019.06.13.09.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 09:13:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=NwGeY6c5;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f52.google.com (mail-wm1-f52.google.com [209.85.128.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id CEB3A21848
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:13:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560442412;
	bh=RT5ARPzRqXVzJnJRWsb4aSjhGlmdp5Dxz378/CaIaL8=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=NwGeY6c5yx5u+vAf+WFQFGDxu4tJunZee5S3v8/3Qa+DA8OJcbCm8FmnWlW22EeIo
	 pvPbgqFLEzgMn1IjNleSrLm81jYN3yBQ71Ciz8HfYJq/FtRHBbbhMiZLbPlFV0PnuP
	 ocg5sCTo1sMNGcufG6vv6SGvTttlwV0I45IEbCZo=
Received: by mail-wm1-f52.google.com with SMTP id a15so10807334wmj.5
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 09:13:31 -0700 (PDT)
X-Received: by 2002:a7b:cd84:: with SMTP id y4mr4464357wmj.79.1560442410236;
 Thu, 13 Jun 2019 09:13:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net> <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
 <459e2273-bc27-f422-601b-2d6cdaf06f84@amazon.com>
In-Reply-To: <459e2273-bc27-f422-601b-2d6cdaf06f84@amazon.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 13 Jun 2019 09:13:19 -0700
X-Gmail-Original-Message-ID: <CALCETrVRuQb-P7auHCgxzs5L=qA2_qHzVGTtRMAqoMAut0ETFw@mail.gmail.com>
Message-ID: <CALCETrVRuQb-P7auHCgxzs5L=qA2_qHzVGTtRMAqoMAut0ETFw@mail.gmail.com>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
To: Alexander Graf <graf@amazon.com>, Nadav Amit <namit@vmware.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, 
	Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, 
	"the arch/x86 maintainers" <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 12:53 AM Alexander Graf <graf@amazon.com> wrote:
>
>
> On 13.06.19 03:30, Andy Lutomirski wrote:
> > On Wed, Jun 12, 2019 at 1:27 PM Andy Lutomirski <luto@amacapital.net> w=
rote:
> >>
> >>
> >>> On Jun 12, 2019, at 12:55 PM, Dave Hansen <dave.hansen@intel.com> wro=
te:
> >>>
> >>>> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
> >>>> This patch series proposes to introduce a region for what we call
> >>>> process-local memory into the kernel's virtual address space.
> >>> It might be fun to cc some x86 folks on this series.  They might have
> >>> some relevant opinions. ;)
> >>>
> >>> A few high-level questions:
> >>>
> >>> Why go to all this trouble to hide guest state like registers if all =
the
> >>> guest data itself is still mapped?
> >>>
> >>> Where's the context-switching code?  Did I just miss it?
> >>>
> >>> We've discussed having per-cpu page tables where a given PGD is only =
in
> >>> use from one CPU at a time.  I *think* this scheme still works in suc=
h a
> >>> case, it just adds one more PGD entry that would have to context-swit=
ched.
> >> Fair warning: Linus is on record as absolutely hating this idea. He mi=
ght change his mind, but it=E2=80=99s an uphill battle.
> > I looked at the patch, and it (sensibly) has nothing to do with
> > per-cpu PGDs.  So it's in great shape!
>
>
> Thanks a lot for the very timely review!
>
>
> >
> > Seriously, though, here are some very high-level review comments:
> >
> > Please don't call it "process local", since "process" is meaningless.
> > Call it "mm local" or something like that.
>
>
> Naming is hard, yes :). Is "mmlocal" obvious enough to most readers? I'm
> not fully convinced, but I don't find it better or worse than proclocal.
> So whatever flies with the majority works for me :).

My objection to "proc" is that we have many concepts of "process" in
the kernel: task, mm, signal handling context, etc.  These memory
ranges are specifically local to the mm.  Admittedly, it would be very
surprising to have memory that is local to a signal handling context,
but still.

>
>
> > We already have a per-mm kernel mapping: the LDT.  So please nix all
> > the code that adds a new VA region, etc, except to the extent that
> > some of it consists of valid cleanups in and of itself.  Instead,
> > please refactor the LDT code (arch/x86/kernel/ldt.c, mainly) to make
> > it use a more general "mm local" address range, and then reuse the
> > same infrastructure for other fancy things.  The code that makes it
>
>
> I don't fully understand how those two are related. Are you referring to
> the KPTI enabling code in there? That just maps the LDT at the same
> address in both kernel and user mappings, no?

The relevance here is that, when KPTI is on, the exact same address
refers to a different LDT in different mms, so it's genuinely an
mm-local mapping.  It works just like yours: a whole top-level paging
entry is reserved for it.  What I'm suggesting is that, when you're
all done, the LDT should be more or less just one more mm-local
mapping, with two caveats.  First, the LDT needs special KPTI
handling, but that's fine.  Second, the LDT address is visible to user
code on non-UMIP systems, so you'll have to decide if that's okay.  My
suggestion is to have the LDT be the very first address in the
mm-local range and then to randomize everything else in the mm-local
range.

>
> So you're suggesting we use the new mm local address as LDT address
> instead and have that mapped in both kernel and user space? This patch
> set today maps "mm local" data only in kernel space, not in user space,
> as it's meant for kernel data structures.

Yes, exactly.

>
> So I'm not really seeing the path to adapt any of the LDT logic to this.
> Could you please elaborate?
>
>
> > KASLR-able should be in its very own patch that applies *after* the
> > code that makes it all work so that, when the KASLR part causes a
> > crash, we can bisect it.
>
>
> That sounds very reasonable, yes.
>
>
> >
> > + /*
> > + * Faults in process-local memory may be caused by process-local
> > + * addresses leaking into other contexts.
> > + * tbd: warn and handle gracefully.
> > + */
> > + if (unlikely(fault_in_process_local(address))) {
> > + pr_err("page fault in PROCLOCAL at %lx", address);
> > + force_sig_fault(SIGSEGV, SEGV_MAPERR, (void __user *)address, current=
);
> > + }
> > +
> >
> > Huh?  Either it's an OOPS or you shouldn't print any special
> > debugging.  As it is, you're just blatantly leaking the address of the
> > mm-local range to malicious user programs.
>
>
> Yes, this is a left over bit from an idea that we discussed and rejected
> yesterday. The idea was to have a DEBUG config option that allows
> proclocal memory to leak into other processes, but print debug output so
> that it's easier to catch bugs. After discussion, I think we managed to
> convince everyone that an OOPS is the better tool to find bugs :).
>
> Any trace of this will disappear in the next version.
>
>
> >
> > Also, you should IMO consider using this mechanism for kmap_atomic().
>
>
> It might make sense to use it for kmap_atomic() for debug purposes, as
> it ensures that other users can no longer access the same mapping
> through the linear map. However, it does come at quite a big cost, as we
> need to shoot down the TLB of all other threads in the system. So I'm
> not sure it's of general value?

What I meant was that kmap_atomic() could use mm-local memory so that
it doesn't need to do a global shootdown.  But I guess it's not
actually used for real on 64-bit, so this is mostly moot.  Are you
planning to support mm-local on 32-bit?

--Andy
>
>
> Alex
>
>
> > Hi, Nadav!

