Received: from imperial.edgeglobal.com (imperial.edgeglobal.com [208.197.226.14])
	by edgeglobal.com (8.9.1/8.9.1) with ESMTP id RAA15767
	for <linux-mm@kvack.org>; Sat, 4 Sep 1999 17:23:22 -0400
Date: Sat, 4 Sep 1999 17:27:42 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: accel again.
Message-ID: <Pine.LNX.4.10.9909041708350.22380-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Well I did my homework on spinlocks and see what you mean by using
spinlocks to handle accel and framebuffer access. So just before I have
fbcon access the accel engine I could do this right?

In fb.h 
--------
struct fb_info {
	...
	struct vm_area_struct vm_area
	...
}
--------

In fbcon.c

/* I going to access accel engine */
spin_lock(&fb_info->vm_area->vm_mm->page_table_lock); 

/* accessing accel engine */
....
/* done with accel engine */
spin_unlock(&fb_info->vm_area->vm_mm->page_table_lock);

Now this would lock the framebuffer correct? So if a process would try to
acces the framebuffer it would be put to sleep while its doing accels. Is
this basically what I need to do or is their something more that I am
missing. 

Their also exist the possiblity that the accel engine in the kernel and
the accel registers from userland could be access at the same time. This
means that spin_lock could be called twice. Any danger in this? Then some
accel engines use a interuppt to flush their FIFO. So a 
spin_lock_irqsave(&fb_info->vm_area->vm_mm->page_table_lock, flags);
should always be used correct?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
