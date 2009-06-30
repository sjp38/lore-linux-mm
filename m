Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3F96B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 18:45:25 -0400 (EDT)
Message-ID: <4A4A95D8.6020708@goop.org>
Date: Tue, 30 Jun 2009 15:46:48 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC] transcendent memory for Linux
References: <c31ca108-9b68-40ba-936f-3ed2a56fd90b@default>
In-Reply-To: <c31ca108-9b68-40ba-936f-3ed2a56fd90b@default>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>, Keir Fraser <keir.fraser@eu.citrix.com>
List-ID: <linux-mm.kvack.org>

On 06/30/09 14:21, Dan Magenheimer wrote:
> No, the uuid can't be verified.  Tmem gives no indication
> as to whether a newly-created pool is already in use (shared)
> by another guest.  So without both the 128-bit uuid and an
> already-in-use 64-bit object id and 32-bit page index, no data
> is readable or writable by the attacker.
>   

You have to consider things like timing attacks as well (for example, a
tmem hypercall might return faster if the uuid already exists).

Besides, you can tell whether a uuid exists, by at least a couple of
mechanisms (from a quick read of the source, so I might have overlooked
something):

   1. You can create new shared pools until it starts failing as a
      result of hitting the MAX_GLOBAL_SHARED_POOLS limit with junk
      uuids.  If you then successfully "create" a shared pool while
      searching, you know it already existed.
   2. The returned pool id will increase unless the pool already exists,
      in which case you'll get a smaller id back (ignoring wraparound).


> Hmmm... that is definitely a thornier problem.  I guess the
> security angle definitely deserves more design.  But, again,
> this affects only shared precache which is not intended
> to part of the proposed initial tmem patchset, so this is a futures
> issue.)

Yeah, a shared namespace of accessible objects is an entirely new thing
in the Xen universe.  I would also drop Xen support until there's a good
security story about how they can be used.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
