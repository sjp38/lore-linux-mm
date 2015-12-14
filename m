Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 45BAD6B0257
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:40:58 -0500 (EST)
Received: by obciw8 with SMTP id iw8so134040060obc.1
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:40:58 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id o7si7887894obi.38.2015.12.14.07.40.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 07:40:57 -0800 (PST)
Date: Mon, 14 Dec 2015 16:32:34 +0100
From: Quentin Casasnovas <quentin.casasnovas@oracle.com>
Subject: Re: [RFC 1/2] [RFC] mm: Account anon mappings as RLIMIT_DATA
Message-ID: <20151214153234.GE3604@chrystal.uk.oracle.com>
References: <20151213201646.839778758@gmail.com>
 <20151214145126.GC3604@chrystal.uk.oracle.com>
 <20151214151116.GE14045@uranus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151214151116.GE14045@uranus>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Mon, Dec 14, 2015 at 06:11:16PM +0300, Cyrill Gorcunov wrote:
> On Mon, Dec 14, 2015 at 03:51:26PM +0100, Quentin Casasnovas wrote:
> ...
> > 
> > Do we want to fold may_expand_anon_vm() into may_expand_vm() (potentially
> > passing it the flags/struct file if needed) so there is just one such
> > helper function?  Rationale being that it then gets hard to see what
> > restricts what, and it's easy to miss one place.
> 
> I tried to make the patch small as possible (because otherwise indeed
> I would have to pass @vm_file|@file as additional argument). This won't
> be a problem but may_expand_vm is called way more times than
> may_expand_anon_vm. That's the only rationale I followed.
>
> > For example, I couldn't find anything preventing a user to
> > mmap(MAP_GROWSDOWN) and uses that as a base to get pages that would not be
> > accounted for in your patch (making it a poor-man mremap()).
> 
> growsup/down stand for stack usage iirc, so it was intentionally
> not accounted here.
>

Right, but in the same vein of Linus saying RLIMIT_DATA is/was useless
because everyone could use mmap() instead of brk() to get anonymous memory,
what's the point of restricting "almost-all" anonymous memory if one can
just use MAP_GROWSDOWN/UP and cause repeated page faults to extend that
mapping, circumventing your checks?  That makes the new restriction as
useless as what RLIMIT_DATA used to be, doesn't it?

> > 
> > I only had a quick look so apologies if this is handled and I missed it :)
> 
> thanks for feedback! also take a look on Kostya's patch, I think it's
> even better approach (and I like it more than mine).

Ha I'm not subscribed to LKML so I missed those, I suppose you can ignore
my comments then! :)

Quentin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
