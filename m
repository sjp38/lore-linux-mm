Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BF15A6B0088
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 02:45:51 -0500 (EST)
Message-Id: <4CFF45BB0200007800026A63@vpn.id2.novell.com>
Date: Wed, 08 Dec 2010 07:45:47 +0000
From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: [PATCH] use total_highpages when calculating lowmem-only
	 allocation sizes (core)
References: <4CFD20370200007800026269@vpn.id2.novell.com>
 <20101207151054.32542836.akpm@linux-foundation.org>
In-Reply-To: <20101207151054.32542836.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>> On 08.12.10 at 00:10, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 06 Dec 2010 16:41:11 +0000
> "Jan Beulich" <JBeulich@novell.com> wrote:
>=20
>> For those (large) table allocations that come only from lowmem, the
>> total amount of memory shouldn't really matter.
>>=20
>> For vfs_caches_init(), in the same spirit also replace the use of
>> nr_free_pages() by nr_free_buffer_pages().
>>=20
>> Signed-off-by: Jan Beulich <jbeulich@novell.com>
>>=20
>> ---
>>  fs/dcache.c                       |    4 ++--
>>  init/main.c                       |    5 +++--
>>  2 files changed, 5 insertions(+), 4 deletions(-)
>>=20
>> --- linux-2.6.37-rc4/fs/dcache.c
>> +++ 2.6.37-rc4-use-totalhigh_pages/fs/dcache.c
>> @@ -2474,10 +2474,10 @@ void __init vfs_caches_init(unsigned lon
>>  {
>>  	unsigned long reserve;
>> =20
>> -	/* Base hash sizes on available memory, with a reserve equal to
>> +	/* Base hash sizes on available lowmem memory, with a reserve =
equal to
>>             150% of current kernel size */
>> =20
>> -	reserve =3D min((mempages - nr_free_pages()) * 3/2, mempages - 1);
>> +	reserve =3D min((mempages - nr_free_buffer_pages()) * 3/2, =
mempages - 1);
>>  	mempages -=3D reserve;
>> =20
>>  	names_cachep =3D kmem_cache_create("names_cache", PATH_MAX, 0,
>> --- linux-2.6.37-rc4/init/main.c
>> +++ 2.6.37-rc4-use-totalhigh_pages/init/main.c
>> @@ -22,6 +22,7 @@
>>  #include <linux/init.h>
>>  #include <linux/initrd.h>
>>  #include <linux/bootmem.h>
>> +#include <linux/highmem.h>
>>  #include <linux/acpi.h>
>>  #include <linux/tty.h>
>>  #include <linux/percpu.h>
>> @@ -673,13 +674,13 @@ asmlinkage void __init start_kernel(void
>>  #endif
>>  	thread_info_cache_init();
>>  	cred_init();
>> -	fork_init(totalram_pages);
>> +	fork_init(totalram_pages - totalhigh_pages);
>>  	proc_caches_init();
>>  	buffer_init();
>>  	key_init();
>>  	security_init();
>>  	dbg_late_init();
>> -	vfs_caches_init(totalram_pages);
>> +	vfs_caches_init(totalram_pages - totalhigh_pages);
>>  	signals_init();
>>  	/* rootfs populating might need page-writeback */
>>  	page_writeback_init();
>=20
> Dunno.  The code is really quite confused, unobvious and not obviously
> correct.
>=20
> Mainly because it has callers who read some global state and then pass
> that into callees who take that arg and then combine it with other
> global state.  The code would be much more confidence-inspiring if it
> were cleaned up, so that all callees just read the global state when
> they need it.

Usually, when submitting bug fixes that include other cleanup, I'm
asked to separate the two. Now you're asking the opposite...
Irrespective of this I agree that passing global state at the single
call site of a function is questionable, and may deserve cleaning up.

> And is there any significant difference between (totalram_pages -
> totalhigh_pages) and nr_free_buffer_pages()?  They're both kind-of
> evaluating the same thing?

totalram_pages - totalhigh_pages, as their names say, evaluates
to the total number of lowmem pages, whereas
nr_free_buffer_pages() gives us the number of available lowmem
pages (you actually pointed me at this function when I submitted
a first version of these changes).

> And after this patch, vfs_caches_init() is evaluating
>=20
> 	totalram_pages - totalhigh_pages - nr_free_buffer_pages()

The lowmem equivalent of (totalram_pages - nr_free_pages()).

> which will be pretty close to zero, won't it?  Maybe negative?  Does
> the code actually work??

Yes, it has been working for me for many months.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
