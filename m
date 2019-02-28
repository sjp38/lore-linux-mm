Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D04FFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:47:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8729E2186A
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 02:47:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8729E2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B7108E0004; Wed, 27 Feb 2019 21:47:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 166D98E0001; Wed, 27 Feb 2019 21:47:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 055338E0004; Wed, 27 Feb 2019 21:47:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF0828E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 21:47:22 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id b6so14952493qkg.4
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 18:47:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=F7V523KyO9iWV9EggIihKDyw+hsAO/Ss7bgFqV8xigY=;
        b=S7FUNxmaoZfeTFRMxBY1rhplK0HHheA+CkEPQmiR5m/ddkrqCjwbeOa/toqdiMKTc6
         FUbEkD1tRfQ0D1ELeOHTiDXjivUgw9++6/h46PG0Ynf5OVXiiFekGwROvgKm/09XUtga
         AvTXQ9SABwMK0voVRNHMDkHADpvouBxy4sNIVmFFQ5HLqWc5lXg+CH3mRbTC3b/jGrmQ
         CW94OTk7gbXHPExtngPsQCJXWWaoiCK7X3ptTtWF8CM4D4+ligWijRqeoWcWuiMzGUAF
         3YNwIMGsBTd1rHSMVVFlYP9iK0yL7Ku7YOJiRO82Ti9KBfpj9KO10IN1JvvI3USjrnTo
         9TrA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXass2Al0z1oHqld7gUTkGzDQPvvVQXOWzz3LTsQdq8Z8K9ahjp
	je33w7nVSgtR4UdQ45PE/5XXwRfnprxMBKsIc+iTJtaWK2ow6YlS3jUiq31PRfzyujz7/C0DY7g
	DpXIbKTJAqHHdDY2iYXr0swKkssr+UJWlaIgMfY/qYrtPuEGTqoZoVaLC277h5Zc1SA==
X-Received: by 2002:ac8:2c5a:: with SMTP id e26mr4361280qta.189.1551322042581;
        Wed, 27 Feb 2019 18:47:22 -0800 (PST)
X-Google-Smtp-Source: APXvYqz7eSOW1l96dtdeP9W9MQN+N2FwQNXU5BMiYN5t0WTP03QIjOd8vS6xX0PyiHohYJjxnIGt
X-Received: by 2002:ac8:2c5a:: with SMTP id e26mr4361243qta.189.1551322041638;
        Wed, 27 Feb 2019 18:47:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551322041; cv=none;
        d=google.com; s=arc-20160816;
        b=MIcObcE84m9hO3fnhEvttFTEkBf9ZEQEg++w4UJKVNyQAEq4SNHLOKa33xwqheKSuC
         v2F/CxoxHVWKGcyuwcjFffWbRteu7kZAIDHYbVv9cWHBfh5SEuKZIz0T213h1y5j2hLx
         64pdCVRMT7gSq01UPCPKBV3uy2sl87q4Ygt/nNKtlc11fyJBpEKBtARGusjiEfOYOgwi
         b02gNIC6ngGLsWZCMVC/2SwaJ7ZErTG1t7eqSO22alvIlhrraYj2Io4aaWv211X2iOg/
         nEHz1ukpd3vce7YteI6IiqfKxu3cDcAOIOHZdSqU+lhpIEbS/gY4TZtDowwIh+Far0+0
         AjzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=F7V523KyO9iWV9EggIihKDyw+hsAO/Ss7bgFqV8xigY=;
        b=vbBnqNutXRT96y372OIyKSv4zHNMpBg2u2XWM3FlWhfDl0a4WoC1JC0Qz3sYH3Ywyn
         u/esBiQAliXEggBcfZPG7cPapdhLKAzYjbAbaX6qACW7AZWcmjvCyBULEre189qT2lE5
         hzfX4cNc/CYFzwrBu0y5Cq7RT39TZQW52hqD9/O10+dzvCIZHWCTuXSGPKfXs4G0gJ8T
         P7t0/vXpRBUbNuuSLAMDcFK795ad6Z9L79rBH3vWlm23qultCcUmM373EIRqbBC7sYVf
         k875MAMKJugF/2Un7GUD4RTiMul8muktzMf9grl3Z+DLq9iyLdLv9TdLV3uSvwDnej5p
         1nRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y28si239234qvf.34.2019.02.27.18.47.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 18:47:21 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 452BF316EB80;
	Thu, 28 Feb 2019 02:47:20 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id F04F61001DD6;
	Thu, 28 Feb 2019 02:47:10 +0000 (UTC)
Date: Thu, 28 Feb 2019 10:47:07 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 23/26] userfaultfd: wp: don't wake up when doing write
 protect
Message-ID: <20190228024707.GT13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-24-peterx@redhat.com>
 <20190225210934.GE10454@rapoport-lnx>
 <20190226062424.GH13653@xz-x1>
 <20190226072933.GF5873@rapoport-lnx>
 <20190226074117.GL13653@xz-x1>
 <20190226080029.GH5873@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190226080029.GH5873@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 28 Feb 2019 02:47:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 10:00:29AM +0200, Mike Rapoport wrote:
> On Tue, Feb 26, 2019 at 03:41:17PM +0800, Peter Xu wrote:
> > On Tue, Feb 26, 2019 at 09:29:33AM +0200, Mike Rapoport wrote:
> > > On Tue, Feb 26, 2019 at 02:24:52PM +0800, Peter Xu wrote:
> > > > On Mon, Feb 25, 2019 at 11:09:35PM +0200, Mike Rapoport wrote:
> > > > > On Tue, Feb 12, 2019 at 10:56:29AM +0800, Peter Xu wrote:
> > > > > > It does not make sense to try to wake up any waiting thread when we're
> > > > > > write-protecting a memory region.  Only wake up when resolving a write
> > > > > > protected page fault.
> > > > > > 
> > > > > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > > > > ---
> > > > > >  fs/userfaultfd.c | 13 ++++++++-----
> > > > > >  1 file changed, 8 insertions(+), 5 deletions(-)
> > > > > > 
> > > > > > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > > > > > index 81962d62520c..f1f61a0278c2 100644
> > > > > > --- a/fs/userfaultfd.c
> > > > > > +++ b/fs/userfaultfd.c
> > > > > > @@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > > > > >  	struct uffdio_writeprotect uffdio_wp;
> > > > > >  	struct uffdio_writeprotect __user *user_uffdio_wp;
> > > > > >  	struct userfaultfd_wake_range range;
> > > > > > +	bool mode_wp, mode_dontwake;
> > > > > > 
> > > > > >  	if (READ_ONCE(ctx->mmap_changing))
> > > > > >  		return -EAGAIN;
> > > > > > @@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > > > > >  	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
> > > > > >  			       UFFDIO_WRITEPROTECT_MODE_WP))
> > > > > >  		return -EINVAL;
> > > > > > -	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> > > > > > -	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> > > > > > +
> > > > > > +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> > > > > > +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> > > > > > +
> > > > > > +	if (mode_wp && mode_dontwake)
> > > > > >  		return -EINVAL;
> > > > > 
> > > > > This actually means the opposite of the commit message text ;-)
> > > > > 
> > > > > Is any dependency of _WP and _DONTWAKE needed at all?
> > > > 
> > > > So this is indeed confusing at least, because both you and Jerome have
> > > > asked the same question... :)
> > > > 
> > > > My understanding is that we don't have any reason to wake up any
> > > > thread when we are write-protecting a range, in that sense the flag
> > > > UFFDIO_WRITEPROTECT_MODE_DONTWAKE is already meaningless in the
> > > > UFFDIO_WRITEPROTECT ioctl context.  So before everything here's how
> > > > these flags are defined:
> > > > 
> > > > struct uffdio_writeprotect {
> > > > 	struct uffdio_range range;
> > > > 	/* !WP means undo writeprotect. DONTWAKE is valid only with !WP */
> > > > #define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
> > > > #define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
> > > > 	__u64 mode;
> > > > };
> > > > 
> > > > To make it clear, we simply define it as "DONTWAKE is valid only with
> > > > !WP".  When with that, "mode_wp && mode_dontwake" is indeed a
> > > > meaningless flag combination.  Though please note that it does not
> > > > mean that the operation ("don't wake up the thread") is meaningless -
> > > > that's what we'll do no matter what when WP==1.  IMHO it's only about
> > > > the interface not the behavior.
> > > > 
> > > > I don't have a good way to make this clearer because firstly we'll
> > > > need the WP flag to mark whether we're protecting or unprotecting the
> > > > pages.  Later on, we need DONTWAKE for page fault handling case to
> > > > mark that we don't want to wake up the waiting thread now.  So both
> > > > the flags have their reason to stay so far.  Then with all these in
> > > > mind what I can think of is only to forbid using DONTWAKE in WP case,
> > > > and that's how above definition comes (I believe, because it was
> > > > defined that way even before I started to work on it and I think it
> > > > makes sense).
> > > 
> > > There's no argument how DONTWAKE can be used with !WP. The
> > > userfaultfd_writeprotect() is called in response of the uffd monitor to WP
> > > page fault, it asks to clear write protection to some range, but it does
> > > not want to wake the faulting thread yet but rather it will use uffd_wake()
> > > later.
> > > 
> > > Still, I can't grok the usage of DONTWAKE with WP=1. In my understanding,
> > > in this case userfaultfd_writeprotect() is called unrelated to page faults,
> > > and the monitored thread runs freely, so why it should be waked at all?
> > 
> > Exactly this is how I understand it.  And that's why I wrote this
> > patch to remove the extra wakeup() since I think it's unecessary.
> > 
> > > 
> > > And what happens, if the thread is waiting on a missing page fault and we
> > > do userfaultfd_writeprotect(WP=1) at the same time?
> > 
> > Then IMHO the userfaultfd_writeprotect() will be a noop simply because
> > the page is still missing.  Here if with the old code (before this
> > patch) we'll probably even try to wake up this thread but this thread
> > should just fault again on the same address due to the fact that the
> > page is missing.  After this patch the monitored thread should
> > continue to wait on the missing page.
> 
> So, my understanding of what we have is:
> 
> userfaultfd_writeprotect() can be used either to mark a region as write
> protected or to resolve WP page fault.
> In the first case DONTWAKE does not make sense and we forbid setting it
> with WP=1.
> In the second case it's the uffd monitor decision whether to wake up the
> faulting thread immediately after #PF is resolved or later, so with WP=0 we
> allow DONTWAKE.

Yes exactly.

> 
> I suggest to extend the comment in the definition of 
> 'struct uffdio_writeprotect' to something like
> 
> /*
>  * Write protecting a region (WP=1) is unrelated to page faults, therefore
>  * DONTWAKE flag is meaningless with WP=1.
>  * Removing write protection (WP=0) in response to a page fault wakes the
>  * faulting task unless DONTWAKE is set.
>  */
>  
> And a documentation update along these lines would be appreciated :)

Thanks for the write-up!  I'm stoling the whole paragraph into the
patch where uffdio_writeprotect is introduced.

Regards,

-- 
Peter Xu

