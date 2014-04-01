Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id BA99A6B0031
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 14:43:12 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id lf12so10058239vcb.39
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 11:43:12 -0700 (PDT)
Received: from mail-vc0-x229.google.com (mail-vc0-x229.google.com [2607:f8b0:400c:c03::229])
        by mx.google.com with ESMTPS id cm9si3864380vcb.46.2014.04.01.11.43.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 11:43:11 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id ik5so10389117vcb.14
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 11:43:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <533B0301.3010507@citrix.com>
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com>
	<1395425902-29817-3-git-send-email-david.vrabel@citrix.com>
	<533016CB.4090807@citrix.com>
	<CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
	<CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
	<20140331122625.GR25087@suse.de>
	<CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
	<533B0301.3010507@citrix.com>
Date: Tue, 1 Apr 2014 11:43:11 -0700
Message-ID: <CA+55aFw2wReYNaxtTRYjEWTRsV=bMAFq8YK3=qX-PCvQjY72Kw@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: Mel Gorman <mgorman@suse.de>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Tue, Apr 1, 2014 at 11:18 AM, David Vrabel <david.vrabel@citrix.com> wrote:
>
> I don't think it's sufficient to avoid collisions with bits used only
> with P=0.  The original value of this bit must be retained when the
> _PAGE_NUMA bit is set/cleared.
>
> Bit 7 is PAT[2] and whilst Linux currently sets up the PAT such that
> PAT[2] is a 'don't care', there has been talk up adjusting the PAT to
> include more types. So I'm not sure it's a good idea to use bit 7.
>
> What's wrong with using e.g., bit 62? And not supporting this NUMA
> rebalancing feature on 32-bit non-PAE builds?

Sounds good to me, but it's not available in 32-bit PAE. The high bits
are all reserved, afaik.

But you'd have to be insane to care about NUMA balancing on 32-bit,
even with PAE. So restricting it to x86-64 and using the high bits (I
think bits 52-62 are all available to SW) sounds fine to me.

Same goes for soft-dirty. I think it's fine if we say that you won't
have soft-dirty with a 32-bit kernel. Even with PAE.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
