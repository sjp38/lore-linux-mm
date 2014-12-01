Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C25106B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 22:50:37 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so10202889pab.16
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 19:50:37 -0800 (PST)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id bn4si26949622pbd.38.2014.11.30.19.50.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 30 Nov 2014 19:50:36 -0800 (PST)
Received: by mail-pd0-f181.google.com with SMTP id v10so4718050pde.40
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 19:50:35 -0800 (PST)
Date: Sun, 30 Nov 2014 19:50:26 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC v6 1/2] mm: prototype: rid swapoff of quadratic
 complexity
In-Reply-To: <20141112025724.GA7443@kelleynnn-virtual-machine>
Message-ID: <alpine.LSU.2.11.1411301843440.1043@eggly.anvils>
References: <20141112025724.GA7443@kelleynnn-virtual-machine>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>
Cc: linux-mm@kvack.org, riel@surriel.com, riel@redhat.com, opw-kernel@googlegroups.com, hughd@google.com, akpm@linux-foundation.org, jamieliu@google.com, sjenning@linux.vnet.ibm.com, sarah.a.sharp@intel.com

On Tue, 11 Nov 2014, Kelley Nielsen wrote:

> Changes since v5:
> * Make multiple orphan checking passes at the end of try_to_unuse
> * Remove pages from swapcache if we hold the only reference in
> * unuse_pte_range

I'm very glad you're back on this, Kelley, thank you.

I gave it a try this weekend, and at first I was very pleased with
the results - up until make died with an unexplained SIGSEGV, but
that was only after several hours (an unexplained SIGSEGV usually
means a swap error of some kind in my testing).

At the time I put that down to bringing KSM in, and I wasn't
expecting KSM to be right yet anyway.  But after looking at the code,
I was a little disappointed to find the MAX_RETRIES 3 stuff: and
there is a particular bug there which was probably responsible for
my SIGSEGV - when try_to_unuse() has done MAX_RETRIES and gives up,
it returns 0 pretending success: no, please make that, say, -EBUSY.

When I made that change, and at the same time switched from testing
swap on SSD to swap on HDD, it didn't go so well: the eighth swapoff
(under concurrent swapping load) then admitted that it had failed.

Even -EBUSY is not really right there: I do like your improvements,
and want to get them in, but it is a regression to fail under load
like that.  And I imagine that the bigger the swap area, or the
slower the disk, or the heavier the load, then the more likely a
failure is in that case.

It's good that you're now removing from swapcache when you can in
unuse_pte_range(), but that's just not enough: I'm pretty sure it
does need the rmap walk that I suggested back in April (and I'm
hopeful that with that, we could then get rid of those retries -
hopeful but far from certain).  So that a page can be taken out of
swap in one go, with no danger of being repeatedly refaulted in
behind you.

I'm not sure where you want to take it from here.  I'd be happy
for this to go into mmotm (with the changes Rik proposed for 2/2,
and the -EBUSY at MAX_RETRIES), so that it gets wider exposure
(few people will in practice be disadvantaged by that -EBUSY):
so long as one of us commits to fixing up the regression before
it goes to Linus.

I wonder what your time situation is: I wonder if you just haven't
found time to add the rmap walk, or are not confident in doing so.

To be honest, I'd rather like to do that bit myself: apart from
anything else, it is the only way in which I will properly get to
grips with your changes - I'm a coder not a reviewer.  But there
is no chance whatever that I'll get to do it before Christmas,
and whether I find time to do it then rather depends on what
else comes up that may demand higher priority.

And, I don't mean to pressure you with more than you have time for,
but if you do have time, please remember to remove the CONFIG_SHMEM
CONFIG_SWAP stuff from lib/radix-tree.c and radix-tree.h (Cc
Johannes Weiner <hannes@cmpxchg.org> and Konstantin Khlebnikov
<koct9i@gmail.com>, they will give a cheer), and rename all those
"unuse"s to "swapoff"s (Cc Oleg Nesterov <oleg@redhat.com> and
Pavel Machek <pavel@ucw.cz>) to be clearer, and to avoid
confusion with the other unuse_mm().

Of course, anyone can do those cleanups, if you don't have the time:
but you have earned the right, so I'd rather see them in your name.

By the way, I'll Cc you in a few moments on a swapoff fix I tracked
down last week: nothing to do with your changes or my testing of them,
but something I found in testing an unrelated patchset.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
