Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1805C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 23:21:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48D1420823
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 23:21:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pOq4jwIH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48D1420823
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C3506B0003; Thu, 25 Jul 2019 19:21:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 974BB6B0005; Thu, 25 Jul 2019 19:21:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83CB28E0002; Thu, 25 Jul 2019 19:21:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B6D86B0003
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 19:21:13 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id u8so20294948oie.5
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 16:21:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=38jxRDTFNsBuvXEWmRhAENl7Dn2UdsUzhcb9070VNP0=;
        b=mEtY+p4sqIJ3db6+rz3NdYQZGdu3nKKG0AjSYo4S7ClZcevmNHIWOpF9Jyvt5R7BbE
         TsNSzWWSdsTwMW5T/Hkx2hR3QJu1XpLVBih72bT34ehxOFHEerSQvomviroi+5y3r1p/
         hexCVoDNrWRR5vo/7DicmtoPoy3DXKtXYmmk3DyFcfSY/Guyntjaz1/CAXM2w3zyHq1Q
         qUNkYh+K58R2wuKivbel0MuJqfzXv/TLqyx7aPJWXfMMBZqigYsGPmrN3zi5RvYiv/s0
         g5YpvGC7/SH4t6Y2/Ao0VI/T9HDSl7W/miqDFIRoSNZiEruNKhyBHcAiTgjPQXPkQCiY
         SfXA==
X-Gm-Message-State: APjAAAUY+3vsYGgrtxMOOYzXZ1DmF0PiVg0BiHclUD2plUX5Q3wOfMHQ
	TfiV/XgvAe+2a1+n/muIxG3CVXMjCbGgxu18UbaB/YZnldaYW5rnHMooLDNKMPpEUS9xJP8PRzy
	6hHoSV0x8uX8dzaEdbMxxHV2mcEWf2VVInlG5jxGH82J2Knp4kR48tg0jIb70SrcOvQ==
X-Received: by 2002:aca:5410:: with SMTP id i16mr42215715oib.36.1564096872920;
        Thu, 25 Jul 2019 16:21:12 -0700 (PDT)
X-Received: by 2002:aca:5410:: with SMTP id i16mr42215698oib.36.1564096872245;
        Thu, 25 Jul 2019 16:21:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564096872; cv=none;
        d=google.com; s=arc-20160816;
        b=xSMgVTsX4dvpMFzYHX8JV27yFljuSVjEGj6amDCkDcQdqlGR+WHicAH0QJ6xVjrTdS
         ycAJkx1jeFoaq0f5gEoEV8yPbvy5Fm2xtfKSdJbCnomXAtBchos4p22e2QSn0VpOYhrV
         qyMB0fk16MpCEUx5xPM7xxYhxC/EXERxRmCnkK0GZYd0s9sWadwwssPKhS4c3TiCDCFg
         /PhLKwQiTx2ou/AFTwbcRiDwGlS4LK/O/sS1eOCZZLkqqo4EgrfyywvQeaYuuCrRdriy
         twuFCU/61Z7W/8Kk0LaKJ6zgP/7EjH/EW2VJo8YY0Z0HPKQq/cHrgHVxde46gloFaVG5
         osVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=38jxRDTFNsBuvXEWmRhAENl7Dn2UdsUzhcb9070VNP0=;
        b=ELTNFKWdCK8/o2hhe9Du01/jp1I/btyYlQMPJPpQ79KEfcDXED9CQSQWCbuiMFkNpl
         O70KNHL64p7WyzNfVs9gfik2Osog7BCXaaUKujJQfLk2zCmZxi10PS9AR4J14VjSqGnn
         RaarkQmohASUuXM1CNCoDBYb+OwaOJBryd2u57VQA/LvLsFg2rPMEqG1+uH0jYl5+4au
         cxEJa7qu1QTKXsw7l8XGRRkpcXlbsWDtawzk3HuK7ImfEraG17/QK6Womjp/QmEBbNIB
         c5PUEDAPucBpggrhttE91PjRZoHGo2YkaXDOwWHP8gDZbCUZFZ9QdeGVtwdJBpKHdb5k
         cqgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pOq4jwIH;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor26741970otf.164.2019.07.25.16.21.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 16:21:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pOq4jwIH;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=38jxRDTFNsBuvXEWmRhAENl7Dn2UdsUzhcb9070VNP0=;
        b=pOq4jwIH28H2b1iSOQrWo32IdYYxXTbBo3q1WI1pQZh+wScKbCT6GcyOW+Ai5qId/E
         WxRSp38HTlhmMKBUZhyHF0kthb3Hfu2IAtovYxX3MB+9XmSpeRl3KStvol8PJTMEdu98
         hfSx+yBsxsA8MEwwx5UZKvguuEmqulFrDiDgOS9bu0eF0HJwBpIX5ATf10OuETHiSiW0
         UcL1d3XJrzlfQSNNKQdj9XZ5ne/2qHm4vgh5tNIsqfI47F60RJfLOYSn3N8WDyA4V3iR
         ko3LLIDAbctiv1VW95oe08P4AR2xba15afj1ayy+/picFE4mCeH95DA03AoDUFwzchv8
         f83Q==
X-Google-Smtp-Source: APXvYqzQt9JrA2rxwFLAC9k6gQgnEsbS5znL3NvqMmP5TLvNTgxwXAFj1N37C1EmlQjCItCvjUiFYydQVj6azSLq8fk=
X-Received: by 2002:a05:6830:2098:: with SMTP id y24mr25146806otq.173.1564096871998;
 Thu, 25 Jul 2019 16:21:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190725184253.21160-1-lpf.vector@gmail.com> <20190725184253.21160-2-lpf.vector@gmail.com>
 <20190725185800.GC30641@bombadil.infradead.org>
In-Reply-To: <20190725185800.GC30641@bombadil.infradead.org>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Fri, 26 Jul 2019 07:21:00 +0800
Message-ID: <CAD7_sbG+nv-PxnMAxsU25BWQz1EMQx3V0CT7W9XTdfY1HvZfFw@mail.gmail.com>
Subject: Re: [PATCH 01/10] mm/page_alloc: use unsigned int for "order" in should_compact_retry()
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@techsingularity.net, mhocko@suse.com, 
	vbabka@suse.cz, cai@lca.pw, aryabinin@virtuozzo.com, osalvador@suse.de, 
	rostedt@goodmis.org, mingo@redhat.com, pavel.tatashin@microsoft.com, 
	rppt@linux.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 2:58 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Jul 26, 2019 at 02:42:44AM +0800, Pengfei Li wrote:
> >  static inline bool
> > -should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
> > -                  enum compact_result compact_result,
> > -                  enum compact_priority *compact_priority,
> > -                  int *compaction_retries)
> > +should_compact_retry(struct alloc_context *ac, unsigned int order,
> > +     int alloc_flags, enum compact_result compact_result,
> > +     enum compact_priority *compact_priority, int *compaction_retries)
> >  {
> >       int max_retries = MAX_COMPACT_RETRIES;
>
> One tab here is insufficient indentation.  It should be at least two.

Thanks for your comments.

> Some parts of the kernel insist on lining up arguments with the opening
> parenthesis of the function; I don't know if mm really obeys this rule,
> but you're indenting function arguments to the same level as the opening
> variables of the function, which is confusing.

I will use two tabs in the next version.

--
Pengfei

