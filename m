Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A543B6004C0
	for <linux-mm@kvack.org>; Sun,  2 May 2010 04:00:59 -0400 (EDT)
Received: by pxi15 with SMTP id 15so774415pxi.14
        for <linux-mm@kvack.org>; Sun, 02 May 2010 01:00:57 -0700 (PDT)
Message-ID: <4BDD3079.5060101@vflare.org>
Date: Sun, 02 May 2010 13:27:45 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
References: <4BD16D09.2030803@redhat.com>> <b01d7882-1a72-4ba9-8f46-ba539b668f56@default>> <4BD1A74A.2050003@redhat.com>> <4830bd20-77b7-46c8-994b-8b4fa9a79d27@default>> <4BD1B427.9010905@redhat.com> <4BD1B626.7020702@redhat.com>> <5fa93086-b0d7-4603-bdeb-1d6bfca0cd08@default>> <4BD3377E.6010303@redhat.com>> <1c02a94a-a6aa-4cbb-a2e6-9d4647760e91@default4BD43033.7090706@redhat.com>> <ce808441-fae6-4a33-8335-f7702740097a@default>> <20100428055538.GA1730@ucw.cz> <1272591924.23895.807.camel@nimitz> <4BDA8324.7090409@redhat.com> <084f72bf-21fd-4721-8844-9d10cccef316@default> <4BDB026E.1030605@redhat.com> <4BDB18CE.2090608@goop.org 4BDB2069.4000507@redhat.com> <3a62a058-7976-48d7-acd2-8c6a8312f10f@default>
In-Reply-To: <3a62a058-7976-48d7-acd2-8c6a8312f10f@default>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Avi Kivity <avi@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh.dickins@tiscali.co.uk, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 05/01/2010 10:40 PM, Dan Magenheimer wrote:
>> Eventually you'll have to swap frontswap pages, or kill uncooperative
>> guests.  At which point all of the simplicity is gone.
> 
> OK, now I think I see the crux of the disagreement.
> 
> NO!  Frontswap on Xen+tmem never *never* _never_ NEVER results
> in host swapping.  Host swapping is evil.  Host swapping is
> the root of most of the bad reputation that memory overcommit
> has gotten from VMware customers.  Host swapping can't be
> avoided with some memory overcommit technologies (such as page
> sharing), but frontswap on Xen+tmem CAN and DOES avoid it.
> 

Why host-level swapping is evil? In KVM case, VM is just another
process and host will just swap out pages using the same LRU like
scheme as with any other process, AFAIK.

Also, with frontswap, host cannot discard pages at any time as is
the case will cleancache. So, while cleancache is obviously very
useful, the usefulness of frontswap remains doubtful.

IMHO, along with cleancache, we should just have in in-memory
compressed swapping at *host* level i.e. no frontswap. I agree
that using frontswap hooks, it is easy to implement ramzswap
functionality but I think its not worth replacing this driver
with frontswap hooks. This driver already has all the goodness:
asynchronous interface, ability to dynamically add/remove ramzswap
devices etc. All that is lacking in this driver is a more efficient
'discard' functionality so we can free a page as soon as it becomes
unused.

It should also be easy to extend this driver to allow sending pages
to host using virtio (for KVM) or Xen hypercalls, if frontswap is
needed at all.

So, IMHO we can focus on cleancache development and add missing
parts to ramzswap driver.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
