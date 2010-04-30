Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25C9A6B0243
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 12:45:25 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <10e6761a-fb7a-421d-97fc-1f3b6cd94622@default>
Date: Fri, 30 Apr 2010 09:43:55 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>>
 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>>
 <4BD1A74A.2050003@redhat.com>>
 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com>
 <4BD1B626.7020702@redhat.com>>
 <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>>
 <4BD3377E.6010303@redhat.com>>
 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>>
 <ce808441-fae6-4a33-8335-f7702740097a@default>>
 <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz>
 <4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default
 4BDB026E.1030605@redhat.com>
In-Reply-To: <4BDB026E.1030605@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

(I'll back down on the CMM2 comparisons until I can go
back and read the paper :-)

> >> [frontswap is] really
> >> not very different from a synchronous swap device.
> >>
> > Not to beat a dead horse, but there is a very key difference:
> > The size and availability of frontswap is entirely dynamic;
> > any page-to-be-swapped can be rejected at any time even if
> > a page was previously successfully swapped to the same index.
> > Every other swap device is much more static so the swap code
> > assumes a static device.  Existing swap code can account for
> > "bad blocks" on a static device, but this is far from sufficient
> > to handle the dynamicity needed by frontswap.
>=20
> Given that whenever frontswap fails you need to swap anyway, it is
> better for the host to never fail a frontswap request and instead back
> it with disk storage if needed.  This way you avoid a pointless vmexit
> when you're out of memory.  Since it's disk backed it needs to be
> asynchronous and batched.
>=20
> At this point we're back with the ordinary swap API.  Simply have your
> host expose a device which is write cached by host memory, you'll have
> all the benefits of frontswap with none of the disadvantages, and with
> no changes to guest .

I think you are making a number of possibly false assumptions here:
1) The host [the frontswap backend may not even be a hypervisor]
2) can back it with disk storage [not if it is a bare-metal hypervisor]
3) avoid a pointless vmexit [no vmexit for a non-VMX (e.g. PV) guest]
4) when you're out of memory [how can this be determined outside of
   the hypervisor?]

And, importantly, "have your host expose a device which is write
cached by host memory"... you are implying that all guest swapping
should be done to a device managed/controlled by the host?  That
eliminates guest swapping to directIO/SRIOV devices doesn't it?

Anyway, I think we can see now why frontswap might not be a good
match for a hosted hypervisor (KVM), but that doesn't make it
any less useful for a bare-metal hypervisor (or TBD for in-kernel
compressed swap and TBD for possible future pseudo-RAM technologies).

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
