Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 37D7B6B0247
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 13:10:51 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3UH99PT008811
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 11:09:09 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3UHAdiZ116924
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 11:10:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3UHAcG1000959
	for <linux-mm@kvack.org>; Fri, 30 Apr 2010 11:10:38 -0600
Subject: RE: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <10e6761a-fb7a-421d-97fc-1f3b6cd94622@default>
References: <4BD16D09.2030803@redhat.com> >
	 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default> >
	 <4BD1A74A.2050003@redhat.com> >
	 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default> >
	 <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com> >
	 <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default> >
	 <4BD3377E.6010303@redhat.com> >
	 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com> >
	 <ce808441-fae6-4a33-8335-f7702740097a@default> >
	 <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz>
	 <4BDA8324.7090409@redhat.com>
	 <084f72bf-21fd-4721-8844-9d10cccef316@default 4BDB026E.1030605@redhat.com>
	 <10e6761a-fb7a-421d-97fc-1f3b6cd94622@default>
Content-Type: text/plain
Date: Fri, 30 Apr 2010 10:10:36 -0700
Message-Id: <1272647436.23895.2625.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Avi Kivity <avi@redhat.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, 2010-04-30 at 09:43 -0700, Dan Magenheimer wrote:
> And, importantly, "have your host expose a device which is write
> cached by host memory"... you are implying that all guest swapping
> should be done to a device managed/controlled by the host?  That
> eliminates guest swapping to directIO/SRIOV devices doesn't it?

If you have a single swap device, sure.  But, I can also see a case
where you have a "fast" swap and "slow" swap.

The part of the argument about frontswap is that I like is the lack
sizing exposed to the guest.  When you're dealing with swap-only, you
are stuck adding or removing swap devices if you want to "grow/shrink"
the memory footprint.  If the host (or whatever is backing the
frontswap) wants to change the sizes, they're fairly free to.

The part that bothers me it is that it just pushes the problem
elsewhere.  For KVM, we still have to figure out _somewhere_ what to do
with all those pages.  It's nice that the host would have the freedom to
either swap or keep them around, but it doesn't really fix the problem.

I do see the lack of sizing exposed to the guest as being a bad thing,
too.  Let's say we saved 25% of system RAM to back a frontswap-type
device on a KVM host.  The first time a user boots up their set of VMs
and 25% of their RAM is gone, they're going to start complaining,
despite the fact that their 25% smaller systems may end up being faster.

I think I'd be more convinced if we saw this thing actually get used
somehow.  How is a ram-backed frontswap better than a /dev/ramX-backed
swap file in practice?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
