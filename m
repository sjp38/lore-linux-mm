Received: from hpfcla.fc.hp.com (hpfcla.fc.hp.com [15.254.48.2])
	by atlrel2.hp.com (Postfix) with ESMTP id 8EA43639
	for <linux-mm@kvack.org>; Tue, 22 May 2001 19:16:49 -0400 (EDT)
Received: from gplmail.fc.hp.com (nsmail@wslmail.fc.hp.com [15.1.92.20])
	by hpfcla.fc.hp.com (8.9.3 (PHNE_22672)/8.9.3 SMKit7.01) with ESMTP id RAA14938
	for <linux-mm@kvack.org>; Tue, 22 May 2001 17:16:48 -0600 (MDT)
Received: from fc.hp.com (dome.fc.hp.com [15.1.89.118])
          by gplmail.fc.hp.com (Netscape Messaging Server 3.6)  with ESMTP
          id AAACD3 for <linux-mm@kvack.org>;
          Tue, 22 May 2001 17:16:44 -0600
Message-ID: <3B0AF30D.8D25806A@fc.hp.com>
Date: Tue, 22 May 2001 17:15:26 -0600
From: David Pinedo <dp@fc.hp.com>
MIME-Version: 1.0
Subject: Re: Running out of vmalloc space
References: <3B04069C.49787EC2@fc.hp.com> <20010517183931.V2617@redhat.com> <3B045546.312BA42E@fc.hp.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I followed up on the suggestion of several folks to not map the graphics
board into kernel vm space. While investigating how to do that, I
discovered that the frame buffer space did not need to be mapped -- it
was already being mapped with the control space. So instead of needing
(32M+16M)*2=96M of vmalloc space, I only need 32M*2=64M. That change
seemed easier than figuring out how not to map the board into kernel vm
space, so...
 
Given that VMALLOC_RESERVE is 128M, and there was about 92M left when my
graphics driver was being initialized, I thought I should have plenty of
room to map the two graphics boards. It worked -- the first time. If I
exitted the X server and restarted it, I would get the same errors from
the X server as when it was not able to map one of the devices.

I verified that the kernel vm space was being freed when the X server is
shut down, so that wasn't the problem. On further investigation, I found
that after the X server initialized the graphics boards, somebody else
was allocating a 24k chunk of vm space, immiediately after the two
chunks allocated by the graphics driver. When the graphics driver tried
to re-allocate those two chunks the next time the X server was started,
it was able to get the first, but not the second chunk. I looked at the
get_vm_area code in vmalloc.c, I found that it will not allow a vm space
to be allocated from a free space that is exactly the size of the space
being allocated. I think the statement:

    if (size + addr < (unsigned long) tmp->addr)
          break;       

should be:  

    if (size + addr <= (unsigned long) tmp->addr)
          break;

Making this change seems to fix my problem. :-)

David Pinedo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
