Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7982C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:02:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56C1920818
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:02:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="K8tajLnU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56C1920818
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4FE76B0006; Wed, 15 May 2019 11:02:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A01226B0007; Wed, 15 May 2019 11:02:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EEA66B0008; Wed, 15 May 2019 11:02:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6FF6F6B0006
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:02:32 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id d10so2239571ybn.23
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:02:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=JOLdwTp5zRnKj+hnZ/GDoFywULiYCABqyveX8EJm5BY=;
        b=php6Xb6+vuWejOclRQEefj9LJwxQGECc+yISReR3WOXNadr1Ra5WfX9DYkbGjCoxWO
         7KWu4sznZtQhUunkCcq5mm8QLc/0LUckbSf4e1ZNnNJ8wBLRQ9Ftx53Q8QHqNezNsLrY
         B7tf1nA/tN1OMC3oZ++Qqn6pUjaWFjRIz2/d0ySI0lWErrK6K7bJriT5auxo+yudzVKF
         MGgnUiVL664xb2lc/hr3mKR69Jyp2oLNShUEzcbGM42YbOKbIvSWWb9UQDyaG4vLttFt
         5u5WBGN/CsE8S+18StFW7bZdlKgHNpHumHlNA/pSbivKniYdKG1y4FOlIAEDadZZZ1aL
         /j/Q==
X-Gm-Message-State: APjAAAUKzfiwullT6DPvvbLd9VSsHxhbqq6yqj2osqjB0xXcB+qgf6jM
	QnTgiP9c7jfpfobPy4sP675fUwP2VGxZSjcRyh0Rq4+/tgEbNi/Nz2VVk2gDxlNGtsVYP9UZ/Km
	m+gWq0DPkWeKUiwdL95kG8kzP9+9knyoVg3AdPw1+L1yeIjqD6ah5gi9QmxO08tivrA==
X-Received: by 2002:a81:5e0a:: with SMTP id s10mr21787399ywb.451.1557932552067;
        Wed, 15 May 2019 08:02:32 -0700 (PDT)
X-Received: by 2002:a81:5e0a:: with SMTP id s10mr21787327ywb.451.1557932551317;
        Wed, 15 May 2019 08:02:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557932551; cv=none;
        d=google.com; s=arc-20160816;
        b=ZoofNq9Vm0m1qq7E3/A+2nn333MsNaORcZMyAdQsS6Nl5epu1O7EXrXA/g+7QEywcl
         IE27ucrcjsKHrnN3wqZ95JAYcK915gKAh8ACA5ABJ7396xhr1pTNlj+N/xngiBtfVFJH
         CFiKMxmFcye4pMMm8/JExNqg2KHspnHU0UhGdxwos4DMKZV/ySLAqSC8o8LxiFFHxwP1
         zDoYPDoxs8RWq2r3XQ5TVJuebNmqfDo1FKNUsIacQZGq1gkQVTxzwZCmHKqTL9AGVIpf
         Gb1gHtfSM/ZSeX0Oy7C6R5GOttBF/Z7fCS7UakKb6LiTm2xMldT2bVtZhzFZUhghOeyF
         wO3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=JOLdwTp5zRnKj+hnZ/GDoFywULiYCABqyveX8EJm5BY=;
        b=ZwJaABHlLDL4r+1SZ3ke01tNFYSg9ncCHPRcQy210qUbrYs6iNHtOz2/aSxArgV0nP
         zjX9CPKbXA9gdpRusv0cUrfN7OZbTs0ESNguaZd/xKNNyh/XIGQJJdoEplOIbO/vVzMQ
         JthcjTi4ewEBsEGMbSq0xVfIFxHVlNySLZTsxDWIZ6L1IdhOGniN0qndZrVMyfvKBk45
         6CWKoABYsAeZH/8ssr4MSM/2T+aKopcat4LqxPV9cJNsuEnqo+gGNy3h3TAUWBO8LFIo
         YNTu+WDbpZ0MQJCgNA+ilN/WQvBibGdDibzkwZFNwYCLS7t0mExhbcaATz2LvBkPaoSP
         3BXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=K8tajLnU;
       spf=pass (google.com: domain of edumazet@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=edumazet@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e7sor1206392ywa.47.2019.05.15.08.02.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 08:02:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of edumazet@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=K8tajLnU;
       spf=pass (google.com: domain of edumazet@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=edumazet@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=JOLdwTp5zRnKj+hnZ/GDoFywULiYCABqyveX8EJm5BY=;
        b=K8tajLnUevxTs9F5zqowM410qkZAK9RFWtlu34lJ/mIkKmEnPdLHEDzVZZyuvMO4Cl
         ZT7hha/aWIN1JOqcnWJtq9c5byixcK6V73iTabiaIrYYXU1NuX9vAmE8/jcTJlcR7Yox
         t6YMB70z2IBohCh621ydwKso4naAlxgtPFpmsZeSq8dyMQ1YjH4lim4h1TVnGqWSYxwn
         Z7xuOkWOCe5xh/XxJegCGbY+qx7DeGwJ9Ut2heb16Q1CLBF3bFQo2WF95e8yNFm+uhug
         OkxNjXwqnXWCw7t8wdlkk/20/kul3QspQZpFzaQ3JCKeU3hpRUdc2qnWrMbSmbT4SlNT
         YTBg==
X-Google-Smtp-Source: APXvYqxGnVrqH3KQxncl63mkJGYEYCoRKq72QJ6MHEZ+nCms2p/s0E4Z0+F6m1GJjsJtLGvK8ocwvuD0CoB3jyv1g/I=
X-Received: by 2002:a81:27cc:: with SMTP id n195mr21182715ywn.60.1557932550591;
 Wed, 15 May 2019 08:02:30 -0700 (PDT)
MIME-Version: 1.0
References: <d68c83ba-bf5a-f6e8-44dd-be98f45fc97a@camlintechnologies.com>
 <14c9e6f4-3fb8-ca22-91cc-6970f1d52265@camlintechnologies.com>
 <011a16e4-6aff-104c-a19b-d2bd11caba99@camlintechnologies.com> <20190515144352.GC31704@bombadil.infradead.org>
In-Reply-To: <20190515144352.GC31704@bombadil.infradead.org>
From: Eric Dumazet <edumazet@google.com>
Date: Wed, 15 May 2019 08:02:17 -0700
Message-ID: <CANn89iJ0r116a8q_+jUgP_8wPX4iS6WVppQ6HvgZFt9v9CviKA@mail.gmail.com>
Subject: Re: Recurring warning in page_copy_sane (inside copy_page_to_iter)
 when running stress tests involving drop_caches
To: Matthew Wilcox <willy@infradead.org>
Cc: Lech Perczak <l.perczak@camlintechnologies.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	Piotr Figiel <p.figiel@camlintechnologies.com>, 
	=?UTF-8?Q?Krzysztof_Drobi=C5=84ski?= <k.drobinski@camlintechnologies.com>, 
	Pawel Lenkow <p.lenkow@camlintechnologies.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 7:43 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> > > W dniu 25.04.2019 o 11:25, Lech Perczak pisze:
> > >> Some time ago, after upgrading the Kernel on our i.MX6Q-based boards=
 to mainline 4.18, and now to LTS 4.19 line, during stress tests we started=
 noticing strange warnings coming from 'read' syscall, when page_copy_sane(=
) check failed. Typical reproducibility is up to ~4 events per 24h. Warning=
s origin from different processes, mostly involved with the stress tests, b=
ut not necessarily with block devices we're stressing. If the warning appea=
red in process relating to block device stress test, it would be accompanie=
d by corrupted data, as the read operation gets aborted.
> > >>
> > >> When I started debugging the issue, I noticed that in all cases we'r=
e dealing with highmem zero-order pages. In this case, page_head(page) =3D=
=3D page, so page_address(page) should be equal to page_address(head).
> > >> However, it isn't the case, as page_address(head) in each case retur=
ns zero, causing the value of "v" to explode, and the check to fail.
>
> You're seeing a race between page_address(page) being called twice.
> Between those two calls, something has caused the page to be removed from
> the page_address_map() list.  Eric's patch avoids calling page_address(),
> so apply it and be happy.

Hmm... wont the kmap_atomic() done later, after page_copy_sane() would
suffer from the race ?

It seems there is a real bug somewhere to fix.

>
> Greg, can you consider 6daef95b8c914866a46247232a048447fff97279 for
> backporting to stable?  Nobody realised it was a bugfix at the time it
> went in.  I suspect there aren't too many of us running HIGHMEM kernels
> any more.
>

