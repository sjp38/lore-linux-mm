Return-Path: <SRS0=ZOUz=TM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25240C04A6B
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 15:28:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C750E2146F
	for <linux-mm@archiver.kernel.org>; Sun, 12 May 2019 15:28:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C750E2146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BC226B0006; Sun, 12 May 2019 11:28:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46C886B0007; Sun, 12 May 2019 11:28:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 35A916B0008; Sun, 12 May 2019 11:28:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 151F96B0006
	for <linux-mm@kvack.org>; Sun, 12 May 2019 11:28:21 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g7so10586749qkb.7
        for <linux-mm@kvack.org>; Sun, 12 May 2019 08:28:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=0sNfGBtLDxhYULBcYESs4/V69BJ1XyaaY/1G0tL/90Y=;
        b=atxt6dB9xTPKarQ9iIDNavJalzmEz2hxjk8Z55v9rVn/hFNe0IwQY4ft7py6mwCJuc
         DZEzDaMij3OLxDcFEX46kZJHj3dC0iW4U0fzzYDYS5Otjg3rwXRqQZdl524+MvLaWJWN
         GJv1GZUgSQ13dmaSmDIj5tQtzsHlJxhTcW4WCn7AI2OK9h7Im1f9FdCdXPmXRMD7EHIV
         f4O7nvohcteYwcIakPV9pHmJyy9wGOFWf+sjlFwUDhLuXATidZnV392QUOzTwvt0ospN
         Jd8k7eYrKNHh2Sjl7cdaFDL0uFAvgZHuDzeIkdF17hN/JPTe6hxB6YbBsZ/ODVPtR+PF
         45kw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXRR8Ztx+1phLwO/FRJdjkVAkVAPuLDQIqqE5+RqIaiHTbr87VN
	r4q2OEJAGnQf2+l4yIbwp8BKQ1XipeDHjS5OZkbXeagXcfntIBYxgrZYrVUeJca6JJwGPqCY5mi
	Je0k3/XZlM7pnFeLMCwNdRdSrEGk0QT8s3xvVM+yHe2tEsOO8so1Jmf8ujMiHVKO7ig==
X-Received: by 2002:a37:680c:: with SMTP id d12mr18365794qkc.202.1557674900721;
        Sun, 12 May 2019 08:28:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuPySGbHeu6qapGMRrz9AIZ0LB0TQ0mrYwpkYRf6R3/vN7XH4Mos43ySkLb8c+ZphLYkKT
X-Received: by 2002:a37:680c:: with SMTP id d12mr18365759qkc.202.1557674900058;
        Sun, 12 May 2019 08:28:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557674900; cv=none;
        d=google.com; s=arc-20160816;
        b=sYo0KR3RBJrUuTAbtF2/fAo0QogFFvmddKFRMtWaleLgZ0E27fFaIU4H1WXUISsUvu
         +KpSsTxroAWplODGSL5aXSABn+36PoeW/dvn3MXKyBze8i0PytuirYoc1JIWc9nPY5F1
         jMRqsQIMGqkNlrsSeeBMK92xGFl7hi70BXxhEqoMSfISSHmB46fC325ro8GnxWYgQ05u
         LbPP0Vnc33V7Yl+GvhXAX7uNuiHDaDApAwCGNlyHffIV2WblbR/uD+zJuDyY1lHgDFJ2
         GBzZfwRfjGL54gSoZFB484amN0JC3tbA0IvhJiAsq4RdlTt9183wWuvPnRZtkcybxSYR
         /wug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=0sNfGBtLDxhYULBcYESs4/V69BJ1XyaaY/1G0tL/90Y=;
        b=adIMv3kLPwrZ+lMIHGWceE815RFOI/wt8ASUb7CjWIS4Bo909BRRotPwv1wYBejAvF
         y2/aZaRoOMyILwK5+7fffn6Cfy5HnTEH17IuU6CL17I/mPbHjytYlxQyBztP691d3zLB
         YbASMUp3+R+F75Wgxn1x92Xp4b8nmgXZ1vk6D4n+S5YlOKsLAdZNnxTw0EwV1QBk83R2
         8scvpqs/RSIbXrsHnHy9+UFRbANAKL1Kx3vk7izUQF6+mNadvdt1OHGru/iXP4WRR4ZD
         97s5Mvvvj2yUKu53/37XWI7N4Neja5UIjHiShll8bEs4pQFLDRsqjA7VNAwgK7xuXjFw
         1dDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u3si3102982qvh.23.2019.05.12.08.28.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 May 2019 08:28:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 11849308218D;
	Sun, 12 May 2019 15:28:19 +0000 (UTC)
Received: from redhat.com (ovpn-120-196.rdu2.redhat.com [10.10.120.196])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5CB7818A24;
	Sun, 12 May 2019 15:28:17 +0000 (UTC)
Date: Sun, 12 May 2019 11:28:15 -0400
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
Message-ID: <20190512152814.GC4238@redhat.com>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
 <20190506232942.12623-5-rcampbell@nvidia.com>
 <CAFqt6zbhLQuw2N5-=Nma-vHz1BkWjviOttRsPXmde8U1Oocz0Q@mail.gmail.com>
 <fa2078fd-3ec7-5503-94d7-c4d1a766029a@nvidia.com>
 <20190512150724.GA4238@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190512150724.GA4238@redhat.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Sun, 12 May 2019 15:28:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, May 12, 2019 at 11:07:24AM -0400, Jerome Glisse wrote:
> On Tue, May 07, 2019 at 11:12:14AM -0700, Ralph Campbell wrote:
> > 
> > On 5/7/19 6:15 AM, Souptick Joarder wrote:
> > > On Tue, May 7, 2019 at 5:00 AM <rcampbell@nvidia.com> wrote:
> > > > 
> > > > From: Ralph Campbell <rcampbell@nvidia.com>
> > > > 
> > > > The helper function hmm_vma_fault() calls hmm_range_register() but is
> > > > missing a call to hmm_range_unregister() in one of the error paths.
> > > > This leads to a reference count leak and ultimately a memory leak on
> > > > struct hmm.
> > > > 
> > > > Always call hmm_range_unregister() if hmm_range_register() succeeded.
> > > 
> > > How about * Call hmm_range_unregister() in error path if
> > > hmm_range_register() succeeded* ?
> > 
> > Sure, sounds good.
> > I'll include that in v2.
> 
> NAK for the patch see below why
> 
> > 
> > > > 
> > > > Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> > > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > > Cc: Ira Weiny <ira.weiny@intel.com>
> > > > Cc: Dan Williams <dan.j.williams@intel.com>
> > > > Cc: Arnd Bergmann <arnd@arndb.de>
> > > > Cc: Balbir Singh <bsingharora@gmail.com>
> > > > Cc: Dan Carpenter <dan.carpenter@oracle.com>
> > > > Cc: Matthew Wilcox <willy@infradead.org>
> > > > Cc: Souptick Joarder <jrdr.linux@gmail.com>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > ---
> > > >   include/linux/hmm.h | 3 ++-
> > > >   1 file changed, 2 insertions(+), 1 deletion(-)
> > > > 
> > > > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > > > index 35a429621e1e..fa0671d67269 100644
> > > > --- a/include/linux/hmm.h
> > > > +++ b/include/linux/hmm.h
> > > > @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> > > >                  return (int)ret;
> > > > 
> > > >          if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> > > > +               hmm_range_unregister(range);
> > > >                  /*
> > > >                   * The mmap_sem was taken by driver we release it here and
> > > >                   * returns -EAGAIN which correspond to mmap_sem have been
> > > > @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> > > > 
> > > >          ret = hmm_range_fault(range, block);
> > > >          if (ret <= 0) {
> > > > +               hmm_range_unregister(range);
> > > 
> > > what is the reason to moved it up ?
> > 
> > I moved it up because the normal calling pattern is:
> >     down_read(&mm->mmap_sem)
> >     hmm_vma_fault()
> >         hmm_range_register()
> >         hmm_range_fault()
> >         hmm_range_unregister()
> >     up_read(&mm->mmap_sem)
> > 
> > I don't think it is a bug to unlock mmap_sem and then unregister,
> > it is just more consistent nesting.
> 
> So this is not the usage pattern with HMM usage pattern is:
> 
> hmm_range_register()
> hmm_range_fault()
> hmm_range_unregister()
> 
> The hmm_vma_fault() is gonne so this patch here break thing.
> 
> See https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-5.2-v3

Sorry not enough coffee on sunday morning, so yeah this patch
looks good except that you do not need to move it up.

Note that hmm_vma_fault() is a gonner once ODP to HMM is upstream
and i converted nouveau/amd to new API then we can remove that
one.

Cheers,
Jérôme

