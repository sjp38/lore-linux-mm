Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC306B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 14:52:09 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o20so7930766wro.8
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 11:52:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a30si381166eda.163.2017.11.27.11.52.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Nov 2017 11:52:08 -0800 (PST)
Date: Mon, 27 Nov 2017 20:52:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: disable `vm.max_map_count' sysctl limit
Message-ID: <20171127195207.vderbbkbgygawuhx@dhcp22.suse.cz>
References: <23066.59196.909026.689706@gargle.gargle.HOWL>
 <20171127101232.ykriowhatecnvjvg@dhcp22.suse.cz>
 <CAM43=SPVvBTPz31Uu=iz3fpS9tb75uSmL=pYP3AfsfmYr9u4Og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM43=SPVvBTPz31Uu=iz3fpS9tb75uSmL=pYP3AfsfmYr9u4Og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikael Pettersson <mikpelinux@gmail.com>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>

On Mon 27-11-17 20:18:00, Mikael Pettersson wrote:
> On Mon, Nov 27, 2017 at 11:12 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > I've kept the kernel tunable to not break the API towards user-space,
> > > but it's a no-op now.  Also the distinction between split_vma() and
> > > __split_vma() disappears, so they are merged.
> >
> > Could you be more explicit about _why_ we need to remove this tunable?
> > I am not saying I disagree, the removal simplifies the code but I do not
> > really see any justification here.
> 
> In principle you don't "need" to, as those that know about it can bump it
> to some insanely high value and get on with life.  Meanwhile those that don't
> (and I was one of them until fairly recently, and I'm no newcomer to Unix or
> Linux) get to scratch their heads and wonder why the kernel says ENOMEM
> when one has loads of free RAM.

I agree that our error reporting is more than suboptimal in this regard.
These are all historical mistakes and we have much more of those. The
thing is that we have means to debug these issues (check
/proc/<pid>/maps e.g.).

> But what _is_ the justification for having this arbitrary limit?
> There might have been historical reasons, but at least ELF core dumps
> are no longer a problem.

Andi has already mentioned the the resource consumption. You can create
a lot of unreclaimable memory and there should be some cap. Whether our
default is good is questionable. Whether we can remove it altogether is
a different thing.

As I've said I am not a great fan of the limit but "I've just notice it
breaks on me" doesn't sound like a very good justification. You still
have an option to increase it. Considering we do not have too many
reports suggests that this is not such a big deal for most users.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
