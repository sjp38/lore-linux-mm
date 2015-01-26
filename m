Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id A44986B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 12:28:37 -0500 (EST)
Received: by mail-we0-f181.google.com with SMTP id k48so10379692wev.12
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 09:28:37 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cv8si21575708wjc.78.2015.01.26.09.28.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 09:28:36 -0800 (PST)
Date: Mon, 26 Jan 2015 18:28:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm: vmscan: fix the page state calculation in
 too_many_isolated
Message-ID: <20150126172832.GC22681@dhcp22.suse.cz>
References: <1421235419-30736-1-git-send-email-vinmenon@codeaurora.org>
 <20150114165036.GI4706@dhcp22.suse.cz>
 <54B7F7C4.2070105@codeaurora.org>
 <20150116154922.GB4650@dhcp22.suse.cz>
 <54BA7D3A.40100@codeaurora.org>
 <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501171347290.25464@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mgorman@suse.de, minchan@kernel.org

On Sat 17-01-15 13:48:34, Christoph Lameter wrote:
> On Sat, 17 Jan 2015, Vinayak Menon wrote:
> 
> > which had not updated the vmstat_diff. This CPU was in idle for around 30
> > secs. When I looked at the tvec base for this CPU, the timer associated with
> > vmstat_update had its expiry time less than current jiffies. This timer had
> > its deferrable flag set, and was tied to the next non-deferrable timer in the
> 
> We can remove the deferrrable flag now since the vmstat threads are only
> activated as necessary with the recent changes. Looks like this could fix
> your issue?

OK, I have checked the history and the deferrable behavior has been
introduced by 39bf6270f524 (VM statistics: Make timer deferrable) which
hasn't offered any numbers which would justify the change. So I think it
would be a good idea to revert this one as it can clearly cause issues.

Could you retest with this change? It still wouldn't help with the
highly overloaded workqueues but that sounds like a bigger change and
this one sounds like quite safe to me so it is a good start.
---
