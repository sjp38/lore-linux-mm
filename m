Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id AF3668E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 08:19:10 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w1so3298727qta.12
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 05:19:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p126sor32640018qkd.106.2019.01.08.05.19.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 05:19:09 -0800 (PST)
Message-ID: <1546953547.6911.1.camel@lca.pw>
Subject: Re: [PATCH v3] mm/page_owner: fix for deferred struct page init
From: Qian Cai <cai@lca.pw>
Date: Tue, 08 Jan 2019 08:19:07 -0500
In-Reply-To: <20190108082032.GP31793@dhcp22.suse.cz>
References: <20190103202235.GE31793@dhcp22.suse.cz>
	 <a5666d82-b7ad-4b90-5f4e-fd22afc3e1dc@lca.pw>
	 <20190104130906.GO31793@dhcp22.suse.cz>
	 <e4ad9d12-387d-1cc6-f404-cae6d43ccf80@lca.pw>
	 <20190104151737.GT31793@dhcp22.suse.cz>
	 <c8faf7eb-d23f-4ef7-3432-0acc7165f883@lca.pw>
	 <20190104153245.GV31793@dhcp22.suse.cz>
	 <fa135cd8-32e5-86f7-14ee-30685bca91b5@lca.pw>
	 <20190107184309.GM31793@dhcp22.suse.cz>
	 <bfcd017d-dcf4-b687-1aef-ab0810b12c73@lca.pw>
	 <20190108082032.GP31793@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, Pavel.Tatashin@microsoft.com, mingo@kernel.org, mgorman@techsingularity.net, iamjoonsoo.kim@lge.com, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 2019-01-08 at 09:20 +0100, Michal Hocko wrote:
> On Mon 07-01-19 20:53:08, Qian Cai wrote:
> > 
> > 
> > On 1/7/19 1:43 PM, Michal Hocko wrote:
> > > On Fri 04-01-19 15:18:08, Qian Cai wrote:
> > > [...]
> > > > Though, I can't see any really benefit of this approach apart from
> > > > "beautify"
> > > 
> > > This is not about beautifying! This is about making the code long term
> > > maintainable. As you can see it is just too easy to break it with the
> > > current scheme. And that is bad especially when the code is broken
> > > because of an optimization.
> > > 
> > 
> > Understood, but the code is now fixed. If there is something fundamentally
> > broken in the future, it may be a good time then to create a looks like
> > hundred-line cleanup patch for long-term maintenance at the same time to fix
> > real bugs.
> 
> Yeah, so revert = fix and redisign the thing to make the code more
> robust longterm + allow to catch more allocation. I really fail to see
> why this has to be repeated several times in this thread. Really.
> 

Again, this will introduce a immediately regression (arguably small) that
existing page_owner users with DEFERRED_STRUCT_PAGE_INIT deselected that would
start to miss tens of thousands early page allocation call sites.

I think the disagreement comes from that you want to deal with this passively
rather than proactively that you said "I am pretty sure we will hear about that
when that happens. And act accordingly", but I think it is better to fix it now
rather than later with a 4-line ifdef which you don't like.

I suppose someone else needs to make a judgment call for this as we are in a
"you can't convince me and I can't convince you" situation right now.
