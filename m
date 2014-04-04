Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id E151F6B0031
	for <linux-mm@kvack.org>; Fri,  4 Apr 2014 10:08:01 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id rl12so3387265iec.22
        for <linux-mm@kvack.org>; Fri, 04 Apr 2014 07:08:01 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id k5si5155884ige.44.2014.04.04.07.07.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Apr 2014 07:07:58 -0700 (PDT)
Date: Fri, 4 Apr 2014 16:07:32 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: msync: require either MS_ASYNC or MS_SYNC [resend]
Message-ID: <20140404140732.GG10526@twins.programming.kicks-ass.net>
References: <533B04A9.6090405@bbn.com>
 <20140402111032.GA27551@infradead.org>
 <1396439119.2726.29.camel@menhir>
 <533CA0F6.2070100@bbn.com>
 <533E5B7A.7030309@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533E5B7A.7030309@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Richard Hansen <rhansen@bbn.com>, Steven Whitehouse <swhiteho@redhat.com>, Christoph Hellwig <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Greg Troxel <gdt@ir.bbn.com>, bug-readline@gnu.org

On Fri, Apr 04, 2014 at 09:12:58AM +0200, Michael Kerrisk (man-pages) wrote:
> >   * Clearer intentions.  Looking at the existing code and the code
> >     history, the fact that flags=0 behaves like flags=MS_ASYNC appears
> >     to be a coincidence, not the result of an intentional choice.
> 
> Maybe. You earlier asserted that the semantics when flags==0 may have
> been different, prior to Peter Zijstra's patch,
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=204ec841fbea3e5138168edbc3a76d46747cc987
> .
> It's not clear to me that that is the case. But, it would be wise to
> CC the developer, in case he has an insight.

Right; so before that patch there appears to have been a difference.
The code looked like:

  if (flags & MS_ASYNC) {
  	balance_dirty_pages_ratelimited();
  } else if (flags & MS_SYNC) {
  	do_fsync()
  } else {
  	/* do nothing */
  }

Which would give the following semantics:

  msync(.flags = 0) -- scan PTEs and update dirty page accounting
  msync(.flags = MS_ASYNC) -- scan PTEs and dirty throttle
  msync(.flags = MS_SYNC) -- scan PTEs and flush dirty pages

However with the introduction of accurate dirty page accounting in
.19 we always had an accurate dirty page count and both .flags=0 and
.flags=MS_ASYNC turn into the same NO-OP.

Yielding todays state, where 0 and MS_ASYNC don't do anything much and
MS_SYNC issues the fsync() -- although I understand Willy recently
posted a patch to do a data-range-sync instead of the full fsync.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
