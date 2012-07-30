Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 0DBF76B004D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2012 03:56:49 -0400 (EDT)
Message-ID: <50163D94.5050607@parallels.com>
Date: Mon, 30 Jul 2012 11:53:56 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Any reason to use put_page in slub.c?
References: <1343391586-18837-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207271054230.18371@router.home>
In-Reply-To: <alpine.DEB.2.00.1207271054230.18371@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 07/27/2012 07:55 PM, Christoph Lameter wrote:
> On Fri, 27 Jul 2012, Glauber Costa wrote:
> 
>> But I am still wondering if there is anything I am overlooking.
> 
> put_page() is necessary because other subsystems may still be holding a
> refcount on the page (if f.e. there is DMA still pending to that page).
> 

Humm, this seems to be extremely unsafe in my read.
If you do kmalloc, the API - AFAIK - does not provide us with any
guarantee that the object (it's not even a page, in the strict sense!)
allocated is reference counted internally. So relying on kfree to do it
doesn't bode well. For one thing, slab doesn't go to the page allocator
for high order allocations, and this code would crash miserably if
running with the slab.

Or am I missing something ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
