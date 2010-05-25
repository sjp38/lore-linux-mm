Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0E3906B01AD
	for <linux-mm@kvack.org>; Tue, 25 May 2010 14:26:36 -0400 (EDT)
Message-ID: <4BFC1657.5000707@yahoo.es>
Date: Tue, 25 May 2010 20:26:31 +0200
From: Albert Herranz <albert_herranz@yahoo.es>
MIME-Version: 1.0
Subject: Re: page_mkwrite vs pte dirty race in fb_defio
References: <20100525160149.GE20853@laptop>
In-Reply-To: <20100525160149.GE20853@laptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: aya Kumar <jayakumar.lkml@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On 05/25/2010 06:01 PM, Nick Piggin wrote:
> Hi,
> 
> I couldn't find where this patch (49bbd815fd8) was discussed, so I'll
> make my own thread. Adding a few lists to cc because it might be of
> interest to driver and filesystem writers.
> 

The original thread can be found here:
http://marc.info/?l=linux-fbdev&m=127369791432181

> The old ->page_mkwrite calling convention was causing problems exactly
> because of this race, and we solved it by allowing page_mkwrite to
> return with the page locked, and the lock will be held until the
> pte is marked dirty. See commit b827e496c893de0c0f142abfaeb8730a2fd6b37f.
> 

Ah, didn't know about that. Thanks for the pointer.

> I hope that should provide a more elegant solution to your problem. I
> would really like you to take a look at that, because we already have
> filesystem code (NFS) relying on it, and more code we have relying on
> this synchronization, the more chance we would find a subtle problem
> with it (also it should be just nicer).
> 

So if I undestand it correctly, using the "new" calling convention I should just lock the page on fb_deferred_io_mkwrite() and return VM_FAULT_LOCKED to fix the described race for fb_defio.

> Thanks,
> Nick
> 

Thanks,
Albert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
