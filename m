Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5893C41514
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:24:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ECDE233FC
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:24:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="U5M7r7PI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ECDE233FC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7A7376B031E; Thu, 22 Aug 2019 10:24:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 757626B031F; Thu, 22 Aug 2019 10:24:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66E556B0320; Thu, 22 Aug 2019 10:24:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0016.hostedemail.com [216.40.44.16])
	by kanga.kvack.org (Postfix) with ESMTP id 45D246B031E
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:24:13 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BB1416D94
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:24:12 +0000 (UTC)
X-FDA: 75850283544.02.crown11_7c075135e7821
X-HE-Tag: crown11_7c075135e7821
X-Filterd-Recvd-Size: 4865
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:24:12 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id s145so5266088qke.7
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:24:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Dc5+B44d/riVZ4BUj5s+q3Lkc18YuwqlI4z9+Sq+DYI=;
        b=U5M7r7PIyUiUocgqIIxQGJhmG0OFdz9U6VAO0wM0x9A3Vm1DHeBBjWMEOm+kGH0+sZ
         DVv7IgnNa8XvXNx76i2JRGXB1VOoVy4HaRSd5Majxg2lBxexhTGf4IqG48SiOLjcbvhE
         Mgx+/6CT1tNcq2BuTPXz8aDbbkhIzpAZObMLT2Axn3xV8AUEPMljgWAa7yQMvm08Ssyj
         Z+5muEGCOJ/m+c/Z3hTPXgauluqi3fD9P9IRfcmxsuTg1tqEb+PCwj8pdWwr8DWOjvtw
         +g//1M+gbQ6xkkIk7Px0hFVwWYVOOI7HP4+k4bs2ecFl2T7g0x/XQiWSQxDtGK4KXiOT
         9sxg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=Dc5+B44d/riVZ4BUj5s+q3Lkc18YuwqlI4z9+Sq+DYI=;
        b=UGF+E9CaN6h5fWRFY0255+HUzikVI9yoVOiMlofozz1bM6YpuimcoK6aJ9qDIHVMbo
         mpPk2uKuh1HVdA+bKGM+DMzmJOFQpx9uLK6P4LvQWaGzLscLjfIAE3Z+UmRelXJNDm7g
         HC16tuFV6SjPhdTNZnFPVUGx1st/8wZoV1fHmJLhw1v1fOChn5TZQFsmO0dTYutaIo5O
         1+w1cE9oSFWFuqeI3yTGdE6Hlq2JVvqp7A4rzz28NfP85W7vqkTwrcL5ox5Swm+LbFiK
         K35/N0Z+WcLIAE5wHQFQ2PR5g7BBMHnWMMaBR7KOByVCp/IozyEuk6Irtdjd4OnhXcyK
         w+fg==
X-Gm-Message-State: APjAAAUhM4xKdaoT0sNHP1fiyeGAJFfVP/8LRQ6Yduw8E5ev5JLZF+Qk
	jcMFyMuC9LnPpVl506rLA4aUqw==
X-Google-Smtp-Source: APXvYqx1hDXEyXaCf4TQxuW7kB785QqUUNv48fJgwQaA1egBhvm9xoK/w0v99nR0V1KI+G1DH5vz7A==
X-Received: by 2002:a37:47d8:: with SMTP id u207mr20384093qka.255.1566483851626;
        Thu, 22 Aug 2019 07:24:11 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m3sm7668768qki.10.2019.08.22.07.24.10
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 22 Aug 2019 07:24:10 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i0o0Y-000763-37; Thu, 22 Aug 2019 11:24:10 -0300
Date: Thu, 22 Aug 2019 11:24:10 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/4] mm, notifier: Catch sleeping/blocking for !blockable
Message-ID: <20190822142410.GB8339@ziepe.ca>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-5-daniel.vetter@ffwll.ch>
 <20190820133418.GG29246@ziepe.ca>
 <20190820151810.GG11147@phenom.ffwll.local>
 <20190821154151.GK11147@phenom.ffwll.local>
 <20190821161635.GC8653@ziepe.ca>
 <CAKMK7uERsmgFqDVHMCWs=4s_3fHM0eRr7MV6A8Mdv7xVouyxJw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uERsmgFqDVHMCWs=4s_3fHM0eRr7MV6A8Mdv7xVouyxJw@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 10:42:39AM +0200, Daniel Vetter wrote:

> > RDMA has a mutex:
> >
> > ib_umem_notifier_invalidate_range_end
> >   rbt_ib_umem_for_each_in_range
> >    invalidate_range_start_trampoline
> >     ib_umem_notifier_end_account
> >       mutex_lock(&umem_odp->umem_mutex);
> >
> > I'm working to delete this path though!
> >
> > nonblocking or not follows the start, the same flag gets placed into
> > the mmu_notifier_range struct passed to end.
> 
> Ok, makes sense.
> 
> I guess that also means the might_sleep (I started on that) in
> invalidate_range_end also needs to be conditional? Or not bother with
> a might_sleep in invalidate_range_end since you're working on removing
> the last sleep in there?

I might suggest the same pattern as used for locked, the might_sleep
unconditionally on the start, and a 2nd might sleep after the IF in
__mmu_notifier_invalidate_range_end()

Observing that by audit all the callers already have the same locking
context for start/end

Jason

