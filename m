Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74045C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:58:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28DE220879
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 15:58:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="lEXht/Yz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28DE220879
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 974226B0007; Wed, 22 May 2019 11:58:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9248E6B0008; Wed, 22 May 2019 11:58:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 812196B000A; Wed, 22 May 2019 11:58:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f72.google.com (mail-ua1-f72.google.com [209.85.222.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59A626B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 11:58:01 -0400 (EDT)
Received: by mail-ua1-f72.google.com with SMTP id j14so580244ual.22
        for <linux-mm@kvack.org>; Wed, 22 May 2019 08:58:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=s+WN2NSpn2jB+QUHcx4gNYGLsVtBRRfA1ymT26broI0=;
        b=GX4QJcC2/UIgMlMcMHzgSy1z55yvNn3y/nhdQfPG1wXss0011FzUijsdxT3ujfsfZ2
         8HLW3K7zpQsv5bz8wxPYRTlu2GN+QNNPxuiHJqx3WksisKJWtVZh/InpGb9l3no1Mz2G
         ug0LCBCp3LCxDyFzFAPlSvmcvrNvCdK2ODU7iW+uUgbsBu0iNJSQf3P9HUjDkIBvBXuJ
         BIIT50ArcdwUVr81ojaleXRGiPDkNYaFUNUOMPRNz4UFCJuuv0vufjA6fy55DMRg13A/
         QI6zBoJ83PsoZTvfQF++8c0kN8PQq76b/WBhJ+hLm4o1ApGvkT1eP64St2Nm796FiSky
         w/3w==
X-Gm-Message-State: APjAAAXSJi5EtVhNaMqGjaoG8CixRGOvPeCDAKWJyMweawEtO0t8uqcr
	l7TjSlQaaFAWXrjlUxSk7VmKvk5vDWNAhVk8285zqgf1kNjiDXKYzeajXy8C0iKNI9SK+9I+BUX
	u2gce4X4Kyq7d8Mgq1PeZc7vhtwPXNPmk3aE7GTOedKCr1u7iPkc4sIjgdAM03+DAlQ==
X-Received: by 2002:a05:6102:c3:: with SMTP id u3mr44089763vsp.0.1558540681043;
        Wed, 22 May 2019 08:58:01 -0700 (PDT)
X-Received: by 2002:a05:6102:c3:: with SMTP id u3mr44089730vsp.0.1558540680338;
        Wed, 22 May 2019 08:58:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558540680; cv=none;
        d=google.com; s=arc-20160816;
        b=UhymmFgNVs2Mh/Kze5nIVQsb2B7XwyWrEAjgm980s6K0YKhS1teuy6wYNM8D3RmBXA
         OL4Wc2T/4NppDJZPhwWul6m9/JNQBcv+Q6hGfS8bs2wCwr73bQPQ+rBG18ujnRA55L/c
         g8BAIbFi2LOOYXdcntAM14OEnZV8799U1NtskQPGJDOxYimz9AVjowladknea20J04Ef
         2nTFjVWAjkp/fMSBLwFYQMZm4jKFlKWvrLtewF6/qQv8gb7s8HC80HCTIu18Pc2cE9JO
         JiXlj2jGaHY0D8o1tbSbjeFZJQMoP7/WH9MgzZAC8vV6AFV/SeFh4sCodr8sOuY4F9sL
         KX6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=s+WN2NSpn2jB+QUHcx4gNYGLsVtBRRfA1ymT26broI0=;
        b=qVo2SlUjls6aYZZ3o9xVP81sD9/8k0CYviK3eLl/0UNka8Vt2XyhxLeh4wMcspinyF
         mYg+Z5Z74eFIsLAirJ+DO6VL93aPSS5fqzoiyWP6bYkrBSKdvllI9BHhKVG24wJUmMsc
         zSNEa/EgrFywD0WLjWQuMAySeR3CwDnWTecT5K1LXVpeVvsEKHlmLtwnnW8arJN3Tg4N
         llVBWV/rJ4NFOJL1JcxIslqgR2VWFUpcUhwIpmfUW6RsqwPZ1Ur0vT4loUyO77QYYdKa
         moEWS1LnWcnCZfxem2zbOMfBxQvrlUjkboL0UjGit4fer8zRr+TLddOx+TXPHSflBruq
         Sabw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="lEXht/Yz";
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y128sor11342628vsc.54.2019.05.22.08.58.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 08:58:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="lEXht/Yz";
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=s+WN2NSpn2jB+QUHcx4gNYGLsVtBRRfA1ymT26broI0=;
        b=lEXht/YzHUZXrnvdt5qubD90lRzX9j1Hhl5VcHyTADFl7HzlKZD3QAkyg2J05xaB+W
         v+yjOf3FT4gNaluoicvNLlvsh1zpPzq7MIKXk+qQ8OfuPhgWCfjUsNBtvbFFQfLZmmaS
         pRfHWOPDr0Svw9fuTxYmtViBinOwFT8aK1hpeHXxkVPlFJYXmEAeS//9FgBg4FlU26Lm
         GD035e+60AW9wjRfTojUD/fXVAhoYtaTlMk9wq9qwgvlOS0yRD5tbXYTtmBa/dmL9uGb
         pAKj37gKgvWH/F1SOhOG5rKvqXgptpqEM3fRlIrPwElyc92ah4Y4Jd/79Du7582TE1IF
         IUaA==
X-Google-Smtp-Source: APXvYqyweCTnIudqCQoYfR74UirDb+xbgaCwS7136xNVmk5dacdDUaPrVVugetVcSqKqiDfJrOtZO/R40hLE8CE7dbA=
X-Received: by 2002:a67:1485:: with SMTP id 127mr15146284vsu.77.1558540679719;
 Wed, 22 May 2019 08:57:59 -0700 (PDT)
MIME-Version: 1.0
References: <20190520035254.57579-1-minchan@kernel.org> <20190521084158.s5wwjgewexjzrsm6@brauner.io>
 <20190521110552.GG219653@google.com> <20190521113029.76iopljdicymghvq@brauner.io>
 <20190521113911.2rypoh7uniuri2bj@brauner.io> <CAKOZuesjDcD3EM4PS7aO7yTa3KZ=FEzMP63MR0aEph4iW1NCYQ@mail.gmail.com>
 <CAHrFyr6iuoZ-r6e57zp1rz7b=Ee0Vko+syuUKW2an+TkAEz_iA@mail.gmail.com>
 <CAKOZueupb10vmm-bmL0j_b__qsC9ZrzhzHgpGhwPVUrfX0X-Og@mail.gmail.com>
 <20190522145216.jkimuudoxi6pder2@brauner.io> <CAKOZueu837QGDAGat-tdA9J1qtKaeuQ5rg0tDyEjyvd_hjVc6g@mail.gmail.com>
 <20190522154823.hu77qbjho5weado5@brauner.io>
In-Reply-To: <20190522154823.hu77qbjho5weado5@brauner.io>
From: Daniel Colascione <dancol@google.com>
Date: Wed, 22 May 2019 08:57:47 -0700
Message-ID: <CAKOZuev97fTvmXhEkjb7_RfDvjki4UoPw+QnVOsSAg0RB8RyMQ@mail.gmail.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
To: Christian Brauner <christian@brauner.io>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Tim Murray <timmurray@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Suren Baghdasaryan <surenb@google.com>, 
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 22, 2019 at 8:48 AM Christian Brauner <christian@brauner.io> wrote:
>
> On Wed, May 22, 2019 at 08:17:23AM -0700, Daniel Colascione wrote:
> > On Wed, May 22, 2019 at 7:52 AM Christian Brauner <christian@brauner.io> wrote:
> > > I'm not going to go into yet another long argument. I prefer pidfd_*.
> >
> > Ok. We're each allowed our opinion.
> >
> > > It's tied to the api, transparent for userspace, and disambiguates it
> > > from process_vm_{read,write}v that both take a pid_t.
> >
> > Speaking of process_vm_readv and process_vm_writev: both have a
> > currently-unused flags argument. Both should grow a flag that tells
> > them to interpret the pid argument as a pidfd. Or do you support
> > adding pidfd_vm_readv and pidfd_vm_writev system calls? If not, why
> > should process_madvise be called pidfd_madvise while process_vm_readv
> > isn't called pidfd_vm_readv?
>
> Actually, you should then do the same with process_madvise() and give it
> a flag for that too if that's not too crazy.

I don't know what you mean. My gut feeling is that for the sake of
consistency, process_madvise, process_vm_readv, and process_vm_writev
should all accept a first argument interpreted as either a numeric PID
or a pidfd depending on a flag --- ideally the same flag. Is that what
you have in mind?

