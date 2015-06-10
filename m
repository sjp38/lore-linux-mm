Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1B56B0072
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 05:08:20 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so40339004wib.1
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:08:19 -0700 (PDT)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id gd5si16603298wjb.115.2015.06.10.02.08.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 02:08:18 -0700 (PDT)
Received: by wgez8 with SMTP id z8so30624447wge.0
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 02:08:18 -0700 (PDT)
Date: Wed, 10 Jun 2015 11:08:13 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/3] TLB flush multiple pages per IPI v5
Message-ID: <20150610090813.GA30359@gmail.com>
References: <1433767854-24408-1-git-send-email-mgorman@suse.de>
 <20150608174551.GA27558@gmail.com>
 <20150609084739.GQ26425@suse.de>
 <20150609103231.GA11026@gmail.com>
 <20150609112055.GS26425@suse.de>
 <20150609124328.GA23066@gmail.com>
 <20150609130536.GT26425@suse.de>
 <20150610085141.GA25704@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150610085141.GA25704@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Ingo Molnar <mingo@kernel.org> wrote:

> Stop this crap.
> 
> I made a really clear and unambiguous chain of arguments:
> 
>  - I'm unconvinced about the benefits of INVLPG in general, and your patches adds
>    a whole new bunch of them. [...]

... and note that your claim that 'we were doing them before, this is just an 
equivalent transformation' is utter bullsh*t technically: what we were doing 
previously was a hideously expensive IPI combined with an INVLPG.

The behavior was dominated by the huge overhead of the remote flushing IPI, which 
does not prove or disprove either your or my opinion!

Preserving that old INVLPG logic without measuring its benefits _again_ would be 
cargo cult programming.

So I think this should be measured, and I don't mind worst-case TLB trashing 
measurements, which would be relatively straightforward to construct and the 
results should be unambiguous.

The batching limit (which you set to 32) should then be tuned by comparing it to a 
working full-flushing batching logic, not by comparing it to the previous single 
IPI per single flush approach!

... and if the benefits of a complex algorithm are not measurable and if there are 
doubts about the cost/benefit tradeoff then frankly it should not exist in the 
kernel in the first place. It's not like the Linux TLB flushing code is too boring 
due to overwhelming simplicity.

and yes, it's my job as a maintainer to request measurements justifying complexity 
and your ad hominem attacks against me are disgusting - you should know better.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
