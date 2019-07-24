Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 348C6C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:49:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C13EF21743
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:49:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C13EF21743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E6F26B0008; Wed, 24 Jul 2019 02:49:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BF546B000A; Wed, 24 Jul 2019 02:49:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D4508E0002; Wed, 24 Jul 2019 02:49:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15FE76B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:49:23 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h3so27643419pgc.19
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:49:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=vMChR67aqlw4NWL2FqFkGfTM2ajtplmPQnK1p+Jeyws=;
        b=L0pkix+nt7UWvwE9YvPEEIj9SixMfUhDu9iDlTJRicopQIsX0oBP3/ll6p/O9foIvz
         8CchLL7rP4l3ebeACs7nqFgjdq8BQRKyJIvoqe07DmRrPiQ8ToUd8atY/wLS9zhWyrh5
         Ufv9Lu1EDgSeuMeJKNx18h3o5jcFqWf1JGqsqZSa9DCBNQPtbAxoj2zliMrNTpLNgM8H
         T7FJ6GuxyMvcYf2OOLMQ7RA5UK3wOWhPw15lVAHsaAUgSsvVDKbaHKcXqUw/ICcDY0WT
         Y74f6R1/C4LfzP8Rz7uAI+vaTKNqb6uUv3m8SO96EiuNbKjzsE6O23oAdOGE1OXYazRC
         NxqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: APjAAAXRKUEvBi3uu6UMI3/pF5yF6SOxoaO2Q+8XJ4UWiCkhrMMwx0Q2
	joQitEKDhxc6uzHCR3fd83euT76tXQjERe5QtSfzoIloJ9QWOwVancPCWFH7oVV7fgCnvvWAmp1
	YVIYulhpUpCRw3pB7ZZGk43GCvd9WWAZSqUCIqcafkCx5vyHArskHF2eoPkjwYo274Q==
X-Received: by 2002:a63:3112:: with SMTP id x18mr79958643pgx.385.1563950962549;
        Tue, 23 Jul 2019 23:49:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxLBybcdZqA3tnDL8IPh/J1wHjSafgr8w+eeE3V2SYQm/slzfV8C0lz1vv9LYaZ6bfdqcag
X-Received: by 2002:a63:3112:: with SMTP id x18mr79958578pgx.385.1563950961561;
        Tue, 23 Jul 2019 23:49:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563950961; cv=none;
        d=google.com; s=arc-20160816;
        b=GjIB6I6MQfvZjVL1z+tzGDiN8SWShMlRoA0KqFaBXxaDT8LaNJ0zmJG9OaPfdoqDKw
         E4MTUTa4Ia47/B6g1cvowDYYePna+xYJUNYFTAWf8Ru/txNrY3zYAKa5/X/ZxcWqw2x2
         SgtFYSGzt9UC9V8F/CzOtodglRzAPzSzp9JMbK9SGjMDKWUWP8GIJL/UchLchgHOMGh1
         ga6wMGQqNOrBlyDwIeM7KrQrX7b1fRRGHNZk/nvTtDEDPTmZIOECKupStGCr54ReNcwt
         fS/SUtHyw9ohpthnPncR+8lzEmFiMyZYfaccOdKZCUKpJt6+EMWgonNDQuvlOM46uOfP
         /6xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=vMChR67aqlw4NWL2FqFkGfTM2ajtplmPQnK1p+Jeyws=;
        b=yd91QgSOnhnnqqfVdfFrWpvNPlnPrJu4w5rK8UZ6nbC0Hd8t/t1JSZDzaM9qjPiAxl
         6hvgcnC82Tk9cImDn6ngDmkfsrSo61z+0rq5vu+ggcvKDJyLAwW6Asz3PyayrCgX1cyV
         XddJRZ7MFWwUHuL6h6jnzTTBVXaH6RQaKeDx6PE9CUeKYVAwfI58+d+tuS8jYv4X/AWV
         pbt2NUeb4p7nv65JAvVSryLkTwqW1knE17ePKveiyu1ZsM1Ht15ex6DVSHKn71Otxhu9
         O/Ea64t2R93Fi4fKrjaL73b4f/CzmXQvChLw//oBsioym2ZhjedQaLDMaZbw44mENXhq
         liWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id h69si14509495pge.543.2019.07.23.23.49.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 23:49:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) client-ip=114.179.232.162;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.162 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate02.nec.co.jp ([114.179.233.122])
	by tyo162.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x6O6nG5d021120
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 24 Jul 2019 15:49:16 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate02.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6O6nGFx009426;
	Wed, 24 Jul 2019 15:49:16 +0900
Received: from mail03.kamome.nec.co.jp (mail03.kamome.nec.co.jp [10.25.43.7])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x6O6dSsL017998;
	Wed, 24 Jul 2019 15:49:16 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.150] [10.38.151.150]) by mail03.kamome.nec.co.jp with ESMTP id BT-MMP-2404595; Wed, 24 Jul 2019 15:48:55 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC22GP.gisp.nec.co.jp ([10.38.151.150]) with mapi id 14.03.0439.000; Wed,
 24 Jul 2019 15:48:55 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Jane Chu <jane.chu@oracle.com>, Dan Williams <dan.j.williams@intel.com>
CC: Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nvdimm <linux-nvdimm@lists.01.org>
Subject: Re: [PATCH] mm/memory-failure: Poison read receives SIGKILL instead
 of SIGBUS if mmaped more than once
Thread-Topic: [PATCH] mm/memory-failure: Poison read receives SIGKILL
 instead of SIGBUS if mmaped more than once
Thread-Index: AQHVQbAJYBnoCgkSO0yo1OfL2uazvqbYZaaAgABXyAA=
Date: Wed, 24 Jul 2019 06:48:54 +0000
Message-ID: <20190724064846.GA17567@hori.linux.bs1.fc.nec.co.jp>
References: <1563925110-19359-1-git-send-email-jane.chu@oracle.com>
 <CAPcyv4hyvHFnSE4AUbXooxX_Ug-raxAJgzC7jzkHp_mSg_sCmg@mail.gmail.com>
In-Reply-To: <CAPcyv4hyvHFnSE4AUbXooxX_Ug-raxAJgzC7jzkHp_mSg_sCmg@mail.gmail.com>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.96]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A8D19D1E94905D479DFEEA8EADF01457@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jane, Dan,

On Tue, Jul 23, 2019 at 06:34:35PM -0700, Dan Williams wrote:
> On Tue, Jul 23, 2019 at 4:49 PM Jane Chu <jane.chu@oracle.com> wrote:
> >
> > Mmap /dev/dax more than once, then read the poison location using addre=
ss
> > from one of the mappings. The other mappings due to not having the page
> > mapped in will cause SIGKILLs delivered to the process. SIGKILL succeed=
s
> > over SIGBUS, so user process looses the opportunity to handle the UE.
> >
> > Although one may add MAP_POPULATE to mmap(2) to work around the issue,
> > MAP_POPULATE makes mapping 128GB of pmem several magnitudes slower, so
> > isn't always an option.
> >
> > Details -
> >
> > ndctl inject-error --block=3D10 --count=3D1 namespace6.0
> >
> > ./read_poison -x dax6.0 -o 5120 -m 2
> > mmaped address 0x7f5bb6600000
> > mmaped address 0x7f3cf3600000
> > doing local read at address 0x7f3cf3601400
> > Killed
> >
> > Console messages in instrumented kernel -
> >
> > mce: Uncorrected hardware memory error in user-access at edbe201400
> > Memory failure: tk->addr =3D 7f5bb6601000
> > Memory failure: address edbe201: call dev_pagemap_mapping_shift
> > dev_pagemap_mapping_shift: page edbe201: no PUD
> > Memory failure: tk->size_shift =3D=3D 0
> > Memory failure: Unable to find user space address edbe201 in read_poiso=
n
> > Memory failure: tk->addr =3D 7f3cf3601000
> > Memory failure: address edbe201: call dev_pagemap_mapping_shift
> > Memory failure: tk->size_shift =3D 21
> > Memory failure: 0xedbe201: forcibly killing read_poison:22434 because o=
f failure to unmap corrupted page
> >   =3D> to deliver SIGKILL
> > Memory failure: 0xedbe201: Killing read_poison:22434 due to hardware me=
mory corruption
> >   =3D> to deliver SIGBUS
> >
> > Signed-off-by: Jane Chu <jane.chu@oracle.com>
> > ---
> >  mm/memory-failure.c | 16 ++++++++++------
> >  1 file changed, 10 insertions(+), 6 deletions(-)
> >
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index d9cc660..7038abd 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -315,7 +315,6 @@ static void add_to_kill(struct task_struct *tsk, st=
ruct page *p,
> >
> >         if (*tkc) {
> >                 tk =3D *tkc;
> > -               *tkc =3D NULL;
> >         } else {
> >                 tk =3D kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
> >                 if (!tk) {
> > @@ -331,16 +330,21 @@ static void add_to_kill(struct task_struct *tsk, =
struct page *p,
> >                 tk->size_shift =3D compound_order(compound_head(p)) + P=
AGE_SHIFT;
> >
> >         /*
> > -        * In theory we don't have to kill when the page was
> > -        * munmaped. But it could be also a mremap. Since that's
> > -        * likely very rare kill anyways just out of paranoia, but use
> > -        * a SIGKILL because the error is not contained anymore.
> > +        * Indeed a page could be mmapped N times within a process. And=
 it's possible
> > +        * that not all of those N VMAs contain valid mapping for the p=
age. In which
> > +        * case we don't want to send SIGKILL to the process on behalf =
of the VMAs
> > +        * that don't have the valid mapping, because doing so will ecl=
ipse the SIGBUS
> > +        * delivered on behalf of the active VMA.
> >          */
> >         if (tk->addr =3D=3D -EFAULT || tk->size_shift =3D=3D 0) {
> >                 pr_info("Memory failure: Unable to find user space addr=
ess %lx in %s\n",
> >                         page_to_pfn(p), tsk->comm);
> > -               tk->addr_valid =3D 0;
> > +               if (tk !=3D *tkc)
> > +                       kfree(tk);
> > +               return;

The immediate return bypasses list_add_tail() below, so we might lose
the chance of sending SIGBUS to the process.

tk->size_shift is always non-zero for !is_zone_device_page(), so
"tk->size_shift =3D=3D 0" effectively checks "no mapping on ZONE_DEVICE" no=
w.
As you mention above, "no mapping" doesn't means "invalid address"
so we can drop "tk->size_shift =3D=3D 0" check from this if-statement.
Going forward in this direction, "tk->addr_valid =3D=3D 0" is equivalent to
"tk->addr =3D=3D -EFAULT", so we seems to be able to remove ->addr_valid.
This observation leads me to the following change, does it work for you?

  --- a/mm/memory-failure.c
  +++ b/mm/memory-failure.c
  @@ -199,7 +199,6 @@ struct to_kill {
   	struct task_struct *tsk;
   	unsigned long addr;
   	short size_shift;
  -	char addr_valid;
   };
  =20
   /*
  @@ -324,7 +323,6 @@ static void add_to_kill(struct task_struct *tsk, stru=
ct page *p,
   		}
   	}
   	tk->addr =3D page_address_in_vma(p, vma);
  -	tk->addr_valid =3D 1;
   	if (is_zone_device_page(p))
   		tk->size_shift =3D dev_pagemap_mapping_shift(p, vma);
   	else
  @@ -336,11 +334,9 @@ static void add_to_kill(struct task_struct *tsk, str=
uct page *p,
   	 * likely very rare kill anyways just out of paranoia, but use
   	 * a SIGKILL because the error is not contained anymore.
   	 */
  -	if (tk->addr =3D=3D -EFAULT || tk->size_shift =3D=3D 0) {
  +	if (tk->addr =3D=3D -EFAULT)
   		pr_info("Memory failure: Unable to find user space address %lx in %s\n=
",
   			page_to_pfn(p), tsk->comm);
  -		tk->addr_valid =3D 0;
  -	}
   	get_task_struct(tsk);
   	tk->tsk =3D tsk;
   	list_add_tail(&tk->nd, to_kill);
  @@ -366,7 +362,7 @@ static void kill_procs(struct list_head *to_kill, int=
 forcekill, bool fail,
   			 * make sure the process doesn't catch the
   			 * signal and then access the memory. Just kill it.
   			 */
  -			if (fail || tk->addr_valid =3D=3D 0) {
  +			if (fail || tk->addr =3D=3D -EFAULT) {
   				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of fail=
ure to unmap corrupted page\n",
   				       pfn, tk->tsk->comm, tk->tsk->pid);
   				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,

> >         }
> > +       if (tk =3D=3D *tkc)
> > +               *tkc =3D NULL;
> >         get_task_struct(tsk);
> >         tk->tsk =3D tsk;
> >         list_add_tail(&tk->nd, to_kill);
>=20
>=20
> Concept and policy looks good to me, and I never did understand what
> the mremap() case was trying to protect against.
>=20
> The patch is a bit difficult to read (not your fault) because of the
> odd way that add_to_kill() expects the first 'tk' to be pre-allocated.
> May I ask for a lead-in cleanup that moves all the allocation internal
> to add_to_kill() and drops the **tk argument?

I totally agree with this cleanup. Thanks for the comment.

Thanks,
Naoya Horiguchi=

