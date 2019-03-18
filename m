Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1E4EC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 19:29:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A9742133F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 19:29:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A9742133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDB136B0005; Mon, 18 Mar 2019 15:29:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C62BD6B0006; Mon, 18 Mar 2019 15:29:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B054D6B0007; Mon, 18 Mar 2019 15:29:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 813FF6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 15:29:03 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id w134so15551281qka.6
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:29:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=GYGFcvt7DpBMQvnNzMcEGerL0iGaEfM5BmHI/k15prY=;
        b=Un7WmOLERGO56wqEImR4KM9LYH9eEt4ImAmpT35FIf4j1jUClGxVcupRkDFFTyOYIi
         1YduKW/Fly3aauUie74fvRnh9Kqqs+0bjXCvZQDASARekHpLSIYBpb2U6DPHkOGH/WD3
         oOfyFQxXRV1A8DYPecI0vHmIK1qB1U0XGjmACxtYbzV3Yzm8yACpktA0kw0BR/fzMOhM
         UcngpDkIZFcQ/fwkNuBEBN3GjlIXJNxCp8gDBpHpYui1U3dR05IulIpQJtxQl6H/DCyU
         2UyRkd8Ak4/BeD7GkchiBuoH0wPTDhCvKJfNuCl8pf+g+OG0iH90Nan6NEvKOPJGQ+Bo
         5anQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV68GS1IZnuSZNdFm2ZivP98xCvXoGrFi4KBEFDrMje1oO4400s
	TTVRlZH5hDmQ1pUIf+WlCQNQI5WBBrdhxON5hmdt6wogcydJ/8J7CD4NXX5jZ+ZlcW2OCDvRWxt
	RyHR/mSNRKsDDLk8McPg0fuH0AE2AQfQTIKKPGdbxYQ8Nl/WvTdA8LykjQsNiJlZVAA==
X-Received: by 2002:aed:21c2:: with SMTP id m2mr15747028qtc.107.1552937343287;
        Mon, 18 Mar 2019 12:29:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVnqF8Qrqot7gVoMfFj7nGUtk7RYbgIRxcsFeC6YJzOK4hM2I9hD5RQHYfUFIPYTe6qCm3
X-Received: by 2002:aed:21c2:: with SMTP id m2mr15746955qtc.107.1552937342238;
        Mon, 18 Mar 2019 12:29:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552937342; cv=none;
        d=google.com; s=arc-20160816;
        b=q4SXtqoinymeu7c4g6RG/Om8QSV0vZ3rKn2GYOzoiLKiRpdSvB452zdZ5B4hQBAarG
         3WWDRhjdspK9nZM/IAXyge0bK2c4h/nu7bQfT0nHjxtmazXQPZFyBmJD1yZ1fdabajjq
         TRigH8eUw7BeAAgCzBnZehOk0CjoHIwE9vxgU6fiVyIEhekQ2x4x4aJJz094QtgK36Zs
         A62wYwF14N5YeWJ4IsY19N8vbHFhvGTPDBbGyrrP3smoxV6IJadoG2tTsR6zYNSYy66A
         t6kNFkqM6uDilL3JufWxLPxRvFFHZxuz+8KiKYmZFGfRhZCiuPPY/wRZOPGqr5bHZVLn
         bvGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=GYGFcvt7DpBMQvnNzMcEGerL0iGaEfM5BmHI/k15prY=;
        b=sqm0cdKlcYC/SDucSIRamxURubMgGgQtvm/8UTXod/N32di3bZWcv0zln75NsmP5pI
         MtaZWZujUiSm5VSnR2UdQAP+bDT0HiDfogiRXYAxNcam749H0Fl2iXaLL8JFPGpYnMZ8
         CkTGoJlMNRaxgMcKFMimSAEDzT4r8PqDaMwY8IIhE4pqoTIrG6aD+OaT8rv6BnbHeLRt
         FePRmQAhd0TFougL6wK3EmzclkNj46yvI9cVFsKQa946HsqP7B+J60phe90d9taicz8Y
         OddJy02mBX7av1NqiDlhzhFacGo1pTb+/V9bLc/hU/oNsBo0M0QXRUN6Xh9kQf6Z7DQP
         qySA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v58si6457621qth.287.2019.03.18.12.29.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Mar 2019 12:29:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 540BE5944F;
	Mon, 18 Mar 2019 19:29:01 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0FB2F60123;
	Mon, 18 Mar 2019 19:28:59 +0000 (UTC)
Date: Mon, 18 Mar 2019 15:28:58 -0400
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
Message-ID: <20190318192858.GC6786@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190313012706.GB3402@redhat.com>
 <20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
 <20190318170404.GA6786@redhat.com>
 <CAPcyv4geu34vgZszALiDxJWR8itK+A3qSmpR+_jOq29whGngNg@mail.gmail.com>
 <20190318185437.GB6786@redhat.com>
 <CAPcyv4gLyKkboZ-ucHubiHgdpF4i9w+XKhPujjJ=dwU9Vox=Bg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gLyKkboZ-ucHubiHgdpF4i9w+XKhPujjJ=dwU9Vox=Bg@mail.gmail.com>
User-Agent: Mutt/1.10.0 (2018-05-17)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 18 Mar 2019 19:29:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 12:18:38PM -0700, Dan Williams wrote:
> On Mon, Mar 18, 2019 at 11:55 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Mon, Mar 18, 2019 at 11:30:15AM -0700, Dan Williams wrote:
> > > On Mon, Mar 18, 2019 at 10:04 AM Jerome Glisse <jglisse@redhat.com> wrote:
> > > >
> > > > On Wed, Mar 13, 2019 at 09:10:04AM -0700, Andrew Morton wrote:
> > > > > On Tue, 12 Mar 2019 21:27:06 -0400 Jerome Glisse <jglisse@redhat.com> wrote:
> > > > >
> > > > > > Andrew you will not be pushing this patchset in 5.1 ?
> > > > >
> > > > > I'd like to.  It sounds like we're converging on a plan.
> > > > >
> > > > > It would be good to hear more from the driver developers who will be
> > > > > consuming these new features - links to patchsets, review feedback,
> > > > > etc.  Which individuals should we be asking?  Felix, Christian and
> > > > > Jason, perhaps?
> > > > >
> > > >
> > > > So i am guessing you will not send this to Linus ? Should i repost ?
> > > > This patchset has 2 sides, first side is just reworking the HMM API
> > > > to make something better in respect to process lifetime. AMD folks
> > > > did find that helpful [1]. This rework is also necessary to ease up
> > > > the convertion of ODP to HMM [2] and Jason already said that he is
> > > > interested in seing that happening [3]. By missing 5.1 it means now
> > > > that i can not push ODP to HMM in 5.2 and it will be postpone to 5.3
> > > > which is also postoning other work ...
> > > >
> > > > The second side is it adds 2 new helper dma map and dma unmap both
> > > > are gonna be use by ODP and latter by nouveau (after some other
> > > > nouveau changes are done). This new functions just do dma_map ie:
> > > >     hmm_dma_map() {
> > > >         existing_hmm_api()
> > > >         for_each_page() {
> > > >             dma_map_page()
> > > >         }
> > > >     }
> > > >
> > > > Do you want to see anymore justification than that ?
> > >
> > > Yes, why does hmm needs its own dma mapping apis? It seems to
> > > perpetuate the perception that hmm is something bolted onto the side
> > > of the core-mm rather than a native capability.
> >
> > Seriously ?
> 
> Yes.
> 
> > Kernel is fill with example where common code pattern that are not
> > device specific are turn into helpers and here this is exactly what
> > it is. A common pattern that all device driver will do which is turn
> > into a common helper.
> 
> Yes, but we also try not to introduce thin wrappers around existing
> apis. If the current dma api does not understand some hmm constraint
> I'm questioning why not teach the dma api that constraint and make it
> a native capability rather than asking the driver developer to
> understand the rules about when to use dma_map_page() vs
> hmm_dma_map().

There is nothing special here, existing_hmm_api() return an array of
page and the new helper just call dma_map_page for each entry in that
array. If it fails it undo everything so that error handling is share.

So i am not playing trick with DMA API i am just providing an helper
for a common pattern. Maybe the name confuse you but the pseudo should
be selft explanatory:
    Before
        mydriver_mirror_range() {
            err = existing_hmm_mirror_api(pages)
            if (err) {...}
            for_each_page(pages) {
                pas[i]= dma_map_page()
                if (dma_error(pas[i])) { ... }
            }
            // use pas[]
        }

    After
        mydriver_mirror_range() {
            err = hmm_range_dma_map(pas)
            if (err) { ... }
            // use pas[]
        }

So there is no rule of using one or the other. In the end it is the
same code. But instead of duplicating it in multiple drivers it is
share.

> 
> For example I don't think we want to end up with more headers like
> include/linux/pci-dma-compat.h.
> 
> > Moreover this allow to share the same error code handling accross
> > driver when mapping one page fails. So this avoid the needs to
> > duplicate same boiler plate code accross different drivers.
> >
> > Is code factorization not a good thing ? Should i duplicate every-
> > thing in every single driver ?
> 
> I did not ask for duplication, I asked why is it not more deeply integrated.

Because it is a common code pattern for HMM user not for DMA user.

> > If that's not enough, this will also allow to handle peer to peer
> > and i posted patches for that [1] and again this is to avoid
> > duplicating common code accross different drivers.
> 
> I went looking for the hmm_dma_map() patches on the list but could not
> find them, so I was reacting to the "This new functions just do
> dma_map", and wondered if that was the full extent of the
> justification.

They are here [1] patch 7 in this patch serie

Cheers,
Jérôme

[1] https://lkml.org/lkml/2019/1/29/1016

