Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C92B4C4360F
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 19:42:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CB3A218AC
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 19:42:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CB3A218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F3846B02E1; Sat, 16 Mar 2019 15:42:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A3606B02E2; Sat, 16 Mar 2019 15:42:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 193086B02E3; Sat, 16 Mar 2019 15:42:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBDFE6B02E1
	for <linux-mm@kvack.org>; Sat, 16 Mar 2019 15:42:28 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h51so4419549qte.22
        for <linux-mm@kvack.org>; Sat, 16 Mar 2019 12:42:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7HPivb/qV8PSRNNBNeDafABseXfBCUn/63PfHOEBYpY=;
        b=qJAbCTOXpyDR67xgiv9YjMtk4be1N01BQsgMbYdsqIEWOtLDUt9JXHmzD2zl41Klg8
         Bcq4oyCd03KNLM1cGRPu5rGbjJZy1mPreghjCOPYYCEixGcqzYE0W78YVUYuhg9+bkd3
         TBvr/1OrxtrUqQo4A3a7WPxJ7EV6UL2/UbJd6/JLTwTvC/0UlXCTL3KUGrZzgRTz2zrc
         SWVR0uUPosQyBjh+ybFCDSOx2JZx3vcvWz7xAvzYlKpbFmDeJBbXZS0Wdp5ccdrEpau+
         fPRlCiES0WzWig7+RhWWTSTon0mjwpTWhYT4OSpbF1O3mRCNeQkwUm267Gf7XaDDYN0m
         QzXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXiP0MlBfgTpazYBhCO6DJzbjzAkt98vRRljUBUZlnzXbsWG+AO
	QnAnYupYmzZ7ZvuJLR7mv3ZLpCZJ0AfpyXz+2tfaYuD5pVQ528bMlhdyXAS4A6Uouml3oPFGvsW
	y/tkdlbFUjpcNLrQANqjQoa5KSI/y6kHutyZ6XrTVc9MQBIR61eZhwQsebbGXwj1uSA==
X-Received: by 2002:a37:50d5:: with SMTP id e204mr7816656qkb.26.1552765348695;
        Sat, 16 Mar 2019 12:42:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJ09k9J/Z9p21+L4PToFEOTksijEzb8x8aOFXZIu207EVyqn3dx7yI2FiShlwtG9aJJW8w
X-Received: by 2002:a37:50d5:: with SMTP id e204mr7816634qkb.26.1552765347860;
        Sat, 16 Mar 2019 12:42:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552765347; cv=none;
        d=google.com; s=arc-20160816;
        b=qDa2vjcPhxT90hz/1RMyS3/mq4l0G7YOLt+fef98hV/0RRAnO4qWKlVLIQsvsJEyOt
         Bi7oJuvW9O3qBlqmU5HmAeWwUGKSfGkF6rSermLRyZS2A9I8ij4IPhYfZjOq1uSwI9bM
         08ijo2GZxkl/RDwZ4vBvBrX9OQ3Cs9IQTFPjz9FUBM+r+9CqH52Q9cdzYZUG3ojhJzaq
         3ZcBg9dK33uh4LYf0fRuhEn23o/1nsi46z0TWeejTytdLXz8PyMDj0fpz20hcMfVSgsr
         0oRyX3f5bJBYvVBI9gy7VMn8Zc54VMBZrAC0MyrtW+2zXtgvx0bZw03Zdzks9WU/nosf
         WItw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7HPivb/qV8PSRNNBNeDafABseXfBCUn/63PfHOEBYpY=;
        b=sjAmM5QALcrn5vcJChvZond0d4lScU4PBqmV0WjSuaHixxNUnr2C7u9fSRWs8ijFLe
         fDpWaCCALQ+wHpOO0YRtbIEX/bd4alWAgwytWAvy35KBeZ1WFNfYZVE5k/mZYynPyvGX
         bFIgJ4eBfFPspVyRmB78liWl8a47/+jwqloVpWZdDwzEmjn1Fh03OU6zuDBTtx+fw2ab
         A6Q3oOiox+BluIbRLfUBgmEwEPlIj7jtCp9rElp3SBhG9HB+5LS5D1RW5Vucyfmx9JB9
         N4+k5/2BzyNzrujHKMvazbTkcxXY9dn4TptQjiqV06Ja9nJdpJ8Fnx6GMWIsxzD4+hLH
         zW8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t11si556216qvm.221.2019.03.16.12.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Mar 2019 12:42:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6D5F3C057E68;
	Sat, 16 Mar 2019 19:42:26 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 08A9B1001DE9;
	Sat, 16 Mar 2019 19:42:23 +0000 (UTC)
Date: Sat, 16 Mar 2019 15:42:22 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Peter Xu <peterx@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	syzbot <syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>,
	Michal Hocko <mhocko@kernel.org>, cgroups@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	David Rientjes <rientjes@google.com>,
	Hugh Dickins <hughd@google.com>,
	Matthew Wilcox <willy@infradead.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
Message-ID: <20190316194222.GA29767@redhat.com>
References: <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com>
 <5C7D2F82.40907@huawei.com>
 <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com>
 <5C7D4500.3070607@huawei.com>
 <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com>
 <5C7E1A38.2060906@huawei.com>
 <20190306020540.GA23850@redhat.com>
 <5C821550.50506@huawei.com>
 <20190315213944.GD9967@redhat.com>
 <5C8CC42E.1090208@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5C8CC42E.1090208@huawei.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Sat, 16 Mar 2019 19:42:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 16, 2019 at 05:38:54PM +0800, zhong jiang wrote:
> On 2019/3/16 5:39, Andrea Arcangeli wrote:
> > On Fri, Mar 08, 2019 at 03:10:08PM +0800, zhong jiang wrote:
> >> I can reproduce the issue in arm64 qemu machine.  The issue will leave after applying the
> >> patch.
> >>
> >> Tested-by: zhong jiang <zhongjiang@huawei.com>
> > Thanks a lot for the quick testing!
> >
> >> Meanwhile,  I just has a little doubt whether it is necessary to use RCU to free the task struct or not.
> >> I think that mm->owner alway be NULL after failing to create to process. Because we call mm_clear_owner.
> > I wish it was enough, but the problem is that the other CPU may be in
> > the middle of get_mem_cgroup_from_mm() while this runs, and it would
> > dereference mm->owner while it is been freed without the call_rcu
> > affter we clear mm->owner. What prevents this race is the
> As you had said, It would dereference mm->owner after we clear mm->owner.
> 
> But after we clear mm->owner,  mm->owner should be NULL.  Is it right?
> 
> And mem_cgroup_from_task will check the parameter. 
> you mean that it is possible after checking the parameter to  clear the owner .
> and the NULL pointer will trigger. :-(

Dereference mm->owner didn't mean reading the value of the mm->owner
pointer, it really means to dereference the value of the pointer. It's
like below:

get_mem_cgroup_from_mm()		failing fork()
----					---
task = mm->owner
					mm->owner = NULL;
					free(mm->owner)
*task /* use after free */

We didn't set mm->owner to NULL before, so the window for the race was
larger, but setting mm->owner to NULL only hides the problem and it
can still happen (albeit with a smaller window).

If get_mem_cgroup_from_mm() can see at any time mm->owner not NULL,
then the free of the task struct must be delayed until after
rcu_read_unlock has returned in get_mem_cgroup_from_mm(). This is
the standard RCU model, the freeing must be delayed until after the
next quiescent point.

BTW, both mm_update_next_owner() and mm_clear_owner() should have used
WRITE_ONCE when they write to mm->owner, I can update that too but
it's just to not to make assumptions that gcc does the right thing
(and we still rely on gcc to do the right thing in other places) so
that is just an orthogonal cleanup.

Thanks,
Andrea

