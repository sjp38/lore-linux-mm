Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B300D8D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 05:53:32 -0400 (EDT)
Received: by ewy9 with SMTP id 9so239646ewy.14
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 02:53:29 -0700 (PDT)
Subject: Re: [PATCH 0/1] mm: make read-only accessors take const pointer
 parameters
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
In-Reply-To: <20110415160957.GV15707@random.random>
References: <1302861377-8048-1-git-send-email-ext-phil.2.carmody@nokia.com>
	 <20110415145133.GO15707@random.random>
	 <20110415155916.GD7112@esdhcp04044.research.nokia.com>
	 <20110415160957.GV15707@random.random>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Apr 2011 12:28:37 +0300
Message-ID: <1303291717.2700.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Phil Carmody <ext-phil.2.carmody@nokia.com>, akpm@linux-foundation.org, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2011-04-15 at 18:09 +0200, Andrea Arcangeli wrote:
> On Fri, Apr 15, 2011 at 06:59:16PM +0300, Phil Carmody wrote:
> > of these functions to propagate constness up another layer. It was
> > probably in FUSE, as that's the warning at the top of my screen
> > currently.
> 
> These function themselfs are inline too, so gcc already can see if
> memory has been modified inside the inline function, so it shouldn't
> provide an advantage. It would provide an advantage if page_count and
> friends weren't inline.
> 
> > I think gcc itself is smart enough to have already concluded what it 
> > can and it will not immediately benefit the build from just this change.
> 
> Hmm not sure... but I would hope it is smart enough already with
> inline (it should never be worse to inline than encoding the whole
> thing by hand in the caller, so skipping the function call
> alltogether which then wouldn't require any const).
> 
> > I don't think the static analysis tools are as smart as gcc though, by
> > any means. GCC actually inlines, so everything is visible to it. The
> > static analysis tools only remember the subset of information that they
> > think is useful, and apparently 'didn't change anything, even though it 
> > could' isn't considered so useful.
> > 
> > I'm just glad this wasn't an insta-nack, as I am quite a fan of consts,
> > and hopefully something can be worked out.
> 
> I'm not against it if it's from code strict point of view, I was
> mostly trying to understand if this could have any impact, in which
> case it wouldn't be false positive. I think it's a false positive if
> gcc is as smart as I hope it to be. If we want it from coding style
> reasons to keep the code more strict that's fine with me of course.

I think it is good when small core functions like this are strict and
use 'const' whenever possible, even though 'const' is so imperfect in C.

Let me give an example from my own experience. I was writing code which
was using the kernel RB trees, and I was trying to be strict and use
'const' whenever possible. But because the core functions like 'rb_next'
do not have 'const' modifier, I could not use const in many many places
of my code, because gcc was yelling. And I was not very enthusiastic to
touch the RB-tree code that time.

So the outline is that when core functions are not strict, they force
the upper layers to not use 'const' so making the linux less strict
overall, and making gcc _potential_ to optimize less.

The kernel is large and complex, if if today we do not see any apparent
optimization out of this, to tomorrow when the code changes, new clients
come to the picture - we might get it!

Hence,

Acked-by: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>

And

Thanks-by: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>

P.S.: Phil, probably you've noticed my hint about the RB-trees? :-)

-- 
Best Regards,
Artem Bityutskiy (D?N?N?N?D 1/4  D?D,N?N?N?DoD,D1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
