Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04986C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:26:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C313B2063F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:26:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C313B2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61AFB6B0288; Thu, 15 Aug 2019 14:26:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CC896B030C; Thu, 15 Aug 2019 14:26:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E43F6B030D; Thu, 15 Aug 2019 14:26:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 27F126B0288
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:26:58 -0400 (EDT)
Received: from smtpin17.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CBC516D82
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:26:57 +0000 (UTC)
X-FDA: 75825493674.17.stew20_59beb948da31a
X-HE-Tag: stew20_59beb948da31a
X-Filterd-Recvd-Size: 7323
Received: from mail-ed1-f67.google.com (mail-ed1-f67.google.com [209.85.208.67])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:26:56 +0000 (UTC)
Received: by mail-ed1-f67.google.com with SMTP id g8so2908803edm.6
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 11:26:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=mz7rJ/URdRDQjZL145hyuM17KSbfOM61Ih9LSnGlxDs=;
        b=jWyfMYJc85suEGcprrcQWyY42utF0ie3y5canB+BK0q7GJY5T0yFRAnh6nXNN1Dqxo
         7GUi6Ko6QoNsLk4ipdcnMdmvFHNEP6/FLOCr/CHs8kEE6ilQRdcH3Cg1FzF2fL57FUGy
         5LdHB/xsqrQVEBorOELx7JvRHKsk5f+Kkk0ptgmSfuaA23lnQkNmntHZdGlqiVUxxcqX
         8eJ8CM2zmKufdN5LxFND4tLEAvKeZ7vt4zsURKp1NpfzNPZ1uwMA5wbirtktEAbVBXW1
         y/s/p1QQzA0tZ2nPoI4H9UUBMspwRPjheHoIV4TFS2lY1gkkaxOrY/o4Wv7+Yjd/lF9n
         wfTQ==
X-Gm-Message-State: APjAAAWigxkpa0oV0DVx/VWJu8LH5kvQrMhNzO2Z/fhz1EvlijuXzrwB
	mnhtX2q7sc5Kukova/ZHoEaYTDo7B9fpjznEyC8dZA==
X-Google-Smtp-Source: APXvYqyScduG+EH4jmYr9WMzpZ3dCYyd0cnjTaxtv6Rg8QOToS2vj2KHqhRAHz/M9hJU7fYo7PwAwDr/KG/u9XOHmw4=
X-Received: by 2002:a17:906:e009:: with SMTP id cu9mr5720680ejb.267.1565893615419;
 Thu, 15 Aug 2019 11:26:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190813191435.GB10228@bharath12345-Inspiron-5559>
 <54182261-88a4-9970-1c3c-8402e130dcda@redhat.com> <20190815171834.GA14342@bharath12345-Inspiron-5559>
In-Reply-To: <20190815171834.GA14342@bharath12345-Inspiron-5559>
From: Paolo Bonzini <pbonzini@redhat.com>
Date: Thu, 15 Aug 2019 20:26:43 +0200
Message-ID: <CABgObfbQOS28cG_9Ca_2OXbLmDy_hwUkuqPnzJG5=FZ5sEYGfA@mail.gmail.com>
Subject: Re: [Question-kvm] Can hva_to_pfn_fast be executed in interrupt context?
To: Bharath Vedartham <linux.bhar@gmail.com>
Cc: Radim Krcmar <rkrcmar@redhat.com>, kvm <kvm@vger.kernel.org>, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, khalid.aziz@oracle.com
Content-Type: multipart/alternative; boundary="000000000000b41b8c05902c042a"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000b41b8c05902c042a
Content-Type: text/plain; charset="UTF-8"

Oh, I see. Sorry I didn't understand the question. In the case of KVM,
there's simply no code that runs in interrupt context and needs to use
virtual addresses.

In fact, there's no code that runs in interrupt context at all. The only
code that deals with host interrupts in a virtualization host is in VFIO,
but all it needs to do is signal an eventfd.

Paolo


Il gio 15 ago 2019, 19:18 Bharath Vedartham <linux.bhar@gmail.com> ha
scritto:

> On Tue, Aug 13, 2019 at 10:17:09PM +0200, Paolo Bonzini wrote:
> > On 13/08/19 21:14, Bharath Vedartham wrote:
> > > Hi all,
> > >
> > > I was looking at the function hva_to_pfn_fast(in virt/kvm/kvm_main)
> which is
> > > executed in an atomic context(even in non-atomic context, since
> > > hva_to_pfn_fast is much faster than hva_to_pfn_slow).
> > >
> > > My question is can this be executed in an interrupt context?
> >
> > No, it cannot for the reason you mention below.
> >
> > Paolo
> hmm.. Well I expected the answer to be kvm specific.
> Because I observed a similar use-case for a driver (sgi-gru) where
> we want to retrive the physical address of a virtual address. This was
> done in atomic and non-atomic context similar to hva_to_pfn_fast and
> hva_to_pfn_slow. __get_user_pages_fast(for atomic case)
> would not work as the driver could execute in interrupt context.
>
> The driver manually walked the page tables to handle this issue.
>
> Since kvm is a widely used piece of code, I asked this question to know
> how kvm handled this issue.
>
> Thank you for your time.
>
> Thank you
> Bharath
> > > The motivation for this question is that in an interrupt context, we
> cannot
> > > assume "current" to be the task_struct of the process of interest.
> > > __get_user_pages_fast assume current->mm when walking the process page
> > > tables.
> > >
> > > So if this function hva_to_pfn_fast can be executed in an
> > > interrupt context, it would not be safe to retrive the pfn with
> > > __get_user_pages_fast.
> > >
> > > Thoughts on this?
> > >
> > > Thank you
> > > Bharath
> > >
> >
>

--000000000000b41b8c05902c042a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">Oh, I see. Sorry I didn&#39;t understand the question. In=
 the case of KVM, there&#39;s simply no code that runs in interrupt context=
 and needs to use virtual addresses.<div dir=3D"auto"><br></div><div dir=3D=
"auto">In fact, there&#39;s no code that runs in interrupt context at all. =
The only code that deals with host interrupts in a virtualization host is i=
n VFIO, but all it needs to do is signal an eventfd.</div><div dir=3D"auto"=
><br></div><div dir=3D"auto">Paolo</div><div dir=3D"auto"><br></div></div><=
br><div class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">Il gio =
15 ago 2019, 19:18 Bharath Vedartham &lt;<a href=3D"mailto:linux.bhar@gmail=
.com">linux.bhar@gmail.com</a>&gt; ha scritto:<br></div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">On Tue, Aug 13, 2019 at 10:17:09PM +0200, Paolo Bonzini wrote=
:<br>
&gt; On 13/08/19 21:14, Bharath Vedartham wrote:<br>
&gt; &gt; Hi all,<br>
&gt; &gt; <br>
&gt; &gt; I was looking at the function hva_to_pfn_fast(in virt/kvm/kvm_mai=
n) which is <br>
&gt; &gt; executed in an atomic context(even in non-atomic context, since<b=
r>
&gt; &gt; hva_to_pfn_fast is much faster than hva_to_pfn_slow).<br>
&gt; &gt; <br>
&gt; &gt; My question is can this be executed in an interrupt context? <br>
&gt; <br>
&gt; No, it cannot for the reason you mention below.<br>
&gt; <br>
&gt; Paolo<br>
hmm.. Well I expected the answer to be kvm specific. <br>
Because I observed a similar use-case for a driver (sgi-gru) where <br>
we want to retrive the physical address of a virtual address. This was<br>
done in atomic and non-atomic context similar to hva_to_pfn_fast and<br>
hva_to_pfn_slow. __get_user_pages_fast(for atomic case) <br>
would not work as the driver could execute in interrupt context.<br>
<br>
The driver manually walked the page tables to handle this issue.<br>
<br>
Since kvm is a widely used piece of code, I asked this question to know<br>
how kvm handled this issue. <br>
<br>
Thank you for your time.<br>
<br>
Thank you<br>
Bharath<br>
&gt; &gt; The motivation for this question is that in an interrupt context,=
 we cannot<br>
&gt; &gt; assume &quot;current&quot; to be the task_struct of the process o=
f interest.<br>
&gt; &gt; __get_user_pages_fast assume current-&gt;mm when walking the proc=
ess page<br>
&gt; &gt; tables. <br>
&gt; &gt; <br>
&gt; &gt; So if this function hva_to_pfn_fast can be executed in an<br>
&gt; &gt; interrupt context, it would not be safe to retrive the pfn with<b=
r>
&gt; &gt; __get_user_pages_fast. <br>
&gt; &gt; <br>
&gt; &gt; Thoughts on this?<br>
&gt; &gt; <br>
&gt; &gt; Thank you<br>
&gt; &gt; Bharath<br>
&gt; &gt; <br>
&gt; <br>
</blockquote></div>

--000000000000b41b8c05902c042a--

