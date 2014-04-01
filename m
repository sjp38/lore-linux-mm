Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
	by kanga.kvack.org (Postfix) with ESMTP id 674A86B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:03:48 -0400 (EDT)
Received: by mail-la0-f49.google.com with SMTP id mc6so7283388lab.36
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 12:03:47 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id zv8si11371395lbb.209.2014.04.01.12.03.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 12:03:46 -0700 (PDT)
Received: by mail-la0-f47.google.com with SMTP id pn19so3078394lab.34
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 12:03:46 -0700 (PDT)
Date: Tue, 1 Apr 2014 23:03:44 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
Message-ID: <20140401190344.GX4872@moon>
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com>
 <1395425902-29817-3-git-send-email-david.vrabel@citrix.com>
 <533016CB.4090807@citrix.com>
 <CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
 <CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
 <20140331122625.GR25087@suse.de>
 <CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
 <533B0301.3010507@citrix.com>
 <CA+55aFw2wReYNaxtTRYjEWTRsV=bMAFq8YK3=qX-PCvQjY72Kw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFw2wReYNaxtTRYjEWTRsV=bMAFq8YK3=qX-PCvQjY72Kw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>
Cc: David Vrabel <david.vrabel@citrix.com>, Mel Gorman <mgorman@suse.de>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Tue, Apr 01, 2014 at 11:43:11AM -0700, Linus Torvalds wrote:
> On Tue, Apr 1, 2014 at 11:18 AM, David Vrabel <david.vrabel@citrix.com> wrote:
> >
> > I don't think it's sufficient to avoid collisions with bits used only
> > with P=0.  The original value of this bit must be retained when the
> > _PAGE_NUMA bit is set/cleared.
> >
> > Bit 7 is PAT[2] and whilst Linux currently sets up the PAT such that
> > PAT[2] is a 'don't care', there has been talk up adjusting the PAT to
> > include more types. So I'm not sure it's a good idea to use bit 7.
> >
> > What's wrong with using e.g., bit 62? And not supporting this NUMA
> > rebalancing feature on 32-bit non-PAE builds?
> 
> Sounds good to me, but it's not available in 32-bit PAE. The high bits
> are all reserved, afaik.
> 
> But you'd have to be insane to care about NUMA balancing on 32-bit,
> even with PAE. So restricting it to x86-64 and using the high bits (I
> think bits 52-62 are all available to SW) sounds fine to me.
> 
> Same goes for soft-dirty. I think it's fine if we say that you won't
> have soft-dirty with a 32-bit kernel. Even with PAE.

Well, at the moment we use soft-dirty for x86-64 only in criu but there
were plans to implement complete 32bit support as well. While personally
I don't mind dropping soft-dirty for non x86-64 case, I would like
to hear Pavel's opinion, Pavel?

(n.b, i'm still working on cleaning up _page bits, it appeared to
 be harder than I've been expecting).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
