Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 5DC1E6B006C
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 20:26:11 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 10 Jan 2013 18:26:10 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 929583E4003E
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:26:01 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0B1Q6si180424
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:26:07 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0B1Q6NP006707
	for <linux-mm@kvack.org>; Thu, 10 Jan 2013 18:26:06 -0700
Message-ID: <50EF6A2C.7070606@linux.vnet.ibm.com>
Date: Thu, 10 Jan 2013 17:26:04 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] Reproducible OOM with partial workaround
References: <201301110046.r0B0k6lR024284@como.maths.usyd.edu.au>
In-Reply-To: <201301110046.r0B0k6lR024284@como.maths.usyd.edu.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paul.szabo@sydney.edu.au
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/10/2013 04:46 PM, paul.szabo@sydney.edu.au wrote:
>> Your configuration has never worked.  This isn't a regression ...
>> ... does not mean that we expect it to work.
> 
> Do you mean that CONFIG_HIGHMEM64G is deprecated, should not be used;
> that all development is for 64-bit only?

My last 4GB laptop had a 1GB hole and needed HIGHMEM64G since it had RAM
at 0->5GB.  That worked just fine, btw.  The problem isn't with
HIGHMEM64G itself.

I'm not saying HIGHMEM64G is inherently bad, just that it gets gradually
worse and worse as you add more RAM.  I don't believe 64GB of RAM has
_ever_ been booted on a 32-bit kernel without either violating the ABI
(3GB/1GB split) or doing something that never got merged upstream (that
4GB/4GB split, or other fun stuff like page clustering).

> I find it puzzling that there seems to be a sharp cutoff at 32GB RAM,
> no problem under but OOM just over; whereas I would have expected
> lowmem starvation to be gradual, with OOM occuring much sooner with
> 64GB than with 34GB. Also, the kernel seems capable of reclaiming
> lowmem, so I wonder why does that fail just over the 32GB threshhold.
> (Obviously I have no idea what I am talking about.)

It _is_ puzzling.  It isn't immediately obvious to me why the slab that
you have isn't being reclaimed.  There might, indeed, be a fixable bug
there.  But, there are probably a bunch more bugs which will keep you
from having a nice, smoothly-running system, mostly those bugs have not
had much attention in the 10 years or so since 64-bit x86 became
commonplace.  Plus, even 10 years ago, when folks were working on this
actively, we _never_ got things running smoothly on 32GB of RAM.  Take a
look at this:

http://support.bull.com/ols/product/system/linux/redhat/help/kbf/g/inst/PrKB11417

You are effectively running the "SMP kernel" (hugemem is a completely
different beast).

I had a 32GB i386 system.  It was a really, really fun system to play
with, and its never-ending list of bugs helped keep me employed for
several years.  You don't want to unnecessarily inflict that pain on
yourself, really.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
