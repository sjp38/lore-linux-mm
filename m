Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2D6FC3A59E
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 04:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62FF922CED
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 04:51:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="hs+FLQG6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62FF922CED
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0FBE6B0003; Wed,  4 Sep 2019 00:51:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBFCE6B0006; Wed,  4 Sep 2019 00:51:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8F616B0007; Wed,  4 Sep 2019 00:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0040.hostedemail.com [216.40.44.40])
	by kanga.kvack.org (Postfix) with ESMTP id B32306B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 00:51:58 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 67DAC688E
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:51:58 +0000 (UTC)
X-FDA: 75896015916.06.eye87_687ff961b3231
X-HE-Tag: eye87_687ff961b3231
X-Filterd-Recvd-Size: 3890
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf14.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:51:57 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id y39so9290841ota.7
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 21:51:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7g70nxojyvqUevqcEcO6mWCw0Mvt89bDYJhasa/z5qU=;
        b=hs+FLQG6hGil7CYHLEApAe+DDoHHrAAtp1/JipuDuY8CocVM/VhO4r46fSAaxkUPwW
         jfgpF+yVf3J8Mf9YQ0ZAlPlOZ0A56ZAZ70qFOGRPTLphjJlwyfY+cSJp1zI6vTkgbXFx
         AfqWtOBJHOq+4Fh/kl3zIYgvG02nI+be3NSIuL6+YJKwXIZHCOkjru+yQFKbu4ASyL9c
         5UQSHyY79bcthVT5/tI+YhyiHG3+QNotwCWQGyAfvXx0lCxjybk3f5IsNyINleiDZ7hE
         DHjNoewPDDBABrSPOJDev1gJlnWtk2e9s15h1hSlQ5FAow4I0vAeygMk/zyREM4CCJFX
         K9kw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=7g70nxojyvqUevqcEcO6mWCw0Mvt89bDYJhasa/z5qU=;
        b=Gww+KikWheg11cIByN0jeNkHg8T+wvqsPlv1zolCoZXSK/ToOmvSrQB7q4WZmSbS8W
         JEMcbkVc/WZsVyekNsfMuOLNbEgs4gLr+mvZtnz1r0gsA86NkAhf5XlUAx17wiyqA6A4
         /m5RPwAkERqyPS0TlsXnwvn5hOlORPcvo8SrPHr4iGlr/k4GGtq8ryxEVxTI0Su71/bj
         yyf8JsPdFnlP/gP+cJuVxqv3BTemnDskUCWcgxl1GAURqAUCKvbtC3e5D/MAe5K74oVa
         3kMl5lRGja38bDxmZyrPtQFuYuAybn+q7C9htA5er+IdLmLVBSdm28du8rTr+C/qiR5H
         C6zw==
X-Gm-Message-State: APjAAAU1yn2cxtpCY2SrJOLMkMVUeUnrF/0G0MD//oG3sF4M62sBMtQW
	5OifA4zUM/PiAcyTjmwI+vaBBdDUEPNjnRgVUo9sRg==
X-Google-Smtp-Source: APXvYqwK+0TQHzt1dZYPeNvE5yh0ZFEy9YeCqwtmvVYM2AZU4/vDh4rMtpicZrlbHi4Qc6hV8mY9VZENn/jerJ7RoBk=
X-Received: by 2002:a9d:7343:: with SMTP id l3mr31638937otk.268.1567572716918;
 Tue, 03 Sep 2019 21:51:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190903200905.198642-1-joel@joelfernandes.org> <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
In-Reply-To: <CAJuCfpEXpYq2i3zNbJ3w+R+QXTuMyzwL6S9UpiGEDvTioKORhQ@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Tue, 3 Sep 2019 21:51:20 -0700
Message-ID: <CAKOZuesWV9yxbS9+T5+p1Ty1-=vFeYcHuO=6MgzTY8akMhbFbQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
To: Suren Baghdasaryan <surenb@google.com>
Cc: "Joel Fernandes (Google)" <joel@joelfernandes.org>, LKML <linux-kernel@vger.kernel.org>, 
	Tim Murray <timmurray@google.com>, Carmen Jackson <carmenjackson@google.com>, 
	Mayank Gupta <mayankgupta@google.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	kernel-team <kernel-team@android.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, 
	linux-mm <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.cz>, 
	Ralph Campbell <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 3, 2019 at 9:45 PM Suren Baghdasaryan <surenb@google.com> wrote:
>
> On Tue, Sep 3, 2019 at 1:09 PM Joel Fernandes (Google)
> <joel@joelfernandes.org> wrote:
> >
> > Useful to track how RSS is changing per TGID to detect spikes in RSS and
> > memory hogs. Several Android teams have been using this patch in various
> > kernel trees for half a year now. Many reported to me it is really
> > useful so I'm posting it upstream.

It's also worth being able to turn off the per-task memory counter
caching, otherwise you'll have two levels of batching before the
counter gets updated, IIUC.

