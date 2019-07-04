Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89F58C0650E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 06:59:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C07A2133F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 06:59:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NyQvpTPd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C07A2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 606016B0003; Thu,  4 Jul 2019 02:59:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B7E78E0003; Thu,  4 Jul 2019 02:59:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 458648E0001; Thu,  4 Jul 2019 02:59:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0AC66B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 02:59:54 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id e16so1177955lja.23
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 23:59:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5hoRVzA4RE826A1I76EnR+QMic6YSipDsikJJZV2kHE=;
        b=mAhzX1+hkCBD5/srJE76uBqnPwfb15d4gWY1jyZtZ6tjV4c9/a0KsB/cpR9DVY9z6I
         l+RJ9F0PJ59aSqpPj0WY3UI7a48Eqa1QvQBVOaUUr13r853l8a9F+S4CJALPlFASVXTl
         74DtTd3i1vu3YFvWxHcmYaE5TQ3jMKeXVBipKK1YR1oUGbTlSnRfOk/SEP8/hEK6oOWp
         7zmKOusoNMc8UnahvM+JsHjDGVA0nWwaSgg+6/u0m2qCHNC0HVg3PnieCxwPhHdMc3jw
         Joxx0yTnPt9YLBOYGAO69snqDWgx/Wv8J97qxpVWtsqrHGYkUAo/U9V2grDEGAdHQhMQ
         1vww==
X-Gm-Message-State: APjAAAVD1K9Lg/+K1S/O4kNEgSYUUQpVdktIus3L7c1xja0RPiw5g0ah
	jszQ5EMBfgOZGPmEAb1UpXPYM6ovrYtpsgSAx1qPEKT2SlICSRA3FIzQbSypfO+x9PkJzQ4dWM3
	7H+lG9vYp46q8WU9uLtXC38NF3niD3qfWYABHj5Kd4p2UKQrhRdeCMVifKq5iKO/5fw==
X-Received: by 2002:a19:ed07:: with SMTP id y7mr21029589lfy.56.1562223594006;
        Wed, 03 Jul 2019 23:59:54 -0700 (PDT)
X-Received: by 2002:a19:ed07:: with SMTP id y7mr21029551lfy.56.1562223593195;
        Wed, 03 Jul 2019 23:59:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562223593; cv=none;
        d=google.com; s=arc-20160816;
        b=Rw1bKNxkw1U98A2jwSYV5a4mSVI3R7TQNursF3TLMTaD8dlKVqqtQsjZIxN12Chhv7
         /NNyNKT3EBV8lqjumX3u1ho2/cNt66eh6+xqlCgJkv2VH2sBKuJzJxYoWtzFw5s3zdr6
         Hm7QEPrR+nsxxivpUr1VV6R+jJXtNg+JZbcafrxENKdPHJBeTXGO3T8HqnPYh9gorvK+
         JCtDQmQQIQAQeZe/Kc4kOVlLlmnM3Kj2IidakCw0VIW+1u5Lfc3gDBS3J+/MgBh8sNmW
         0/RsW/Bd/yZGcR41S6nM1EBdqAvDa9QM7ntVHUbnMAvsBi84eDh5D3k0/6Vb4pkPta2T
         Ff5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5hoRVzA4RE826A1I76EnR+QMic6YSipDsikJJZV2kHE=;
        b=DEz5ACKBG04QPrnbKuHwRpZmKDsqkIlr8L1bimzWiVx6aMhszLLATDJZKM2vlWoFxf
         5IZP8jkjz3L136oQ0zdW5XdBSAKXuxYHhnxduDa4OjylfUOOjqa8ua+lFYkqC56kIgRR
         mv3Xnjk185yVFw/h9Ex6RfMaqDTH3z//aZBMyZE8Gw5wSUiMTCzMTMdThp3reLYJiNAP
         wxccg1CEmeQSczfo5OME3+e/U0MZaDyCnhRmcMkPCrT/7obgKlXx4+TZvOox3EBBd1ht
         hbRGyVm3VxnGQ1l+3vNmNN6oSpCH+FMQSLkmD6bE3NE7SizxiDxLwPCTbHrF3ZHo7ofi
         lV2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NyQvpTPd;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t19sor2811720ljc.15.2019.07.03.23.59.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 23:59:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NyQvpTPd;
       spf=pass (google.com: domain of vitalywool@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vitalywool@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5hoRVzA4RE826A1I76EnR+QMic6YSipDsikJJZV2kHE=;
        b=NyQvpTPd571IOxhdQq+w6aslQrUxmrTQfjXU7SWj5Liz6CdmeOxYhNmXtlqBTscAXW
         XrWNJx0vanHYRLpxTANpYQGpfcdJk8Yx9A2O5MGQjw0lMmoE1v1LgaTqnm2ZVTTyKMPz
         ysGnZP8S3xFMDFnlsKmAAmvsQ8Wqxu+8nSRAI2eJR85Ntld8mr0hr6cJp2D7epRAQkSG
         ZEAovlKmk+KuGWstaAfHSPJE9rHL6o12dDlQiwWnYR70aOvSYyAFdNQr+7qaY8k9GSg1
         FCsNr8reWcEHyiL8X2H2FZYH5uCuZVXevE2VCvQqK0PdEtK20RgFLXeATvb8azmq5KUJ
         96jA==
X-Google-Smtp-Source: APXvYqy7b0MBpHABM577oGfvv4PrjBn8uHghNuqy1osjwetzPOKJdSrtXrZxyaR8FvyD+Ih93m709dc1n5bkXzr6lAE=
X-Received: by 2002:a2e:2b8f:: with SMTP id r15mr22873736ljr.210.1562223592718;
 Wed, 03 Jul 2019 23:59:52 -0700 (PDT)
MIME-Version: 1.0
References: <20190701173042.221453-1-henryburns@google.com>
 <CAMJBoFPbRcdZ+NnX17OQ-sOcCwe+ZAsxcDJoR0KDkgBY9WXvpg@mail.gmail.com>
 <CAGQXPTjX=7aD9MQAs2kJthFvPdd3x8Nh53oc=wZCXH_dvDJ=Vg@mail.gmail.com>
 <CAMJBoFMBLv9OpXtQkOAyZ-vw5Ktk1tYtvfT=GPPx8jnKBN01rg@mail.gmail.com> <CALvZod57CZ20SG0eYu95=PDqJ+adoiUErdgAmhc_+qxDo68GoA@mail.gmail.com>
In-Reply-To: <CALvZod57CZ20SG0eYu95=PDqJ+adoiUErdgAmhc_+qxDo68GoA@mail.gmail.com>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Thu, 4 Jul 2019 09:59:41 +0300
Message-ID: <CAMJBoFMq1sOiAWbTMK3hwwicsmRTPH55k566Tsd3r33+FQB_5g@mail.gmail.com>
Subject: Re: [PATCH] mm/z3fold: Fix z3fold_buddy_slots use after free
To: Shakeel Butt <shakeelb@google.com>
Cc: Henry Burns <henryburns@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vitaly Vul <vitaly.vul@sony.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Xidong Wang <wangxidong_97@163.com>, Jonathan Adams <jwadams@google.com>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: multipart/alternative; boundary="0000000000004dc571058cd58684"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000004dc571058cd58684
Content-Type: text/plain; charset="UTF-8"

On Wed, Jul 3, 2019, 10:14 PM Shakeel Butt <shakeelb@google.com> wrote:

> On Tue, Jul 2, 2019 at 11:03 PM Vitaly Wool <vitalywool@gmail.com> wrote:
> >
> > On Tue, Jul 2, 2019 at 6:57 PM Henry Burns <henryburns@google.com>
> wrote:
> > >
> > > On Tue, Jul 2, 2019 at 12:45 AM Vitaly Wool <vitalywool@gmail.com>
> wrote:
> > > >
> > > > Hi Henry,
> > > >
> > > > On Mon, Jul 1, 2019 at 8:31 PM Henry Burns <henryburns@google.com>
> wrote:
> > > > >
> > > > > Running z3fold stress testing with address sanitization
> > > > > showed zhdr->slots was being used after it was freed.
> > > > >
> > > > > z3fold_free(z3fold_pool, handle)
> > > > >   free_handle(handle)
> > > > >     kmem_cache_free(pool->c_handle, zhdr->slots)
> > > > >   release_z3fold_page_locked_list(kref)
> > > > >     __release_z3fold_page(zhdr, true)
> > > > >       zhdr_to_pool(zhdr)
> > > > >         slots_to_pool(zhdr->slots)  *BOOM*
> > > >
> > > > Thanks for looking into this. I'm not entirely sure I'm all for
> > > > splitting free_handle() but let me think about it.
> > > >
> > > > > Instead we split free_handle into two functions, release_handle()
> > > > > and free_slots(). We use release_handle() in place of
> free_handle(),
> > > > > and use free_slots() to call kmem_cache_free() after
> > > > > __release_z3fold_page() is done.
> > > >
> > > > A little less intrusive solution would be to move backlink to pool
> > > > from slots back to z3fold_header. Looks like it was a bad idea from
> > > > the start.
> > > >
> > > > Best regards,
> > > >    Vitaly
> > >
> > > We still want z3fold pages to be movable though. Wouldn't moving
> > > the backink to the pool from slots to z3fold_header prevent us from
> > > enabling migration?
> >
> > That is a valid point but we can just add back pool pointer to
> > z3fold_header. The thing here is, there's another patch in the
> > pipeline that allows for a better (inter-page) compaction and it will
> > somewhat complicate things, because sometimes slots will have to be
> > released after z3fold page is released (because they will hold a
> > handle to another z3fold page). I would prefer that we just added back
> > pool to z3fold_header and changed zhdr_to_pool to just return
> > zhdr->pool, then had the compaction patch valid again, and then we
> > could come back to size optimization.
> >
>
> By adding pool pointer back to z3fold_header, will we still be able to
> move/migrate/compact the z3fold pages?l
>

Sure, it's only zhdr_to_pool() that will change, basically.

~Vitaly

--0000000000004dc571058cd58684
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><div dir=3D"auto"><div><br><br>=
<div class=3D"gmail_quote"><div dir=3D"ltr" class=3D"gmail_attr">On Wed, Ju=
l 3, 2019, 10:14 PM Shakeel Butt &lt;<a href=3D"mailto:shakeelb@google.com"=
 target=3D"_blank">shakeelb@google.com</a>&gt; wrote:<br></div><blockquote =
class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left:1px sol=
id rgb(204,204,204);padding-left:1ex">On Tue, Jul 2, 2019 at 11:03 PM Vital=
y Wool &lt;<a href=3D"mailto:vitalywool@gmail.com" rel=3D"noreferrer" targe=
t=3D"_blank">vitalywool@gmail.com</a>&gt; wrote:<br>
&gt;<br>
&gt; On Tue, Jul 2, 2019 at 6:57 PM Henry Burns &lt;<a href=3D"mailto:henry=
burns@google.com" rel=3D"noreferrer" target=3D"_blank">henryburns@google.co=
m</a>&gt; wrote:<br>
&gt; &gt;<br>
&gt; &gt; On Tue, Jul 2, 2019 at 12:45 AM Vitaly Wool &lt;<a href=3D"mailto=
:vitalywool@gmail.com" rel=3D"noreferrer" target=3D"_blank">vitalywool@gmai=
l.com</a>&gt; wrote:<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Hi Henry,<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; On Mon, Jul 1, 2019 at 8:31 PM Henry Burns &lt;<a href=3D"ma=
ilto:henryburns@google.com" rel=3D"noreferrer" target=3D"_blank">henryburns=
@google.com</a>&gt; wrote:<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Running z3fold stress testing with address sanitization=
<br>
&gt; &gt; &gt; &gt; showed zhdr-&gt;slots was being used after it was freed=
.<br>
&gt; &gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; z3fold_free(z3fold_pool, handle)<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0free_handle(handle)<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0kmem_cache_free(pool-&gt;c_handle, z=
hdr-&gt;slots)<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0release_z3fold_page_locked_list(kref)<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0__release_z3fold_page(zhdr, true)<br=
>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0zhdr_to_pool(zhdr)<br>
&gt; &gt; &gt; &gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0slots_to_pool(zhdr-&gt=
;slots)=C2=A0 *BOOM*<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Thanks for looking into this. I&#39;m not entirely sure I&#3=
9;m all for<br>
&gt; &gt; &gt; splitting free_handle() but let me think about it.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; &gt; Instead we split free_handle into two functions, releas=
e_handle()<br>
&gt; &gt; &gt; &gt; and free_slots(). We use release_handle() in place of f=
ree_handle(),<br>
&gt; &gt; &gt; &gt; and use free_slots() to call kmem_cache_free() after<br=
>
&gt; &gt; &gt; &gt; __release_z3fold_page() is done.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; A little less intrusive solution would be to move backlink t=
o pool<br>
&gt; &gt; &gt; from slots back to z3fold_header. Looks like it was a bad id=
ea from<br>
&gt; &gt; &gt; the start.<br>
&gt; &gt; &gt;<br>
&gt; &gt; &gt; Best regards,<br>
&gt; &gt; &gt;=C2=A0 =C2=A0 Vitaly<br>
&gt; &gt;<br>
&gt; &gt; We still want z3fold pages to be movable though. Wouldn&#39;t mov=
ing<br>
&gt; &gt; the backink to the pool from slots to z3fold_header prevent us fr=
om<br>
&gt; &gt; enabling migration?<br>
&gt;<br>
&gt; That is a valid point but we can just add back pool pointer to<br>
&gt; z3fold_header. The thing here is, there&#39;s another patch in the<br>
&gt; pipeline that allows for a better (inter-page) compaction and it will<=
br>
&gt; somewhat complicate things, because sometimes slots will have to be<br=
>
&gt; released after z3fold page is released (because they will hold a<br>
&gt; handle to another z3fold page). I would prefer that we just added back=
<br>
&gt; pool to z3fold_header and changed zhdr_to_pool to just return<br>
&gt; zhdr-&gt;pool, then had the compaction patch valid again, and then we<=
br>
&gt; could come back to size optimization.<br>
&gt;<br>
<br>
By adding pool pointer back to z3fold_header, will we still be able to<br>
move/migrate/compact the z3fold pages?l<br></blockquote><div><br></div><div=
>Sure, it&#39;s only zhdr_to_pool() that will change, basically.</div><div>=
<br></div><div>~Vitaly<br></div></div></div></div>
</div>

--0000000000004dc571058cd58684--

