Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D08E6B0047
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 13:20:06 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id mBIIKUNh032697
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 11:20:30 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBIILmRh170102
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 11:21:49 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBIILiZv028887
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 11:21:48 -0700
Subject: Re: [RFC v11][PATCH 05/13] Dump memory address space
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <494A9350.1060309@google.com>
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu>
	 <1228498282-11804-6-git-send-email-orenl@cs.columbia.edu>
	 <4949B4ED.9060805@google.com> <494A2F94.2090800@cs.columbia.edu>
	 <494A9350.1060309@google.com>
Content-Type: text/plain
Date: Thu, 18 Dec 2008 10:21:39 -0800
Message-Id: <1229624499.17206.576.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Waychison <mikew@google.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-12-18 at 10:15 -0800, Mike Waychison wrote:
> 
> >>> +    pgarr = kzalloc(sizeof(*pgarr), GFP_KERNEL);
> >>> +    if (!pgarr)
> >>> +        return NULL;
> >>> +
> >>> +    pgarr->vaddrs = kmalloc(CR_PGARR_TOTAL * sizeof(unsigned
> long),
> >> You used PAGE_SIZE / sizeof(void *) above.   Why not
> __get_free_page()?
> > 
> > Hahaha .. well, it's a guaranteed method to keep Dave Hansen from
> > barking about not using kmalloc ...
> > 
> > Personally I prefer __get_free_page() here, but not enough to keep
> > arguing with him. Let me know when the two of you settle it :)
> 
> Alright, I just wasn't sure if it had been considered.

__get_free_page() sucks.  It doesn't do cool stuff like redzoning when
you have slab debugging turned on.  :)

I would personally suggest never using __get_free_page() unless you
truly need a *PAGE*.  That's an aligned, and PAGE_SIZE chunk.  If you
don't need alignment, or don't literally need a 'struct page', don't use
it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
