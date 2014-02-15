Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f180.google.com (mail-ve0-f180.google.com [209.85.128.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2FF6B0036
	for <linux-mm@kvack.org>; Sat, 15 Feb 2014 18:50:30 -0500 (EST)
Received: by mail-ve0-f180.google.com with SMTP id db12so11025118veb.11
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 15:50:30 -0800 (PST)
Received: from mail-vc0-x22e.google.com (mail-vc0-x22e.google.com [2607:f8b0:400c:c03::22e])
        by mx.google.com with ESMTPS id f7si3328876vcz.57.2014.02.15.15.50.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 15 Feb 2014 15:50:29 -0800 (PST)
Received: by mail-vc0-f174.google.com with SMTP id im17so10353978vcb.19
        for <linux-mm@kvack.org>; Sat, 15 Feb 2014 15:50:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140214002427.GN13997@dastard>
References: <20140211210841.GM13647@dastard>
	<52FA9ADA.9040803@sandeen.net>
	<20140212004403.GA17129@redhat.com>
	<20140212010941.GM18016@ZenIV.linux.org.uk>
	<CA+55aFwoWT-0A_KTkXMkNqOy8hc=YmouTMBgWUD_z+8qYPphjA@mail.gmail.com>
	<20140212040358.GA25327@redhat.com>
	<20140212042215.GN18016@ZenIV.linux.org.uk>
	<20140212054043.GB13997@dastard>
	<CA+55aFxy2t7bnCUc-DhhxYxsZ0+GwL9GuQXRYtE_VzqZusmB9A@mail.gmail.com>
	<20140212071829.GE13997@dastard>
	<20140214002427.GN13997@dastard>
Date: Sat, 15 Feb 2014 15:50:29 -0800
Message-ID: <CA+55aFx=i6dbzCUZ6TwCMqniyS4C=tJx9+72p=EA+dU8Vn=2jQ@mail.gmail.com>
Subject: Re: 3.14-rc2 XFS backtrace because irqs_disabled.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Eric Sandeen <sandeen@sandeen.net>, Linux Kernel <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com

[ Added linux-mm to the participants list ]

On Thu, Feb 13, 2014 at 4:24 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Dave, the patch below should chop off the stack usage from
> xfs_log_force_lsn() issuing IO by deferring it to the CIL workqueue.
> Can you given this a run?

Ok, so DaveJ confirmed that DaveC's patch fixes his issue (damn,
people, your parents were some seriously boring people, were they not?
We've got too many Dave's around), but DaveC earlier pointed out that
pretty much any memory allocation path can end up using 3kB of stack
even without XFS being involved.

Which does bring up the question whether we should look (once more) at
the VM direct-reclaim path, and try to avoid GFP_FS/IO direct
reclaim..

Direct reclaim historically used to be an important throttling
mechanism, and I used to not be a fan of trying to avoid direct
reclaim. But the stack depth issue really looks to be pretty bad, and
I think we've gotten better at throttling explicitly, so..

I *think* we already limit filesystem writeback to just kswapd (in
shrink_page_list()), but DaveC posted a backtrace that goes through
do_try_to_free_pages() to shrink_slab(), and through there to the
filesystem and then IO. That looked like a disaster.

And that's because (if I read things right) shrink_page_list() limits
filesystem page writeback to kswapd, but not swap pages. Which I think
probably made more sense back in the days than it does now (I
certainly *hope* that swapping is less important today than it was,
say, ten years ago)

So I'm wondering whether we should remove that page_is_file_cache()
check from shrink_page_list()?

And then there is that whole shrink_slab() case...

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
