Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with SMTP id 6D7D911B52
	for <linux-mm@kvack.org>; Tue,  6 Jun 2000 11:57:39 -0400 (EDT)
From: Ed Tomlinson <tomlins@cam.org>
Reply-To: tomlins@cam.org
Subject: [RFC] pre cleaning (a more lucid description)
Date: Tue, 6 Jun 2000 11:53:19 -0400
Content-Type: text/plain
MIME-Version: 1.0
Message-Id: <00060611573901.12389@oscar>
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Sometimes I hate email.  The previous message on precleaning was NOT intended 
to be sent...  Here is a better description.  I have subscribed to linux-mm so
I will see any comments.  BTW this is for 2.5 land.

This is an idea to help the mm subsystem.  It uses a some IO bandwidth to speed up
gathering free pages.  Simpily stated, the idea is: during the scan for free pages,
once we have found our quota, we should look ahead and write out dirty pages.  The 
next scan, if we have done things correctly, should have very few dirty pages to 
write.  It should be possible to make this process self tuning.

I assumed we are directly scanning the mm array

lets define a few items

Q a pointer or index to the place we stopped looking for free pages.
C a pointer or index to the place we stopped looking for pages to pre clean, note we always
  restart the pre clean process at Q.
D a count of dirty pages, in the pre cleaned area (Q < C),  we had to write gather our
  quota of free pages.
P a count of dirty pages we pre cleaned since the last time we freed pages.
S a count of the number of pages we scaned to get our quota of free pages.

If things are working correctly D should be much less than P.  This ratio
can be used to determine if we are helping.  We should try to pre clean at
least S pages.  The scan/preclean task needs to adjust its priority during
this process.  It needs to be very high during the freeing cycle and low
during the preclean cycle.  If the preclean process is unable to scan S
pages, we can use this as indication that we are short of resources.

A couple of comments.  We do not have to write all dirty pages, just those
that the next scan will select as free.  It may be possible to cluster the
writes.  

The net effect of this should be that we do our page outs when they will
not effect processes.  When we need free pages getting them should
be faster and usually will not require (much) IO.

Thoughts?
 
Ed Tomlinson <tomlins@cam.org>
http://www.cam.org/~tomlins/njpipes.html
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
