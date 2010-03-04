Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 17EFF6B0095
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 11:45:46 -0500 (EST)
Date: Thu, 4 Mar 2010 09:31:47 -0700
Message-Id: <201003041631.o24GVl51005720@alien.loup.net>
From: Mike Hayward <hayward@loup.net>
In-reply-to: <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
	(message from foo saa on Thu, 4 Mar 2010 07:58:07 -0500)
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org> <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: foosaa@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I have seen a couple of your posts on this and thought I'd chime in
since I know a bit about storage.

I frequently see io errors come through to user space (both read and
write requests) from usb flash drives, so there is a functioning error
path there to some degree.  When I see the errors, the kernel is also
logging the sector and eventually resetting the device.

There is no doubt a disk drive will slow down when it hits a bad spot
since it will retry numerous times, most likely trying to remap bad
blocks.  Of course your write succeeded because you probably have the
drive cache enabled.  Flush or a full cache hangs while the drive
retries all of the sectors that are bad, remapping them until finally
it can remap no more.  At some point it probably returns an error if
flush is timing out or it can't remap any more sectors, but it won't
include the bad sector.

I would suggest turning the drive cache off.  Then the drive won't lie
to you about completing writes and you'll at least know which sectors
are bad.  Just a thought :-)

- Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
