Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 327296B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 11:50:57 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so3318957wiv.9
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 08:50:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bl1si11576213wjb.144.2014.09.22.08.50.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Sep 2014 08:50:55 -0700 (PDT)
Date: Mon, 22 Sep 2014 11:50:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: lockless page counters
Message-ID: <20140922155049.GA6630@cmpxchg.org>
References: <1411132928-16143-1-git-send-email-hannes@cmpxchg.org>
 <20140922144436.GG336@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140922144436.GG336@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 22, 2014 at 04:44:36PM +0200, Michal Hocko wrote:
> On Fri 19-09-14 09:22:08, Johannes Weiner wrote:
> > Memory is internally accounted in bytes, using spinlock-protected
> > 64-bit counters, even though the smallest accounting delta is a page.
> > The counter interface is also convoluted and does too many things.
> > 
> > Introduce a new lockless word-sized page counter API, then change all
> > memory accounting over to it and remove the old one.  The translation
> > from and to bytes then only happens when interfacing with userspace.
> 
> Dunno why but I thought other controllers use res_counter as well. But
> this doesn't seem to be the case so this is perfectly reasonable way
> forward.

You were fooled by its generic name!  It really is a lot less generic
than what it was designed for, and there are no new users in sight.

> I have only glanced through the patch and it mostly seems good to me 
> (I have to look more closely on the atomicity of hierarchical operations).
> 
> Nevertheless I think that the counter should live outside of memcg (it
> is ugly and bad in general to make HUGETLB controller depend on MEMCG
> just to have a counter). If you made kernel/page_counter.c and led both
> containers select CONFIG_PAGE_COUNTER then you do not need a dependency
> on MEMCG and I would find it cleaner in general.

The reason I did it this way is because the hugetlb controller simply
accounts and limits a certain type of memory and in the future I would
like to make it a memcg extension, just like kmem and swap.

Once that is done, page counters can become fully private, but until
then I think it's a good idea to make them part of memcg to express
this relationship and to ensure we are moving in the same direction.

> > Aside from the locking costs, this gets rid of the icky unsigned long
> > long types in the very heart of memcg, which is great for 32 bit and
> > also makes the code a lot more readable.
> 
> Definitely. Nice work!

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
