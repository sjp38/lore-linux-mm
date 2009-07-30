Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C46226B00BB
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 21:28:05 -0400 (EDT)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n6U1SBHT021167
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 02:28:11 +0100
Received: from wf-out-1314.google.com (wfc25.prod.google.com [10.142.3.25])
	by spaceape10.eur.corp.google.com with ESMTP id n6U1S7VF027821
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 18:28:09 -0700
Received: by wf-out-1314.google.com with SMTP id 25so309645wfc.22
        for <linux-mm@kvack.org>; Wed, 29 Jul 2009 18:28:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <33307c790907291719r2caf7914xb543877464ba6fc2@mail.gmail.com>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
	 <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
	 <20090729114322.GA9335@localhost>
	 <33307c790907291719r2caf7914xb543877464ba6fc2@mail.gmail.com>
Date: Wed, 29 Jul 2009 18:28:07 -0700
Message-ID: <33307c790907291828x6906e874l4d75e695116aa874@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 29, 2009 at 5:19 PM, Martin Bligh<mbligh@google.com> wrote:
> BTW, can you explain this code at the bottom of generic_sync_sb_inodes
> for me?
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (wbc->nr_to_write <=3D 0) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0wbc->more_io =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> I don't understand why we are setting more_io here? AFAICS, more_io
> means there's more stuff to write ... I would think we'd set this if
> nr_to_write was > 0 ?
>
> Or just have the section below brought up above this
> break check and do:
>
> if (!list_empty(&sb->s_more_io) || !list_empty(&sb->s_io))
> =A0 =A0 =A0 =A0wbc->more_io =3D 1;
>
> Am I just misunderstanding the intent of more_io ?

I am thinking along the lines of:

@@ -638,13 +609,11 @@ sync_sb_inodes(struct super_block *sb, s
                iput(inode);
                cond_resched();
                spin_lock(&inode_lock);
-               if (wbc->nr_to_write <=3D 0) {
-                       wbc->more_io =3D 1;
+               if (wbc->nr_to_write <=3D 0)
                        break;
-               }
-               if (!list_empty(&sb->s_more_io))
-                       wbc->more_io =3D 1;
        }
+       if (!list_empty(&sb->s_more_io) || !list_empty(&sb->s_io)
+               wbc->more_io =3D 1;
        return;         /* Leave any unwritten inodes on s_io */
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
