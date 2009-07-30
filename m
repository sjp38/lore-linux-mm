Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 44EAB6B007E
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 22:57:36 -0400 (EDT)
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n6U2vctt027607
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 03:57:41 +0100
Received: from wf-out-1314.google.com (wfa25.prod.google.com [10.142.1.25])
	by zps78.corp.google.com with ESMTP id n6U2vaBY032260
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 19:57:36 -0700
Received: by wf-out-1314.google.com with SMTP id 25so330691wfa.27
        for <linux-mm@kvack.org>; Wed, 29 Jul 2009 19:57:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090730020922.GD7326@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
	 <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
	 <20090729114322.GA9335@localhost>
	 <33307c790907291719r2caf7914xb543877464ba6fc2@mail.gmail.com>
	 <33307c790907291828x6906e874l4d75e695116aa874@mail.gmail.com>
	 <20090730020922.GD7326@localhost>
Date: Wed, 29 Jul 2009 19:57:35 -0700
Message-ID: <33307c790907291957n35c55afehfe809c6583b10a76@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chad Talbott <ctalbott@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, "sandeen@redhat.com" <sandeen@redhat.com>, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

> On closer looks I found this line:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (inode_dirtied_after(inode, start))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;

Ah, OK.

> In this case "list_empty(&sb->s_io)" is not a good criteria:
> here we are breaking away for some other reasons, and shall
> not touch wbc.more_io.
>
> So let's stick with the current code?

Well, I see two problems. One is that we set more_io based on
whether s_more_io is empty or not before we finish the loop.
I can't see how this can be correct, especially as there can be
other concurrent writers. So somehow we need to check when
we exit the loop, not during it.

The other is that we're saying we are setting more_io when
nr_to_write is <=3D0 ... but we only really check it when
nr_to_write is > 0 ... I can't see how this can be useful?
I'll admit there is one corner case when page_skipped it set
from one of the branches, but I am really not sure what the
intended logic is here, given the above?

In the case where we hit the inode_dirtied_after break
condition, is it bad to set more_io ? There is more to do
on that inode after all. Is there a definition somewhere for
exactly what the more_io flag means?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
