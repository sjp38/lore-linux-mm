From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.56793.520615.700914@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 21:40:57 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8 Fix swapoff races
In-Reply-To: <199906281725.KAA72836@google.engr.sgi.com>
References: <14199.41900.732658.354175@dukat.scot.redhat.com>
	<199906281725.KAA72836@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, andrea@suse.de, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 10:25:45 -0700 (PDT), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

>> But it can atomic_inc(&mm->count) to pin the mm, drop the task lock and
>> take the mm semaphore, and mmput() once it has finished.

> Hmm, hadn't thought about that one. Of course, as soon as you drop 
> the task_lock, in theory, you have to resume your search from the
> beginning of the task list, since the list might have changed while
> you dropped the task_lock (assume for a moment that the vm code does
> not know how the task list is managed). That prevents any forward
> progress by swapoff. 

Then keep a fencepost of the highest pid you have completed so far,
and with the lock held, look for the lowest pid greater than that
one.  If you don't make any progress on the mm, bump up the fencepost
pid by one.

It will work.  It's a little extra overhead, but it confines all of
the cost to the swapoff path.  The pid scan isn't going to be nearly
as expensive as the rest of the vm scanning we are already forced to
do in swapoff.

--Stephen


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
