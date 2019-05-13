Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F408C46470
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:13:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64388206BF
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:13:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Kr4h++I2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64388206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E88CA6B0008; Mon, 13 May 2019 14:13:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E39846B000A; Mon, 13 May 2019 14:13:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D28B46B000C; Mon, 13 May 2019 14:13:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CD086B0008
	for <linux-mm@kvack.org>; Mon, 13 May 2019 14:13:49 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id m12so7358457pls.10
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:13:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LhHnlBi3UxeQKoJppL4krbenEEFMQ12bElAL7PpzgOg=;
        b=XxPno/BdEEuvvzPikySw9gyf4ZX2k0qY+cZWIrHOwZEapn9FjU+99izPEdhpCqpvwd
         o3X68akRp5epMzShoLiViLVWGRCKTGfXgGfGE9+dXnpp7gPrzUGEqUv5/7bDASbHjpZ7
         9VIqhelpTng2LCKZBJM5qHnsTbIjwSr7IvxBMI1e7nmBkcHxYI8wvs44FBWw9FPsVoVg
         yJOlp4sojDr1px7HCG7m5NPUgAluqBThTER6eyku59SXLBR2xzdaW91CvNgExu714QSO
         k2aa7m+jgCG+wOEhdwX5GggnxlJsY8ROJb3cRXR3VborKaM3ZJWJ1uWd0YnvC6rRbuR/
         uccw==
X-Gm-Message-State: APjAAAWWBtyzM1VTkHN8HN1Y6mlhh/UiKcUrP+AXcTD+TKvzbJ6vn/fM
	MDmWeugNALm5OpmEA7NGHQNkJCCeSV7Bu/SFMLDdxVjOIDRBihCds+nJ3cU5CiiNrY9UjEFD59J
	inIwRX9lcL1NFrWJ/JPSOEfM8UOE4U4xbaoemSe0JJYTE3cxBLFJQU1q92nk+8v8DiQ==
X-Received: by 2002:aa7:93a7:: with SMTP id x7mr35510720pff.196.1557771229062;
        Mon, 13 May 2019 11:13:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgB3DRE80krF0/6pER8Q0JQR5PFyfM/qu9DZRM1WnnSQl+DEQQotcfsCT3FEivoU0+uYNK
X-Received: by 2002:aa7:93a7:: with SMTP id x7mr35510622pff.196.1557771228337;
        Mon, 13 May 2019 11:13:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557771228; cv=none;
        d=google.com; s=arc-20160816;
        b=vFfk8qhIjn6v+tLrRRsUKIoBJEtcwrynZrcB0uDayjgjy29Tc87j5ZMQWI17buOBUW
         6v4U0bHqZj/Nb089nNDE7PxCcfhiyrzNwNXFnMwmIhiVNDCbWvgt1YALS4PNRkghWiba
         LIMQ2lRwJS7zO7uZNiRkRQrHhoDBQSrPMG1BLZWY/VcLiqrlfDmM57kwvrwjJQugVSdQ
         6gO6wAc4vh5p86uGGHUZ2dINNOFaJoopP+Y/a0oCgejDRWjhMs07CSJ8EH2qnzuUWYfR
         eBaK7zMl5KZmKlhKnsy9z9FXQ8YAgzImZYvpxfOQeWWyPJ6gpn8ZVOF8L60ShoRe6KhE
         lZuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LhHnlBi3UxeQKoJppL4krbenEEFMQ12bElAL7PpzgOg=;
        b=qNHyhp28NYPF6YzGfVFrV3Xn17cp1A+N/WUwnf25eMH5AKTvH+8MOYXP6VRgY/V9ZS
         JWvEd3QHNC7VrKM7wHHpBHQzpzjsahJ7pQpcPk2oXDH3TzoqoRf5LmsaD5Z2sSKfxEuP
         W2CXCKAX/ntIXGv51iDZAQOyrzUHeUEHGKnFbRhxlx0xyKu2Ma2lAKyhnqbfgdZQmZNp
         oudOCn7st71oE33za4PTt9jCx36YrgdX44iuoQb+7Q7tgd5Av3FSJQA3NAM999L0OOEz
         UD/SqHthH6zN3Bul0pEycll2qGfrvQOLbGrEDoNMyBiNJN8N91cu7GFSm21HiEOkC+ef
         g6OA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Kr4h++I2;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k193si16941568pge.306.2019.05.13.11.13.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 11:13:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Kr4h++I2;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f50.google.com (mail-wm1-f50.google.com [209.85.128.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id AE0AE21019
	for <linux-mm@kvack.org>; Mon, 13 May 2019 18:13:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557771227;
	bh=xJ43iv8JIVJV06BJOR4VuJn38wWKCPs7W85gx3/vesQ=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=Kr4h++I20RzmmFkfWraxMrcWykCiUWMo5cD7jMZUl9TScjEnTaCNGSOpZQ712x9Es
	 JiAUEzbZ2+437fzGeZMnpa+NXORIleALchDX+pLifwNBmHbDzh9hXNyOOpZK+nIkqf
	 JVQfKpUHOI+nklMyMK7NzcpfAx5+BRYIXL99WiV8=
Received: by mail-wm1-f50.google.com with SMTP id f2so286329wmj.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:13:47 -0700 (PDT)
X-Received: by 2002:a1c:486:: with SMTP id 128mr15655411wme.83.1557771226305;
 Mon, 13 May 2019 11:13:46 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-7-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrUzAjUFGd=xZRmCbyLfvDgC_WbPYyXB=OznwTkcV-PKNw@mail.gmail.com> <64c49aa6-e7f2-4400-9254-d280585b4067@oracle.com>
In-Reply-To: <64c49aa6-e7f2-4400-9254-d280585b4067@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 11:13:34 -0700
X-Gmail-Original-Message-ID: <CALCETrUd2UO=+JOb_008mGbPdfW5YJgQyw5H7D_CxOgaWv=gxw@mail.gmail.com>
Message-ID: <CALCETrUd2UO=+JOb_008mGbPdfW5YJgQyw5H7D_CxOgaWv=gxw@mail.gmail.com>
Subject: Re: [RFC KVM 06/27] KVM: x86: Exit KVM isolation on IRQ entry
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, 
	Radim Krcmar <rkrcmar@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 9:28 AM Alexandre Chartre
<alexandre.chartre@oracle.com> wrote:
>
>
>
> On 5/13/19 5:51 PM, Andy Lutomirski wrote:
> > On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
> > <alexandre.chartre@oracle.com> wrote:
> >>
> >> From: Liran Alon <liran.alon@oracle.com>
> >>
> >> Next commits will change most of KVM #VMExit handlers to run
> >> in KVM isolated address space. Any interrupt handler raised
> >> during execution in KVM address space needs to switch back
> >> to host address space.
> >>
> >> This patch makes sure that IRQ handlers will run in full
> >> host address space instead of KVM isolated address space.
> >
> > IMO this needs to be somewhere a lot more central.  What about NMI and
> > MCE?  Or async page faults?  Or any other entry?
> >
>
> Actually, I am not sure this is effectively useful because the IRQ
> handler is probably faulting before it tries to exit isolation, so
> the isolation exit will be done by the kvm page fault handler. I need
> to check that.
>

The whole idea of having #PF exit with a different CR3 than was loaded
on entry seems questionable to me.  I'd be a lot more comfortable with
the whole idea if a page fault due to accessing the wrong data was an
OOPS and the code instead just did the right thing directly.

--Andy

