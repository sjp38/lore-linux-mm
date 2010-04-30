Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 649F56B0248
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 13:52:20 -0400 (EDT)
Message-ID: <4BDB18CE.2090608@goop.org>
Date: Fri, 30 Apr 2010 10:52:14 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>> <4BD1A74A.2050003@redhat.com>> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>> <4BD3377E.6010303@redhat.com>> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>> <ce808441-fae6-4a33-8335-f7702740097a@default>> <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz 4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default> <4BDB026E.1030605@redhat.com>
In-Reply-To: <4BDB026E.1030605@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 04/30/2010 09:16 AM, Avi Kivity wrote:
> Given that whenever frontswap fails you need to swap anyway, it is
> better for the host to never fail a frontswap request and instead back
> it with disk storage if needed.  This way you avoid a pointless vmexit
> when you're out of memory.  Since it's disk backed it needs to be
> asynchronous and batched.

I'd argue the opposite.  There's no point in having the host do swapping
on behalf of guests if guests can do it themselves; it's just a
duplication of functionality.  You end up having two IO paths for each
guest, and the resulting problems in trying to account for the IO,
rate-limit it, etc.  If you can simply say "all guest disk IO happens
via this single interface", its much easier to manage.

If frontswap has value, it's because its providing a new facility to
guests that doesn't already exist and can't be easily emulated with
existing interfaces.

It seems to me the great strengths of the synchronous interface are:

    * it matches the needs of an existing implementation (tmem in Xen)
    * it is simple to understand within the context of the kernel code
      it's used in

Simplicity is important, because it allows the mm code to be understood
and maintained without having to have a deep understanding of
virtualization.  One of the problems with CMM2 was that it puts a lot of
intricate constraints on the mm code which can be easily broken, which
would only become apparent in subtle edge cases in a CMM2-using
environment.  An addition async frontswap-like interface - while not as
complex as CMM2 - still makes things harder for mm maintainers.

The downside is that it may not match some implementation in which the
get/put operations could take a long time (ie, physical IO to a slow
mechanical device).  But a general Linux principle is not to overdesign
interfaces for hypothetical users, only for real needs.

Do you think that you would be able to use frontswap in kvm if it were
an async interface, but not otherwise?  Or are you arguing a hypothetical?

> At this point we're back with the ordinary swap API.  Simply have your
> host expose a device which is write cached by host memory, you'll have
> all the benefits of frontswap with none of the disadvantages, and with
> no changes to guest code.

Yes, that's comfortably within the "guests page themselves" model. 
Setting up a block device for the domain which is backed by pagecache
(something we usually try hard to avoid) is pretty straightforward.  But
it doesn't work well for Xen unless the blkback domain is sized so that
it has all of Xen's free memory in its pagecache.

That said, it does concern me that the host/hypervisor is left holding
the bag on frontswapped pages.  A evil/uncooperative/lazy can just pump
a whole lot of pages into the frontswap pool and leave them there.   I
guess this is mitigated by the fact that the API is designed such that
they can't update or read the data without also allowing the hypervisor
to drop the page (updates can fail destructively, and reads are also
destructive), so the guest can't use it as a clumsy extension of their
normal dedicated memory.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
