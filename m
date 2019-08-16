Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35D06C3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:54:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D848F2077C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 16:54:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="LA5Y5Kjp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D848F2077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 842026B0005; Fri, 16 Aug 2019 12:54:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F3246B0006; Fri, 16 Aug 2019 12:54:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7092A6B0007; Fri, 16 Aug 2019 12:54:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0209.hostedemail.com [216.40.44.209])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBD66B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 12:54:58 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E084775A7
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:54:57 +0000 (UTC)
X-FDA: 75828890634.11.lock53_4862d12b55b37
X-HE-Tag: lock53_4862d12b55b37
X-Filterd-Recvd-Size: 6134
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf35.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 16:54:57 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id l9so6779083qtu.6
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 09:54:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QVJMIAUNTcfruK5R8LRJMxtWPGPQI7Ry9GEDvODlN1s=;
        b=LA5Y5Kjpj+D3o1u9JwoTLIjvYl0rV0tZs9iEM17KKWIaqJu/ZgkkQSR4NyhNUDlRqH
         FjmblR9wtS87K1VeqFzXFQsiypgT9FKdVQKn9t0k6GgL7ZaWTn+75LYisquhf2MDrKP9
         D1076HoCBt9rn1J2iGrU4/d2vqtGTBo0qMc6MmFnT/dxxMPTYtbdtXAoMBBIaQPArPnm
         8q9QeFOc8zJy4t+M9Tm4RZsZwy0eLpF51wJyDXxF9h5NpFTRTHZHoo2uEP20LmlydZZw
         wsRccukrRvnx42UcxrjqGJJ70J68Nv5+rYWjBEpWmNdc11451J1vravRwY6UsghcO+fY
         Ra0w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=QVJMIAUNTcfruK5R8LRJMxtWPGPQI7Ry9GEDvODlN1s=;
        b=IdnhqGzPJHEKY4mjAGk+xMh0LQBV3q9xd76UdxmI4jEyWXAtmgUc5h3XE8A4yZ53vi
         WUcOcuTm/ynep1lAD0MnOcVsj+iSuX/r3aLlrC3/oOB0bR2BKqvkUEot9SNApGXb0Xdh
         l4Pc+Iq58xHkom9SfdtA/c0fGb2mfV2GIobJVToiDpFHPufquoqMjmMpIBXGHSGqjCwl
         MH65jGB205rEQUb0B+cnAV712vDG+mK4XtYqWdztJVkQt1FSSaglaJVzjFmIPJXwf5ZK
         ctULMJlVOyni7sqD3CwazKliiJvalJQs81rmZvSxGuw6V12RL1IQMsyolStlHB1rnUGG
         61nA==
X-Gm-Message-State: APjAAAWZEJwhNoRM4rng1ByBPLcHKwAokgin4U9L3DbPJGtC9sDu1SqX
	ncyby77Dzq4CLju1BPxuS1VUYQ==
X-Google-Smtp-Source: APXvYqzJNDVhKHutNxdNtyYoqetLe4kBGy2raMs/xBZz5bY8799Ba9b9YZFIevc1Y93TXGetBoIvow==
X-Received: by 2002:a0c:c93b:: with SMTP id r56mr2557476qvj.139.1565974496715;
        Fri, 16 Aug 2019 09:54:56 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g28sm3802062qte.46.2019.08.16.09.54.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 09:54:56 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyfV9-0008Ub-Us; Fri, 16 Aug 2019 13:54:55 -0300
Date: Fri, 16 Aug 2019 13:54:55 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Michal Hocko <mhocko@kernel.org>, Feng Tang <feng.tang@intel.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190816165455.GG5398@ziepe.ca>
References: <20190815193526.GT9477@dhcp22.suse.cz>
 <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
 <20190815202721.GV21596@ziepe.ca>
 <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
 <20190816010036.GA9915@ziepe.ca>
 <CAKMK7uH0oa10LoCiEbj1NqAfWitbdOa-jQm9hM=iNL-=8gH9nw@mail.gmail.com>
 <20190816121243.GB5398@ziepe.ca>
 <CAKMK7uHk03OD+N-anPf-ADPzvQJ_NbQXFh5WsVUo-Ewv9vcOAw@mail.gmail.com>
 <20190816143819.GE5398@ziepe.ca>
 <CAKMK7uGzOO4nZPbZzmaDjjBGZiV2HjgdbT45q9Rd5wTO14VH2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uGzOO4nZPbZzmaDjjBGZiV2HjgdbT45q9Rd5wTO14VH2w@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 06:36:52PM +0200, Daniel Vetter wrote:
> On Fri, Aug 16, 2019 at 4:38 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Fri, Aug 16, 2019 at 04:11:34PM +0200, Daniel Vetter wrote:
> > > Also, aside from this patch (which is prep for the next) and some
> > > simple reordering conflicts they're all independent. So if there's no
> > > way to paint this bikeshed here (technicolor perhaps?) then I'd like
> > > to get at least the others considered.
> >
> > Sure, I think for conflict avoidance reasons I'm probably taking
> > mmu_notifier stuff via hmm.git, so:
> >
> > - Andrew had a minor remark on #1, I am ambivalent and would take it
> >   as-is. Your decision if you want to respin.
> 
> I like mine better, see also the reply from Ralph Campbell.

Sure

> > - #2/#3 is this issue, I would stand by the preempt_disable/etc path
> >   Our situation matches yours, debug tests run lockdep/etc.
>
> Since Michal requested the current flavour I think we need spin a bit
> more on these here. I guess I'll just rebase them to the end so
> they're not holding up the others.
> 
> > - #4 I like a lot, except the map should enclose range_end too,
> >   this can be done after the mm_has_notifiers inside the
> >   __mmu_notifier function
> 
> To make sure I get this right: The same lockdep context, but also
> wrapped around invalidate_range_end? 

Yes, the locking context of _range_start and _range_end should be
identical, last time I checked callers this was the case.

So, just add it to __mmu_notifier_invalidate_range_end() outside the
SRCU as there is no reason to burden debug kernel callers twice when
mmu notifiers are not enabled

Jason

