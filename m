Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A345AC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BB4A2173B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 22:20:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="v+Nv91jW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BB4A2173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECD528E0003; Tue, 16 Jul 2019 18:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7D608E0001; Tue, 16 Jul 2019 18:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6D018E0003; Tue, 16 Jul 2019 18:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB83D8E0001
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 18:20:57 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id a198so8476048oii.15
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 15:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=TNhwUv6Ky0s0w03ioY+550UObTT5jDR+657SS9hX3Ow=;
        b=e1XgHCqGqsgjFyKpaUrAMyeG2txZgv/9znK5y5d9dlm67Vvzvigt12r0ZCabC/85Ga
         tfVO2oOL33ahKJopyxP3Mro8Ba9H3m7/1uF6FhDK99nzuij0jdAtbTM/K7x6BUWhEnek
         j3CZeKnTOJ/3RQkB2ps3AFj2xgl8NVgavS1G2M5ILoc2ubIaYgshdkOjGt/qh5fZgoxy
         JpiaCIfHLM+RCf6NzFc+k+iuWFLe13/HRZzTEuvt8ahXb9kVaowAQEY9CZCFHHgyuVPr
         I3UIm1NMmV4EVKshIphdW9XBTUXz5MJegqVaP+51A7tOL0HQ48+gkhicU4RuU8AnWZjS
         z/XA==
X-Gm-Message-State: APjAAAWb0eMfLXTYSx0JOVn1DPodqDfLzlEglBz8A5RUI0vALD5LgvcQ
	oC3O6PH2i/sYOxa2EGbtX6VnVCq1RqyAfK7n5rLPr4x9EzohT9Yuf0wFR5s2PKcZ0JyIcuwkn1A
	7ZGPSl+muCeH52571hP1dRBuBsXDrlRPgiLkf3O3NgmUCyG7eLh7KHwn6vBXaeRjWkA==
X-Received: by 2002:a05:6808:8c2:: with SMTP id k2mr17360612oij.98.1563315657261;
        Tue, 16 Jul 2019 15:20:57 -0700 (PDT)
X-Received: by 2002:a05:6808:8c2:: with SMTP id k2mr17360590oij.98.1563315656610;
        Tue, 16 Jul 2019 15:20:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563315656; cv=none;
        d=google.com; s=arc-20160816;
        b=Lr7S1rJewzgCcnW2zZwY7++QRjMmf62yTtjtod9UENNM2cpnQIoe1wFRjkUK8VZnxc
         KTVxUflksrvnDeYtJeJsZujSTDtfMu3HOp3d/BB5G5Q2etFJatwBQ2hYBcvQhfYntNp5
         94Kj8Uz01keX8Bv0Vlj9geRJD00qjGkqq6ksL+clzWwORQzmOxWqhSNU1rk8Fce+zgOn
         ErFWxR2kMQ+16pt/FtOscSKUbd1h0NHEu9UCZQGc1NIHKmikgjJeNDeZOTD3FuckMAZz
         5rBbZFwAsuon+7s6ToduhEVOE4WDeicb1O8nHK/AMdJJMpL2D6PmEElChkNBgKzo1FRv
         KZ+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=TNhwUv6Ky0s0w03ioY+550UObTT5jDR+657SS9hX3Ow=;
        b=rcju/3dqcl/klWA8HQZlLwB2640KtKtCaFJWgPJis108IQBR1j9trirt2E3prW7dlr
         nS678khqvqQ/PtjNMX7eF1B7CeGpeaTIMLoEzKyAef2vVrRz/Q0VSmlFoGe6xbC0bf3p
         iOC901167olUOahRisRJrsWVo/Apk+Jlqvv961de9gjMfXXQ7X4uCl23jogGuABSYzhg
         Lc3d2OQEzX2yKm+KhopBuXctFHFJzGXsKGjMewYb1JUi/wjRsw8IrNExA1NrmbtkzSJE
         jSxmShoSPMCtP5uwI+Ao7ZmFbiB8CW9RsVTn7Y9xzkPRCihTEg9He9n6lvaWhc5i02WO
         zNiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=v+Nv91jW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j24sor11577463otk.32.2019.07.16.15.20.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 15:20:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=v+Nv91jW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=TNhwUv6Ky0s0w03ioY+550UObTT5jDR+657SS9hX3Ow=;
        b=v+Nv91jWpEWxB3/zZPcDf9TsGYnNUk2CxCYeiVF+WXu3e72lpqWE3E3zL1uP7kKM/I
         mWSC+EA9GPfECv8Dn/F4GCe6BsHuCw3YffdB81/ykh7RlRXTTw+lkwKY5db6NKrA0wiM
         vJIJM0ndSx7Z3vlHSM1Q3GD+OEhEsPak9HqQTmobk2mGCg2RSWBdQZF02DAKviNTolDt
         9SDDOnUdeKCBGe7Zb1ms0i6Eeqm5M8nPavXAQW+DCdbon412FKOVp1/ASfZ7Zm17UkmT
         5oS4kv9hgZ/bOnz/bdm2TKsksc6TCLtJ8qcCftpMyybO9L+LzRjA6LNjWj/T+Tz+Wkpf
         Gyiw==
X-Google-Smtp-Source: APXvYqwEIU4jOVbAg9CR3IdZtyD05lbj5Yyf9evbtBtEsapl8Q2qFdqA8FewNacU01JSVqaAY5FbVjHEwxNT2ZHQ5YY=
X-Received: by 2002:a9d:7b48:: with SMTP id f8mr1338868oto.207.1563315656274;
 Tue, 16 Jul 2019 15:20:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190613045903.4922-1-namit@vmware.com> <CAPcyv4hpWg5DWRhazS-ftyghiZP-J_M-7Vd5tiUd5UKONOib8g@mail.gmail.com>
 <9387A285-B768-4B58-B91B-61B70D964E6E@vmware.com> <CAPcyv4hstt+0teXPtAq2nwFQaNb9TujgetgWPVMOnYH8JwqGeA@mail.gmail.com>
 <19C3DCA0-823E-46CB-A758-D5F82C5FA3C8@vmware.com> <20190716150047.3c13945decc052c077e9ee1e@linux-foundation.org>
 <CAPcyv4iqNHBy-_WbH9XBg5hSqxa=qnkc88EW5=g=-5845jNzsg@mail.gmail.com> <D463DD43-C09F-4B6E-B1BC-7E1CA5C8A9C4@vmware.com>
In-Reply-To: <D463DD43-C09F-4B6E-B1BC-7E1CA5C8A9C4@vmware.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 16 Jul 2019 15:20:45 -0700
Message-ID: <CAPcyv4gGkgCsf4NtDPj7FNcTMO6o+fUYgfq8AP_pLkqDSbxjzA@mail.gmail.com>
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

On Tue, Jul 16, 2019 at 3:13 PM Nadav Amit <namit@vmware.com> wrote:
>
> > On Jul 16, 2019, at 3:07 PM, Dan Williams <dan.j.williams@intel.com> wr=
ote:
> >
> > On Tue, Jul 16, 2019 at 3:01 PM Andrew Morton <akpm@linux-foundation.or=
g> wrote:
> >> On Tue, 18 Jun 2019 21:56:43 +0000 Nadav Amit <namit@vmware.com> wrote=
:
> >>
> >>>> ...and is constant for the life of the device and all subsequent map=
pings.
> >>>>
> >>>>> Perhaps you want to cache the cachability-mode in vma->vm_page_prot=
 (which I
> >>>>> see being done in quite a few cases), but I don=E2=80=99t know the =
code well enough
> >>>>> to be certain that every vma should have a single protection and th=
at it
> >>>>> should not change afterwards.
> >>>>
> >>>> No, I'm thinking this would naturally fit as a property hanging off =
a
> >>>> 'struct dax_device', and then create a version of vmf_insert_mixed()
> >>>> and vmf_insert_pfn_pmd() that bypass track_pfn_insert() to insert th=
at
> >>>> saved value.
> >>>
> >>> Thanks for the detailed explanation. I=E2=80=99ll give it a try (the =
moment I find
> >>> some free time). I still think that patch 2/3 is beneficial, but base=
d on
> >>> your feedback, patch 3/3 should be dropped.
> >>
> >> It has been a while.  What should we do with
> >>
> >> resource-fix-locking-in-find_next_iomem_res.patch
> >
> > This one looks obviously correct to me, you can add:
> >
> > Reviewed-by: Dan Williams <dan.j.williams@intel.com>
> >
> >> resource-avoid-unnecessary-lookups-in-find_next_iomem_res.patch
> >
> > This one is a good bug report that we need to go fix pgprot lookups
> > for dax, but I don't think we need to increase the trickiness of the
> > core resource lookup code in the meantime.
>
> I think that traversing big parts of the tree that are known to be
> irrelevant is wasteful no matter what, and this code is used in other cas=
es.
>
> I don=E2=80=99t think the new code is so tricky - can you point to the pa=
rt of the
> code that you find tricky?

Given dax can be updated to avoid this abuse of find_next_iomem_res(),
it was a general observation that the patch adds more lines than it
removes and is not strictly necessary. I'm ambivalent as to whether it
is worth pushing upstream. If anything the changelog is going to be
invalidated by a change to dax to avoid find_next_iomem_res(). Can you
update the changelog to be relevant outside of the dax case?

