Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53B5B6B03B5
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 14:03:05 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id c130so6284948ioe.19
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 11:03:05 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id 65si2644316itg.51.2017.04.11.11.03.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 11:03:03 -0700 (PDT)
Date: Tue, 11 Apr 2017 13:03:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <20170411164134.GA21171@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org>
References: <20170404151600.GN15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org> <20170404194220.GT15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org> <20170404201334.GV15132@dhcp22.suse.cz>
 <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com> <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com> <20170411141956.GP6729@dhcp22.suse.cz> <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
 <20170411164134.GA21171@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Apr 2017, Michal Hocko wrote:

> >
> > There is a flag SLAB_DEBUG_OBJECTS that is available for this check.
>
> Which is way too late, at least for the kfree path. page->slab_cache
> on anything else than PageSlab is just a garbage. And my understanding
> of the patch objective is to stop those from happening.

We are looking here at SLAB. SLUB code can legitimately have a compound
page there because large allocations fallback to the page allocator.

Garbage would be attempting to free a page that has !PageSLAB set but also
is no compound page. That condition is already checked in kfree() with a
BUG_ON() and that BUG_ON has been there for a long time. Certainly we can
make SLAB consistent if there is no check there already. Slab just
attempts a free on that object which will fail too.

So we are already handling that condition. Why change things? Add a BUG_ON
if you want to make SLAB consistent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
