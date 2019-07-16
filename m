Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CE4FC76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:45:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA6B92173E
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:45:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="yWuFBwvC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA6B92173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F2846B0003; Tue, 16 Jul 2019 18:45:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A4838E0001; Tue, 16 Jul 2019 18:45:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56B186B0006; Tue, 16 Jul 2019 18:45:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BA076B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 18:45:22 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id b124so8517020oii.11
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 15:45:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=CHc4daItHr047JAX6t6Ygj5bjbut9nVoR+XN5tnnFNU=;
        b=ThGJIK3FEMa3ucUQtv8yINjK1JZJVhIFIbZZ2cdy7+O7jUfSHNuXbm4sgYijYsbE0p
         HYITpqxXAHq9+BrBSWIZ1wQVO6Vrgvj6+NL9xf/v5Q8GwblH8D3LlWhsDINacqjfORkt
         PzSb9A15n6AUMDTMlD+swKPZH+lbCG3IasqXwrOy0rb2kAUbcQEvMa4sBewjHIDFDioM
         oDiUlV+UQLIUwSp6Nz3Pjwaf//kNHmEPxDJ6qW8SGAAO4v7b3e2EFRDOeZln8+eSezJi
         tMeZBvcU6af2dVudsSv7N2wlOWwe74DOwGzSkffgMDXXschkPgN+dXMsfIu4UVdibg7r
         KVfQ==
X-Gm-Message-State: APjAAAXfyR8l6cqb2t5gSoxc1XYP1mdlmxqPSZfj7Q3TovHnWeTQfjqo
	MwpIapiKNuwUD6JPlstLW3zCEeEYwFZ2ax1lMjUKnXrcO5FIzqBXnIK815TfQDpZZU4YKKlIg/k
	g9tLWKObJvOyhcIFHBsmvwB/otUwIDu/H/UJVmluBu34RZ5mLp2wFIQ9ED/dIVwtxJg==
X-Received: by 2002:aca:c3d7:: with SMTP id t206mr16313152oif.138.1563317121789;
        Tue, 16 Jul 2019 15:45:21 -0700 (PDT)
X-Received: by 2002:aca:c3d7:: with SMTP id t206mr16313111oif.138.1563317120599;
        Tue, 16 Jul 2019 15:45:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563317120; cv=none;
        d=google.com; s=arc-20160816;
        b=JXtXvslhzbVVI3uAFa6ds/+Sh7S6IyfOjHD+D3HRwGvxCLDaZLCSC1sCDpg6RKIDZR
         xELwxK7V097cNkBEFEeK0DCf65nHzs/Fzd4g8Y3SZYXiLZJJJIe9xCe+LYwErxnNL6+r
         8KETv0PwmM3uspdI+PX3Trua3hgGRRE7auDJFdiiTd3IW4j6SlO8Cw1oGaEH1cuM3D7g
         zGm84L0Zv/wAViahfK1uAo22iRm8hZ0WEZdkBwFCyqs+LJDXLAjxfE4nHHg0U6OXHxpY
         NklQd+tYs8CMKTGWeCJVoV0V7TrvXuqmc1OBzwfkcLSreE103kGpC9jIPuKXYORXi5/8
         TiDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=CHc4daItHr047JAX6t6Ygj5bjbut9nVoR+XN5tnnFNU=;
        b=mRo+ycJue3azBUC3OIWQRoJ5sIC7/XdsNKS6p9UCk+Lskj3gvDANTGX3qkS5S5MPo7
         l9GkywZ0s/Adaz8ufjDaOMQGtzLhz3mwjvrm0GVlLQkdX+tTi96P2RuumJR/ihCKXc4R
         EuOs/O+QqmhvqGsVbxz2aVZ4FAQjtKTSYxwY0UprVHantMBDmH4Mf4KNB6IRyFDr6Yaw
         1svcaJUQRAtGlOh6cMYPTaC9Zi6Nouyv79sqCZ4WpdQOBlGVDz6XnjJvM8YnIL9NW7Lu
         5VD2WJy8PJ3gYVRAh5Nmemuu0SjRETQa+oGCNGbyuL0UvFcAbCP8ayc36NVU+dVFGv9j
         DITg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=yWuFBwvC;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j14sor10343174oib.137.2019.07.16.15.45.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 15:45:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=yWuFBwvC;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=CHc4daItHr047JAX6t6Ygj5bjbut9nVoR+XN5tnnFNU=;
        b=yWuFBwvCVvk0bqJ1fWzLXH2rBWx/FNnUSgVei/R5Ar5PeDVXdMfiBgNSwKyI2Ht2KZ
         LSrvS9RJI96GzWauHQwqt67UNiuc2qCaC5rLLu6VZcHDrxOGzslnCjT2e2qxZ0rFt5D4
         luQB1aPKdURv5/cdrcPuQsK1PnBOYpNB/+lfGAI9usbEIeg8N60a+THwW7+dR+yaHIDL
         ato8gF15L0hsZsqQcCS1O9DFzP76Yf4sNul3sgeiMgJbsOvPqk8MtpsdKqkkgbtDZvw8
         qR3YWl8qz/lq/e01gxS90t01/VluVPvoDRQc40zDNvxww8+mVVmAAURMrK3hbtUWN65F
         /Jgw==
X-Google-Smtp-Source: APXvYqwATpjKwXHNrTFAzooQoGXlc0BH9RXXaDSu7AI1VaKpd0PA2MG4OY2F2Xuo3BJH3fT51VRssHd8KgiBQhs9XeY=
X-Received: by 2002:aca:1304:: with SMTP id e4mr17392219oii.149.1563317119863;
 Tue, 16 Jul 2019 15:45:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190613045903.4922-1-namit@vmware.com> <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
 <9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com> <CAPcyv4hstt+0teXPtAq2nwFQaNb9TujgetgWPVMOnYH8JwqGeA@mail.gmail.com>
 <19C3DCA0-823E-46CB-A758-D5F82C5FA3C8@vmware.com> <20190716150047.3c13945decc052c077e9ee1e@linux-foundation.org>
 <CAPcyv4iqNHBy-_WbH9XBg5hSqxa=qnkc88EW5=g=-5845jNzsg@mail.gmail.com>
 <D463DD43-C09F-4B6E-B1BC-7E1CA5C8A9C4@vmware.com> <CAPcyv4gGkgCsf4NtDPj7FNcTMO6o+fUYgfq8AP_pLkqDSbxjzA@mail.gmail.com>
 <39E58DBC-C13E-429C-A5FC-8FD80ABBBF55@vmware.com>
In-Reply-To: <39E58DBC-C13E-429C-A5FC-8FD80ABBBF55@vmware.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 16 Jul 2019 15:45:08 -0700
Message-ID: <CAPcyv4g4Qv-1eEcVxfr4gnTngprtn1DdwXBgRQ3T_-9Kr0vKDw@mail.gmail.com>
Subject: Re: [PATCH 0/3] resource: find_next_iomem_res() improvements
To: Nadav Amit <namit@vmware.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>, Peter Zijlstra <peterz@infradead.org>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Bjorn Helgaas <bhelgaas@google.com>, 
	Ingo Molnar <mingo@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 3:29 PM Nadav Amit <namit@vmware.com> wrote:
>
> > On Jul 16, 2019, at 3:20 PM, Dan Williams <dan.j.williams@intel.com> wr=
ote:
> >
> > On Tue, Jul 16, 2019 at 3:13 PM Nadav Amit <namit@vmware.com> wrote:
> >>> On Jul 16, 2019, at 3:07 PM, Dan Williams <dan.j.williams@intel.com> =
wrote:
> >>>
> >>> On Tue, Jul 16, 2019 at 3:01 PM Andrew Morton <akpm@linux-foundation.=
org> wrote:
> >>>> On Tue, 18 Jun 2019 21:56:43 +0000 Nadav Amit <namit@vmware.com> wro=
te:
> >>>>
> >>>>>> ...and is constant for the life of the device and all subsequent m=
appings.
> >>>>>>
> >>>>>>> Perhaps you want to cache the cachability-mode in vma->vm_page_pr=
ot (which I
> >>>>>>> see being done in quite a few cases), but I don=E2=80=99t know th=
e code well enough
> >>>>>>> to be certain that every vma should have a single protection and =
that it
> >>>>>>> should not change afterwards.
> >>>>>>
> >>>>>> No, I'm thinking this would naturally fit as a property hanging of=
f a
> >>>>>> 'struct dax_device', and then create a version of vmf_insert_mixed=
()
> >>>>>> and vmf_insert_pfn_pmd() that bypass track_pfn_insert() to insert =
that
> >>>>>> saved value.
> >>>>>
> >>>>> Thanks for the detailed explanation. I=E2=80=99ll give it a try (th=
e moment I find
> >>>>> some free time). I still think that patch 2/3 is beneficial, but ba=
sed on
> >>>>> your feedback, patch 3/3 should be dropped.
> >>>>
> >>>> It has been a while.  What should we do with
> >>>>
> >>>> resource-fix-locking-in-find_next_iomem_res.patch
> >>>
> >>> This one looks obviously correct to me, you can add:
> >>>
> >>> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> >>>
> >>>> resource-avoid-unnecessary-lookups-in-find_next_iomem_res.patch
> >>>
> >>> This one is a good bug report that we need to go fix pgprot lookups
> >>> for dax, but I don't think we need to increase the trickiness of the
> >>> core resource lookup code in the meantime.
> >>
> >> I think that traversing big parts of the tree that are known to be
> >> irrelevant is wasteful no matter what, and this code is used in other =
cases.
> >>
> >> I don=E2=80=99t think the new code is so tricky - can you point to the=
 part of the
> >> code that you find tricky?
> >
> > Given dax can be updated to avoid this abuse of find_next_iomem_res(),
> > it was a general observation that the patch adds more lines than it
> > removes and is not strictly necessary. I'm ambivalent as to whether it
> > is worth pushing upstream. If anything the changelog is going to be
> > invalidated by a change to dax to avoid find_next_iomem_res(). Can you
> > update the changelog to be relevant outside of the dax case?
>
> Well, 8 lines are comments, 4 are empty lines, so it adds 3 lines of code
> according to my calculations. :)
>
> Having said that, if you think I might have made a mistake, or you are
> concerned with some bug I might have caused, please let me know. I
> understand that this logic might have been lying around for some time.

Like I said, I'm ambivalent and not NAK'ing it. It looks ok, but at
the same time something is wrong if a hot path is constantly
re-looking up a resource. The fact that it shows up in profiles when
that happens could be considered useful.

> I can update the commit log, emphasizing the redundant search operations =
as
> motivation and then mentioning dax as an instance that induces overheads =
due
> to this overhead, and say it should be handled regardless to this patch-s=
et.
> Once I find time, I am going to deal with DAX, unless you beat me to it.

It turns out that the ability to ask the driver for pgprot bits is
useful above and beyond this performance optimization. For example I'm
looking to use it to support disabling speculation into pages with
known  media errors by letting the driver consult its 'badblock' list.
There are also usages for passing the key-id for persistent memory
encrypted by MKTME.

