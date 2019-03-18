Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD02C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 18:54:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1862A20989
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 18:54:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1862A20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99A366B0006; Mon, 18 Mar 2019 14:54:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9211A6B0007; Mon, 18 Mar 2019 14:54:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80FA26B0008; Mon, 18 Mar 2019 14:54:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 603FA6B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 14:54:43 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q21so6149889qtf.10
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 11:54:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KSRGyI7+eM1gZhlMZ3WRXorgkLgGMvJ0zO1neaVZJ4s=;
        b=Y7xthBENakTdJzflfy3l4mRizP2wcNHKPMv+xFGTKhtOzz5HEoin9NFzqBh62xJbg9
         kc/KpSCeJQsxV9lIg5wH0S7yix79JdurO81zCW2aLcnKJeSYcHgBUVfcZe1jxymRcN50
         6i8fhtFkPWjSxao5ishKKW3jjaOTtu323sWyei9jG3co4781h1/6ciIW6tMoPO4L9WqS
         b4JuI7av9RQnb/7mPWGYg1qCUzShJwlNhwmQc3k2esBD3879yuuwzXV1TEAc+xenDyLX
         8YPeSwu1uu1wcS8JeVTYJOzN77WPN5KkiwKMeMaCVn3lI001PmMAHupHs/LtE06zGp0T
         Bu4Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUOhrNLoqxHl7Or6lWOlFtvI5P8QmrDjGeEBZKjB87TYeUfQx0M
	STXxHBeJfMvjWk1glHDPcG1ckv8JxfUzOYcD2qEQQENnEFBT+WBNxjZqVi+2B4aEpL/WSqtd3NG
	2UXEZHVTtGg30NjisP+QOJQBQ85f2idlmjlNlFjxIKEJmcL6IrBk3xrh78ZGac7w4kQ==
X-Received: by 2002:a05:620a:390:: with SMTP id q16mr5066942qkm.201.1552935283138;
        Mon, 18 Mar 2019 11:54:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNYp4hQVfLxUtNS9G4OlmEh5gWxCTfidJpWDPDN59n76mMM+EUXUr77sH2hx2rliC6BsfO
X-Received: by 2002:a05:620a:390:: with SMTP id q16mr5066895qkm.201.1552935282083;
        Mon, 18 Mar 2019 11:54:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552935282; cv=none;
        d=google.com; s=arc-20160816;
        b=Yz8aJe4ACvH/qaWxDkdFIZnk9Iafp092BpY3WL8qxhJQ67ENppCqV9GVA3+lVYG852
         6UO3b4qbdzI9Ocaj9RtAMS+CnW7Z7TKlEqV6tf0A46ddoT4GCLSFso9ox0DZKpDjVjtW
         MY/mIW4t6d2bNEuDQOICHQ1jWPJZbJRaAnJoZpaaBzSH7UJ5fa1MvkGGGWM9QZeqFrpo
         XnJ4IsnGnutiphrZZxYuFRKQsYis4BdEdKTVCwy5laiR2UCRKiK3AelBhdIgeQUyM8lp
         grkihZFOLgfx5Cas9n+CEsmvDbJ9A6LxwfTMlj99TgHD5w8A/fRKNyzshifHhY0eNmc+
         6Lrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=KSRGyI7+eM1gZhlMZ3WRXorgkLgGMvJ0zO1neaVZJ4s=;
        b=b4BakimtmGpZSPdGZLJO4F9jmCMU3CAsGVVaymNiUBqfCk36skrFG7msVtEft+o2+Q
         PaQBccGnQfIM6gcxALaCfXcUrfuQWqFtlL7gahskYdbpvbF97zF3f76McnWq+sQxe2RU
         OngbnciZheyUFuds4GHDAWhF8U2Y8jqqtv8jNhmZMv//VMI1fAPobfGYoQBPvSwp9T3i
         FU0rRTzAvnMDFlmj0nQSpm/RS4PmHuugLRU+XohaqsWD9a+aEr6ftkQTIXzAP+B4/aTv
         leNjKQtCB6OVmWUD/t9BtTp57K9zmwmGpscVrdpxHccgpLqguS6r+nMVeEVzylQBGPf7
         m7ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h34si1222655qva.39.2019.03.18.11.54.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 11:54:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 16C704E92A;
	Mon, 18 Mar 2019 18:54:41 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C4DE25DD97;
	Mon, 18 Mar 2019 18:54:39 +0000 (UTC)
Date: Mon, 18 Mar 2019 14:54:38 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190318185437.GB6786@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com>
 <CAPcyv4geu34vgZszALiDxJWR8itK+A3qSmpR+_jOq29whGngNg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4geu34vgZszALiDxJWR8itK+A3qSmpR+_jOq29whGngNg@mail.gmail.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 18 Mar 2019 18:54:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 11:30:15AM -0700, Dan Williams wrote:
> On Mon, Mar 18, 2019 at 10:04 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> > > On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > >
> > > > Andrew you will not be pushing this patchset in 5.1 ?
> > >
> > > I'd like to.  It sounds like we're converging on a plan.
> > >
> > > It would be good to hear more from the driver developers who will be
> > > consuming these new features - links to patchsets, review feedback,
> > > etc.  Which individuals should we be asking?  Felix, Christian and
> > > Jason, perhaps?
> > >
> >
> > So i am guessing you will not send this to Linus ? Should i repost ?
> > This patchset has 2 sides, first side is just reworking the HMM API
> > to make something better in respect to process lifetime. AMD folks
> > did find that helpful [1]. This rework is also necessary to ease up
> > the convertion of ODP to HMM [2] and Jason already said that he is
> > interested in seing that happening [3]. By missing 5.1 it means now
> > that i can not push ODP to HMM in 5.2 and it will be postpone to 5.3
> > which is also postoning other work ...
> >
> > The second side is it adds 2 new helper dma map and dma unmap both
> > are gonna be use by ODP and latter by nouveau (after some other
> > nouveau changes are done). This new functions just do dma_map ie:
> >     hmm_dma_map() {
> >         existing_hmm_api()
> >         for_each_page() {
> >             dma_map_page()
> >         }
> >     }
> >
> > Do you want to see anymore justification than that ?
> 
> Yes, why does hmm needs its own dma mapping apis? It seems to
> perpetuate the perception that hmm is something bolted onto the side
> of the core-mm rather than a native capability.

Seriously ?

Kernel is fill with example where common code pattern that are not
device specific are turn into helpers and here this is exactly what
it is. A common pattern that all device driver will do which is turn
into a common helper.

Moreover this allow to share the same error code handling accross
driver when mapping one page fails. So this avoid the needs to
duplicate same boiler plate code accross different drivers.

Is code factorization not a good thing ? Should i duplicate every-
thing in every single driver ?


If that's not enough, this will also allow to handle peer to peer
and i posted patches for that [1] and again this is to avoid
duplicating common code accross different drivers.


It does feel that you oppose everything with HMM in its name just
because you do not like it. It is your prerogative to not like some-
thing but you should propose something that achieve the same result
instead of constantly questioning every single comma.

Cheers,
Jérôme

[1] https://lwn.net/ml/linux-kernel/20190129174728.6430-1-jglisse@redhat.com/

