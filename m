Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AD24B600337
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 07:41:40 -0400 (EDT)
Received: from guests.acceleratorcentre.net ([209.222.173.41] helo=crashcourse.ca)
	by astoria.ccjclearline.com with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <rpjday@crashcourse.ca>)
	id 1NykgS-0007aC-Jc
	for linux-mm@kvack.org; Mon, 05 Apr 2010 07:41:36 -0400
Date: Mon, 5 Apr 2010 07:39:27 -0400 (EDT)
From: "Robert P. J. Day" <rpjday@crashcourse.ca>
Subject: a couple more oddities(?) in mm code
Message-ID: <alpine.LFD.2.00.1004050732180.5342@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


  (aside:  i am not trying to be an annoying pedant, i am merely
succeeding.  seriously, i'm currently working my way thru the MM code,
in a (possibly vain) attempt to finally understand it, and i
occasionally run across things that just look a bit, well, odd.  but
maybe it's just me.  let me know if any of this is inappropriate.)

  from filemap.c:

        if (!isblk) {
                /* FIXME: this is for backwards compatibility with 2.4 */

is there any compelling reason why any MM code still wants to be 2.4
backwards compatible?  aren't we past that point by now?

  also, from mmu_notifier.c, i find this *really* weird:

=============

int mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
{
        return do_mmu_notifier_register(mn, mm, 1);
}
EXPORT_SYMBOL_GPL(mmu_notifier_register);

/*
 * Same as mmu_notifier_register but here the caller must hold the
 * mmap_sem in write mode.
 */
int __mmu_notifier_register(struct mmu_notifier *mn, struct mm_struct *mm)
{
        return do_mmu_notifier_register(mn, mm, 0);
}
EXPORT_SYMBOL_GPL(__mmu_notifier_register);

=============

  as a general rule, i normally expect the difference between two
kernel routines, say, func() and __func(), to be that func() would be
the generally callable one, while __func() would be a lower-level one,
perhaps using func() as a more convenient wrapper.  but the above
shows that those two routines represent *different* invocations of
do_mmu_notifier_register().  that's just not a pattern i'm used to
seeing.  doesn't it kind of fly in the face of kernel coding
standards?

rday
--

========================================================================
Robert P. J. Day                               Waterloo, Ontario, CANADA

            Linux Consulting, Training and Kernel Pedantry.

Web page:                                          http://crashcourse.ca
Twitter:                                       http://twitter.com/rpjday
========================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
