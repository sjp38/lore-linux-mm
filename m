From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14357.39150.714844.910876@dukat.scot.redhat.com>
Date: Tue, 26 Oct 1999 13:05:02 +0100 (BST)
Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
In-Reply-To: <qwwg0yymv5a.fsf@sap.com>
References: <199910260158.JAA00043@chpc.ict.ac.cn>
	<qwwg0yymv5a.fsf@sap.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: fxzhang@chpc.ict.ac.cn, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On 26 Oct 1999 09:35:45 +0200, Christoph Rohland
<hans-christoph.rohland@sap.com> said:

> Yes I would like to see it also, but at least in 2.0 days it was
> really difficult/impossible.

In 2.2 it is much easier --- I did most of the required work when
making swap cache sharing persistant.  Then the 2.2 codefreeze hit...

The first remaining problem is initialisation of demand-zero pages for
shared vmas.  You have to be able to ensure that when one process
faults in a shared page for the first time, all other processes pick
up the correct new page.

There are several ways you could do this.  The SysV-shm mechanism
would work, but it would be harder to garbage-collect all of the
resources used by a page which is no longer shared.  Normal
demand-zero page instantiation would work provided that it was
performed atomically over all the vmas concerned, which would require
careful locking on 2.3 for SMP.

The only fly in the ointment is that 2.3's new bigmem code doesn't
observe the swap cache rules so carefully, and shared pages can become
separated.  We'd have to make the swap cache capable of working
properly on high memory pages.  

The other thing still needing done is to make the swap cache work
properly for writable pages --- there are still various places in the
VM where we assume mapped swap cache pages are readonly. 

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
