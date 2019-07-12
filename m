Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CADAC742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:00:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1454C20651
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:00:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ntqoYFzy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1454C20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91C458E015F; Fri, 12 Jul 2019 13:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CCC38E0003; Fri, 12 Jul 2019 13:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7951D8E015F; Fri, 12 Jul 2019 13:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 510198E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 13:00:21 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id j140so4204424vke.10
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:00:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Xa/JIc+XiGXpm5Gi1iHsvZxDgn8MNFaOrmXkkSzsQhU=;
        b=ZyS0rL/uJzUd6UNQCR+OudSlHF961P0+0zVR1R4RpCQ1napWyXaGeweXLLpjG5WqKp
         H3RAIuMENovCPdD+4sGJkrZ233FhAMseD5lS0ZTrAnSaiFX/TjWhy9rTtwcrUITg8Eju
         NelChptWSwjC5DSluyFSn4QXTHTMd8D+EIIPrA9PcHifie/+F9i6wdKwag8mTGuAGxT+
         vRslYn/Emxds0u+j/u6VvowwiK/xBOSsfiILdnpGVQZr4izQzUNQnbZM/m8v1eui8nt4
         CzcFU3xDXH5g3GllvJB8xMs9y+0MYjP9Xkwd8PwsZeToCSyazc80moFCkxw25pqI34qD
         02rQ==
X-Gm-Message-State: APjAAAWqVRIaOTSNIibnEqhrxAZUO/hfFu07mFzQYktSO3wQ/W+euv5s
	CcRe9oOoV5RAbwdyMtcNa1vBcQ1WeGDDKKuZHqd91S20NrlfcSKQGocQI75T5fMoGM8M1USQxAE
	Wqi+PllO8fBkCrUDLIijIs9EDyX6oPCbcTLq/iMd3tZzWN7aHD21RurCLk6EWF0Vy/A==
X-Received: by 2002:a1f:be51:: with SMTP id o78mr6454532vkf.66.1562950820768;
        Fri, 12 Jul 2019 10:00:20 -0700 (PDT)
X-Received: by 2002:a1f:be51:: with SMTP id o78mr6454496vkf.66.1562950819906;
        Fri, 12 Jul 2019 10:00:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562950819; cv=none;
        d=google.com; s=arc-20160816;
        b=fYaNTfcUwQJLRD5QreSjv6k8aYPuxznY31vfFtTfSBc5hbUb/AB80TNy+ChozB+9hE
         g83G1jhwDTdUpWOkCBxmuijU7Un158b6fs6noDsmURR80NulbMRLaJ3fcXkjGCyiD88Y
         sddwDrCNJzVvygo+KN6NgACzxXElzssyCY6OmZ4V38FOwgzSNVvyVlXkFrPeAp4omMWB
         NPmKV53J8II2XKrSC3FCq6qCc/ziQHMCm+NwvbKwffaZC19q/PHrLrDhikm2x9F2vgzs
         Y5+qJOHaP99tu9lMAgd084oImbSPZRl5UbQTb7xgosFGF5IBZkqTKHn4GaL801CZq/Fb
         /Tgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Xa/JIc+XiGXpm5Gi1iHsvZxDgn8MNFaOrmXkkSzsQhU=;
        b=Jpz1UIjfxC9+2+hXp/YCXZJpGNcmCNDRK1pMZQoDvdYWLYSnHb6WwHFeeNRQHydITz
         we33LsLDgMYf78SZsr+pg8N94Z+auu54qicllomY5xKRqUvVihy1ETAA7VUmwiSpstis
         H5JuwHDo883MA2v5jjE+Z09TkwQnbJ1cEikZVvS7Gt3OANFxVEFS9RbgCax6x/butcrC
         r5ikSS01VEjzl3tnEOTo+iZAa7odcWmdehsbdh4kAck5xw7CKmNIukBH0IE2yf1Pr2SR
         6D/yEKTf/LN7Ul/j/pgXR+9fNHjJnFNq2Fe34w++OVZYmpOkiIRTy8IWlL0cYS9BKPhM
         ZVHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ntqoYFzy;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16sor4906509vsr.72.2019.07.12.10.00.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jul 2019 10:00:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ntqoYFzy;
       spf=pass (google.com: domain of walken@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=walken@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Xa/JIc+XiGXpm5Gi1iHsvZxDgn8MNFaOrmXkkSzsQhU=;
        b=ntqoYFzy45x5nH1dbIIy2cdYjWHGlisy72XlIy7vKgmOHMuEOp7rDYlRHlZK5KslUH
         cSTpclAr5jlrXouH5YXj/oC00K9V2ghHhHw5d2MyX/IbEwftEaNyQEvwu+2TrCmJttMg
         xijN++2pDIXgAsaQHll/UjzHAU3PaAauqgv+/kdMpO7jC1H7ZyUwIPBWmFNz+HsyGizf
         MrMMIAbe0d4SZhTIaQ9W4WsvET4ZWBQevj8ib5gZJbA4OZV6O5oHSL7Gb+KNGINVtHcY
         OQDqXrSB1xBkuCMCkTj4BW87ZeLpazRD/6qFbuYcuSIzLvdke2rMmvWZJ1YaNQ4tP6YS
         LU5w==
X-Google-Smtp-Source: APXvYqwLnT96Jqh0/cv6O2LK00nrN85AzB6P4BY5Khs4jQZ53nF/9r7GJrdQ7XU76VyyHVvvZl0qdlQfCDUjrdBy0fc=
X-Received: by 2002:a67:ba12:: with SMTP id l18mr9474162vsn.29.1562950819093;
 Fri, 12 Jul 2019 10:00:19 -0700 (PDT)
MIME-Version: 1.0
References: <1558073209-79549-1-git-send-email-chenjianhong2@huawei.com>
 <CANN689G6mGLSOkyj31ympGgnqxnJosPVc4EakW5gYGtA_45L7g@mail.gmail.com>
 <df001b6fbe2a4bdc86999c78933dab7f@huawei.com> <20190711182002.9bb943006da6b61ab66b95fd@linux-foundation.org>
 <71c4329e246344eeb38c8ac25c63c09d@huawei.com>
In-Reply-To: <71c4329e246344eeb38c8ac25c63c09d@huawei.com>
From: Michel Lespinasse <walken@google.com>
Date: Fri, 12 Jul 2019 10:00:06 -0700
Message-ID: <CANN689H1wtbKOqhpTSuxvTDcsU00y1xXd8wRVFvbG_2p3WvoqQ@mail.gmail.com>
Subject: Re: [PATCH] mm/mmap: fix the adjusted length error
To: "chenjianhong (A)" <chenjianhong2@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "mhocko@suse.com" <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Yang Shi <yang.shi@linux.alibaba.com>, "jannh@google.com" <jannh@google.com>, 
	"steve.capper@arm.com" <steve.capper@arm.com>, "tiny.windzz@gmail.com" <tiny.windzz@gmail.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	"stable@vger.kernel.org" <stable@vger.kernel.org>, "willy@infradead.org" <willy@infradead.org>, 
	"wangle (H)" <wangle6@huawei.com>, "Chengang (L)" <cg.chen@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 3:53 AM chenjianhong (A)
<chenjianhong2@huawei.com> wrote:
> Thank you for your reply!
> > How significant is this problem in real-world use cases?  How much trou=
ble is it causing?
>    In my opinion, this problem is very rare in real-world use cases. In a=
rm64
>    or x86 environment, the virtual memory is enough. In arm32 environment=
,
>    each process has only 3G or 4G or less, but we seldom use out all of t=
he virtual memory,
>    it only happens in some special environment. They almost use out all t=
he virtual memory, and
>    in some moment, they will change their working mode so they will relea=
se and allocate
>    memory again. This current length limitation will cause this problem. =
I explain it's the memory
>    length limitation. But they can't accept the reason, it is unreasonabl=
e that we fail to allocate
>    memory even though the memory gap is enough.

Right. So to summarize, you have a customer accidentally hitting this
and asking you about it ? and I assume their workload is not public ?

> > Have you looked further into this?  Michel is concerned about the perfo=
rmance cost of the current solution.
>    The current algorithm(change before) is wonderful, and it has been use=
d for a long time, I don't
>    think it is worthy to change the whole algorithm in order to fix this =
problem. Therefore, I just
>    adjust the gap_start and gap_end value in place of the length. My chan=
ge really affects the
>    performance because I calculate the gap_start and gap_end value again =
and again. Does it affect
>    too much performance?  I have no complex environment, so I can't test =
it, but I don't think it will cause
>    too much performance loss. First, I don't change the whole algorithm. =
Second, unmapped_area and
>    unmapped_area_topdown function aren't used frequently. Maybe there are=
 some big performance problems
>    I'm not concerned about. But I think if that's not a problem, there sh=
ould be a limitation description.

The case I am worried about is if there are a lot of gaps that are
large enough for an unaligned allocation, but too small for an aligned
one.

You could create the bad case as follows:
- Allocate a huge memory block (no need to populate it, so it can
really be as large as virtual memory will allow)
- Free a bunch of 2M holes in that block, but none of them are aligned
- Try to force allocation of a 2M aligned block

With the current code, the allocation will quickly skip over the
unaligned 2M holes. It will either find a 4M gap and allocate a 2M
aligned block from it, or it will fail, but it will be quick in either
case. With the suggested change, the allocation would try each of the
unaligned 2M holes, which could take a long time, before eventually
either finding a large enough aligned gap, or failing.

I can see two ways around this:
- the code could search for a 4M gap at first, like it currently does,
and that fails it could look at all 2M gaps and see if one of them is
aligned. So, there would still be the slow case, but only if the
initial (fast) check failed. Maybe there should be a sysfs setting to
enable the second pass, which would be disabled by default at least on
64-bit systems.
- If the issue only happens when allocating huge pages, and we know
the possible huge page sizes for a process from the start, we could
maintain more information about the gaps so that we could quickly
search for a suitable aligned gaps. that is, for each subtree we would
store both the highest 4K aligned size that can be allocated, and the
highest 2M aligned size as well. That makes a more complete solution
but probably overkill as we are not hitting this frequently enough to
justify the complications.

>
> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Friday, July 12, 2019 9:20 AM
> To: chenjianhong (A) <chenjianhong2@huawei.com>
> Cc: Michel Lespinasse <walken@google.com>; Greg Kroah-Hartman <gregkh@lin=
uxfoundation.org>; mhocko@suse.com; Vlastimil Babka <vbabka@suse.cz>; Kiril=
l A. Shutemov <kirill.shutemov@linux.intel.com>; Yang Shi <yang.shi@linux.a=
libaba.com>; jannh@google.com; steve.capper@arm.com; tiny.windzz@gmail.com;=
 LKML <linux-kernel@vger.kernel.org>; linux-mm <linux-mm@kvack.org>; stable=
@vger.kernel.org; willy@infradead.org
> Subject: Re: [PATCH] mm/mmap: fix the adjusted length error
>
> On Sat, 18 May 2019 07:05:07 +0000 "chenjianhong (A)" <chenjianhong2@huaw=
ei.com> wrote:
>
> > I explain my test code and the problem in detail. This problem is
> > found in 32-bit user process, because its virtual is limited, 3G or 4G.
> >
> > First, I explain the bug I found. Function unmapped_area and
> > unmapped_area_topdowns adjust search length to account for worst case
> > alignment overhead, the code is ' length =3D info->length + info->align=
_mask; '.
> > The variable info->length is the length we allocate and the variable
> > info->align_mask accounts for the alignment, because the gap_start  or
> > info->gap_end
> > value also should be an alignment address, but we can't know the alignm=
ent offset.
> > So in the current algorithm, it uses the max alignment offset, this
> > value maybe zero or other(0x1ff000 for shmat function).
> > Is it reasonable way? The required value is longer than what I allocate=
.
> > What's more,  why for the first time I can allocate the memory
> > successfully Via shmat, but after releasing the memory via shmdt and I
> > want to attach again, it fails. This is not acceptable for many people.
> >
> > Second, I explain my test code. The code I have sent an email. The
> > following is the step. I don't think it's something unusual or
> > unreasonable, because the virtual memory space is enough, but the
> > process can allocate from it. And we can't pass explicit addresses to
> > function mmap or shmat, the address is getting from the left vma gap.
> >  1, we allocat large virtual memory;
> >  2, we allocate hugepage memory via shmat, and release one  of the
> > hugepage memory block;  3, we allocate hugepage memory by shmat again,
> > this will fail.
>
> How significant is this problem in real-world use cases?  How much troubl=
e is it causing?
>
> > Third, I want to introduce my change in the current algorithm. I don't
> > change the current algorithm. Also, I think there maybe a better way
> > to fix this error. Nowadays, I can just adjust the gap_start value.
>
> Have you looked further into this?  Michel is concerned about the perform=
ance cost of the current solution.
>


--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

