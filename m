Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2D36C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 06:19:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CA822084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 06:19:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CA822084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD7428E0170; Mon, 25 Feb 2019 01:19:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A850E8E016E; Mon, 25 Feb 2019 01:19:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 925C68E0170; Mon, 25 Feb 2019 01:19:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6164B8E016E
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 01:19:24 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f24so8447733qte.4
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 22:19:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DKEzyQ08gWiFm9CUn9ucdBXwqG2HfKtivQ/gA+QfZ/s=;
        b=OGEXMQIrUWmlsQ+yJNcr6+wT3S8nVojHxkkBl4jjcnd7XhNGlNiJk8gdWqSGJNgBet
         HzlFC+elSMZ9HS+pMp5ck6HFB0Gm+b+iUktqtC0DWcHbYLEC2G3W/xfGySxYK2qAMdtX
         Gem5ycZWWr74By+nbHRkK9WlqdwMe+S3DOp9nZDQmNxiErEd/NQsk3hrls11Svzu0PTU
         utKx+WW0eKX0qiqcN9RHyRzfsIIV5wKAyXu5JkNNWsheVFZ/C13c4xuUCC8L9qZ1PikB
         TREk8GtK3SJwAJeog8DBZEVlEKFIM43pWSkQcBVQ1EPWIBJHqYqzMQCTmu5wN2kHvvXD
         QBjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYw12OXXB9+3GVu6aZ1Smxujh4g6ri7pIFK9wFitYC5oJN4pmGs
	e+ws4vF/zkaJZaW2f3VswUE8a2F93FlPs+IDM7u92QJ9kwv3KwPB9pJRJBwzjyUgTpxI8vwdTib
	OmuLu/TuaSsT2U9owOD3zZAD8Dk4d3ttqkOqFRKpqkherbv2nMZ3ZRN9nyxr3o4VDbA==
X-Received: by 2002:ac8:1659:: with SMTP id x25mr12506429qtk.291.1551075564146;
        Sun, 24 Feb 2019 22:19:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYctZU6ckJ41pVTcQSxHGhl1f1F2vdEJIkDciEWNDdBM4RtN7WuLmoNprJqSomwyWC1qVtU
X-Received: by 2002:ac8:1659:: with SMTP id x25mr12506400qtk.291.1551075563285;
        Sun, 24 Feb 2019 22:19:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551075563; cv=none;
        d=google.com; s=arc-20160816;
        b=gzndXyliqf8xrYGOdwd4l7fftlhzermddmICFMpX1ftuNjFqkXzFHTLdJ51s4th6Ww
         ZYs6S9xXj4PXaJhzMrai1unQuQKZX6UmzASvQYHfVFE+d+paIp0NpIrFCOTfCy4JIBpn
         QS7df2fyfUQTcLXccjGsYH7P1cb6JD7aY29oSlIblXM6/voBGMZ2UPv/xUGu1Kw6w1yL
         RjcX4bcr5lashsdc5b5cMtPq1yt2SII3szblAy/iAAHDw6aiEVe3WwjH/Vik3jCUWSNe
         nn6zvj90eQmS6q+m0OchAcsDPu9P7kq3BV/I+IRW7mxDubdpRhO2zaZlGr/Si0R5J1Z/
         CHPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DKEzyQ08gWiFm9CUn9ucdBXwqG2HfKtivQ/gA+QfZ/s=;
        b=rUgxyKju96C7QKPSux7mjn/mogKpm/wUkfNjvD0o9qec6JngJcS3imdY7z619A2VLI
         SWYJZtijeyi8PMYlGVro9DL3hTc3NZY6dZQK/CYgp488vO6LoZ65d0GrcwZFbEQllX0d
         mrKH3KSlklXxMx6npuMT9T/ge80QLXhXdEtrfkrs36LOKYQhJAjggZezguy929K7LPAY
         kGusUCCkfX8SkQnRV7YEn/8VjxumbbmlFxn9FPBMt7K/i1I+u9NOfyZyo56VR9guhlQW
         CcRfe2qvY2caqpE9Wm9cIytwdYMW5ZMcMjSButTtrWJ+ETsdP3fHEniftFrmofzWfxBw
         at3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p31si1645163qvc.25.2019.02.24.22.19.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 22:19:23 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0E51630013E6;
	Mon, 25 Feb 2019 06:19:22 +0000 (UTC)
Received: from xz-x1 (ovpn-12-105.pek2.redhat.com [10.72.12.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 321E310027D9;
	Mon, 25 Feb 2019 06:19:11 +0000 (UTC)
Date: Mon, 25 Feb 2019 14:19:09 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2.1 04/26] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190225061835.GA28121@xz-x1>
References: <20190212025632.28946-5-peterx@redhat.com>
 <20190221085656.18529-1-peterx@redhat.com>
 <20190221155311.GD2813@redhat.com>
 <20190222042544.GD8904@xz-x1>
 <20190222151101.GA7783@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190222151101.GA7783@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 25 Feb 2019 06:19:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 10:11:58AM -0500, Jerome Glisse wrote:
> On Fri, Feb 22, 2019 at 12:25:44PM +0800, Peter Xu wrote:
> > On Thu, Feb 21, 2019 at 10:53:11AM -0500, Jerome Glisse wrote:
> > > On Thu, Feb 21, 2019 at 04:56:56PM +0800, Peter Xu wrote:
> > > > The idea comes from a discussion between Linus and Andrea [1].
> 
> [...]
> 
> > > > diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> > > > index 248ff0a28ecd..d842c3e02a50 100644
> > > > --- a/arch/x86/mm/fault.c
> > > > +++ b/arch/x86/mm/fault.c
> > > > @@ -1483,9 +1483,7 @@ void do_user_addr_fault(struct pt_regs *regs,
> > > >  	if (unlikely(fault & VM_FAULT_RETRY)) {
> > > >  		bool is_user = flags & FAULT_FLAG_USER;
> > > >  
> > > > -		/* Retry at most once */
> > > >  		if (flags & FAULT_FLAG_ALLOW_RETRY) {
> > > > -			flags &= ~FAULT_FLAG_ALLOW_RETRY;
> > > >  			flags |= FAULT_FLAG_TRIED;
> > > >  			if (is_user && signal_pending(tsk))
> > > >  				return;
> > > 
> > > So here you have a change in behavior, it can retry indefinitly for as
> > > long as they are no signal. Don't you want so test for FAULT_FLAG_TRIED ?
> > 
> > These first five patches do want to allow the page fault to retry as
> > much as needed.  "indefinitely" seems to be a scary word, but IMHO
> > this is fine for page faults since otherwise we'll simply crash the
> > program or even crash the system depending on the fault context, so it
> > seems to be nowhere worse.
> > 
> > For userspace programs, if anything really really go wrong (so far I
> > still cannot think a valid scenario in a bug-free system, but just
> > assuming...) and it loops indefinitely, IMHO it'll just hang the buggy
> > process itself rather than coredump, and the admin can simply kill the
> > process to retake the resources since we'll still detect signals.
> > 
> > Or did I misunderstood the question?
> 
> No i think you are right, it is fine to keep retrying while they are
> no signal maybe just add a comment that says so in so many words :)
> So people do not see that as a potential issue.

Sure thing.  I don't know whether commenting this on all the
architectures is good...  I'll try to add some comments above
FAULT_FLAG_* deinitions to explain this.

Thanks!

-- 
Peter Xu

