Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8CD826B006A
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:58:42 -0400 (EDT)
Date: Tue, 2 Jun 2009 16:05:45 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler in the VM v3
Message-ID: <20090602140545.GP1065@one.firstfloor.org>
References: <20090601185147.GT1065@one.firstfloor.org> <20090602121031.GC1392@wotan.suse.de> <20090602123450.GF1065@one.firstfloor.org> <20090602123720.GF1392@wotan.suse.de> <20090602125538.GH1065@one.firstfloor.org> <20090602130306.GA6262@wotan.suse.de> <20090602132002.GJ1065@one.firstfloor.org> <20090602131937.GB6262@wotan.suse.de> <20090602134610.GO1065@one.firstfloor.org> <20090602134739.GA26982@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602134739.GA26982@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, riel@redhat.com, akpm@linux-foundation.org, chris.mason@oracle.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>

> I was kind of thinking about we could SIGKILL them as they try
> to access it or fsync it. But then the question is how long to
> keep SIGKILLing? At one end of the scale you could do stupid
> and simple and have another error flag in the mapping to do
> the SIGKILL just once for the next read/write/fsync etc. Or

It's pretty radical to SIGKILL on a IO error.

Perhaps we can make fsync give EIO again in this case 
with a new mapping flag. The question would be when
to clear that flag again. Probably devil in the details.

> at the other end, you keep the page in the pagecache and
> poisoned, and kill everyone until the page is explicitly truncated
> by userspace. I don't really know...

We do that for the swapcache to avoid a similar problem, but
it's more a hack than a good solution.  I think it would be
worse for the page cache, because if you stop the program
then there's no reason to keep that around.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
