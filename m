Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA166B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 07:27:02 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id q75so17912971pfl.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:27:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v5si5785019pgr.387.2017.09.26.04.27.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 04:27:01 -0700 (PDT)
Date: Tue, 26 Sep 2017 13:26:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm: introduce validity check on vm dirtiness settings
Message-ID: <20170926112656.tbu7nr2lxdqt5rft@dhcp22.suse.cz>
References: <1505861015-11919-1-git-send-email-laoar.shao@gmail.com>
 <20170926102532.culqxb45xwzafomj@dhcp22.suse.cz>
 <CALOAHbAbFedJ-h+QUWeeoAnpeEfpYe2T1GutFb56kBeL=2jN0A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbAbFedJ-h+QUWeeoAnpeEfpYe2T1GutFb56kBeL=2jN0A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Jan Kara <jack@suse.cz>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, vdavydov.dev@gmail.com, jlayton@redhat.com, nborisov@suse.com, Theodore Ts'o <tytso@mit.edu>, mawilcox@microsoft.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 26-09-17 19:06:37, Yafang Shao wrote:
> 2017-09-26 18:25 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> > On Wed 20-09-17 06:43:35, Yafang Shao wrote:
> >> we can find the logic in domain_dirty_limits() that
> >> when dirty bg_thresh is bigger than dirty thresh,
> >> bg_thresh will be set as thresh * 1 / 2.
> >>       if (bg_thresh >= thresh)
> >>               bg_thresh = thresh / 2;
> >>
> >> But actually we can set vm background dirtiness bigger than
> >> vm dirtiness successfully. This behavior may mislead us.
> >> We'd better do this validity check at the beginning.
> >
> > This is an admin only interface. You can screw setting this up even
> > when you keep consistency between the background and direct limits. In
> > general we do not try to be clever for these knobs because we _expect_
> > admins to do sane things. Why is this any different and why do we need
> > to add quite some code to handle one particular corner case?
> >
> 
> Of course we expect admins to do the sane things, but not all admins
> are expert or faimilar with linux kernel source code.
> If we have to read the source code to know what is the right thing to
> do, I don't think this is a good interface, even for the admin.

Well, it is kind of natural to setup background below the direct limit
in general so I am not sure what is so surprising here. Moreover setting
a non default drity limits already requires some expertise. It is not
like an arbitrary value will work just fine...

> Anyway, there's no document on that direct limits should not less than
> background limits.

Then improve the documentation.

> > To be honest I am not entirely sure this is worth the code and the
> > future maintenance burden.
> I'm not sure if this code is a burden for the future maintenance, but
> I think that if we don't introduce this code it is a burden to the
> admins.

anytime we might need to tweak background vs direct limit we would have
to change these checks as well and that sounds like a maint. burden to
me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
