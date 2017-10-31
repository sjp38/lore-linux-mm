Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C35626B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 11:25:51 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id n33so43737495ioi.7
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:25:51 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id l132si2187681ith.28.2017.10.31.08.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Oct 2017 08:25:51 -0700 (PDT)
Date: Tue, 31 Oct 2017 16:25:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171031152532.uah32qiftjerc3gx@hirez.programming.kicks-ass.net>
References: <089e0825eec8955c1f055c83d476@google.com>
 <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
 <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
 <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
 <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171031131333.pr2ophwd2bsvxc3l@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Byungchul Park <byungchul.park@lge.com>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Tue, Oct 31, 2017 at 02:13:33PM +0100, Michal Hocko wrote:

> > I can indeed confirm it's running old code; cpuhp_state is no more.
> 
> Does this mean the below chain is no longer possible with the current
> linux-next (tip)?

I see I failed to answer this; no it will happen but now reads like:

	s/cpuhp_state/&_up/

Where we used to have a single lock protecting the hotplug stuff, we now
have 2, one for bringing stuff up and one for tearing it down.

This got rid of lock cycles that included cpu-up and cpu-down parts;
those are false positives because we cannot do cpu-up and cpu-down
concurrently.

But this report only includes a single (cpu-up) part and therefore is
not affected by that change other than a lock name changing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
