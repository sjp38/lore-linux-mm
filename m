Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id C192D6B0074
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 08:02:54 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id w8so421253qac.31
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 05:02:54 -0800 (PST)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com. [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id b4si6309231qge.4.2014.11.05.05.02.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 05:02:53 -0800 (PST)
Received: by mail-qc0-f179.google.com with SMTP id o8so463914qcw.10
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 05:02:53 -0800 (PST)
Date: Wed, 5 Nov 2014 08:02:47 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105130247.GA14386@htj.dyndns.org>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <2156351.pWp6MNRoWm@vostro.rjw.lan>
 <20141021141159.GE9415@dhcp22.suse.cz>
 <4766859.KSKPTm3b0x@vostro.rjw.lan>
 <20141021142939.GG9415@dhcp22.suse.cz>
 <20141104192705.GA22163@htj.dyndns.org>
 <20141105124620.GB4527@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141105124620.GB4527@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

Hello, Michal.

On Wed, Nov 05, 2014 at 01:46:20PM +0100, Michal Hocko wrote:
> As I've said I wasn't entirely happy with this half solution but it helped
> the current situation at the time. The full solution would require to

I don't think this helps the situation.  It just makes the bug more
obscure and the race window while reduced is still pretty big and
there seems to be an actual not too low chance of the bug triggering
out in the wild.  How does this level of obscuring help anything?  In
addition to making the bug more difficult to reproduce, it also adds a
bunch of code which *pretends* to address the issue but ultimately
just lowers visibility into what's going on and hinders tracking down
the issue when something actually goes wrong.  This is *NOT* making
the situation better.  The patch is net negative.

> I think the patch below should be safe. Would you prefer this solution
> instead? It is race free but there is the risk that exposing a lock which

Yes, this is an a lot saner approach in general.

> completely blocks OOM killer from the allocation path will kick us
> later.

Can you please spell it out?  How would it kick us?  We already have
oom_killer_disable/enable(), how is this any different in terms of
correctness from them?  Also, why isn't this part of
oom_killer_disable/enable()?  The way they're implemented is really
silly now.  It just sets a flag and returns whether there's a
currently running instance or not.  How were these even useful?  Why
can't you just make disable/enable to what they were supposed to do
from the beginning?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
