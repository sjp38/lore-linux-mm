From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14281.23624.70350.745345@dukat.scot.redhat.com>
Date: Sun, 29 Aug 1999 17:14:00 +0100 (BST)
Subject: Re: accel handling
In-Reply-To: <Pine.LNX.4.10.9908291037120.28136-100000@imperial.edgeglobal.com>
References: <Pine.LNX.4.10.9908291037120.28136-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 29 Aug 1999 10:52:29 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

>  My name is James Simmons and I'm one of the new core designers for the
> framebuffer devices for linux. Well I have redesigned the framebuffer
> system and now it takes advantages of accels. Now the problem is that alot
> of cards can't have simulanteous access to the framebuffer and the accel
> engine. What I need to a way to put any process to sleep when they access
> the framebuffer while the accel engine is active. This is for both read
> and write access. Then once the accel engine is idle wake up the
> process.

You really need to have a cooperative locking engine.  Doing this sort
of thing by playing VM tricks is not acceptable: you are just making the
driver side of things simpler by placing a whole extra lot of work onto
the VM, and things will not necessarily go any faster.  

The real problem with a VM solution is that threaded applications on a
multi-processor machine will go *immensely* slower.  Every time you need
to lock out a VM region, you have to send a storm of interrupts to the
other CPUs to make sure they aren't in the middle of accessing the same
region from a related thread.  In general, any solution which requires
fast twiddling of VM to make this work just will not be accepted.

A combination of shared-memory spinlocks (for fast tight-loop locking)
and SysV semaphores (for a blocking lock if the lock is taken for too
long) can be combined to give a simple but very efficient locking engine
for this type of thing.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
