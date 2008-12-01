Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id mB1KotC6031365
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 15:50:55 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB1KpOnG163908
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 15:51:24 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB1Kower011758
	for <linux-mm@kvack.org>; Mon, 1 Dec 2008 15:50:58 -0500
Subject: Re: [RFC v10][PATCH 08/13] Dump open file descriptors
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <493447DD.7010102@cs.columbia.edu>
References: <1227747884-14150-1-git-send-email-orenl@cs.columbia.edu>
	 <1227747884-14150-9-git-send-email-orenl@cs.columbia.edu>
	 <20081128101919.GO28946@ZenIV.linux.org.uk>
	 <1228153645.2971.36.camel@nimitz>  <493447DD.7010102@cs.columbia.edu>
Content-Type: text/plain
Date: Mon, 01 Dec 2008 12:51:19 -0800
Message-Id: <1228164679.2971.91.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-01 at 15:23 -0500, Oren Laadan wrote:
> Verifying that the size doesn't change does not ensure that the table's
> contents remained the same, so we can still end up with obsolete data.

With the realloc() scheme, we have virtually no guarantees about how the
fdtable that we read relates to the source.  All that we know is that
the n'th fd was at this value at *some* time.

Using the scheme that I just suggested (and you evidently originally
used) at least guarantees that we have an atomic copy of the fdtable.

Why is this done in two steps?  It first grabs a list of fd numbers
which needs to be validated, then goes back and turns those into 'struct
file's which it saves off.  Is there a problem with doing that
fd->'struct file' conversion under the files->file_lock?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
