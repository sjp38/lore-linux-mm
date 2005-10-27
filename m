Date: Thu, 27 Oct 2005 17:11:23 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051027151123.GO5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1130425212.23729.55.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, Jeff Dike <jdike@addtoit.com>, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 27, 2005 at 08:00:12AM -0700, Badari Pulavarty wrote:
> BTW, my initial testing found no bugs so far - thats why I am scared :(
> But again, I am sure my testing is not covering cases where shared 
> memory segments got swapped out. I need to do a closer audit to make
> sure that I am indeed freeing up all the swap entries.

Freeing swap entries is the most important thing and at the same time
the most complex in the patch (that's why the previous MADV_DISCARD was
so simple ;).

> And also, I am not sure we should allow using this interface for
> truncating up. 

I guess we can allow using the interface for truncating up too.
Currently you can map beyond the end of the i_size but it sigbus if you
touch it. So if you want to suddently have more mmap space to store
data, you can first MADV_TRUNCATE it, and then it won't sigbus anymore
(and it will be recorded on disk/swap depending if it's a real fs or
tmpfs) up to the highest point of the truncate range.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
