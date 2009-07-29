Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 056426B004F
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 03:15:52 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n6T7Fr5Q011135
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 08:15:54 +0100
Received: from pzk41 (pzk41.prod.google.com [10.243.19.169])
	by spaceape11.eur.corp.google.com with ESMTP id n6T7FnlG005418
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 00:15:50 -0700
Received: by pzk41 with SMTP id 41so392141pzk.30
        for <linux-mm@kvack.org>; Wed, 29 Jul 2009 00:15:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
Date: Wed, 29 Jul 2009 00:15:48 -0700
Message-ID: <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Chad Talbott <ctalbott@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 28, 2009 at 2:49 PM, Martin Bligh<mbligh@google.com> wrote:
>> An interesting recent-ish change is "writeback: speed up writeback of
>> big dirty files." =A0When I revert the change to __sync_single_inode the
>> problem appears to go away and background writeout proceeds at disk
>> speed. =A0Interestingly, that code is in the git commit [2], but not in
>> the post to LKML. [3] =A0This is may not be the fix, but it makes this
>> test behave better.
>
> I'm fairly sure this is not fixing the root cause - but putting it at the=
 head
> rather than the tail of the queue causes the error not to starve wb_kupda=
te
> for nearly so long - as long as we keep the queue full, the bug is hidden=
.

OK, it seems this is the root cause - I wasn't clear why all the pages were=
n't
being written back, and thought there was another bug. What happens is
we go into write_cache_pages, and stuff the disk queue with as much as
we can put into it, and then inevitably hit the congestion limit.

Then we back out to __sync_single_inode, who says "huh, you didn't manage
to write your whole slice", and penalizes the poor blameless inode in quest=
ion
by putting it back into the penalty box for 30s.

This results in very lumpy I/O writeback at 5s intervals, and very
poor throughput.

Patch below is inline and probably text munged, but is for RFC only.
I'll test it
more thoroughly tomorrow. As for the comment about starving other writes,
I believe requeue_io moves it from s_io to s_more_io which should at least
allow some progress of other files.

--- linux-2.6.30/fs/fs-writeback.c.old  2009-07-29 00:08:29.000000000 -0700
+++ linux-2.6.30/fs/fs-writeback.c      2009-07-29 00:11:28.000000000 -0700
@@ -322,46 +322,11 @@ __sync_single_inode(struct inode *inode,
                        /*
                         * We didn't write back all the pages.  nfs_writepa=
ges()
                         * sometimes bales out without doing anything. Redi=
rty
-                        * the inode; Move it from s_io onto s_more_io/s_di=
rty.
+                        * the inode; Move it from s_io onto s_more_io. It
+                        * may well have just encountered congestion
                         */
-                       /*
-                        * akpm: if the caller was the kupdate function we =
put
-                        * this inode at the head of s_dirty so it gets fir=
st
-                        * consideration.  Otherwise, move it to the tail, =
for
-                        * the reasons described there.  I'm not really sur=
e
-                        * how much sense this makes.  Presumably I had a g=
ood
-                        * reasons for doing it this way, and I'd rather no=
t
-                        * muck with it at present.
-                        */
-                       if (wbc->for_kupdate) {
-                               /*
-                                * For the kupdate function we move the ino=
de
-                                * to s_more_io so it will get more writeou=
t as
-                                * soon as the queue becomes uncongested.
-                                */
-                               inode->i_state |=3D I_DIRTY_PAGES;
-                               if (wbc->nr_to_write <=3D 0) {
-                                       /*
-                                        * slice used up: queue for next tu=
rn
-                                        */
-                                       requeue_io(inode);
-                               } else {
-                                       /*
-                                        * somehow blocked: retry later
-                                        */
-                                       redirty_tail(inode);
-                               }
-                       } else {
-                               /*
-                                * Otherwise fully redirty the inode so tha=
t
-                                * other inodes on this superblock will get=
 some
-                                * writeout.  Otherwise heavy writing to on=
e
-                                * file would indefinitely suspend writeout=
 of
-                                * all the other files.
-                                */
-                               inode->i_state |=3D I_DIRTY_PAGES;
-                               redirty_tail(inode);
-                       }
+                       inode->i_state |=3D I_DIRTY_PAGES;
+                       requeue_io(inode);
                } else if (inode->i_state & I_DIRTY) {
                        /*
                         * Someone redirtied the inode while were writing b=
ack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
