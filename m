Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8B2F26B023B
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 12:00:20 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <084f72bf-21fd-4721-8844-9d10cccef316@default>
Date: Fri, 30 Apr 2010 08:59:55 -0700 (PDT)
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
 <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz
 4BDA8324.7090409@redhat.com>
In-Reply-To: <4BDA8324.7090409@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

> > A large portion of CMM2's gain came from the fact that you could take
> > memory away from guests without _them_ doing any work.  If the system
> is
> > experiencing a load spike, you increase load even more by making the
> > guests swap.  If you can just take some of their memory away, you can
> > smooth that spike out.  CMM2 and frontswap do that.  The guests
> > explicitly give up page contents that the hypervisor does not have to
> > first consult with the guest before discarding.
>=20
> Frontswap does not do this.  Once a page has been frontswapped, the
> host
> is committed to retaining it until the guest releases it.

Dave or others can correct me if I am wrong, but I think CMM2 also
handles dirty pages that must be retained by the hypervisor.  The
difference between CMM2 (for dirty pages) and frontswap is that
CMM2 sets hints that can be handled asynchronously while frontswap
provides explicit hooks that synchronously succeed/fail.

In fact, Avi, CMM2 is probably a fairly good approximation of what
the asynchronous interface you are suggesting might look like.
In other words, feasible but much much more complex than frontswap.

> [frontswap is] really
> not very different from a synchronous swap device.

Not to beat a dead horse, but there is a very key difference:
The size and availability of frontswap is entirely dynamic;
any page-to-be-swapped can be rejected at any time even if
a page was previously successfully swapped to the same index.
Every other swap device is much more static so the swap code
assumes a static device.  Existing swap code can account for
"bad blocks" on a static device, but this is far from sufficient
to handle the dynamicity needed by frontswap.

> I think cleancache allows the hypervisor to drop pages without the
> guest's immediate knowledge, but I'm not sure.

Yes, cleancache can drop pages at any time because (as the
name implies) only clean pages can be put into cleancache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
