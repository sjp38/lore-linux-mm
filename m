Date: Wed, 12 Jun 2002 16:29:41 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: slab cache
Message-ID: <20020612162941.M12834@redhat.com>
References: <3D036BBE.4030603@shaolinmicro.com> <20020610095750.B2571@redhat.com> <3D076339.1070301@shaolinmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D076339.1070301@shaolinmicro.com>; from davidchow@shaolinmicro.com on Wed, Jun 12, 2002 at 11:05:29PM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chow <davidchow@shaolinmicro.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jun 12, 2002 at 11:05:29PM +0800, David Chow wrote:

> >Using 4k buffers does not limit your ability to use larger data
> >structures --- you can still chain 4k buffers together by creating an
> >array of struct page* pointers via which you can access the data.

> Yes, but for me it is very hard. When doing compression code, most of 
> the stuff is not even byte aligned, most of them might be bitwise 
> operated, it need very change to existing code. 

Perhaps, but the VM basically doesn't give you any primitives that you
can use for arbitrarily large chunks of linear data; things like
vmalloc are limited in the amount of data they can use, total, and it
is _slow_ to set up and tear down vmalloc mappings.

> get_free_page to allocate memory that is 4k to avoid some stress to the 
> vm, I have no idea about the difference of get_fee_page and the slab 
> cache. All my linear buffers stuff is already using array of page 
> pointers, if there any benefits for changing them to use slabcache? 
> Please advice, thanks.

It might be if you are allocating and deallocating large numbers of
them in bunches, since the slab cache can then keep a few pages cached
for immediate reuse rather than going to the global page allocator for
every single page.  The per-cpu slab stuff would also help to keep the
pages concerned hot in the cache of the local cpu, and that is likely
to be a big performance improvement in some cases.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
