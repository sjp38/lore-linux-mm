Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C1B9C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 19:46:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 064AD2080D
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 19:46:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="D+opncBv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 064AD2080D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACF968E00F1; Wed,  6 Feb 2019 14:46:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A56BE8E00EE; Wed,  6 Feb 2019 14:46:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 945838E00F1; Wed,  6 Feb 2019 14:46:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65A7E8E00EE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 14:46:09 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id q16so7147164otf.5
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 11:46:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DPRk2YeA0ENLaCELegsjd2/mMdISAWmeKeSJ7XCFV30=;
        b=S1LmAMbrx9Bt5x3BCzEtBNKAnz90PS+AcwgAnfigFgxPJ3yJSpVDKa0y5RqnE4Usn0
         zJTiuRFX/ZauERLl1wQuOZTPb2la28/hseTaeva3DIawnr4WqeNuthdSqrTBY7qUvgIy
         IDiQkY3GTtPEAkdHa7DA3RmKauYZ1IRuqljL1EVSOUbyb/6fc9muXVnswAclZO17U8nF
         erLO9L5PhhtNIAZmKi0nX5N6GQSQuE/qyfRqGnKe8WI9WmgwT3Kh5PdmD03JAo/7gJWI
         DvONNTLO3Ig6hAOMC5LxrTPsCVVEpSO+7dyroqAkCrxtEl4gpkWaL/KQY/SwRdUqowKs
         odCQ==
X-Gm-Message-State: AHQUAuaaEBdsiTj3VJuZN+BmoIfxiKiLb2RxlSJdKRiB/OwWJ8KV4ui+
	KCJzQBRsIn0tpWPz1ACksRFaYNilOtsd1N7H6OwGJ7VHhdufIk0o7FXmdlgskixilD5mZ5SCDE8
	GCHZDZY2zP3QVhWdofTedireUbgNtuKYK9QUoKfpFem48NZxqZvhxMeZcN/AxcI8aq7TU7O1sQ0
	Vg6D8kyCe20tGxF0PudwNkUoyIXBfu8msybAikmRaeQSM8BV1wvF6ZyxJCOSFoQeYSD/1tVrNQ4
	3J+GrIwiuQFuKai92kVgSqkKrjJEejNTfwjgSB/GeLJ3MB3bmJGBanaayFjH8xpgbOWnvQ1YD9Q
	b/WZRUX4g22kqFFd3CYKl/khT5C6pV2pEijfSAiqlorRd5v6ou3HS+IPdVaohxfRHg87wbMAgw2
	I
X-Received: by 2002:aca:6288:: with SMTP id w130mr486880oib.29.1549482368978;
        Wed, 06 Feb 2019 11:46:08 -0800 (PST)
X-Received: by 2002:aca:6288:: with SMTP id w130mr486854oib.29.1549482368210;
        Wed, 06 Feb 2019 11:46:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549482368; cv=none;
        d=google.com; s=arc-20160816;
        b=ktQntO2lFf7KKfaC553cpOT53LYznmTKfjQC5pRkJ3bsrGxeQk4aon+EmU6uSNqaJ9
         eGC0XHfPyfdYYlmOOSUgeS1fqnJR9cWU3IexN4hGPNPfFaaG/WVqZ2+0U6GxhifKjHlH
         1ZBIikIN/4rMc1Qd+1T+OEpb8PezYsgaxYhgmtafdp5luoQK6UklzeG7b3yyFLpyEJFX
         5LEqA61PJzzOGgJ1mvetFvpS0xTLdZNbmcrUY1Xv7lcgcJmwCSP9YRGAli+xNj23nF86
         7eZUz80SEhFaN/ZZb6YuX+nEHlOiDq2NDdNHafO7XV9PlTHLmQzmXiL2uaQ/1Ad5P21z
         BaNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DPRk2YeA0ENLaCELegsjd2/mMdISAWmeKeSJ7XCFV30=;
        b=Qbgg2fqG63XM99x7dfrthnisFwfQjVKeiofc+dMSLqB57PnazikLAP02wrq409bnLG
         WL+WAQciqb036UnJoIOLRdhE3xMeGFKUDZHBnQcfCpC7sNr/CgCxpnqY3L1LtITifc3P
         hqPStRZvv+XqADmu3YkTJA1bnOpRh2Yv0MhPpmPeabI3/YDqKtWZ8aBQTrfQWmGFuNWa
         zcYj/3K9mm2sJeKnGf9+xGFunZniPZIvgO7Oewk913j4nQyXhxJoR2muxu3ByIITJxSk
         uOqG1p7uBUGSONSL9uoW9c7GVYVkxSYY6l7tyWUWzwsUpraLq0WdPo+SMp98bsurnYya
         nrkg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=D+opncBv;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n31sor14625508otn.41.2019.02.06.11.46.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 11:46:08 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=D+opncBv;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DPRk2YeA0ENLaCELegsjd2/mMdISAWmeKeSJ7XCFV30=;
        b=D+opncBvF6bDRVFj2WCKwHoO6oV/Y3U6I7oyuFwqVTqLo57o4BCg4re51jm57NgtA6
         ZVbb1nNsmHaoiADxy9d0RYV5RCd0kophHtPirdWFjW3lcbih/CSNYHfEwIMp5gASIcop
         JyRI4Q/7bnNjz3EJSq87ynSThUyRwZVxhJ5g6GugqC+WYedS12P9ULseURTpQ1pvMw3P
         7IHFTZ4kMiDI5wCJ2cFDbDjY7nKGNrNrfXeNSPcCt6gVVwx9safARDLh6EYsN2yatBil
         943mbvlBkI8D7mzjvKttwI/evQmMOzaYVvLF/HwkxQ4kmHgO9cPYa+yUbb9eqOKF93b0
         Vd3Q==
X-Google-Smtp-Source: AHgI3IbfowQ6doWzN8plMe6p/eR9jKuKihJMQsfeoWqHAFPTBKwxHJ+qAJPMxS3Qqf/ayEhmLl8IwOaQSZV7zgzp2PE=
X-Received: by 2002:a9d:3a0a:: with SMTP id j10mr6481150otc.229.1549482367913;
 Wed, 06 Feb 2019 11:46:07 -0800 (PST)
MIME-Version: 1.0
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
 <20190206095000.GA12006@quack2.suse.cz> <20190206173114.GB12227@ziepe.ca>
 <20190206175233.GN21860@bombadil.infradead.org> <47820c4d696aee41225854071ec73373a273fd4a.camel@redhat.com>
 <20190206183503.GO21860@bombadil.infradead.org> <20190206185233.GE12227@ziepe.ca>
In-Reply-To: <20190206185233.GE12227@ziepe.ca>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 6 Feb 2019 11:45:56 -0800
Message-ID: <CAPcyv4j4gDNHu836N4RfgQsE+eZU9Wt0N9Y09KQ43zV+4mK-eg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>, Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, 
	Ira Weiny <ira.weiny@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, 
	Jerome Glisse <jglisse@redhat.com>, Dave Chinner <david@fromorbit.com>, 
	Michal Hocko <mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 10:52 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Wed, Feb 06, 2019 at 10:35:04AM -0800, Matthew Wilcox wrote:
>
> > > Admittedly, I'm coming in late to this conversation, but did I miss the
> > > portion where that alternative was ruled out?
> >
> > That's my preferred option too, but the preponderance of opinion leans
> > towards "We can't give people a way to make files un-truncatable".
>
> I haven't heard an explanation why blocking ftruncate is worse than
> giving people a way to break RDMA using process by calling ftruncate??
>
> Isn't it exactly the same argument the other way?

No, I don't think it is. The lease is there to set the expectation of
getting out of the way, it's not a silent un-coordinated failure. The
user asked for it, the kernel is just honoring a valid request. If the
RDMA application doesn't want it to happen, arrange for it by
permissions or other coordination to prevent truncation, but once the
two conflicting / valid requests have arrived at the filesystem try to
move the result forward to the user requested state not block and fail
indefinitely.

