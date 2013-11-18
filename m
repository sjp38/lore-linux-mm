Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 23A256B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 16:56:29 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fa1so7384009pad.16
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 13:56:28 -0800 (PST)
Received: from psmtp.com ([74.125.245.140])
        by mx.google.com with SMTP id vs7si10588767pbc.355.2013.11.18.13.56.26
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 13:56:27 -0800 (PST)
Date: Mon, 18 Nov 2013 16:56:18 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1384811778-7euptzgp-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <528A7D36.5020500@sr71.net>
References: <20131115225550.737E5C33@viggo.jf.intel.com>
 <20131115225553.B0E9DFFB@viggo.jf.intel.com>
 <1384800714-y653r3ch-mutt-n-horiguchi@ah.jp.nec.com>
 <1384800841-314l1f3e-mutt-n-horiguchi@ah.jp.nec.com>
 <528A6448.3080907@sr71.net>
 <1384806022-4718p9lh-mutt-n-horiguchi@ah.jp.nec.com>
 <528A7D36.5020500@sr71.net>
Subject: Re: [PATCH] mm: call cond_resched() per MAX_ORDER_NR_PAGES pages copy
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave.jiang@intel.com, akpm@linux-foundation.org, dhillf@gmail.com, Mel Gorman <mgorman@suse.de>

On Mon, Nov 18, 2013 at 12:48:54PM -0800, Dave Hansen wrote:
> On 11/18/2013 12:20 PM, Naoya Horiguchi wrote:
> >> > Really, though, a lot of things seem to have MAX_ORDER set up so that
> >> > it's at 256MB or 512MB.  That's an awful lot to do between rescheds.
> > Yes.
> > 
> > BTW, I found that we have the same problem for other functions like
> > copy_user_gigantic_page, copy_user_huge_page, and maybe clear_gigantic_page.
> > So we had better handle them too.
> 
> Is there a problem you're trying to solve here?  The common case of the
> cond_resched() call boils down to a read of a percpu variable which will
> surely be in the L1 cache after the first run around the loop.  In other
> words, it's about as cheap of an operation as we're going to get.

Yes, cond_resched() is cheap if should_resched() is false (and it is in
common case).

> Why bother trying to "optimize" it?

I thought that if we call cond_resched() too often, the copying thread can
take too long in a heavy load system, because the copying thread always
yields the CPU in every loop.

But it seems to be an extreme case, so I can't push it strongly.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
