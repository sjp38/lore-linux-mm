Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9C80C606B0
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 08:40:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CEAF20838
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 08:40:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SChbYa6v"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CEAF20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E230C8E006B; Wed, 10 Jul 2019 04:40:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD3CC8E0032; Wed, 10 Jul 2019 04:40:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC2C68E006B; Wed, 10 Jul 2019 04:40:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id A2B6B8E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 04:40:24 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v72so694950oia.8
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 01:40:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Z6YmTEgTEwKg2yvsPJh1tPfsth8NlCli3K7+n36xF4o=;
        b=Dnm0CBAAf/kQMm/kow8uw9BURWZp+uyIavLVxNg16/z3wurunymLi+zajXOHONY4l1
         AlIsNHoptGIz1UlszygZHjbDcUGdOS5uR8dQQieVf4yESfAqUu4VqfsMRKEHzfRMxF0v
         U2MFLSVfk8pWGK4Iro84AFOwzhUeAMqB4C9+u8IdeIG1Q/Avfo4pV0u+Bb7g53XVwZlH
         YniSRHNyHwo1IcNLTW3zYCJ+CGdzoOET9X9+2FSBUUhnsL3jem5KKXi5D43XneKuBJPc
         6I9qMu5mYRlMULwTMP/fBA8Q0TuwqUXPipdXUP2Vl6Iyk5NGckNYyIk2DW2JKz92nVOI
         hV6Q==
X-Gm-Message-State: APjAAAUA0KfdhRMbDNPyet5tbPamxCcMjP4yqbFC5j2GuvbXSHPjOwkJ
	zgRbSsov2RCJJsZpzEO+aLVAXDls+geN2AqUJCSeSw/YJ5bYOgVceDrqEc9yY0UdiyUX9AKHzHv
	R+0rR8c9aJUillTq6NbIoAUFm6S75f4p5WBIJcZhTeYgb6Mudj7KFPk8xZoWgra35Qw==
X-Received: by 2002:a9d:4d0b:: with SMTP id n11mr8683423otf.229.1562748024293;
        Wed, 10 Jul 2019 01:40:24 -0700 (PDT)
X-Received: by 2002:a9d:4d0b:: with SMTP id n11mr8683388otf.229.1562748023463;
        Wed, 10 Jul 2019 01:40:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562748023; cv=none;
        d=google.com; s=arc-20160816;
        b=w5o0uVLqGmlJpFdtGUN+bQKZF0SLtbTU217A28U6VkkprjqKWn2CSVvp8kjkR7op33
         DFfnTo7XxH941vy1tn4ld15CNEadTkmNPcXCRmsy5oJzjPRVF8NUSnd+MQKYnvqO5+JL
         h/eR89MHq5dW/xkvh0zq9zQqD5edubqMaKX2aMUuePZZ1HF8jACfFn/NCbxlyRTXKMLd
         bjMyysTYjNGsES2RyS5OHrT3MrRPQdQ9qAXT6peuE5p8D075yenp5DUcVDm9QPlt9X91
         ZcRL0wFv6qYyQkDYJCQYmFhpggpbU89/qJXtOWMzGUzV7/284IHRNV2rWTBFKfJtQDFQ
         wjiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Z6YmTEgTEwKg2yvsPJh1tPfsth8NlCli3K7+n36xF4o=;
        b=kO3DOwqpnsYzMR2WOcgdM/Etgpx0WS4zMdH4LYLEpfMR3hHjMSZZ20KJ6958o6+R+I
         hlS0EsOq1KlUTyPdkser1MYapvn5jl+mwlBwqkJBMCtfk+QqeNfrpw17HXbGXM6Ocx5f
         n6IDnEO4uK6HECNkxRHNjHcufUReHMmsnh7eBfoV4t0aS3h8Exv9HkTcd+OiqxVuPmDy
         qTq8evRhbHK5NPpwkprh/ssR8njVvWI631Kv/lq+x++cVrzH1m+GjkYoCTcIw9AZ1cLP
         Fc57KS3Q0F9joRWEIZJOxmDklUUvUHb9P0mxIq5D/7iOrXGiIIYOCBzerGZSylC7i5Ks
         SewA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SChbYa6v;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g19sor709960oti.100.2019.07.10.01.40.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Jul 2019 01:40:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SChbYa6v;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Z6YmTEgTEwKg2yvsPJh1tPfsth8NlCli3K7+n36xF4o=;
        b=SChbYa6vqOPxSrVss4jvB9tAF5OwMipdIy0s56Usv1Xte2BSlygDBfiNDqi2CdjODl
         Ug0jrCu+bv0/xHwZxDoEA7p7qrHLq5Qjrg43WWGsFxU97ztP5tAdsTE07lPSBp7pi1Y/
         k0rD9Jlj6IQREds6kXolxrcTDAbr9qxnAWH0S7d5YXjySeQofztuYqTGmOJ0XyLirdOc
         B+lkGRWenHKBU0Y29efsJHEsE+DpBsrEU8ctJGCdyawBpkBc9zpIOf7DYiMV50yXoQZw
         0ydFObFgoNJFiGgjTiHlvwygdQe6YuN9Dl0LhsUPxsSfXcOfUpPaE5oV4aBKgjoQeXWe
         1x6g==
X-Google-Smtp-Source: APXvYqyf8ILBm+7MuZ4uDo+ul82G2IUmOV2LrKOdiouZHwiVejCLx4x6FlOy+TF5NqGRZGxV1T2S3iyyyzLIPzkC5G4=
X-Received: by 2002:a05:6602:2413:: with SMTP id s19mr17062108ioa.161.1562748023178;
 Wed, 10 Jul 2019 01:40:23 -0700 (PDT)
MIME-Version: 1.0
References: <1562300143-11671-1-git-send-email-kernelfans@gmail.com>
 <1562300143-11671-2-git-send-email-kernelfans@gmail.com> <alpine.DEB.2.21.1907072133310.3648@nanos.tec.linutronix.de>
 <CAFgQCTvwS+yEkAmCJnsCfnr0JS01OFtBnDg4cr41_GqU79A4Gg@mail.gmail.com>
 <alpine.DEB.2.21.1907081125300.3648@nanos.tec.linutronix.de>
 <CAFgQCTvAOeerLHQvgvFXy_kLs=H=CuUFjYE+UAN+vhPCG+s=pQ@mail.gmail.com>
 <alpine.DEB.2.21.1907090810490.1961@nanos.tec.linutronix.de>
 <CAFgQCTui7D6_FQ_v_ijj6k_=+TQzQ3PaGvzxd6p+XEGjQ2S6jw@mail.gmail.com> <4AF3459B-28F2-425F-8E4B-40311DEF30C6@amacapital.net>
In-Reply-To: <4AF3459B-28F2-425F-8E4B-40311DEF30C6@amacapital.net>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Wed, 10 Jul 2019 16:40:11 +0800
Message-ID: <CAFgQCTtK7G9NPQgHa_gJkr8WLzYqagBVLaqBY7-w+tirX-+w-g@mail.gmail.com>
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
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 9, 2019 at 9:34 PM Andy Lutomirski <luto@amacapital.net> wrote:
>
>
>
> > On Jul 9, 2019, at 1:24 AM, Pingfan Liu <kernelfans@gmail.com> wrote:
> >
> >> On Tue, Jul 9, 2019 at 2:12 PM Thomas Gleixner <tglx@linutronix.de> wr=
ote:
> >>
> >>> On Tue, 9 Jul 2019, Pingfan Liu wrote:
> >>>> On Mon, Jul 8, 2019 at 5:35 PM Thomas Gleixner <tglx@linutronix.de> =
wrote:
> >>>> It can and it does.
> >>>>
> >>>> That's the whole point why we bring up all CPUs in the 'nosmt' case =
and
> >>>> shut the siblings down again after setting CR4.MCE. Actually that's =
in fact
> >>>> a 'let's hope no MCE hits before that happened' approach, but that's=
 all we
> >>>> can do.
> >>>>
> >>>> If we don't do that then the MCE broadcast can hit a CPU which has s=
ome
> >>>> firmware initialized state. The result can be a full system lockup, =
triple
> >>>> fault etc.
> >>>>
> >>>> So when the MCE hits a CPU which is still in the crashed kernel lala=
 state,
> >>>> then all hell breaks lose.
> >>> Thank you for the comprehensive explain. With your guide, now, I have
> >>> a full understanding of the issue.
> >>>
> >>> But when I tried to add something to enable CR4.MCE in
> >>> crash_nmi_callback(), I realized that it is undo-able in some case (i=
f
> >>> crashed, we will not ask an offline smt cpu to online), also it is
> >>> needless. "kexec -l/-p" takes the advantage of the cpu state in the
> >>> first kernel, where all logical cpu has CR4.MCE=3D1.
> >>>
> >>> So kexec is exempt from this bug if the first kernel already do it.
> >>
> >> No. If the MCE broadcast is handled by a CPU which is stuck in the old
> >> kernel stop loop, then it will execute on the old kernel and eventuall=
y run
> >> into the memory corruption which crashed the old one.
> >>
> > Yes, you are right. Stuck cpu may execute the old do_machine_check()
> > code. But I just found out that we have
> > do_machine_check()->__mc_check_crashing_cpu() to against this case.
> >
> > And I think the MCE issue with nr_cpus is not closely related with
> > this series, can
> > be a separated issue. I had question whether Andy will take it, if
> > not, I am glad to do it.
> >
> >
>
> Go for it. I=E2=80=99m not familiar enough with the SMP boot stuff that I=
 would be able to do it any faster than you. I=E2=80=99ll gladly help revie=
w it.
I had sent out a patch to fix maxcpus "[PATCH] smp: force all cpu to
boot once under maxcpus option"
But for the case of nrcpus, I think things will not be so easy due to
percpu area, and I think it may take a quite different way.

Thanks,
  Pingfan

