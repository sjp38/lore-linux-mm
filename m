Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 99EC46B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 19:31:28 -0400 (EDT)
Message-ID: <4A4BF1D2.8010305@goop.org>
Date: Wed, 01 Jul 2009 16:31:30 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [RFC] transcendent memory for Linux
References: <79a405e4-3c4c-4194-aed4-a3832c6c5d6e@default>
In-Reply-To: <79a405e4-3c4c-4194-aed4-a3832c6c5d6e@default>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>, Keir Fraser <keir.fraser@eu.citrix.com>
List-ID: <linux-mm.kvack.org>

On 07/01/09 16:02, Dan Magenheimer wrote:
> All of these still require a large number of guesses
> across a 128-bit space of possible uuids, right?
> It should be easy to implement "guess limits" in xen
> that disable tmem use by a guest if it fails too many guesses.
>   

How does Xen distinguish between someone "guessing" uuids and a normal
user which wants to create lots of pools?

>> You also have to consider the case of a domain which was once part of
>> the ocfs cluster, but now is not - it may still know the uuid, but not
>> be otherwise allowed to use the cluster.
>>     
>
> But on the other hand, the security model here can be that
> if a trusted entity becomes untrusted, you have to change
> the locks.
>   

Revocation is one of the big problems with capabilities-based systems.

>> Yeah, a shared namespace of accessible objects is an entirely 
>> new thing
>> in the Xen universe.  I would also drop Xen support until 
>> there's a good
>> security story about how they can be used.
>>     
>
> While I agree that the security is not bulletproof, I wonder
> if this position might be a bit extreme.  Certainly, the NSA
> should not turn on tmem in a cluster, but that doesn't mean that
> nobody should be allowed to.  I really suspect that there are
> less costly / more rewarding attack vectors at several layers
> in the hardware/software stack of most clusters.
>   

Well, I think you can define any security model you like, but I think
you need to have a defined security model before making it an available
API.  At the moment the model is defined by whatever you currently have
implemented, and anyone using the API as-is - without special
consideration of its security properties - is going to end up vulnerable.

In an earlier mail I said "a shared namespace of accessible objects is
an entirely new thing in the Xen universe", which is obviously not true:
we have Xenbus.

It seems to me that a better approach to shared tmem pools should be
moderated via Xenbus, which in turn allows dom0/xenstored/tmemd/etc to
apply arbitrary policies to who gets to see what handles, revoke them, etc.

You don't need to deal with "uuids" at the tmem hypercall level. 
Instead, you have a well-defined xenbus path corresponding to the
resource; reading it will return a handle number, which you can then use
with your hypercalls.  If your access is denied or revoked, then the
read will fail (or the current handle will stop working if revoked). 
This requires some privileged hypercalls to establish and remove tmem
handles for a particular domain.

I'm assuming that the job of managing and balancing tmem resources will
need to happen in a tmem-domain rather than trying to build all that
policy into Xen itself, so putting a bit more logic in there to manage
shared access rules doesn't add much complexity to the system.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
