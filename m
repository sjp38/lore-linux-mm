Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 625496B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 21:43:37 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id c11so1421163ieb.1
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 18:43:36 -0700 (PDT)
Date: Wed, 10 Apr 2013 20:43:32 -0500
From: Rob Landley <rob@landley.net>
Subject: Re: [PATCHv9 8/8] zswap: add documentation
In-Reply-To: <1365617940-21623-9-git-send-email-sjenning@linux.vnet.ibm.com>
	(from sjenning@linux.vnet.ibm.com on Wed Apr 10 13:19:00 2013)
Message-Id: <1365644612.18069.72@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, Heesub Shin <heesub.shin@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 04/10/2013 01:19:00 PM, Seth Jennings wrote:
> This patch adds the documentation file for the zswap functionality
>=20
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> ---
>  Documentation/vm/zsmalloc.txt |  2 +-
>  Documentation/vm/zswap.txt    | 82 =20
> +++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 83 insertions(+), 1 deletion(-)
>  create mode 100644 Documentation/vm/zswap.txt

Acked-by: Rob Landley <rob@landley.net>

Minor kibbitzing anyway:

> diff --git a/Documentation/vm/zsmalloc.txt =20
> b/Documentation/vm/zsmalloc.txt
> index 85aa617..4133ade 100644
> --- a/Documentation/vm/zsmalloc.txt
> +++ b/Documentation/vm/zsmalloc.txt
> @@ -65,4 +65,4 @@ zs_unmap_object(pool, handle);
>  zs_free(pool, handle);
>=20
>  /* destroy the pool */
> -zs_destroy_pool(pool);
> +zs_destroy_pool(pool);
> diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.txt
> new file mode 100644
> index 0000000..f29b82f
> --- /dev/null
> +++ b/Documentation/vm/zswap.txt
> @@ -0,0 +1,82 @@
> +Overview:
> +
> +Zswap is a lightweight compressed cache for swap pages. It takes
> +pages that are in the process of being swapped out and attempts to
> +compress them into a dynamically allocated RAM-based memory pool.
> +If this process is successful, the writeback to the swap device is
> +deferred and, in many cases, avoided completely.=C2=A0 This results in
> +a significant I/O reduction and performance gains for systems that
> +are swapping.
> +
> +Zswap provides compressed swap caching that basically trades CPU =20
> cycles
> +for reduced swap I/O.=C2=A0 This trade-off can result in a significant
> +performance improvement as reads to/writes from to the compressed

writes from to?

> +cache almost always faster that reading from a swap device

are almost

> +which incurs the latency of an asynchronous block I/O read.
> +
> +Some potential benefits:
> +* Desktop/laptop users with limited RAM capacities can mitigate the
> +=C2=A0=C2=A0=C2=A0 performance impact of swapping.
> +* Overcommitted guests that share a common I/O resource can
> +=C2=A0=C2=A0=C2=A0 dramatically reduce their swap I/O pressure, avoiding=
 heavy
> +=C2=A0=C2=A0=C2=A0 handed I/O throttling by the hypervisor.=C2=A0 This a=
llows more work
> +=C2=A0=C2=A0=C2=A0 to get done with less impact to the guest workload an=
d guests
> +=C2=A0=C2=A0=C2=A0 sharing the I/O subsystem
> +* Users with SSDs as swap devices can extend the life of the device =20
> by
> +=C2=A0=C2=A0=C2=A0 drastically reducing life-shortening writes.

Does it work even if you have no actual swap mounted? And if you swap =20
to NBD in a cluster it can keep network traffic down.

> +Zswap evicts pages from compressed cache on an LRU basis to the =20
> backing
> +swap device when the compress pool reaches it size limit or the pool =20
> is
> +unable to obtain additional pages from the buddy allocator.=C2=A0 This
> +requirement had been identified in prior community discussions.

I do not understand the "this requirement" sentence: aren't you just =20
describing the design here? Memory evicts to the compressed cache, =20
which evicts to persistent storage? What do historical community =20
discussions have to do with it? "We designed this feature based on user =20
feedback" is pretty much like saying "and this was developed in an open =20
source manner"...

> +To enabled zswap, the "enabled" attribute must be set to 1 at boot =20
> time.
> +e.g. zswap.enabled=3D1

So if you configure it in, nothing happens. You have to press an extra =20
button on the command line to have anything actually happen.

Why? (And why can't swapon do this? I dunno, swapon /dev/null or =20
something, which the swapon guys can make a nice flag for later.)

> +Design:
> +
> +Zswap receives pages for compression through the Frontswap API and
> +is able to evict pages from its own compressed pool on an LRU basis
> +and write them back to the backing swap device in the case that the
> +compressed pool is full or unable to secure additional pages from
> +the buddy allocator.
> +
> +Zswap makes use of zsmalloc for the managing the compressed memory
> +pool.  This is because zsmalloc is specifically designed to minimize

s/.  This is because zsmalloc/, which/

> +fragmentation on large (> PAGE_SIZE/2) allocation sizes.  Each
> +allocation in zsmalloc is not directly accessible by address.
> +Rather, a handle is return by the allocation routine and that handle

returned

> +must be mapped before being accessed.  The compressed memory pool =20
> grows
> +on demand and shrinks as compressed pages are freed.  The pool is
> +not preallocated.
> +
> +When a swap page is passed from frontswap to zswap, zswap maintains
> +a mapping of the swap entry, a combination of the swap type and swap
> +offset, to the zsmalloc handle that references that compressed swap
> +page.  This mapping is achieved with a red-black tree per swap type.
> +The swap offset is the search key for the tree nodes.
> +
> +During a page fault on a PTE that is a swap entry, frontswap calls
> +the zswap load function to decompress the page into the page
> +allocated by the page fault handler.
> +
> +Once there are no PTEs referencing a swap page stored in zswap
> +(i.e. the count in the swap_map goes to 0) the swap code calls
> +the zswap invalidate function, via frontswap, to free the compressed
> +entry.
> +
> +Zswap seeks to be simple in its policies.

Does that last sentence actually provide any information, or can it go?

> Sysfs attributes allow for two user controlled policies:
> +* max_compression_ratio - Maximum compression ratio, as as =20
> percentage,
> +    for an acceptable compressed page. Any page that does not =20
> compress
> +    by at least this ratio will be rejected.
> +* max_pool_percent - The maximum percentage of memory that the =20
> compressed
> +    pool can occupy.

Personally I'd put the user-visible control knobs earlier in the file, =20
before implementation details.

> +Zswap allows the compressor to be selected at kernel boot time by
> +setting the =E2=80=9Ccompressor=E2=80=9D attribute.  The default compres=
sor is lzo.
> +e.g. zswap.compressor=3Ddeflate

Can we hardwire in one at compile time and not have to do this?

> +A debugfs interface is provided for various statistic about pool =20
> size,

statistics

> +number of pages stored, and various counters for the reasons pages
> +are rejected.
> --
> 1.8.2.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe =20
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
