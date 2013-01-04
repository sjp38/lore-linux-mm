Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id B16F96B005D
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 17:45:42 -0500 (EST)
MIME-Version: 1.0
Message-ID: <f66f40b3-6568-4183-b592-2990d4cd2083@default>
Date: Fri, 4 Jan 2013 14:45:28 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 7/8] zswap: add to mm/
References: <<1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com>>
 <<1355262966-15281-8-git-send-email-sjenning@linux.vnet.ibm.com>>
 <0e91c1e5-7a62-4b89-9473-09fff384a334@default>
 <50E32255.60901@linux.vnet.ibm.com>
 <26bb76b3-308e-404f-b2bf-3d19b28b393a@default>
 <50E4C1FA.4070701@linux.vnet.ibm.com>
 <640d712e-0217-456a-a2d1-d03dd7914a55@default>
 <50E6F862.2030703@linux.vnet.ibm.com>
In-Reply-To: <50E6F862.2030703@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, Dave Hansen <dave@linux.vnet.ibm.com>

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: Re: [PATCH 7/8] zswap: add to mm/
>=20
> On 01/03/2013 04:33 PM, Dan Magenheimer wrote:
> >> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> >>
> >> However, once the flushing code was introduced and could free an entry
> >> from the zswap_fs_store() path, it became necessary to add a per-entry
> >> refcount to make sure that the entry isn't freed while another code
> >> path was operating on it.
> >
> > Hmmm... doesn't the refcount at least need to be an atomic_t?
>=20
> An entry's refcount is only ever changed under the tree lock, so
> making them atomic_t would be redundantly atomic.

Maybe I'm missing something still but then I think you also
need to evaluate and act on the refcount (not just read it) while
your treelock is held.  I.e., in:

> +=09=09/* page is already in the swap cache, ignore for now */
> +=09=09spin_lock(&tree->lock);
> +=09=09refcount =3D zswap_entry_put(entry);
> +=09=09spin_unlock(&tree->lock);
> +
> +=09=09if (likely(refcount))
> +=09=09=09return 0;
> +
> +=09=09/* if the refcount is zero, invalidate must have come in */
> +=09=09/* free */
> +=09=09zs_free(tree->pool, entry->handle);
> +=09=09zswap_entry_cache_free(entry);
> +=09=09atomic_dec(&zswap_stored_pages);

the entry's refcount may be changed by another processor
immediately after the unlock, and then the "if (refcount)"
is testing a stale value and you will get (I think) a memory leak.

There is similar racy code in zswap_fs_invalidate_page which
I think could lead to a double free.  There's another
I think in zswap_fs_load...  And the refcount is dec'd
in one path inside of zswap_fs_store as well which may
race with the above.

When flushing multiple zpages to free a pageframe, you may
need to test refcounts for all the entries while within the lock.
If so, this is one place where the high-density storage will make
things messy, especially if page boundaries are crossed.

A nit: Even I, steeped in tmem terminology, was confused by
your use of "fs"... to nearly all readers it will
be translated as "filesystem" which is mystifying.
Just spell it out "frontswap", even if it causes a few
lines to be wrapped.

Have a good weekend!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
