Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C32E6B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 01:52:50 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBJ6rEDT002955
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 23:53:14 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBJ6sw4c191006
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 23:54:58 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBJ6sweU021523
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 23:54:58 -0700
Subject: Re: [rfc][patch 1/2] mnt_want_write speedup 1
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081219061937.GA16268@wotan.suse.de>
References: <20081219061937.GA16268@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 18 Dec 2008 22:54:57 -0800
Message-Id: <1229669697.17206.602.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2008-12-19 at 07:19 +0100, Nick Piggin wrote:
> @@ -369,24 +283,34 @@ static int mnt_make_readonly(struct vfsm
>  {
>         int ret = 0;
> 
> -       lock_mnt_writers();
> +       spin_lock(&vfsmount_lock);
> +       mnt->mnt_flags |= MNT_WRITE_HOLD;
>         /*
> -        * With all the locks held, this value is stable
> +        * After storing MNT_WRITE_HOLD, we'll read the counters. This store
> +        * should be visible before we do.
>          */
> -       if (atomic_read(&mnt->__mnt_writers) > 0) {
> +       smp_mb();
> +
> +       /*
> +        * With writers on hold, if this value is zero, then there are definitely
> +        * no active writers (although held writers may subsequently increment
> +        * the count, they'll have to wait, and decrement it after seeing
> +        * MNT_READONLY).
> +        */
> +       if (count_mnt_writers(mnt) > 0) {
>                 ret = -EBUSY;

OK, I think this is one of the big races inherent with this approach.
There's nothing in here to ensure that no one is in the middle of an
update during this code.  The preempt_disable() will, of course, reduce
the window, but I think there's still a race here.

Is this where you wanted to put the synchronize_rcu()?  That's a nice
touch because although *that* will ensure that no one is in the middle
of an increment here and that they will, at worst, be blocking on the
MNT_WRITE_HOLD thing.

I kinda remember going down this path a few times, bu you may have
cracked the problem.  Dunno.  I need to stare at the code a bit more
before I'm convinced.  I'm optimistic, but a bit skeptical this can
work. :)

I am really wondering where all the cost is that you're observing in
those benchmarks.  Have you captured any profiles by chance?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
