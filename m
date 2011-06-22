Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 67E53900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 14:14:01 -0400 (EDT)
Message-ID: <4E0230CD.1030505@zytor.com>
Date: Wed, 22 Jun 2011 11:13:33 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110622110034.89ee399c.akpm@linux-foundation.org>
In-Reply-To: <20110622110034.89ee399c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

On 06/22/2011 11:00 AM, Andrew Morton wrote:
> : 
> : Second, the BadRAM patch expands the address patterns from the command
> : line into individual entries in the kernel's e820 table.  The e820
> : table is a fixed buffer that supports a very small, hard coded number
> : of entries (128).  We require a much larger number of entries (on
> : the order of a few thousand), so much of the google kernel patch deals
> : with expanding the e820 table.

This has not been true for a long time.

> I have a couple of thoughts here:
> 
> - If this patchset is merged and a major user such as google is
>   unable to use it and has to continue to carry a separate patch then
>   that's a regrettable situation for the upstream kernel.
> 
> - Google's is, afaik, the largest use case we know of: zillions of
>   machines for a number of years.  And this real-world experience tells
>   us that the badram patchset has shortcomings.  Shortcomings which we
>   can expect other users to experience.
> 
> So.  What are your thoughts on these issues?

I think a binary structure fed as a linked list data object makes a lot
more sense.  We already support feeding e820 entries in this way,
bypassing the 128-entry limitation of the fixed table in the zeropage.

The main issue then is priority; in particular memory marked UNUSABLE
(type 5) in the fed-in e820 map will of course overlap entries with
normal RAM (type 1) information in the native map; we need to make sure
that the type 5 information takes priority.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
