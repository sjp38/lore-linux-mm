Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8E8DC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:39:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 820F92075C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:39:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 820F92075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24E1E8E0003; Wed, 13 Mar 2019 14:39:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FDF78E0001; Wed, 13 Mar 2019 14:39:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 116B08E0003; Wed, 13 Mar 2019 14:39:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA3068E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:39:56 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id d49so2815617qtd.15
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:39:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZohGR4V8wSpVzmC739+QOkXi1t3IjdSONDFbUF9hSUk=;
        b=YAOLuHjKdfUsCqTMVmMDt4X2PNeJ3d9I1Hv8XCfjfp7i+UK9Dl9O5vJ3jfZCV1+i1o
         Rb4y65US4Qypc/z6qtgzpjJ2oMJ5nUs1SFUhGAQbEq/lE4J6NPNDAmB8/ZZNPli8Nm4w
         qS7rHP6RVgpouCudGofV39CDXNqwJhlxXGAAD2/k8e4WxZZuWXvQ0FP/TP5EStNtziXC
         h1xKoruiMKWGl3VFCUIJY2derdA+qyOBVHTmI6T8kHOmzhVqhkp7UufTFx+YWh0/lu1v
         pw3J1Z/C1eH66N8gNeVuaXBEhbtUBwfjBhM993i1/d07Slf9DOeA4WIS90DTsmiBthjo
         1DEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVyeeMul5mPfDwe6aqIOjemqF2Vij/vk6OGLku21XFH67cA6KEK
	nZlNzTsVpPeWSIkQ93Cqzfn5bT0zADcZYjo7KSy7K7XFdoAp3NSzMPy6EsIYwotyagWZtMyMGDq
	monjW0Cd2yfNSyJyadB8dT55q/F+YesgXklipB8G3kmVk3rLRJYDeQLeKgYQf3xfM8A==
X-Received: by 2002:ac8:4a13:: with SMTP id x19mr16316331qtq.306.1552502396628;
        Wed, 13 Mar 2019 11:39:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDTiD+LpaIp7/UIHXat/J96d2zesVx9o9cGRX3SSSgfFr6+AM+5RjyY1DeISL3Aj2kI6d0
X-Received: by 2002:ac8:4a13:: with SMTP id x19mr16316293qtq.306.1552502395722;
        Wed, 13 Mar 2019 11:39:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552502395; cv=none;
        d=google.com; s=arc-20160816;
        b=tGHlTJ1TteZmZzxduTDdqXHUXBuNB6V4IAq6TC/lZFo9+e9bbf0eKLl2dL5rV2Ldyu
         tB+S2n8YXqcGBb9PuC1CXAQYKlZevg6UU1LG2rYlmuGJKgK9oQiNj/+z76G726iuqAZA
         CSg2vGZIuiSn7nxHSNixtrf+X9EZLu0sZox6cbxSzoVRZvmlfx/TJYd/0fX7MTcGQIAA
         j9mC7QRdSMIUmxCMGrtjDI2TaaIE4XVSrsvXc6nR2L9Z5pWiznKh/Gafy2UDfQ/z5CS5
         dYmmizDPd5S1AYEbC9MHU96N2GCVWTlC0KrrNgkdKWPwoFD4j+iAQcSK1i1RpV2uNms7
         obLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZohGR4V8wSpVzmC739+QOkXi1t3IjdSONDFbUF9hSUk=;
        b=sY9UxZ3ptJM3v1ACJcU7VHd++P4qhf+V2O01wGJwt1vrtW2iphPGDF4fUt506mU7cT
         eYlAkyy3rJZU4eO3VM8yrVJ4IirhJhrmJl+dyG5j4FwL4+XJeNdamP5w7+7kwEFOeqs4
         DkVIAtQi/P2s5GF9IQWaF+eoTWvM74/nIr5+Vjewou2Fs/TPQl/5mhQ3zIa6uN2y5UjL
         bz8q/4oH7WezrNO3vaMjdIuLRAN2zYgtQMQ3U0PSS5dqCuk55h86iF6S6nkWwF7Droyr
         GTzcj+eXFx/GY89dTV8y5cfrxz1gKQbAqZUhe/2Bkb3+ykQ3YEDbPrxDJ2IljsPXJgZm
         nibA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t25si520349qtt.104.2019.03.13.11.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 11:39:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AAFB3C065871;
	Wed, 13 Mar 2019 18:39:54 +0000 (UTC)
Received: from redhat.com (ovpn-125-95.rdu2.redhat.com [10.10.125.95])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C9CF060F87;
	Wed, 13 Mar 2019 18:39:53 +0000 (UTC)
Date: Wed, 13 Mar 2019 14:39:50 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190313183950.GB4651@redhat.com>
References: <20190307094654.35391e0066396b204d133927@linux-foundation.org>
 <20190307185623.GD3835@redhat.com>
 <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
 <20190312152551.GA3233@redhat.com>
 <CAPcyv4iYzTVpP+4iezH1BekawwPwJYiMvk2GZDzfzFLUnO+RgA@mail.gmail.com>
 <20190312190606.GA15675@redhat.com>
 <CAPcyv4g-z8nkM1B65oR-3PT_RFQbmQMsM-J-P0-nzyvvJ8gVog@mail.gmail.com>
 <20190312145214.9c8f0381cf2ff2fc2904e2d8@linux-foundation.org>
 <20190313001018.GA3312@redhat.com>
 <20190313090604.968100351b19338cacbfa3bc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190313090604.968100351b19338cacbfa3bc@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 13 Mar 2019 18:39:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 09:06:04AM -0700, Andrew Morton wrote:
> On Tue, 12 Mar 2019 20:10:19 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > > You're correct.  We chose to go this way because the HMM code is so
> > > large and all-over-the-place that developing it in a standalone tree
> > > seemed impractical - better to feed it into mainline piecewise.
> > > 
> > > This decision very much assumed that HMM users would definitely be
> > > merged, and that it would happen soon.  I was skeptical for a long time
> > > and was eventually persuaded by quite a few conversations with various
> > > architecture and driver maintainers indicating that these HMM users
> > > would be forthcoming.
> > > 
> > > In retrospect, the arrival of HMM clients took quite a lot longer than
> > > was anticipated and I'm not sure that all of the anticipated usage
> > > sites will actually be using it.  I wish I'd kept records of
> > > who-said-what, but I didn't and the info is now all rather dissipated.
> > > 
> > > So the plan didn't really work out as hoped.  Lesson learned, I would
> > > now very much prefer that new HMM feature work's changelogs include
> > > links to the driver patchsets which will be using those features and
> > > acks and review input from the developers of those driver patchsets.
> > 
> > This is what i am doing now and this patchset falls into that. I did
> > post the ODP and nouveau bits to use the 2 new functions (dma map and
> > unmap). I expect to merge both ODP and nouveau bits for that during
> > the next merge window.
> > 
> > Also with 5.1 everything that is upstream is use by nouveau at least.
> > They are posted patches to use HMM for AMD, Intel, Radeon, ODP, PPC.
> > Some are going through several revisions so i do not know exactly when
> > each will make it upstream but i keep working on all this.
> > 
> > So the guideline we agree on:
> >     - no new infrastructure without user
> >     - device driver maintainer for which new infrastructure is done
> >       must either sign off or review of explicitly say that they want
> >       the feature I do not expect all driver maintainer will have
> >       the bandwidth to do proper review of the mm part of the infra-
> >       structure and it would not be fair to ask that from them. They
> >       can still provide feedback on the API expose to the device
> >       driver.
> 
> The patchset in -mm ("HMM updates for 5.1") has review from Ralph
> Campbell @ nvidia.  Are there any other maintainers who we should have
> feedback from?

John Hubbard also give his review on couple of them iirc.

> 
> >     - driver bits must be posted at the same time as the new infra-
> >       structure even if they target the next release cycle to avoid
> >       inter-tree dependency
> >     - driver bits must be merge as soon as possible
> 
> Are there links to driver patchsets which we can add to the changelogs?
> 

Issue with that is that i often post the infrastructure bit first and
then the driver bit so i have email circular dependency :) I can alway
post driver bits first and then add links to driver bits. Or i can
reply after posting so that i can cross link both.

Or i can post the driver bit on mm the first time around and mark them
as "not for Andrew" or any tag that make it clear that those patch will
be merge through the appropriate driver tree.

In any case for this patchset there is:

https://patchwork.kernel.org/patch/10786625/

Also this patchset refactor some of the hmm internal for better API so
it is getting use by nouveau too which is already upstream.


> > Thing we do not agree on:
> >     - If driver bits miss for any reason the +1 target directly
> >       revert the new infra-structure. I think it should not be black
> >       and white and the reasons why the driver bit missed the merge
> >       window should be taken into account. If the feature is still
> >       wanted and the driver bits missed the window for simple reasons
> >       then it means that we push everything by 2 release ie the
> >       revert is done in +1 then we reupload the infra-structure in
> >       +2 and finaly repush the driver bit in +3 so we loose 1 cycle.
> >       Hence why i would rather that the revert would only happen if
> >       it is clear that the infrastructure is not ready or can not
> >       be use in timely (over couple kernel release) fashion by any
> >       drivers.
> 
> I agree that this should be more a philosophy than a set of hard rules.
> 

