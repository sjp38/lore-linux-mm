Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 550436B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 16:33:15 -0400 (EDT)
Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id n6UKXCkd007083
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 21:33:12 +0100
Received: from pxi28 (pxi28.prod.google.com [10.243.27.28])
	by spaceape8.eur.corp.google.com with ESMTP id n6UKX9Te032441
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 13:33:10 -0700
Received: by pxi28 with SMTP id 28so558348pxi.28
        for <linux-mm@kvack.org>; Thu, 30 Jul 2009 13:33:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090730031927.GA17669@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <33307c790907281449k5e8d4f6cib2c93848f5ec2661@mail.gmail.com>
	 <33307c790907290015m1e6b5666x9c0014cdaf5ed08@mail.gmail.com>
	 <20090729114322.GA9335@localhost>
	 <33307c790907291719r2caf7914xb543877464ba6fc2@mail.gmail.com>
	 <33307c790907291828x6906e874l4d75e695116aa874@mail.gmail.com>
	 <20090730020922.GD7326@localhost>
	 <33307c790907291957n35c55afehfe809c6583b10a76@mail.gmail.com>
	 <20090730031927.GA17669@localhost>
Date: Thu, 30 Jul 2009 13:33:09 -0700
Message-ID: <33307c790907301333i28b571eat29460164d558d370@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Chad Talbott <ctalbott@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, "sandeen@redhat.com" <sandeen@redhat.com>, Michael Davidson <md@google.com>
List-ID: <linux-mm.kvack.org>

(BTW: background ... I'm not picking through this code for fun, I'm
trying to debug writeback problems introduced in our new kernel
that are affecting Google production workloads ;-))

>> Well, I see two problems. One is that we set more_io based on
>> whether s_more_io is empty or not before we finish the loop.
>> I can't see how this can be correct, especially as there can be
>> other concurrent writers. So somehow we need to check when
>> we exit the loop, not during it.
>
> It is correct inside the loop, however with some overheads.
>
> We put it inside the loop because sometimes the whole filesystem is
> skipped and we shall not set more_io on them whether or not s_more_io
> is empty.

My point was that you're setting more_io based on a condition
at a point in time that isn't when you return to the caller.

By the time you return to the caller (after several more loops
iterations), that condition may no longer be true.

One other way to address that would to be only to set if if we're
about to fall off the end of the loop, ie change it to:

if (!list_empty(&sb->s_more_io) && list_empty(&sb->s_io))
       wbc->more_io = 1;

>> The other is that we're saying we are setting more_io when
>> nr_to_write is <=0 ... but we only really check it when
>> nr_to_write is > 0 ... I can't see how this can be useful?
>
> That's the caller's fault - I guess the logic was changed a bit by
> Jens in linux-next. I noticed this just now. It shall be fixed.

I am guessing you're setting more_io here because we're stopping
because our slice expired, presumably without us completing
all the io there was to do? That doesn't seem entirely accurate,
we could have finished all the pending IO (particularly given that
we can go over nr_to_write somewhat and send it negative).
Hence, I though that checking whether s_more_io and s_io were
empty at the time of return might be a more accurate check,
but on the other hand they are shared lists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
