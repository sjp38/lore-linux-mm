Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2C2696B006A
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 20:04:57 -0400 (EDT)
Message-ID: <4A553707.5060107@goop.org>
Date: Wed, 08 Jul 2009 17:17:11 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [Xen-devel] Re: [RFC PATCH 0/4] (Take 2): transcendent memory
 ("tmem") for Linux
References: <ac5dec0d-e593-4a82-8c9d-8aa374e8c6ed@default> <4A553272.5050909@codemonkey.ws>
In-Reply-To: <4A553272.5050909@codemonkey.ws>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, npiggin@suse.de, akpm@osdl.org, xen-devel@lists.xensource.com, tmem-devel@oss.oracle.com, kurt.hackel@oracle.com, Rusty Russell <rusty@rustcorp.com.au>, linux-kernel@vger.kernel.org, dave.mccracken@oracle.com, linux-mm@kvack.org, chris.mason@oracle.com, sunil.mushran@oracle.com, Avi Kivity <avi@redhat.com>, Schwidefsky <schwidefsky@de.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, alan@lxorguk.ukuu.org.uk, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On 07/08/09 16:57, Anthony Liguori wrote:
> Why does tmem require a special store?
>
> A VMM can trap write operations pages can be stored on disk
> transparently by the VMM if necessary.  I guess that's the bit I'm
> missing.

tmem doesn't store anything to disk.  It's more about making sure that
free host memory can be quickly and efficiently be handed out to guests
as they need it; to increase "memory liquidity" as it were.  Guests need
to explicitly ask to use tmem, rather than having the host/hypervisor
try to intuit what to do based on access patterns and hints; typically
they'll use tmem as the first line storage for memory which they were
about to swap out anyway.  There's no point in making tmem swappable,
because the guest is perfectly capable of swapping its own memory.

The copying interface avoids a lot of the delicate corners of the CMM
code, in which subtle races can lurk in fairly hard-to-test-for ways. 

>> The copy may be expensive on an older machine, but on newer
>> machines copying a page is relatively inexpensive.
>
> I don't think that's a true statement at all :-)  If you had a
> workload where data never came into the CPU cache (zero-copy) and now
> you introduce a copy, even with new system, you're going to see a
> significant performance hit.

If the copy helps avoid physical disk IO, then it is cheap at the
price.  A guest generally wouldn't push a page into tmem unless it was
about to evict it anyway, so it has already determined the page is
cold/unwanted, and the copy isn't a great cost.  Hot/busy pages
shouldn't be anywhere near tmem; if they are, it suggests you've cut
your domain's memory too aggressively.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
