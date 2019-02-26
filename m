Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8796BC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:25:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E1F12173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:25:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E1F12173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA9F68E0003; Tue, 26 Feb 2019 01:25:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4DE28E0002; Tue, 26 Feb 2019 01:25:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C63008E0003; Tue, 26 Feb 2019 01:25:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCE08E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:25:10 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id e31so11245793qtb.22
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:25:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AGeyhIWuilZzjypRYSbv3jefgHfFwWqZZzzYkiNDc00=;
        b=FpbNfHkC0fLNPzaFrXvDW/whCWci9NAb7TsvDuCRy7nS3eBRUTX1lGRAvWMZcAGN+c
         uSemGlh8TxfNBtmfxhmcTVhpNiLkmsPWs0k8V31nKv9JUMbxonfrh25pJeRI91r8Thdo
         BZguuR+NMfZzxcvxDTBrgQ8A8JZaRXkbAJEx+kv+KB40AGlF6J5vxAh4UudhNoWRMGk/
         o9pYThKipeTx+0osj8/ztifuzK3J3d7TU5yKW0LjTJd4bYlldzZYDUu2wIF/f8j76v4F
         FB6Sv0rgpuinJrUJPSFrR0XlPQSJ6Ev7AFrZflQZGzwMS6YwNz62u1gTA3dXt3rmR5GP
         GXOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaiGQE91gJBAFrbtNF2xV0Gx9H8djJIFoEJTVUSzHZ+VE2i7wnT
	iV3KBjmhyoSU50X7dadxb9h7Wf7pMMfd8oT//qmZqhXFYJtSlhf8hrUdUNEMS1hUUwVIN5e6ohg
	zrR8YsEMyUb48+b62NJAHMAlg6ej0tXjZ/x9Qr1k/8KXqBrdSHW/BX4dXeNacXh7/sA==
X-Received: by 2002:ac8:4141:: with SMTP id e1mr16242255qtm.96.1551162310371;
        Mon, 25 Feb 2019 22:25:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaCfStZiOdSffUmD+/6APbTM4SoGdFbKlsZTRoCwd7AexuYSeXvWwP6D19F8pir94nQGEdV
X-Received: by 2002:ac8:4141:: with SMTP id e1mr16242228qtm.96.1551162309618;
        Mon, 25 Feb 2019 22:25:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551162309; cv=none;
        d=google.com; s=arc-20160816;
        b=1C5fMxnZA7XUBQPEtClWEJtLq7u6X//XsFsn1rcsJEKouIUIp6sGzo4CZoWwDk5ztM
         I0MRW5QVB2prQzhWnPp0m0sEHkvhgfzG3c2nP2NMJ5GZDdsLLZzDylkA3KP284oEdi9Z
         8EZvEffQuJsVaQDFW5qLTdaowl7EvUAsOlbQl7KGaIcJZiU8HrHvBYzmF0gD3zow/ZyA
         ZxbEL2XCUk4az/+58b5gs0gB/PnqPpToZELRFAPcuJHQxxWMH2taWOW/1LqoCWQX0hrx
         CA1fPOhYyih2mW+CKStVk3VFYWAtGsaRp9WHi4jjjLTAvoluMfKwpS9IWIEq+dmpY3EH
         yIyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AGeyhIWuilZzjypRYSbv3jefgHfFwWqZZzzYkiNDc00=;
        b=dSLyYCVjVzW5d0gXXxGdnCvKwXrSvk1+zfJa3HPYG+vclLLWnzXQgVVsWK82NTRE0q
         Zrb6MT4mDZa5A1Kx9nFgqGdzC1aN95pjj9QMwRNhYQ9hQLsTGqPeXodeLz+b3YH58Iqe
         PffDO1bsYGSteFBjjv2Y8RDrtS+E4+PVyaeQ5Sce6iq79n/SeG2EnT/+1F6H/4Hn6vg7
         iBEYuYKvwmCjBKO0z5DVlCsdwBdPxTuDa/h3hnW6mTPUzwTXhWusaII/3mg7T7VH0Sql
         D+Zdb9rMuVN6CrdQDB2LjUmu5+qBVgG5S36tvWVD0ZjT9fADLSBjXhLG8pBZUYMexN/3
         vvaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p15si2680045qki.224.2019.02.25.22.25.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:25:09 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 801D7307DAB7;
	Tue, 26 Feb 2019 06:25:07 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C36AA60865;
	Tue, 26 Feb 2019 06:24:54 +0000 (UTC)
Date: Tue, 26 Feb 2019 14:24:52 +0800
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
Message-ID: <20190226062424.GH13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-24-peterx@redhat.com>
 <20190225210934.GE10454@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190225210934.GE10454@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 26 Feb 2019 06:25:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 11:09:35PM +0200, Mike Rapoport wrote:
> On Tue, Feb 12, 2019 at 10:56:29AM +0800, Peter Xu wrote:
> > It does not make sense to try to wake up any waiting thread when we're
> > write-protecting a memory region.  Only wake up when resolving a write
> > protected page fault.
> > 
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> > ---
> >  fs/userfaultfd.c | 13 ++++++++-----
> >  1 file changed, 8 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
> > index 81962d62520c..f1f61a0278c2 100644
> > --- a/fs/userfaultfd.c
> > +++ b/fs/userfaultfd.c
> > @@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> >  	struct uffdio_writeprotect uffdio_wp;
> >  	struct uffdio_writeprotect __user *user_uffdio_wp;
> >  	struct userfaultfd_wake_range range;
> > +	bool mode_wp, mode_dontwake;
> > 
> >  	if (READ_ONCE(ctx->mmap_changing))
> >  		return -EAGAIN;
> > @@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> >  	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
> >  			       UFFDIO_WRITEPROTECT_MODE_WP))
> >  		return -EINVAL;
> > -	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
> > -	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
> > +
> > +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> > +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> > +
> > +	if (mode_wp && mode_dontwake)
> >  		return -EINVAL;
> 
> This actually means the opposite of the commit message text ;-)
> 
> Is any dependency of _WP and _DONTWAKE needed at all?

So this is indeed confusing at least, because both you and Jerome have
asked the same question... :)

My understanding is that we don't have any reason to wake up any
thread when we are write-protecting a range, in that sense the flag
UFFDIO_WRITEPROTECT_MODE_DONTWAKE is already meaningless in the
UFFDIO_WRITEPROTECT ioctl context.  So before everything here's how
these flags are defined:

struct uffdio_writeprotect {
	struct uffdio_range range;
	/* !WP means undo writeprotect. DONTWAKE is valid only with !WP */
#define UFFDIO_WRITEPROTECT_MODE_WP		((__u64)1<<0)
#define UFFDIO_WRITEPROTECT_MODE_DONTWAKE	((__u64)1<<1)
	__u64 mode;
};

To make it clear, we simply define it as "DONTWAKE is valid only with
!WP".  When with that, "mode_wp && mode_dontwake" is indeed a
meaningless flag combination.  Though please note that it does not
mean that the operation ("don't wake up the thread") is meaningless -
that's what we'll do no matter what when WP==1.  IMHO it's only about
the interface not the behavior.

I don't have a good way to make this clearer because firstly we'll
need the WP flag to mark whether we're protecting or unprotecting the
pages.  Later on, we need DONTWAKE for page fault handling case to
mark that we don't want to wake up the waiting thread now.  So both
the flags have their reason to stay so far.  Then with all these in
mind what I can think of is only to forbid using DONTWAKE in WP case,
and that's how above definition comes (I believe, because it was
defined that way even before I started to work on it and I think it
makes sense).

Thanks,

-- 
Peter Xu

