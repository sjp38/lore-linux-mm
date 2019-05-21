Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DDEFC04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EDEB20863
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:32:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EDEB20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4A836B0006; Tue, 21 May 2019 12:32:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFB926B0008; Tue, 21 May 2019 12:32:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C27B6B000A; Tue, 21 May 2019 12:32:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5F66B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:32:39 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b79so4885105qkc.0
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:32:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=CyiKs5cfIEIKfXpx3b3DK4d29hAOIk0KdCLWxqGTyA0=;
        b=FCknQXiytrmqm4dpWIjzTeQ/KG9Pyrmy7vczm/13grbL9LEw2riX1BR30xgDI0+iwq
         zeCro+zEtD080yyaEfERpjjhDlckZnn9fNQamSNyep0USYW/kSg1VM1bEGJcwHqAO1oG
         /KZHmDW4JZfi4QgTHrlP1IuyJCy1kv62QTTBu3i9QCL/iXsdjT+3IUJxRiBcGdubVRX6
         kHHewVSa9vfLPaYIstPr3SEjLt1nj0H4JXwMidpxY1V6bfF8ThWM37+C5XtourM1pfdw
         ktYE1R1iKw6Y2npZDmkjg/O2nf/mCzbyrLN5FYT9+jAiKj2bkFcNNO8Kq3tl6qQ+MVJk
         FK8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWoRTdyRIibBU2lbwUJuuHCLg1WTRXE1KCIPs3iruuYn9raRwtc
	3/OyoxAAYMbS1kQuOiuyo7djrcwNKqYp/QOt/mui7FDl1nqucYgc7nqvWz6/uLFowk9N+D4xDcC
	CuCbsAMdcKdLUXO+m8HeG9jda80duvFbvXvMrWU5cAwJm5dcPs+Fu4JfkLPKBEtAq5Q==
X-Received: by 2002:aed:3e69:: with SMTP id m38mr69178984qtf.101.1558456359267;
        Tue, 21 May 2019 09:32:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzLN5hqyx4D33SgnZdhgYuX+A5rUyqVMSCOyjxYXne/i65rqF2DRb/SpVMQnPakqHjiAW7
X-Received: by 2002:aed:3e69:: with SMTP id m38mr69178930qtf.101.1558456358572;
        Tue, 21 May 2019 09:32:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558456358; cv=none;
        d=google.com; s=arc-20160816;
        b=AwY07hnxeui/CnvNMA0gWaWCzuPLIi2YoA8Mt7YK22MmQHI8LQQPMCDv+wFYEcvvv9
         LyGtbAno/npOt2QiiHG4jTzRR3KX5cFUO2H9RECXkL9TvNiH2vbqQ5UGqtEVD+AgT6EX
         hyXv9DL7pRkSHIPoK8IDq2iBI6phpeslXm5ClNamT+6Bna/ayKpOLuDcMzSLujfD+om/
         myEyrpxe0psgyYVcm+18IPkA5ySh4lh++lAWRyLKOEC6o8jJehn4oNNEw63PUn+quEis
         prEepDgmEMmqD9/co5mcKhiEm95Zv6WVE+NvKfUKoo92YYEv4M3fayAJXAcPqDUUzB/n
         6RbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=CyiKs5cfIEIKfXpx3b3DK4d29hAOIk0KdCLWxqGTyA0=;
        b=z7ZMmLAUTUgrfpY5RtyXXR6HY2o+wAqYzFvW7knWm52iNoOV1seQ2q4WzvYntLeHJw
         ZMOCSgOmhI0Sp9b8sdXMAVIw42ICkmv/lQzTtj3PTJW1jCy+UdQ6wZWchL44LOkVq09z
         HnVJVWobd+UoJS3Dwb0De7XuFo2g2T5ZdEieY44/Qp/Tq5Mejot/0EsMv+xApb4n2zs5
         dH38eItA3YIAriBwFihgo6fj+DDHk63xHMmi9yJIxFSNs16m2Puelaog0vJzmuhULi3c
         iAZY5zgXLSUhv3bkCjnbuAfaukVUSG8onNKBuey0i9Zc/A/7l9t4vPyevq2v0E13pQnM
         IvLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v56si1027302qtj.230.2019.05.21.09.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 09:32:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D9CD5947D;
	Tue, 21 May 2019 16:32:30 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B0CEB1001E6C;
	Tue, 21 May 2019 16:32:26 +0000 (UTC)
Date: Tue, 21 May 2019 12:32:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 4/4] mm, notifier: Add a lockdep map for
 invalidate_range_start
Message-ID: <20190521163224.GE3836@redhat.com>
References: <20190520213945.17046-1-daniel.vetter@ffwll.ch>
 <20190520213945.17046-4-daniel.vetter@ffwll.ch>
 <20190521154059.GC3836@redhat.com>
 <CAKMK7uEaKJiT__=dt=ROUP4Kkq1NgwScLJFQcMuBs2GYjMWOLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAKMK7uEaKJiT__=dt=ROUP4Kkq1NgwScLJFQcMuBs2GYjMWOLw@mail.gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 21 May 2019 16:32:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 06:00:36PM +0200, Daniel Vetter wrote:
> On Tue, May 21, 2019 at 5:41 PM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Mon, May 20, 2019 at 11:39:45PM +0200, Daniel Vetter wrote:
> > > This is a similar idea to the fs_reclaim fake lockdep lock. It's
> > > fairly easy to provoke a specific notifier to be run on a specific
> > > range: Just prep it, and then munmap() it.
> > >
> > > A bit harder, but still doable, is to provoke the mmu notifiers for
> > > all the various callchains that might lead to them. But both at the
> > > same time is really hard to reliable hit, especially when you want to
> > > exercise paths like direct reclaim or compaction, where it's not
> > > easy to control what exactly will be unmapped.
> > >
> > > By introducing a lockdep map to tie them all together we allow lockdep
> > > to see a lot more dependencies, without having to actually hit them
> > > in a single challchain while testing.
> > >
> > > Aside: Since I typed this to test i915 mmu notifiers I've only rolled
> > > this out for the invaliate_range_start callback. If there's
> > > interest, we should probably roll this out to all of them. But my
> > > undestanding of core mm is seriously lacking, and I'm not clear on
> > > whether we need a lockdep map for each callback, or whether some can
> > > be shared.
> >
> > I need to read more on lockdep but it is legal to have mmu notifier
> > invalidation within each other. For instance when you munmap you
> > might split a huge pmd and it will trigger a second invalidate range
> > while the munmap one is not done yet. Would that trigger the lockdep
> > here ?
> 
> Depends how it's nesting. I'm wrapping the annotation only just around
> the individual mmu notifier callback, so if the nesting is just
> - munmap starts
> - invalidate_range_start #1
> - we noticed that there's a huge pmd we need to split
> - invalidate_range_start #2
> - invalidate_reange_end #2
> - invalidate_range_end #1
> - munmap is done

Yeah this is how it looks. All the callback from range_start #1 would
happens before range_start #2 happens so we should be fine.

> 
> But if otoh it's ok to trigger the 2nd invalidate range from within an
> mmu_notifier->invalidate_range_start callback, then lockdep will be
> pissed about that.

No that would be illegal for a callback to do that. There is no existing
callback that would do that at least AFAIK. So we can just say that it
is illegal. I would not see the point.

> 
> > Worst case i can think of is 2 invalidate_range_start chain one after
> > the other. I don't think you can triggers a 3 levels nesting but maybe.
> 
> Lockdep has special nesting annotations. I think it'd be more an issue
> of getting those funneled through the entire call chain, assuming we
> really need that.

I think we are fine. So this patch looks good.

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

