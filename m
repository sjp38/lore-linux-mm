Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9096BC76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:32:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D8702199C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 05:32:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="cCibAOf/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D8702199C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D19B96B000A; Tue, 23 Jul 2019 01:32:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA2828E0003; Tue, 23 Jul 2019 01:32:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6C678E0001; Tue, 23 Jul 2019 01:32:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 94DBC6B000A
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:32:16 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id e103so23399821ote.2
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 22:32:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rfVOBTkGgWLnADqNb7WUL1YdExalu2RGHdRuN86uruA=;
        b=l0xajq1BEYVMA0MHygPUvBRMXCuP5a6CQEmTgvVmmhgx/3O/tpQAqYYJjW9FevN3EF
         fAUhgNjlMdyC97PvNnH1EJdKkM+aXwZ9UYjrW/wtyBORKabWd6NUKx/d87m3dJEN086Q
         5/wh3ER1FH6vyqIrfYLvw0clnxxAEY5BMYWg4M6PG9xp/Ca66IXLGP0re10xi6OwmxO/
         4fI427fGrWi1boces9kCQKn1Cs9s8ml4ZhiWHcw6wgCkLeC4V3h7UEehWhtqXi69r2mh
         yYdAiIJQc4+vB/mkpdoLyrrdKuYKRAZzVjb5VJZMORCEqN+qjtLO/ktNyzCXmQB0pxzB
         zjzg==
X-Gm-Message-State: APjAAAVkJVUmBzbwKEPcrswbKe/cwPiKlWnKi0ZKJ2XuqI6+q3OyW1xK
	kDkTnl0q8BocSFLvXsgGjlD83sF6QptiBNcGf6twwC2SFInHZVpfnuA4H8yRP0Y7J0LOEkTcy/w
	FZGEFTmDNeplP5wjHoHhk9TMeq5JgKWU2I0UW2tftFxdWLyePw1y1GRw2Cxkv2w3zFA==
X-Received: by 2002:aca:4c14:: with SMTP id z20mr35367050oia.121.1563859936172;
        Mon, 22 Jul 2019 22:32:16 -0700 (PDT)
X-Received: by 2002:aca:4c14:: with SMTP id z20mr35367026oia.121.1563859935503;
        Mon, 22 Jul 2019 22:32:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563859935; cv=none;
        d=google.com; s=arc-20160816;
        b=bpz/5NwFPnNz3S7cRBEvasoH0VleQq86EL+65FCZfabrm3ap7vpOhzlV1nGNoYx62f
         2EX8BzTaodwqT5Vt9Y3aVncggsr9mdjr5O+YUDb4ck0/AfvYdXSRcxSL46iun9K29y/h
         dTkBuGd+Hry9OpSmffLs2H2ul1b2UWOCjnI1ldb7lnyoBGe/qBNHwY6WHcWiA6sXiBpt
         cYfgABje+DtY+IaBp1fTGy+tXSPrmMtrTq/G/6oDhASBbyEZWdLc0ts/TAx/l9uxqDHf
         3XtYB6olfz32xUc3h4Jcd3EVPJGXGyzbwvsNo4qLvKk6OFPhQUVWV5frV5RY0do/wkw2
         rEgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rfVOBTkGgWLnADqNb7WUL1YdExalu2RGHdRuN86uruA=;
        b=cqms4NhPGi+tkSbEfHD+lmRFzrMgEvuQesyxoNK1lnY2c8FhQTumUrH0HiJcuJHFQS
         ViL3qNt0CVnRu8gufatKeqjRZ+Lu4ltA/PC+DQoHeTtmaTJRRe0Kfnu+szmERPP+SFET
         iPeULf93oimKR2pI/c0vIjqoePG8ZZJF6+M1ir6MAFMHQ2dBrDZ+gtiW7w6QHGPG6LkL
         BoRXvItrwYugxU2yvpVid3fT35X1yjjxAO8aiVhHUHQZV2veOUtTKauEiRaWCxsoVzb0
         Ww3h9ZzyUECdZMreZzCeHbD7XGrkZzZ4EaNfuTK180Euh5phx7e1Za/vGtv6fhfHcffo
         A75g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="cCibAOf/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h91sor21350788otb.2.2019.07.22.22.32.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jul 2019 22:32:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="cCibAOf/";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rfVOBTkGgWLnADqNb7WUL1YdExalu2RGHdRuN86uruA=;
        b=cCibAOf/Js0bFf/rOoWSrEyv9y1+LYPfRTwhuC16wpTr2xqyeheiY8joolznjwpFlP
         EbgrMxhMTsMUIefhUgH/OmAXMe6s+jzC0XdqdQeOkk1pUiz/pGhkFAjClaN8uIVhXPF3
         jkqht7TWonRqMhxwIj84p7o2qG7aDmnoSj33hNmiZPmSjKmXJivzBSIab1oXHzDJCYGq
         yUXZreSZ42kaDuP8Ikp/IDHhRmJfO+C47QlO7Af9mva8zDj5lJGj3eyQvC+zwjof36U+
         r9aYfq+OT3HnG5wU/ZC/A6jMWzVUD1dWXhrjMRMOkfkASGysOpiw7bpJIXU1mBVC7XJt
         Vcwg==
X-Google-Smtp-Source: APXvYqyjt2ypLm0Iyn93tghYH78tRb7uLgwNWDeXJ9GGqsHKMUS9oIUtJUlcsPdUhpTaqHwb8X/qdw/MGcgyJyksvSU=
X-Received: by 2002:a9d:7a8b:: with SMTP id l11mr21255488otn.247.1563859934961;
 Mon, 22 Jul 2019 22:32:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190722094143.18387-1-hch@lst.de>
In-Reply-To: <20190722094143.18387-1-hch@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 Jul 2019 22:32:03 -0700
Message-ID: <CAPcyv4j7wPPBbcPDRGn=L8K-HQCZQbM0+HiXJX_F+1Uway+qXA@mail.gmail.com>
Subject: Re: [PATCH] memremap: move from kernel/ to mm/
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 2:42 AM Christoph Hellwig <hch@lst.de> wrote:
>
> memremap.c implements MM functionality for ZONE_DEVICE, so it really
> should be in the mm/ directory, not the kernel/ one.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Dan Williams <dan.j.williams@intel.com>

