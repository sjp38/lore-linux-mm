Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC8EBC10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4DCB213A2
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:41:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4DCB213A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A1DB8E0003; Tue, 26 Feb 2019 02:41:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3513A8E0002; Tue, 26 Feb 2019 02:41:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21C138E0003; Tue, 26 Feb 2019 02:41:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id E7FAF8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:41:32 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id k5so11609909qte.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:41:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=guOlYyuM3iVgzRYwgViknVoftch7aCd0M4cz251FyV4=;
        b=LnQ9yj75qxJ9w6+2AeZwOOzHHpiM2jsAxi5/E8V4D9GzY/5EC7oPpJ5om4Bpx6lI4v
         thD3JKODwLtO8uVLqLltmybfT3926Y85sFeNEIGcuffIQ7HEGqNZr2YqmQSE1yr6Gpd7
         YLLTJmYREFSjhPHSCb/udegUXwo7Yz8ml5Yf71c1pise3S+bqntaRQokQ0gsvCSsU0WN
         G3kZcE1IDUcfvjd6A7ICvVGB2Ld0MNlub2gG6Qt4EXU5444G7duBvejohZpKE7VQ+kzn
         Oj49x3SIdwjjl05IP/ptJBQIH3m9KZyj0rrOWRri2/5Y+H857axjXO+4JS0yuxNN/DRp
         MVZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaMNxIbc2ql0b5+UZPKK68Z9I8mKE9mlKeuG9JE3/Qbpnuq8xnL
	2a5VnaX8IlnGjGnkYfCmMXtwfnLcivg3O6KygluhZrpruX01upQPLdtCOi04m9U/9Q9xGr0xqWs
	KSmL93x/CwyIg4DDVNEtj638PCDTzvQoULKLqWuURa5KzoyjhvzsJfTnsBxMWXam7Kw==
X-Received: by 2002:ae9:e890:: with SMTP id a138mr15755016qkg.339.1551166892673;
        Mon, 25 Feb 2019 23:41:32 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaAtAQCwtRc69qvxHGd5IqHgBiya4e0Tu7LSe91uDbE1WgErlx/3RyurMcBEYnT7emCZ+yW
X-Received: by 2002:ae9:e890:: with SMTP id a138mr15754982qkg.339.1551166891758;
        Mon, 25 Feb 2019 23:41:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551166891; cv=none;
        d=google.com; s=arc-20160816;
        b=qlYLM2OsUcXf5Ua5HV8RUp6WxxnLjVyAfirAgs4tqp0d30ljN5mzx3uj4mN2vbYzG8
         ExLBqbxa8q05BN+GuWCc5KwhA7n1Z8DN+wyHya9AG3mOrwIcO/M7zSJn/Hb60tA3j882
         i+BLC5GKd4MZDWn3CiJ4HyGcZws3lRPo5zM7081B/1fwmfXXQGVNtb4HwU2OL863Xc3J
         kbO5OM2RlikqbvmzXBXvHqD4Zhay6x0jA2fSdcABGMOm4FQOd0BEbChQRI8L+aD5SNxC
         yxJ44f3n7ndQSVOLx8jAabl194k0Uzdqaz66r80k8ViGzMPxEdXjVWTkuL90mbd31s8u
         gCPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=guOlYyuM3iVgzRYwgViknVoftch7aCd0M4cz251FyV4=;
        b=Q55I/Rj/UAXW/VNQ7Lvrt5ZCJGHO44QfFEzSndGFwrNXM/cG/DJlnMpTHMcAM6Fas+
         B58HcsuirkLH6/fCUsWu2Q9DdpZyTEaNHY2Te2rNX54xKoTGkvqVboYWUiI1bd5LpGzX
         SsjU2Hu89MyGGqBH92tpH8e050Gz3/LPhSXkvvpRUbeGTBKsfg9P2JoSgFTrtU23Q/w7
         w+f9NmoZ1Q5rPm0Pth+eE4C42UVpUrPDNfZKvHKswu1T9pw01X4dnMOjIGk3V+FBXKyb
         efFAhfS5X4xDEZe3SPBeh/FQQXnGW8oz84tvcIjjYDEchbyVor2VzHNQgJgD2MkAd3VI
         BgSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m11si2337799qkk.267.2019.02.25.23.41.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:41:31 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 03095309D288;
	Tue, 26 Feb 2019 07:41:30 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D5D0A5D6AA;
	Tue, 26 Feb 2019 07:41:20 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:41:17 +0800
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
Message-ID: <20190226074117.GL13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-24-peterx@redhat.com>
 <20190225210934.GE10454@rapoport-lnx>
 <20190226062424.GH13653@xz-x1>
 <20190226072933.GF5873@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190226072933.GF5873@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 26 Feb 2019 07:41:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 09:29:33AM +0200, Mike Rapoport wrote:
> On Tue, Feb 26, 2019 at 02:24:52PM +0800, Peter Xu wrote:
> > On Mon, Feb 25, 2019 at 11:09:35PM +0200, Mike Rapoport wrote:
> > > On Tue, Feb 12, 2019 at 10:56:29AM +0800, Peter Xu wrote:
> > > > It does not make sense to try to wake up any waiting thread when we're
> > > > write-protecting a memory region.  Only wake up when resolving a write
> > > > protected page fault.
> > > > 
> > > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > > ---
> > > >  fs/userfaultfd.c | 13 ++++++++-----
> > > >  1 file changed, 8 insertions(+), 5 deletions(-)
> > > > 
> > > > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > > > index 81962d62520c..f1f61a0278c2 100644
> > > > --- a/fs/userfaultfd.c
> > > > +++ b/fs/userfaultfd.c
> > > > @@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > > >  	struct uffdio_writeprotect uffdio_wp;
> > > >  	struct uffdio_writeprotect __user *user_uffdio_wp;
> > > >  	struct userfaultfd_wake_range range;
> > > > +	bool mode_wp, mode_dontwake;
> > > > 
> > > >  	if (READ_ONCE(ctx->mmap_changing))
> > > >  		return -EAGAIN;
> > > > @@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > > >  	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
> > > >  			       UFFDIO_WRITEPROTECT_MODE_WP))
> > > >  		return -EINVAL;
> > > > -	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> > > > -	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> > > > +
> > > > +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> > > > +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> > > > +
> > > > +	if (mode_wp && mode_dontwake)
> > > >  		return -EINVAL;
> > > 
> > > This actually means the opposite of the commit message text ;-)
> > > 
> > > Is any dependency of _WP and _DONTWAKE needed at all?
> > 
> > So this is indeed confusing at least, because both you and Jerome have
> > asked the same question... :)
> > 
> > My understanding is that we don't have any reason to wake up any
> > thread when we are write-protecting a range, in that sense the flag
> > UFFDIO_WRITEPROTECT_MODE_DONTWAKE is already meaningless in the
> > UFFDIO_WRITEPROTECT ioctl context.  So before everything here's how
> > these flags are defined:
> > 
> > struct uffdio_writeprotect {
> > 	struct uffdio_range range;
> > 	/* !WP means undo writeprotect. DONTWAKE is valid only with !WP */
> > #define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
> > #define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
> > 	__u64 mode;
> > };
> > 
> > To make it clear, we simply define it as "DONTWAKE is valid only with
> > !WP".  When with that, "mode_wp && mode_dontwake" is indeed a
> > meaningless flag combination.  Though please note that it does not
> > mean that the operation ("don't wake up the thread") is meaningless -
> > that's what we'll do no matter what when WP==1.  IMHO it's only about
> > the interface not the behavior.
> > 
> > I don't have a good way to make this clearer because firstly we'll
> > need the WP flag to mark whether we're protecting or unprotecting the
> > pages.  Later on, we need DONTWAKE for page fault handling case to
> > mark that we don't want to wake up the waiting thread now.  So both
> > the flags have their reason to stay so far.  Then with all these in
> > mind what I can think of is only to forbid using DONTWAKE in WP case,
> > and that's how above definition comes (I believe, because it was
> > defined that way even before I started to work on it and I think it
> > makes sense).
> 
> There's no argument how DONTWAKE can be used with !WP. The
> userfaultfd_writeprotect() is called in response of the uffd monitor to WP
> page fault, it asks to clear write protection to some range, but it does
> not want to wake the faulting thread yet but rather it will use uffd_wake()
> later.
> 
> Still, I can't grok the usage of DONTWAKE with WP=1. In my understanding,
> in this case userfaultfd_writeprotect() is called unrelated to page faults,
> and the monitored thread runs freely, so why it should be waked at all?

Exactly this is how I understand it.  And that's why I wrote this
patch to remove the extra wakeup() since I think it's unecessary.

> 
> And what happens, if the thread is waiting on a missing page fault and we
> do userfaultfd_writeprotect(WP=1) at the same time?

Then IMHO the userfaultfd_writeprotect() will be a noop simply because
the page is still missing.  Here if with the old code (before this
patch) we'll probably even try to wake up this thread but this thread
should just fault again on the same address due to the fact that the
page is missing.  After this patch the monitored thread should
continue to wait on the missing page.

Thanks,

-- 
Peter Xu

