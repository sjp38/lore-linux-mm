Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id E877D6B0037
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 11:41:08 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ik5so8483149vcb.14
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 08:41:08 -0700 (PDT)
Received: from mail-vc0-x234.google.com (mail-vc0-x234.google.com [2607:f8b0:400c:c03::234])
        by mx.google.com with ESMTPS id o2si656739vew.61.2014.03.31.08.41.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 31 Mar 2014 08:41:08 -0700 (PDT)
Received: by mail-vc0-f180.google.com with SMTP id lf12so8194943vcb.39
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 08:41:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140331122625.GR25087@suse.de>
References: <1395425902-29817-1-git-send-email-david.vrabel@citrix.com>
	<1395425902-29817-3-git-send-email-david.vrabel@citrix.com>
	<533016CB.4090807@citrix.com>
	<CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
	<CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
	<20140331122625.GR25087@suse.de>
Date: Mon, 31 Mar 2014 08:41:07 -0700
Message-ID: <CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Mon, Mar 31, 2014 at 5:26 AM, Mel Gorman <mgorman@suse.de> wrote:
>
> Ok, so how do you suggest that _PAGE_NUMA could have been implemented
> that did *not* use _PAGE_PROTNONE on x86, trapped a fault and was not
> expensive as hell to handle?

So on x86, the obvious model is to use another bit. We've got several.
The _PAGE_NUMA case only matters for when _PAGE_PRESENT is clear, and
when that bit is clear the hardware doesn't care about any of the
other bits. Currently we use:

  #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
  #define _PAGE_BIT_FILE          _PAGE_BIT_DIRTY

which are bits 8 and 6 respectively, afaik.

and the only rule is that (a) we should *not* use a bit we already use
when the page is not present (since that is ambiguous!) and (b) we
should *not* use a bit that is used by the swap index cases. I think
bit 7 should work, but maybe I missed something.

Can somebody tell me why _PAGE_NUMA is *not* that bit seven? Make
"pte_present()" on x86 just check all of the present/numa/protnone
bits, and if any of them is set, it's a "present" page.

Now, unlike x86, some other architectures do *not* have free bits, so
there may be problems elsewhere.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
