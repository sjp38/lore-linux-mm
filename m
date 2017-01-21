Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34C146B0253
	for <linux-mm@kvack.org>; Sat, 21 Jan 2017 08:17:45 -0500 (EST)
Received: by mail-yw0-f197.google.com with SMTP id u8so86295407ywu.0
        for <linux-mm@kvack.org>; Sat, 21 Jan 2017 05:17:45 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id a2si2818491ybi.152.2017.01.21.05.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Jan 2017 05:17:44 -0800 (PST)
Date: Sat, 21 Jan 2017 08:16:44 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [ATTEND] many topics
Message-ID: <20170121131644.zupuk44p5jyzu5c5@thunk.org>
References: <20170118054945.GD18349@bombadil.infradead.org>
 <20170118133243.GB7021@dhcp22.suse.cz>
 <20170119110513.GA22816@bombadil.infradead.org>
 <20170119113317.GO30786@dhcp22.suse.cz>
 <20170119115243.GB22816@bombadil.infradead.org>
 <20170119121135.GR30786@dhcp22.suse.cz>
 <878tq5ff0i.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878tq5ff0i.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Michal Hocko <mhocko@kernel.org>, willy@bombadil.infradead.org, willy@infradead.org, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jan 21, 2017 at 11:11:41AM +1100, NeilBrown wrote:
> What are the benefits of GFP_TEMPORARY?  Presumably it doesn't guarantee
> success any more than GFP_KERNEL does, but maybe it is slightly less
> likely to fail, and somewhat less likely to block for a long time??  But
> without some sort of promise, I wonder why anyone would use the
> flag.  Is there a promise?  Or is it just "you can be nice to the MM
> layer by setting this flag sometimes". ???

My understanding is that the idea is to allow short-term use cases not
to be mixed with long-term use cases --- in the Java world, to declare
that a particular object will never be promoted from the "nursury"
arena to the "tenured" arena, so that we don't end up with a situation
where a page is used 90% for temporary objects, and 10% for a tenured
object, such that later on we have a page which is 90% unused.

Many of the existing users may in fact be for things like a temporary
bounce buffer for I/O, where declaring this to the mm system could
lead to less fragmented pages, but which would violate your proposed
contract:

>   GFP_TEMPORARY should be used when the memory allocated will either be
>   freed, or will be placed in a reclaimable cache, before the process
>   which allocated it enters an TASK_INTERRUPTIBLE sleep or returns to
>   user-space.  It allows access to memory which is usually reserved for
>   XXX and so can be expected to succeed more quickly during times of
>   high memory pressure.

I think what you are suggested is something very different, where you
are thinking that for *very* short-term usage perhaps we could have a
pool of memory, perhaps the same as the GFP_ATOMIC memory, or at least
similar in mechanism, where such usage could be handy.

Is there enough use cases where this would be useful?  In the local
disk backed file system world, I doubt it.  But maybe in the (for
example) NFS world, such a use would in fact be common enough that it
would be useful.

I'd suggest doing this though as a new category, perhaps
GFP_REALLY_SHORT_TERM, or GFP_MAYFLY for short.  :-)

		       	  	     	 	 - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
