Received: from freak.distro.conectiva (freak.distro.conectiva [10.0.17.22])
	by perninha.conectiva.com.br (Postfix) with ESMTP id 705A738CA7
	for <linux-mm@kvack.org>; Tue,  5 Jun 2001 23:06:45 -0300 (EST)
Date: Tue, 5 Jun 2001 21:31:01 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: [RFC] some experimental VM code 
Message-ID: <Pine.LNX.4.21.0106052108440.3769-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi people, 

As you may know, the current behaviour of the kernel when it hits a
low memory condition is to allow each task to:

 - Writeout data to free memory
 - Unmap pte's/allocate swap space and age down pages

Until the task gets a free page. 

I've been saying for sometime now that I think only kswapd should do
the page aging part. If we don't do it this way, heavy VM loads will make
each memory intensive task age down other processes pages, so we see
ourselves in a "unmapping/faulting" storm. Imagine what happens to
interactivity in such a case. 

Trying to avoid that bad behaviour, I've experimented some code which 

 - Makes only kswapd age pages/unmap pte's. 
 - Tasks doing __GFP_IO allocations (non GFP_BUFFER allocations) wait on 
   the kswapd waitqueue when they are not able to do any progress trying
   to free pages themselves.
 - kswapd will not sleep until there is an inactive shortage or a free
   shortage.

Plus some other tweaks.

The behaviour is far away from getting nice, but I believe this is a step
on the right direction.

I _really_ would like to receive reports on this patch --- interactivity
under high loads should be quite better with it.

http://bazar.conectiva.com.br/~marcelo/patches/v2.4/2.4.6pre1/2.4.6pre1-vm-mt.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
