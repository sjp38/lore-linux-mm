Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f208.google.com (mail-ie0-f208.google.com [209.85.223.208])
	by kanga.kvack.org (Postfix) with ESMTP id B208F6B0036
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 08:53:58 -0500 (EST)
Received: by mail-ie0-f208.google.com with SMTP id e14so119148iej.3
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:53:58 -0800 (PST)
Received: from blackbird.sr71.net ([2001:19d0:2:6:209:6bff:fe9a:902])
        by mx.google.com with ESMTP id 41si15138165yhf.177.2013.12.10.13.45.59
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 13:45:59 -0800 (PST)
Message-ID: <52A78B55.8050500@sr71.net>
Date: Tue, 10 Dec 2013 13:44:53 -0800
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] [RFC] mm: slab: separate slab_page from 'struct page'
References: <20131210204641.3CB515AE@viggo.jf.intel.com> <00000142de5634af-f92870a7-efe2-45cd-b50d-a6fbdf3b353c-000000@email.amazonses.com>
In-Reply-To: <00000142de5634af-f92870a7-efe2-45cd-b50d-a6fbdf3b353c-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>

On 12/10/2013 01:07 PM, Christoph Lameter wrote:
> On Tue, 10 Dec 2013, Dave Hansen wrote:
>> At least for slab, this doesn't turn out to be too big of a deal:
>> it's only 8 casts.  slub looks like it'll be a bit more work, but
>> still manageable.
> 
> The single page struct definitions makes it easy to see how a certain
> field is being used in various subsystems. If you add a field then you
> can see other use cases in other subsystems. If you happen to call
> them then you know that there is trouble afoot.

First of all, I'd really argue with the assertion that the way it is now
make it easy to figure anything out.  Maybe we can take a vote. :)

We _need_ to share fields when the structure is handed between different
subsystems and it needs to be consistent in both places.  For slab page
at least, the only data that actually gets used consistently is
page->flags.  It seems silly to bend over backwards just to share a
single bitfield.

> How do you ensure that the sizes and the locations of the fields in
> multiple page structs stay consistent?

Check out the BUILD_BUG_ON().  That shows one example of how we do it
for a field location.  We could do the same for sizeof() the two.

> As far as I can tell we are trying to put everything into one page struct
> to keep track of the uses of various fields and to allow a reference for
> newcomes to the kernel.

If the goal is to make a structure which is approachable to newcomers to
the kernel, then I think we've utterly failed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
