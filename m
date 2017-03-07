Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 232256B038D
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 06:42:13 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 68so1354434ioh.4
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 03:42:13 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id q63si127931iof.61.2017.03.07.03.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 03:42:12 -0800 (PST)
Date: Tue, 7 Mar 2017 12:42:04 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 06/13] lockdep: Implement crossrelease feature
Message-ID: <20170307114204.GA3312@twins.programming.kicks-ass.net>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-7-git-send-email-byungchul.park@lge.com>
 <20170228134018.GK5680@worktop>
 <20170301054323.GE11663@X58A-UD3R>
 <20170301122843.GF6515@twins.programming.kicks-ass.net>
 <20170302134031.GG6536@twins.programming.kicks-ass.net>
 <20170303001737.GF28562@X58A-UD3R>
 <20170303081416.GT6515@twins.programming.kicks-ass.net>
 <20170305030845.GA11100@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170305030845.GA11100@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: mingo@kernel.org, tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com, kernel-team@lge.com, Michal Hocko <mhocko@kernel.org>, Nikolay Borisov <nborisov@suse.com>, Mel Gorman <mgorman@suse.de>

On Sun, Mar 05, 2017 at 12:08:45PM +0900, Byungchul Park wrote:
> On Fri, Mar 03, 2017 at 09:14:16AM +0100, Peter Zijlstra wrote:

> > 
> > Now the problem with the above condition is that it makes reports
> > harder to decipher, because by avoiding adding redundant links to our
> > graph we loose a possible shorter path.
> 
> Let's see the following example:
> 
>    A -> B -> C
> 
>    where A, B and C are typical lock class.
> 
> Assume the graph above was built and operations happena in the
> following order:
> 
>    CONTEXT X		CONTEXT Y
>    ---------		---------
>    acquire DX
> 			acquire A
> 			acquire B
> 			acquire C
> 
> 			release and commit DX
> 
>    where A, B and C are typical lock class, DX is a crosslock class.
> 
> The graph will grow as following _without_ prev_gen_id.
> 
>         -> A -> B -> C
>        /    /    /
>    DX -----------
> 
>    where A, B and C are typical lock class, DX is a crosslock class.
> 
> The graph will grow as following _with_ prev_gen_id.
> 
>    DX -> A -> B -> C
> 
>    where A, B and C are typical lock class, DX is a crosslock class.
> 
> You said the former is better because it has smaller cost in bfs.

No, I said the former is better because when you report a DX inversion
against C, A and B are not required and the report is easier to
understand by _humans_.

I don't particularly care about the BFS cost itself.

> But it has to use _much_ more memory to keep additional nodes in
> graph. Without exaggeration, every crosslock would get linked with all
> locks in history locks, on commit, unless redundant. It might be
> pretty more than we expect - I will check and let you know how many it
> is. Is it still good?

Dunno, probably not.. but it would be good to have numbers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
