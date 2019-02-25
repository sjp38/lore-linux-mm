Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B6CC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:59:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0F8720651
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0F8720651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0A328E0178; Mon, 25 Feb 2019 03:59:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB96E8E0167; Mon, 25 Feb 2019 03:59:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C80AA8E0178; Mon, 25 Feb 2019 03:59:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E0088E0167
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 03:59:01 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id q15so7260467qki.14
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 00:59:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=kz1mKKhlKzVNVRtZjudxG5ilqmccR317itUsMuWj+Ok=;
        b=IAbc/4PVi+8AV3LvRI4VYcmaVKlmrBOaCvQnOc0ekF/c2lHoE8IqSc6cBgz/9RBeVq
         1FQ5YcfrqkKkV9h4/E/U1EwGDDn+Tjm10/tkOxbzKtBOxutf9A1NT3rqGyqJWVf0D4h7
         9UCRP0zh+KDWeqTKXJsq/wcrBTeX8Azcm3dOHjDMc9Rj1qNahaEF1Rf9HqtH/Ltpf7tM
         eH8l3gOTezSLYPSVYHUBDpdov85rAOPFJOAhd/CT9R9PJMui9lm69V46Jm4gTpl6lQBt
         miawb0skP8fmqMYrIb91ry/Vj7yiarAB31OawW2cShdZUQ47IsrR1Kzf6643FrPEdh0a
         f1Gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZNtJl9Uf+2nLxEVddOmsnpalWn7CiJTDLdROLX3GCJUHYQXM6Y
	IkhL5QIJcEr9wa734MmLq3s+boaLMTIwMvjN4fqyzQfD2f5+YRUPCu901+jODro/EGCpfAiBztd
	3kCw54r1j5/CHRuwBZ+O96zwT44NaP81QUi2sC20iYPuaP4krd7VBToKVEvYz+L16MQ==
X-Received: by 2002:a37:4f45:: with SMTP id d66mr12118106qkb.81.1551085141354;
        Mon, 25 Feb 2019 00:59:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYZGTnQKjhulVOtHIiBTEj/0fiy7EYds8F6pjGS8Wz+5Dy4WGGaPpkqprSzqtyaeaZ5nFJl
X-Received: by 2002:a37:4f45:: with SMTP id d66mr12118080qkb.81.1551085140497;
        Mon, 25 Feb 2019 00:59:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551085140; cv=none;
        d=google.com; s=arc-20160816;
        b=MJKg4r84H+wCxW6bp4PchyIVD0T5uCd0o6WUA9kWXAoeyYMoV8dPXwSKQI0xGUEjxv
         NrsibEFVMM39uvWbRw3Xhb252jIP6FpWRYFFZFzNl0gNpk+s8AbsXOgXUbB5oXPrjwxf
         whfe3HAmhmmRtEMFA0UdTqBNoR7mgJSKY9oNC3AyYlNorwxIk1uJn5R4bXtkhSHG2FnR
         0KDxDEVdfbf6ZdQPd3cLmlPMWMZE9uOuW66SWVlbaHcf3wnAaOeCXilPytGN9kwPwzZA
         EQSwYE8PfQJpWcbxyxEZn4VdyfxKwdiLP+s6F7Q5XDDFEsbpePsfYWI1G/iZSzh7xK94
         /aSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=kz1mKKhlKzVNVRtZjudxG5ilqmccR317itUsMuWj+Ok=;
        b=T5pNQBVzvaCWXtnKUvPEAsoU81FvCARLwu8HVu2bpX1pT6v0iQS408Lqyd77AJ0qHV
         fuk+SQqqBdFHjlbi1D8P9qatKb8uWEyhjAPEbi3bWUPiDSPTt/3RM0/38PmCQogN7iGB
         lEOnpvqOvTI6AuD1Bpdr5zQFbfYPYQO0igOUepj+TRQzG9xRRNZ9smtikBBvSpLqMexL
         d/d1wXT76i06S2URsRx60QojcrbRaPYqJMqtRiWJOVpenY4DOGrzlIg57X4b76sANS9R
         Y9G7srLhtwNNatkDTLuuYtNCP0763Iarrtnxu48lsbwuEDQfmvRYbPzrgPnWzEV7k0K/
         aBvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d9si1685570qve.12.2019.02.25.00.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 00:59:00 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 030013003AFB;
	Mon, 25 Feb 2019 08:58:59 +0000 (UTC)
Received: from xz-x1 (ovpn-12-105.pek2.redhat.com [10.72.12.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1368560BE7;
	Mon, 25 Feb 2019 08:58:48 +0000 (UTC)
Date: Mon, 25 Feb 2019 16:58:46 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
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
Message-ID: <20190225085846.GE13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-24-peterx@redhat.com>
 <20190221183653.GV2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190221183653.GV2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Mon, 25 Feb 2019 08:58:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 01:36:54PM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:29AM +0800, Peter Xu wrote:
> > It does not make sense to try to wake up any waiting thread when we're
> > write-protecting a memory region.  Only wake up when resolving a write
> > protected page fault.
> > 
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> I am bit confuse here, see below.
> 
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

[1]

> > +
> > +	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
> > +	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
> > +
> > +	if (mode_wp && mode_dontwake)

[2]

> >  		return -EINVAL;
> 
> I am confuse by the logic here. DONTWAKE means do not wake any waiting
> thread right ? So if the patch header it seems to me the logic should
> be:
>     if (mode_wp && !mode_dontwake)
>         return -EINVAL;

This should be the most common case when we want to write protect a
page (or a set of pages).  I'll explain more details below...

> 
> At very least this part does seems to mean the opposite of what the
> commit message says.

Let me paste the matrix to be clear on these flags:

  |------+-------------------------+------------------------------|
  |      | dontwake=0              | dontwake=1                   |
  |------+-------------------------+------------------------------|
  | wp=0 | (a) resolve pf, do wake | (b) resolve pf only, no wake |
  | wp=1 | (c) wp page range       | (d) invalid                  |
  |------+-------------------------+------------------------------|

Above check at [1] was checking against case (d) in the matrix.  It is
indeed an invalid condition because when we want to write protect a
page we should not try to wake up any thread, so the donewake
parameter is actually useless (we'll always do that).  And above [2]
is simply rewritting [1] with the new variables.

> 
> >  
> >  	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
> > -				  uffdio_wp.range.len, uffdio_wp.mode &
> > -				  UFFDIO_WRITEPROTECT_MODE_WP,
> > +				  uffdio_wp.range.len, mode_wp,
> >  				  &ctx->mmap_changing);
> >  	if (ret)
> >  		return ret;
> >  
> > -	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
> > +	if (!mode_wp && !mode_dontwake) {
> 
> This part match the commit message :)

Here is what the patch really want to change: before this patch we'll
even call wake_userfault() below for case (c) while it doesn't really
make too much sense IMHO.  After this patch we'll only do the wakeup
for (a,b).

> 
> >  		range.start = uffdio_wp.range.start;
> >  		range.len = uffdio_wp.range.len;
> >  		wake_userfault(ctx, &range);

Thanks,

-- 
Peter Xu

