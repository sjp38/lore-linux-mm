Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD506B00BB
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 11:07:04 -0500 (EST)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1OG4ZC3030161
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 11:04:35 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1OG71eM127054
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 11:07:01 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1OG5keP025313
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 11:05:48 -0500
Subject: Re: [RFC v13][PATCH 05/14] x86 support for checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090224014739.1b82fc35@thinkcentre.lan>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1233076092-8660-6-git-send-email-orenl@cs.columbia.edu>
	 <20090224014739.1b82fc35@thinkcentre.lan>
Content-Type: text/plain
Date: Tue, 24 Feb 2009 08:06:46 -0800
Message-Id: <1235491606.26788.248.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Lynch <ntl@pobox.com>
Cc: Oren Laadan <orenl@cs.columbia.edu>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 2009-02-24 at 01:47 -0600, Nathan Lynch wrote:
> But I think this has been pointed out before.  If I understand the
> justification for cr_hbuf_get correctly, the allocations it services
> are somehow known to be bounded in size and nesting.  But even if that
> is the case, it's not much of a reason to avoid using kmalloc, is it?

Oren wants this particular facility to be used for live migration.  To
support good live migration, we need to be able to return from the
syscall as fast as possible.  To do that, Oren proposed that we buffer
all the data needed for the checkpoint inside the kernel.

The current cr_hbuf_put/get() could easily be modified to support this
usage by basically making put() do nothing, then handing off a handle to
the cr_ctx structure elsewhere in the kernel.  When the time comes to
free up the in-memory image, you only have one simple structure to go
free (the hbuf) as opposed to a bunch of little kmalloc()'d objects.

I'm sure I'm missing something.  I'm also sure that this *will* work
eventually.  But, I don't think the code as it stands supports keeping
the abstraction in there.  It is virtually impossible to debate the
design or its alternatives in this state.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
