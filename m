Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 461CB6B00A8
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 09:29:46 -0400 (EDT)
Received: by mail-la0-f52.google.com with SMTP id ec20so162067lab.11
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 06:29:45 -0700 (PDT)
Received: from mail-lb0-x22b.google.com (mail-lb0-x22b.google.com [2a00:1450:4010:c04::22b])
        by mx.google.com with ESMTPS id iz10si321911lbc.123.2014.04.02.06.29.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 06:29:44 -0700 (PDT)
Received: by mail-lb0-f171.google.com with SMTP id w7so157927lbi.16
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 06:29:43 -0700 (PDT)
Date: Wed, 2 Apr 2014 17:29:42 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 2/2] x86: use pv-ops in {pte,pmd}_{set,clear}_flags()
Message-ID: <20140402132942.GZ4872@moon>
References: <1395425902-29817-3-git-send-email-david.vrabel@citrix.com>
 <533016CB.4090807@citrix.com>
 <CAKbGBLiVqaHEOZx6y4MW4xDTUdKRhVLZXTTGiqYT7vuH2Wgeww@mail.gmail.com>
 <CA+55aFwEwUmLe+dsFghMcaXdG5LPZ_NcQeOU1zZvEf7rCPw5CQ@mail.gmail.com>
 <20140331122625.GR25087@suse.de>
 <CA+55aFwGF9G+FBH3a5L0hHkTYaP9eCAfUT+OwvqUY_6N6LcbaQ@mail.gmail.com>
 <533B0301.3010507@citrix.com>
 <CA+55aFw2wReYNaxtTRYjEWTRsV=bMAFq8YK3=qX-PCvQjY72Kw@mail.gmail.com>
 <20140401190344.GX4872@moon>
 <533BF59C.1080203@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533BF59C.1080203@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Vrabel <david.vrabel@citrix.com>, Mel Gorman <mgorman@suse.de>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, linux-mm <linux-mm@kvack.org>

On Wed, Apr 02, 2014 at 03:33:48PM +0400, Pavel Emelyanov wrote:
...
> >>
> >> But you'd have to be insane to care about NUMA balancing on 32-bit,
> >> even with PAE. So restricting it to x86-64 and using the high bits (I
> >> think bits 52-62 are all available to SW) sounds fine to me.
> >>
> >> Same goes for soft-dirty. I think it's fine if we say that you won't
> >> have soft-dirty with a 32-bit kernel. Even with PAE.
> > 
> > Well, at the moment we use soft-dirty for x86-64 only in criu but there
> > were plans to implement complete 32bit support as well. While personally
> > I don't mind dropping soft-dirty for non x86-64 case, I would like
> > to hear Pavel's opinion, Pavel?
> 
> We (Parallels) don't have plans on C/R on 32-bit kernels, but I speak only
> for Parallels. However, people I know who need 32-bit C/R use ARM :)

OK, since it's x86 specific I can prepare patch for dropping softdirty on
x86-32 (this will release ugly macros in file mapping a bit but not that
significantly).

Guys, while looking into how to re-define _PAGE bits for case where present
bit is dropped I though about the form like

#define _PAGE_BIT_FILE		(_PAGE_BIT_PRESENT + 1)	/* _PAGE_BIT_RW */
#define _PAGE_BIT_NUMA		(_PAGE_BIT_PRESENT + 2)	/* _PAGE_BIT_USER */
#define _PAGE_BIT_PROTNONE	(_PAGE_BIT_PRESENT + 3)	/* _PAGE_BIT_PWT */

and while _PAGE_BIT_FILE case should work (as well as swap pages), I'm not that
sure about the numa and protnone case. I fear there are some code paths which
depends on the former bits positions -- ie when

	PAGE_BIT_PROTNONE = _PAGE_BIT_NUMA = _PAGE_BIT_GLOBAL.

One of the _PAGE_BIT_GLOBAL user is the page attributes code. It seems to always check
_PAGE_BIT_PRESENT together with _PAGE_BIT_GLOBAL, so if _PAGE_BIT_PROTNONE get redefined
to a new value it should not fail. Thus main concern is protnone + numa code, which
I must admit I don't know well enough yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
