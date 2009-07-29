Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B8B406B004F
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 10:11:13 -0400 (EDT)
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n6TEBDHl029700
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 07:11:14 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by zps78.corp.google.com with ESMTP id n6TEBAKO016133
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 07:11:11 -0700
Received: by pzk30 with SMTP id 30so555019pzk.5
        for <linux-mm@kvack.org>; Wed, 29 Jul 2009 07:11:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090729114322.GA9335@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
	 <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
	 <20090729114322.GA9335@localhost>
Date: Wed, 29 Jul 2009 07:11:10 -0700
Message-ID: <33307c790907290711s320607b0i79c939104d4c2d61@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

> --- mm.orig/fs/fs-writeback.c
> +++ mm/fs/fs-writeback.c
> @@ -325,7 +325,8 @@ __sync_single_inode(struct inode *inode,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * soon as=
 the queue becomes uncongested.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode->i_s=
tate |=3D I_DIRTY_PAGES;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wbc->nr=
_to_write <=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (wbc->nr=
_to_write <=3D 0 ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 wbc=
->encountered_congestion) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 * slice used up: queue for next turn
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 */
>

That's not sufficient - it only the problem in the wb_kupdate path. If you =
want
to be more conservative, how about we do this?

--- linux-2.6.30/fs/fs-writeback.c.old  2009-07-29 00:08:29.000000000 -0700
+++ linux-2.6.30/fs/fs-writeback.c      2009-07-29 07:08:48.000000000 -0700
@@ -323,43 +323,14 @@ __sync_single_inode(struct inode *inode,
                         * We didn't write back all the pages.  nfs_writepa=
ges(
)
                         * sometimes bales out without doing anything. Redi=
rty
                         * the inode; Move it from s_io onto s_more_io/s_di=
rty.
+                        * It may well have just encountered congestion
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
 som
e
-                                * writeout.  Otherwise heavy writing to on=
e
-                                * file would indefinitely suspend writeout=
 of
-                                * all the other files.
-                                */
-                               inode->i_state |=3D I_DIRTY_PAGES;
+                       inode->i_state |=3D I_DIRTY_PAGES;
+                       if (wbc->nr_to_write <=3D 0 ||     /* sliced used u=
p */
+                            wbc->encountered_congestion)
+                               requeue_io(inode);
+                       else {
+                               /* somehow blocked: retry later */
                                redirty_tail(inode);
                        }
                } else if (inode->i_state & I_DIRTY) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
