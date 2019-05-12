Return-Path: <SRS0=ZOUz=TM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55B44C04A6B
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 15:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC99320850
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 15:07:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC99320850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36C406B0003; Sun, 12 May 2019 11:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31DDA6B0005; Sun, 12 May 2019 11:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 233926B0006; Sun, 12 May 2019 11:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id F40826B0003
	for <linux-mm@kvack.org>; Sun, 12 May 2019 11:07:30 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id t51so11878935qtb.11
        for <linux-mm@kvack.org>; Sun, 12 May 2019 08:07:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=esV7ZquD2TFM89nJy4yZbNRteT7gRam6/wb6pcqQV+o=;
        b=i71vjL5UsiG8GR3bW67bFQTuSVj2rsGO0J/DDjtgG5LJ7hZpg0Hz4Pj0evnALeNRQF
         jiXwiHiFXcWExE4Fa/rHNmfdO9+mfVLj0hhglwUEsRB4W3yvwILRxgr2FaOg3By4EX9Z
         nDfus8pQq3DORL7C22E31vlxUiv+Bm36X5HkkzkQI74MfGjli66Higd0HwgXl3hxFw5U
         r1nenEQhch/TzufAv7y7rpP0wZjvWZsRLC0O2kSUcVUpIu+mANjalX6p58nx3Zi/TGxA
         elMnmOJfpRKA+2XC9+DCkwdBNGBT1PfrY7EhoqkUw/4GKmuJxtOxLzGm9hJounWa0hqv
         +Ztg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXAF/zFrpQs+p3Q+QZ3Ozzq8RuksBlcmnzCHLOgBJiFN7V1Ku2m
	lmSCGg8Eh0XYjxbPhrf3f99mTPGXewbKDW0AMpq/ZtOU/X9smy2Wq6DBF5/8piBEvupN+4K9h0f
	qdigN7Xm2pY34DKHW2Heevgq3iN92J4cxG6+atHKynDwYR6glCTInulqCSCzG//8Jzg==
X-Received: by 2002:ac8:7514:: with SMTP id u20mr19001552qtq.81.1557673650695;
        Sun, 12 May 2019 08:07:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYcdhbRt1uY+QcokLTDv4TwZ9KYh0gVERAaWxxMczqRYsCMPoHWzrmh8SEF7e5Gi2mAMId
X-Received: by 2002:ac8:7514:: with SMTP id u20mr19001472qtq.81.1557673649588;
        Sun, 12 May 2019 08:07:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557673649; cv=none;
        d=google.com; s=arc-20160816;
        b=OfbthoVBhwtipu7xYHNTGX/vycBbGRxhp/1SNai49JUgN6694B6kcFLjVGKf9qFnc0
         O2xSGBRFAYWeegf+hkxqEcYANijr66FcbejEKBRG1sUyRPJeDXDFudW23uMQMMBY/OYS
         gRlyRdJXJh2rzsqZWmpyGz4Ei1VruNCHu1Jd4UxWGR6aGAXIpva63Npwh7RjinZW8OP2
         RAbz4dSAnaBttF/mfVgDPfe24h/xBhDmUUfEUQYbWjEhI4WrFfnQEh6TJ9BjHVu8+Twm
         howv++Zjk+3AedJdkv/r+KZDyHC/jhKQfdYPSniP7KM05lEK7tvFcHQ67/jUuZAs5xwI
         WszQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=esV7ZquD2TFM89nJy4yZbNRteT7gRam6/wb6pcqQV+o=;
        b=fVTKTFbyfzbmM/w+Gjk1dqcwD5HAAemS7pGHA3FWUZGcjH4JoorBktXcFLRHFOA9TB
         9WtnXXGccMrwyop0Sz+nynpj2NdJRQW3APNZNe1NmbP0igdncWOu7BRYgM3jRlUOVs61
         X+MdPNIm86DRJkds+4gW6BtOMJ+BFUcuJs6q3Pvpbj49wKrUreFPz5B7dOX7q2EdCXTA
         0+4LiqgGb1pHFTDeeq67HmKQp17CD0OzM5i3yA8wTWxmMtY9eNNW3g5r8wMsZ5bMCMG0
         FsXUBA68F2K0N5kpZiJV1YcGVHtOQKYcS4raC/b7G2jcLYm69s1LuxvNr1DtKnGj3cI/
         4XzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c45si621970qta.244.2019.05.12.08.07.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 May 2019 08:07:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 66B913086275;
	Sun, 12 May 2019 15:07:28 +0000 (UTC)
Received: from redhat.com (ovpn-120-196.rdu2.redhat.com [10.10.120.196])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 84A3860C47;
	Sun, 12 May 2019 15:07:26 +0000 (UTC)
Date: Sun, 12 May 2019 11:07:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, Linux-MM <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call
 hmm_range_unregister()
Message-ID: <20190512150724.GA4238@redhat.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-5-rcampbell@nvidia.com>
 <CAFqt6zbhLQuw2N5-=Nma-vHz1BkWjviOttRsPXmde8U1Oocz0Q@mail.gmail.com>
 <fa2078fd-3ec7-5503-94d7-c4d1a766029a@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa2078fd-3ec7-5503-94d7-c4d1a766029a@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Sun, 12 May 2019 15:07:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 11:12:14AM -0700, Ralph Campbell wrote:
> 
> On 5/7/19 6:15 AM, Souptick Joarder wrote:
> > On Tue, May 7, 2019 at 5:00 AM <rcampbell@nvidia.com> wrote:
> > > 
> > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > 
> > > The helper function hmm_vma_fault() calls hmm_range_register() but is
> > > missing a call to hmm_range_unregister() in one of the error paths.
> > > This leads to a reference count leak and ultimately a memory leak on
> > > struct hmm.
> > > 
> > > Always call hmm_range_unregister() if hmm_range_register() succeeded.
> > 
> > How about * Call hmm_range_unregister() in error path if
> > hmm_range_register() succeeded* ?
> 
> Sure, sounds good.
> I'll include that in v2.

NAK for the patch see below why

> 
> > > 
> > > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > Cc: Arnd Bergmann <arnd@arndb.de>
> > > Cc: Balbir Singh <bsingharora@gmail.com>
> > > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > > Cc: Matthew Wilcox <willy@infradead.org>
> > > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > ---
> > >   include/linux/hmm.h | 3 ++-
> > >   1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > > index 35a429621e1e..fa0671d67269 100644
> > > --- a/include/linux/hmm.h
> > > +++ b/include/linux/hmm.h
> > > @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> > >                  return (int)ret;
> > > 
> > >          if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> > > +               hmm_range_unregister(range);
> > >                  /*
> > >                   * The mmap_sem was taken by driver we release it here and
> > >                   * returns -EAGAIN which correspond to mmap_sem have been
> > > @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> > > 
> > >          ret = hmm_range_fault(range, block);
> > >          if (ret <= 0) {
> > > +               hmm_range_unregister(range);
> > 
> > what is the reason to moved it up ?
> 
> I moved it up because the normal calling pattern is:
>     down_read(&mm->mmap_sem)
>     hmm_vma_fault()
>         hmm_range_register()
>         hmm_range_fault()
>         hmm_range_unregister()
>     up_read(&mm->mmap_sem)
> 
> I don't think it is a bug to unlock mmap_sem and then unregister,
> it is just more consistent nesting.

So this is not the usage pattern with HMM usage pattern is:

hmm_range_register()
hmm_range_fault()
hmm_range_unregister()

The hmm_vma_fault() is gonne so this patch here break thing.

See https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.2-v3


