Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 981AD5F0003
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:17:33 -0400 (EDT)
Date: Tue, 2 Jun 2009 17:17:29 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602151729.GC17448@wotan.suse.de>
References: <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601183225.GS1065@one.firstfloor.org> <20090602120042.GB1392@wotan.suse.de> <20090602124757.GG1065@one.firstfloor.org> <20090602125713.GG1392@wotan.suse.de> <20090602134659.GA21338@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602134659.GA21338@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02, 2009 at 09:46:59PM +0800, Wu Fengguang wrote:
> On Tue, Jun 02, 2009 at 08:57:13PM +0800, Nick Piggin wrote:
> > Obviously I don't mean just use that single call for the entire
> > handler. You can set the EIO bit or whatever you like. The
> > "error handling" you have there also seems strange. You could
> > retain it, but the page is assured to be removed from pagecache.
> 
> You mean this?
> 
>         if (page_has_private(p) && !try_to_release_page(p, GFP_NOIO))
>                 return FAILED;
> 
> If page->private cannot be removed, that means some fs may start IO on it, so
> we return FAILED.

Hmm, if you're handling buffercache here then possibly yes.
But if you throw out dirty buffer cache then you're probably
corrupting your filesystem just as bad (or even worse than
a couple of bits flipped). Just seems ad-hoc.

I guess it is best-effort in most places though, and this
doesn't take much effort. But due to being best effort
means that it is hard for someone who knows exactly what all
the code does, to know what your intentions or intended
semantics are in places like this. So short comments would help,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
