Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D10156B005C
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 17:22:59 -0400 (EDT)
Message-ID: <4A4930DA.5030700@goop.org>
Date: Mon, 29 Jun 2009 14:23:38 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC] transcendent memory for Linux
References: <6639b922-4ed7-48fd-9a3d-c78a4f93355c@default>
In-Reply-To: <6639b922-4ed7-48fd-9a3d-c78a4f93355c@default>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

On 06/29/09 14:13, Dan Magenheimer wrote:
> The uuid is only used for shared pools.  If two different
> "tmem clients" (guests) agree on a 128-bit "shared secret",
> they can share a tmem pool.  For ocfs2, the 128-bit uuid in
> the on-disk superblock is used for this purpose to implement
> shared precache.  (Pages evicted by one cluster node
> can be used by another cluster node that co-resides on
> the same physical system.)
>   

What are the implications of some third party VM guessing the "uuid" of
a shared pool?  Presumably they could view and modify the contents of
the pool.  Is there any security model beyond making UUIDs unguessable?

> The (page)size argument is always fixed (at PAGE_SIZE) for
> any given kernel.  The underlying implementation can
> be capable of supporting multiple pagesizes.
>   

Pavel's other point was that merging the size field into the flags is a
bit unusual/ugly.  But you can workaround that by just defining the
"flag" values for each plausible page size, since there's a pretty small
bound: TMEM_PAGESZ_4K, 8K, etc.

Also, having an "API version number" is a very bad idea.  Such version
numbers are very inflexible and basically don't work (esp if you're
expecting to have multiple independent implementations of this API). 
Much better is to have feature flags; the caller asks for features on
the new pool, and pool creation either succeeds or doesn't (a call to
return the set of supported features is a good compliment).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
