Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 304CF6B00A6
	for <linux-mm@kvack.org>; Sat,  7 Feb 2015 09:38:44 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id j5so119726qga.3
        for <linux-mm@kvack.org>; Sat, 07 Feb 2015 06:38:44 -0800 (PST)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id c5si6774692qad.38.2015.02.07.06.38.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Feb 2015 06:38:43 -0800 (PST)
Received: by mail-qg0-f51.google.com with SMTP id z60so11573719qgd.10
        for <linux-mm@kvack.org>; Sat, 07 Feb 2015 06:38:43 -0800 (PST)
Date: Sat, 7 Feb 2015 09:38:39 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC] Making memcg track ownership per address_space or anon_vma
Message-ID: <20150207143839.GA9926@htj.dyndns.org>
References: <20150202194608.GA8169@htj.dyndns.org>
 <CAHH2K0aSPjNgt30uJQa_6r=AXZso3SitjWOm96dtJF32CumZjQ@mail.gmail.com>
 <20150204170656.GA18858@htj.dyndns.org>
 <xr93zj8ti6ca.fsf@gthelen.mtv.corp.google.com>
 <20150205131514.GD25736@htj.dyndns.org>
 <xr93siekt3p3.fsf@gthelen.mtv.corp.google.com>
 <20150205222522.GA10580@htj.dyndns.org>
 <xr93pp9nucrt.fsf@gthelen.mtv.corp.google.com>
 <20150206141746.GB10580@htj.dyndns.org>
 <CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0bxvc34u1PugVQsSfxXhmN8qU6KRpiCWwOVBa6BPqMDOg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Cgroups <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>

Hello, Greg.

On Fri, Feb 06, 2015 at 03:43:11PM -0800, Greg Thelen wrote:
> If cgroups are about isolation then writing to shared files should be
> rare, so I'm willing to say that we don't need to handle shared
> writers well.  Shared readers seem like a more valuable use cases
> (thin provisioning).  I'm getting overwhelmed with the thought
> exercise of automatically moving inodes to common ancestors and back
> charging the sharers for shared_usage.  I haven't wrapped my head
> around how these shared data pages will get protected.  It seems like
> they'd no longer be protected by child min watermarks.

Yes, this is challenging and what my current thought is around taking
the maximum of the low settings of the sharing children but I need to
think more about it.  One problem is that the shared inodes will
preemptively take away the amount shared from the children's low
protection.  They won't compete fairly with other inodes or anons but
they can't really as they don't really belong to any single sharer.

> So I know this thread opened with the claim "both memcg and blkcg must
> be looking at the same picture.  Deviating them is highly likely to
> lead to long-term issues forcing us to look at this again anyway, only
> with far more baggage."  But I'm still wondering if the following is
> simpler:
> (1) leave memcg as a per page controller.
> (2) maintain a per inode i_memcg which is set to the common dirtying
> ancestor.  If not shared then it'll point to the memcg that the page
> was charged to.
> (3) when memcg dirtying page pressure is seen, walk up the cgroup tree
> writing dirty inodes, this will write shared inodes using blkcg
> priority of the respective levels.
> (4) background limit wb_check_background_flush() and time based
> wb_check_old_data_flush() can feel free to attack shared inodes to
> hopefully restore them to non-shared state.
> For non-shared inodes, this should behave the same.  For shared inodes
> it should only affect those in the hierarchy which is sharing.

The thing which breaks when you de-couple what memcg sees from the
rest of the stack is that the amount of memory which may be available
to a given cgroup and how much of that is dirty is the main linkage
propagating IO pressure to actual dirtying tasks.  If you decouple the
two worldviews, you lose the ability to propagate IO pressure to
dirtiers in a controlled manner and that's why anything inside a memcg
currently is always triggering direct reclaim path instead of being
properly dirty throttled.

You can argue that an inode being actively dirtied from multiple
cgroups is a rare case which we can sweep under the rug and that
*might* be the case but I have a nagging feeling that that would be a
decision which is made merely out of immediate convenience and would
much prefer having a well defined model of sharing inodes and anons
across cgroups so that the behaviors shown in thoses cases aren't mere
accidental consequences without any innate meaning.

If we can argue that memcg and blkcg having different views is
meaningful and characterize and justify the behaviors stemming from
the deviation, sure, that'd be fine, but I don't think we have that as
of now.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
