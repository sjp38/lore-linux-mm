Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id E4E7C82F66
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 15:29:38 -0400 (EDT)
Received: by qgev79 with SMTP id v79so158849333qge.0
        for <linux-mm@kvack.org>; Mon, 05 Oct 2015 12:29:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 9si24426521qhu.104.2015.10.05.12.29.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Oct 2015 12:29:38 -0700 (PDT)
Date: Mon, 5 Oct 2015 12:29:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-Id: <20151005122936.8a3b0fe21629390c9aa8bc2a@linux-foundation.org>
In-Reply-To: <20151005134713.GC7023@dhcp22.suse.cz>
References: <560D59F7.4070002@roeck-us.net>
	<20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
	<20151002072522.GC30354@dhcp22.suse.cz>
	<20151002134953.551e6379ee9f6b5a0aeb7af7@linux-foundation.org>
	<20151005134713.GC7023@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Guenter Roeck <linux@roeck-us.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Mon, 5 Oct 2015 15:47:13 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > The fourth best way of fixing this is a nasty short-term bodge, such a
> > the one you just sent ;) But if we're going to do this, it should be
> > the minimal bodge which fixes this deadlock.  Is it possible to come up
> > with a one-liner (plus suitable comment) to get us out of this mess?
> 
> Yes I do agree that the fix I am proposing is short-term but this seems
> like the easiest way to go for stable and older kernels that might be
> affected. I thought your proposal for mapping_gfp_constraint was exactly
> to have all such places annotated for an easier future transition to
> something more reasonable.

hm, OK, let's go that way.  But I expect this mess will continue to
float around for a long time - fixing it nicely will be somewhat
intrusive.

> > Longer-term I suggest we look at generalising the memalloc_noio_foo()
> > stuff so as to permit callers to mask off (ie: zero) __GFP_ flags in
> > callees.  I have a suspicion we should have done this 15 years ago
> > (which is about when I started wanting to do it).
> 
> I am not sure memalloc_noio_foo is a huge win. It is an easy hack where
> the whole allocation transaction is clear - like in the PM code. I am
> not sure this is true also for the FS.

mm..  I think it'll work out OK - a set/restore around particular
callsites.

It might get messy in core MM though.  Do we apply current->mask at the
very low levels of the page allocator?  If so, that might muck up
intermediate callers who are peeking into specific gfp_t flags.

Perhaps it would be better to apply the mask at the highest possible
level: wherever a function which was not passed a gfp_t decides to
create one.  Basically a grep for "GFP_".  But then we need to decide
*which* gfp_t-creators need the treatment.  All of them (yikes) or is
this mechanism only for called-via-address_space_operations code?  That
might work.

Maybe it would be better to add the gfp_t argument to the
address_space_operations.  At a minimum, writepage(), readpage(),
writepages(), readpages().  What a pickle.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
