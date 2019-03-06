Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69318C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D4712063F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 18:43:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lFKuLd26"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D4712063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF5ED8E0003; Wed,  6 Mar 2019 13:43:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA57A8E0002; Wed,  6 Mar 2019 13:43:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BBB28E0003; Wed,  6 Mar 2019 13:43:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 736958E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 13:43:39 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id v125so6272596itc.4
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 10:43:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XKsJSARaIXiJsFyVSuRaZysl9pduI66L9p2pAHVz2y4=;
        b=rweN54A4BcUC2Dy3nm7Gjy5DdoJKyRyMKiEdjlX5RldshsLl6BVu9zth/3r1ggQAMI
         rQDOB2XV9WRW9UKCwpB5ZrfYJqBPaf4/TjD1813uJV35R0TEUvHcmuqViuiIfQ46NXNP
         xMSUa5HyDSkT3nhKz8kDBR6psQrNuFkVEVtkqwJx/ls1oynzdPPahmRgKSz5UzAWASov
         QjsPOpxWJCsQ8vq373hcbG2x8frZL8/Qrr5SFrHYEDUldbGSEEut/qDbSknRvUut2uc4
         xYLxZ/9B11C9KlSCjuIaYXuChmVLVce9K5NTzPylIt76DgucveD+nKsDQT4+K3U9I7xF
         Puiw==
X-Gm-Message-State: APjAAAXlfWRcLdIW0zYQ6JZ5rUn3c9zLHLPht/Iws6kW31JnqFibMi6k
	m5KFt474bFh9dwAxjLcveUzpEtW543DClsXxf4szJBFy7fPdWyaMMTE/McRfp+MaxQcj2W+UMiG
	lMVIMk2cDW20YlVGIbqzDEQZYPBrdrkfOs4Dqe89d+NBBI8nQhh55IR2TJBGGjOr6AvynR2oFrP
	VtTV+/crF5kvrPFDQPysE+mZRUjyT0cV1PnaKYDyQD7avWbcWuaR3gwqey/WVKkHmcWeo1QLNrh
	s/q+UJGw27w/o7XnI9IeXvKx/POBeLwV+D+I27te0Q2sKKFKqEXdUShj738EQqvSE7K6apt3uOi
	gFYm+kVKszQZzM30fGhwX7u/JFdb103zlOgD4cwLFgXs3JT/bUHT0a6Offpvq3K2sTJInlBevkG
	p
X-Received: by 2002:a24:4198:: with SMTP id b24mr3261223itd.25.1551897819230;
        Wed, 06 Mar 2019 10:43:39 -0800 (PST)
X-Received: by 2002:a24:4198:: with SMTP id b24mr3261184itd.25.1551897818505;
        Wed, 06 Mar 2019 10:43:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551897818; cv=none;
        d=google.com; s=arc-20160816;
        b=nWLhyfoOFinGqMvLR77C/IzuXRT+FiaBv9w/PlXyfHOMBnDmxTT9WXv0IRjuJwOo4k
         uOqQfbqMe6zw9pJLTQRWBRCFmq65P68BEv/AdZw8pqMregMGPQq9+LLqDumHmLIU71wD
         dg9s7hxKPGHH8yDGJwlgFj+RKXIatuT772XnZrGhGgVcRlQygB3jWOgxVs91BQR/S8dP
         IdELTgwsiOwQpzRtXAgN7Wi37mf8obDki+A+hUMRVqAsVDAiNqMFVx6imhL5/syoV1qi
         ZnAbWPWY3a/55GQgmVkN9lmaiFXaqTfzicaN0KCXLuHjXaD76aKLVwXat6FE5OKRsjD1
         uayQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XKsJSARaIXiJsFyVSuRaZysl9pduI66L9p2pAHVz2y4=;
        b=QY8o9hHr8Ljn/jJeJ7YyGZh7kranEd1UhXmWF0HKbQFA8mlMdZj8BiQvdISFg4mIdh
         LdocjLx50ZdLGmgNehWwpaQD4x7wN0OC6Zcida1j30dDDZlpjg9jabiRfbGSiw2tsgIW
         Xu5OOaRH5/lj1bbvcxR28zymifg7Bm6mxKjpVkWmNZtEtkMr6mtIr1cJSU04RFUXRm/+
         K9JSQfAxSmI6hiP6Y847U2clUfuBxOj8nN/u2rR2/3eFkxSTPd1AedXYMmKeAr7niUC0
         TczGaREXSyP8GHxOmWVfbyiivL4mN8iI6QvYZ0PtfRQziXIM8H1fWO+zldqakAl5O5Li
         6btg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lFKuLd26;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f194sor4576839itf.23.2019.03.06.10.43.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Mar 2019 10:43:38 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lFKuLd26;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XKsJSARaIXiJsFyVSuRaZysl9pduI66L9p2pAHVz2y4=;
        b=lFKuLd26PoIcx6hogS2YHTqJUMClViOLA34+tUpEX26awsWVyMv7LSszyu7OuPv0UN
         bf+btaQivqAeZbYIbveaDUEHgxF2IeYKfEn1M7G8tQjrAhgibnH1QlweCxohnf21HIBJ
         KnDYWZR1D5URjSD/pPnbSv7uRHNXRalACiKdfaOdarCkVRVCnMOWGNii6WNmI2An1lWM
         TXogghqokttOGPiCN/vtAEwzHqVbGK049zpQSoNpCJPTDBaEpk/OMP8oEOZL+xlXTuFe
         idMC8kdih4EAGpuyY/DsUcHXT7vRV5gJNzKGr88YIzGAm+DMl64Cf5PvutPuH+gmvQCT
         ln4Q==
X-Google-Smtp-Source: APXvYqzQc8y/SQZqjHW3Wb9NqF49Slajo0x5JptFFGJXyB/4hlWmx/e0UkTYelRMjCYNpSfD5JXcVrwTMz9Jo8gY5ws=
X-Received: by 2002:a24:45e3:: with SMTP id c96mr2719435itd.89.1551897818040;
 Wed, 06 Mar 2019 10:43:38 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306110501-mutt-send-email-mst@kernel.org>
 <bd029eb2-501a-8d2d-5f75-5d2b229c7e75@redhat.com> <20190306130955-mutt-send-email-mst@kernel.org>
 <afc52d00-c769-01a0-949a-8bc96af47fab@redhat.com> <20190306133613-mutt-send-email-mst@kernel.org>
 <7a77ce2a-853f-86c6-6d10-1d8db8fb8ae4@redhat.com>
In-Reply-To: <7a77ce2a-853f-86c6-6d10-1d8db8fb8ae4@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 6 Mar 2019 10:43:26 -0800
Message-ID: <CAKgT0UfC0E6_ZSs5zvkTsH+2LdQuL7fWHqNJQtz+j7BThx5FDA@mail.gmail.com>
Subject: Re: [RFC][Patch v9 0/6] KVM: Guest Free Page Hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, David Hildenbrand <david@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 10:41 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
> On 3/6/19 1:38 PM, Michael S. Tsirkin wrote:
> > On Wed, Mar 06, 2019 at 01:30:14PM -0500, Nitesh Narayan Lal wrote:
> >>> Want to try testing Alex's patches for comparison?
> >> Somehow I am not in a favor of doing a hypercall on every page (with
> >> huge TLB order/MAX_ORDER -1) as I think it will be costly.
> >> I can try using Alex's host side logic instead of virtio.
> >> Let me know what you think?
> > I am just saying maybe your setup is misconfigured
> > that's why you see no speedup.
> Got it.
> > If you try Alex's
> > patches and *don't* see speedup like he does, then
> > he might be able to help you figure out why.
> > OTOH if you do then *you* can try figuring out why
> > don't your patches help.
> Yeap, I can do that.
> Thanks.

If I can get your patches up and running I can probably try the same
test I did to see if I am able to reproduce the behavior. It may take
a bit though as I am running into several merge conflicts that I am
having to sort out.

Thanks.

- Alex

