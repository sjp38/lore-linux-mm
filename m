Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6045DC00319
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 00:23:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F33C32087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 00:23:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="V7pozMlw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F33C32087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4DB3A8E015B; Sun, 24 Feb 2019 19:23:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 489F38E015A; Sun, 24 Feb 2019 19:23:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3785D8E015B; Sun, 24 Feb 2019 19:23:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 088008E015A
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 19:23:53 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id d13so7861508qth.6
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 16:23:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=QUPTL3PLqLo52so3LAReL1b7OoKBQnl+BlN/LgFRYCg=;
        b=YCTOwr4ArYCHKmwOV2zXvFl+BuXsqw3MmkdAOw8RXDBAmhwBuMsJ9AWrqYMzy2EumZ
         Oi/mcIJmV3MKYB1CR1CXml4Cg4wvchUbIBvTsd8kqfdHkOuvfZVPiOmhsnE1khwM2QP1
         LBugeHss8Y0kTNjJV2eDCv2RVS3vFwl1MnQdhC7wpb0APNxdFVFQDzjnY0kjBtYke6z5
         XXdswUCEtqYZeXwzPCCla44rpBdAkH0lRairHXPHKdr6zvX/7aNMYEJjgn4kw+Ckq7s9
         /fFX49lqaIzM3BDPiR/ux6N0Ua1UeMmxx3nxdWXnNrySc8DcdN9p0ELpdw9xhrn+qDbb
         E5WQ==
X-Gm-Message-State: AHQUAub7BIl9Jn5srNXvLIKnvgfrfh7vEoC8xTQeLONRWEIua2morTib
	FDoIATeWLL1CMOt45p3dF93q4Ztohyg9FqaLwtfE0UH7IoBuz4vzO4QyEJpd5pBLEnOwsOg9pWP
	hZRA9tMhZAYnnajPH+iBYApn3+6IhG7cODNXzBy3hp9tCRCAkb5FE9aDRlIJyzFLg4fgwkBPD18
	kkrl4oQa3x0d3hNJq9gd735aFvnSRG45m2oLLTrYym09B6kuAQDO/MZQDJQBIK6FE+dwzbCN+9s
	Olx9aWq15OlDzX2H/fd9Uyv8MWfBfsxVzHDDiAqcXYMukVIoKgrgR84Ek6PcHNxYW/sqovJiEVU
	QDNkrspFjtjrYL2pfdx6WIFnQqX6VQF7BkXZwLOdbKgvvXwyxd2EHaGCHszZNodpvC4mmTlp1xm
	M
X-Received: by 2002:ac8:2827:: with SMTP id 36mr11566595qtq.359.1551054232669;
        Sun, 24 Feb 2019 16:23:52 -0800 (PST)
X-Received: by 2002:ac8:2827:: with SMTP id 36mr11566573qtq.359.1551054231788;
        Sun, 24 Feb 2019 16:23:51 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551054231; cv=none;
        d=google.com; s=arc-20160816;
        b=rmsga/w2/84KGWVPKLbM1kj8hNvXq9ZcZqzw1pFci3ekSK8qbgdsr9fsYCQxityIYp
         densyBGshf8Z4F14dp1m9DkFXMb0Gzno44Cg9F4vJatmAy6YTtiMC5B3n5fvX2AFIjI9
         ZRpG4vqnsHg2sqSFgFiKzGg7+e6ez29RHYvZ4SaenePLq55kQLGT5jLEmEOePX9ix5l/
         oYCe78/zTPTlGSC7lkpOVchAqJsu3BzhwTr4qYnjwMoqTaiZMILaIeYzlrFZVA4i3eJ5
         aZeobI1Fk/UEtiyTMHlm1ApFHVOkEjhKZAjkl4wKtTWniy52WwlDpnZOo+0MMmaqx8oe
         0ZNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=QUPTL3PLqLo52so3LAReL1b7OoKBQnl+BlN/LgFRYCg=;
        b=r1zqMIWAHmTgl8A3NYxkghZKcqHo646vmJit3olvNUcQvOQkSAmMWtQ3gQuVAgSTYw
         ZpG6LJmuh0b5LQBjltcljF1ZYw9R5KcKRu/i+9HDEpOkxdF62G05Q5kZ5/69Jct030xJ
         DAZAeSlKg9zdMgheanl3ownXLBNpMAVoqVBciQEdjtBaQZnkowclB7J2U8Z31SMnyL0v
         NHP4z3b9Kc30AnTgenZiZaI+3NXcbWmiOHH5nEpxahThv2SSZuoUPKbSPtGJ8HGw4WGz
         nuFoopJMLizz2E38htZFFfrqKiECh8Sgc70hkMsfQhk63CxC3KovWqA3d8cQCmksOqtO
         zOqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=V7pozMlw;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8sor4485279qkl.128.2019.02.24.16.23.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 24 Feb 2019 16:23:51 -0800 (PST)
Received-SPF: pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=V7pozMlw;
       spf=pass (google.com: domain of drinkcat@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=drinkcat@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QUPTL3PLqLo52so3LAReL1b7OoKBQnl+BlN/LgFRYCg=;
        b=V7pozMlwApDKiEuQ9KL99F2KVnCWK4yyb52Eec+39LdbtmZGHL4qD9tBIbF/OwIW+y
         cM1aCYv/z1jPXZ7bMZ6GvPia/8hff80OYppp2fw6cFExuhUxML2MU9prpa0SluDPE0dw
         5R6hzapbb+GT0B0Q6uA7M4QHKCJm20igRHoL4=
X-Google-Smtp-Source: AHgI3IYirf19cEx+D7YVBM5KBkdm2qM0SS7imatY1p89YM8NkGpwT67vhO3HIEUXH8EZmfreZX4pl0NiDFDcK8eBgF0=
X-Received: by 2002:ae9:e901:: with SMTP id x1mr11369376qkf.124.1551054230094;
 Sun, 24 Feb 2019 16:23:50 -0800 (PST)
MIME-Version: 1.0
References: <20181210011504.122604-1-drinkcat@chromium.org>
 <CANMq1KAmFKpcxi49wJyfP4N01A80B2d-2RGY2Wrwg0BvaFxAxg@mail.gmail.com>
 <20190111102155.in5rctq5krs4ewfi@8bytes.org> <CANMq1KCq7wEYXKLZGCZczZ_yQrmK=MkHbUXESKhHnx5G_CMNVg@mail.gmail.com>
 <789fb2e6-0d80-b6de-adf3-57180a50ec3e@suse.cz>
In-Reply-To: <789fb2e6-0d80-b6de-adf3-57180a50ec3e@suse.cz>
From: Nicolas Boichat <drinkcat@chromium.org>
Date: Mon, 25 Feb 2019 08:23:39 +0800
Message-ID: <CANMq1KCfhWdWtXP_PRd_LEEcWV8SQg=hOy4V7_grqtL873uUCg@mail.gmail.com>
Subject: Re: [PATCH v6 0/3] iommu/io-pgtable-arm-v7s: Use DMA32 zone for page tables
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, 
	David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Levin Alexander <Alexander.Levin@microsoft.com>, Huaisheng Ye <yehs1@lenovo.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	linux-arm Mailing List <linux-arm-kernel@lists.infradead.org>, iommu@lists.linux-foundation.org, 
	lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Yong Wu <yong.wu@mediatek.com>, Matthias Brugger <matthias.bgg@gmail.com>, 
	Tomasz Figa <tfiga@google.com>, Yingjoe Chen <yingjoe.chen@mediatek.com>, hch@infradead.org, 
	Matthew Wilcox <willy@infradead.org>, Hsin-Yi Wang <hsinyi@chromium.org>, stable@vger.kernel.org, 
	Joerg Roedel <joro@8bytes.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 1:12 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 1/22/19 11:51 PM, Nicolas Boichat wrote:
> > Hi Andrew,
> >
> > On Fri, Jan 11, 2019 at 6:21 PM Joerg Roedel <joro@8bytes.org> wrote:
> >>
> >> On Wed, Jan 02, 2019 at 01:51:45PM +0800, Nicolas Boichat wrote:
> >> > Does anyone have any further comment on this series? If not, which
> >> > maintainer is going to pick this up? I assume Andrew Morton?
> >>
> >> Probably, yes. I don't like to carry the mm-changes in iommu-tree, so
> >> this should go through mm.
> >
> > Gentle ping on this series, it seems like it's better if it goes
> > through your tree.
> >
> > Series still applies cleanly on linux-next, but I'm happy to resend if
> > that helps.
>
> Ping, Andrew?

Another gentle ping, I still don't see these patches in mmot[ms]. Thanks.

> > Thanks!
> >
> >> Regards,
> >>
> >>         Joerg
> >
>

