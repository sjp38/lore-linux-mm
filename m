Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C8F846B04F0
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 07:32:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v60so31062239wrc.7
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 04:32:36 -0700 (PDT)
Received: from mail-wr0-x22c.google.com (mail-wr0-x22c.google.com. [2a00:1450:400c:c0c::22c])
        by mx.google.com with ESMTPS id 60si9701366wrj.58.2017.07.11.04.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 04:32:35 -0700 (PDT)
Received: by mail-wr0-x22c.google.com with SMTP id c11so179407077wrc.3
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 04:32:35 -0700 (PDT)
Date: Tue, 11 Jul 2017 12:32:33 +0100
From: Matt Fleming <matt@codeblueprint.co.uk>
Subject: Re: [PATCH v4 00/10] PCID and improved laziness
Message-ID: <20170711113233.GA19177@codeblueprint.co.uk>
References: <cover.1498751203.git.luto@kernel.org>
 <20170630124422.GA12077@codeblueprint.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170630124422.GA12077@codeblueprint.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Fri, 30 Jun, at 01:44:22PM, Matt Fleming wrote:
> On Thu, 29 Jun, at 08:53:12AM, Andy Lutomirski wrote:
> > *** Ingo, even if this misses 4.13, please apply the first patch before
> > *** the merge window.
> > 
> > There are three performance benefits here:
> > 
> > 1. TLB flushing is slow.  (I.e. the flush itself takes a while.)
> >    This avoids many of them when switching tasks by using PCID.  In
> >    a stupid little benchmark I did, it saves about 100ns on my laptop
> >    per context switch.  I'll try to improve that benchmark.
> > 
> > 2. Mms that have been used recently on a given CPU might get to keep
> >    their TLB entries alive across process switches with this patch
> >    set.  TLB fills are pretty fast on modern CPUs, but they're even
> >    faster when they don't happen.
> > 
> > 3. Lazy TLB is way better.  We used to do two stupid things when we
> >    ran kernel threads: we'd send IPIs to flush user contexts on their
> >    CPUs and then we'd write to CR3 for no particular reason as an excuse
> >    to stop further IPIs.  With this patch, we do neither.
> 
> Heads up, I'm gonna queue this for a run on SUSE's performance test
> grid.

FWIW, I didn't see any change in performance with this series on a
PCID-capable machine. On the plus side, I didn't see any weird-looking
bugs either.

Are your benchmarks available anywhere?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
