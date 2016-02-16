Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 336B06B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 03:36:11 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id g62so180363284wme.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 00:36:11 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id ll4si47162700wjb.130.2016.02.16.00.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 00:36:10 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id g62so93938350wme.1
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 00:36:10 -0800 (PST)
Date: Tue, 16 Feb 2016 09:36:06 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 02/33] mm: overload get_user_pages() functions
Message-ID: <20160216083606.GB3335@gmail.com>
References: <20160212210152.9CAD15B0@viggo.jf.intel.com>
 <20160212210155.73222EE1@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160212210155.73222EE1@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz


* Dave Hansen <dave@sr71.net> wrote:

> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> The concept here was a suggestion from Ingo.  The implementation
> horrors are all mine.
> 
> This allows get_user_pages(), get_user_pages_unlocked(), and
> get_user_pages_locked() to be called with or without the
> leading tsk/mm arguments.  We will give a compile-time warning
> about the old style being __deprecated and we will also
> WARN_ON() if the non-remote version is used for a remote-style
> access.

So at minimum this should be WARN_ON_ONCE(), to make it easier to recover some 
meaningful kernel log from such incidents.

But:

> Doing this, folks will get nice warnings and will not break the
> build.  This should be nice for -next and will hopefully let
> developers fix up their own code instead of maintainers needing
> to do it at merge time.
> 
> The way we do this is hideous.  It uses the __VA_ARGS__ macro
> functionality to call different functions based on the number
> of arguments passed to the macro.
> 
> There's an additional hack to ensure that our EXPORT_SYMBOL()
> of the deprecated symbols doesn't trigger a warning.
> 
> We should be able to remove this mess as soon as -rc1 hits in
> the release after this is merged.

So when I suggested this then it looked a _lot_ cleanear to me, in my head!

OTOH this, if factored out a bit perhaps, could be the basis for a useful 
technical model to do 'phased in, -next invariant' prototype migrations in the 
future, especially when it involves lots of subsystems.

Strictly only in cases where -rc1 will truly get rid of the __VA_ARGS__ hackery - 
which we'd do in this case.

Nevertheless I'd love to have a high level buy-in from either Linus or Andrew that 
we can do it this way, as the hackery looks very hideous...

The alternative would be to allow the -next churn and to allow the occasional 
(fairly trivial but tester-disruptive) build breakage.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
