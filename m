Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C3FC86B020E
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 21:51:17 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3U1hrQr006937
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 19:43:53 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3U1jR4o110356
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 19:45:27 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3U1jQAE002011
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 19:45:26 -0600
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100428055538.GA1730@ucw.cz>
References: <4BD16D09.2030803@redhat.com>
	 <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>
	 <4BD1A74A.2050003@redhat.com>
	 <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>
	 <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>
	 <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>
	 <4BD3377E.6010303@redhat.com>
	 <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>
	 <ce808441-fae6-4a33-8335-f7702740097a@default>
	 <20100428055538.GA1730@ucw.cz>
Content-Type: text/plain
Date: Thu, 29 Apr 2010 18:45:24 -0700
Message-Id: <1272591924.23895.807.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 2010-04-28 at 07:55 +0200, Pavel Machek wrote:
> > > Seems frontswap is like a reverse balloon, where the balloon is in
> > > hypervisor space instead of the guest space.
> > 
> > That's a reasonable analogy.  Frontswap serves nicely as an
> > emergency safety valve when a guest has given up (too) much of
> > its memory via ballooning but unexpectedly has an urgent need
> > that can't be serviced quickly enough by the balloon driver.
> 
> wtf? So lets fix the ballooning driver instead?
> 
> There's no reason it could not be as fast as frontswap, right?
> Actually I'd expect it to be faster -- it can deal with big chunks.

Frontswap and things like CMM2[1] have some fundamental advantages over
swapping and ballooning.  First of all, there are serious limits on
ballooning.  It's difficult for a guest to span a very wide range of
memory sizes without also including memory hotplug in the mix.  The ~1%
'struct page' penalty alone causes issues here.

A large portion of CMM2's gain came from the fact that you could take
memory away from guests without _them_ doing any work.  If the system is
experiencing a load spike, you increase load even more by making the
guests swap.  If you can just take some of their memory away, you can
smooth that spike out.  CMM2 and frontswap do that.  The guests
explicitly give up page contents that the hypervisor does not have to
first consult with the guest before discarding.

[1] http://www.kernel.org/doc/ols/2006/ols2006v2-pages-321-336.pdf 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
