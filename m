From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14315.48702.873172.788668@dukat.scot.redhat.com>
Date: Fri, 24 Sep 1999 19:09:02 +0100 (BST)
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909241040460.12262-100000@imperial.edgeglobal.com>
References: <14314.49322.671097.451248@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9909241040460.12262-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 24 Sep 1999 10:59:31 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

> Does this mean while one process is in the act of mlocking a memory
> region another process can actually change the contents of that memory?

Yes.  The semaphore only protects against changes to the mmap lists and
page tables.  It does not protect memory itself.  On a multi-processor
machine, the only way the kernel on one CPU can prevent the contents of
a page from being modified by a process on another CPU is to forcibly
revoke all read-write mappings to that page.

>> > Will this semaphore protect this region? In a SMP machine same
>> > thing. What kind of protect does this semaphore provide? Does it
>> > prevent other process from doing anything to the memory. 
>> 
>> No.

> I obtained this idea from do_page_fault. This function is called from a
> interrupt when a process actually tries to access memory correct? 

No, it is only called when a process tries to access memory which is not
currently in the process's page tables.  If the page is already mapped,
then there is no page fault.  Otherwise you'd be doing massive amounts
of kernel work for every byte of data accessed by every process.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
