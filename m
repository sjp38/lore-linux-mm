Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 519DD6B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 12:31:10 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id w24so17290840pgm.7
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 09:31:10 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y6si1783681pgp.746.2017.10.31.09.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 09:31:09 -0700 (PDT)
Date: Tue, 31 Oct 2017 17:30:58 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171031163058.2byfed2i36fcum3g@hirez.programming.kicks-ass.net>
References: <089e0825eec8955c1f055c83d476@google.com>
 <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
 <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
 <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
 <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
 <20171031152532.uah32qiftjerc3gx@hirez.programming.kicks-ass.net>
 <20171031154546.ouryhw4rtpbrch2f@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031154546.ouryhw4rtpbrch2f@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com, David Herrmann <dh.herrmann@gmail.com>

On Tue, Oct 31, 2017 at 04:45:46PM +0100, Michal Hocko wrote:
> Anyway, this lock dependecy is subtle as hell and I am worried that we
> might have way too many of those. We have so many callers of
> get_online_cpus that dependecies like this are just waiting to blow up.

Yes, the filesystem locks inside hotplug thing is totally annoying. I've
got a few other splats that contain a similar theme and I've no real
clue what to do about.

See for instance this one:

  https://lkml.kernel.org/r/20171027151137.GC3165@worktop.lehotels.local

splice from devtmpfs is another common theme and links it do the
pipe->mutex, which then makes another other splice op invert against
that hotplug crap :/


I'm sure I've suggested simply creating possible_cpus devtmpfs files up
front to get around this... maybe we should just do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
