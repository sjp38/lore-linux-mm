Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 970B16B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 20:24:11 -0500 (EST)
Received: by iyj17 with SMTP id 17so268832iyj.14
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 17:24:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110118152844.88cfdc2c.akpm@linux-foundation.org>
References: <E1Pf9Zj-0002td-Ct@pomaz-ex.szeredi.hu>
	<20110118152844.88cfdc2c.akpm@linux-foundation.org>
Date: Wed, 19 Jan 2011 10:24:09 +0900
Message-ID: <AANLkTimh7jq7HLjfxVX0XKdhOhWEQtDn-faGc+iJ-ykd@mail.gmail.com>
Subject: Re: [PATCH v4] mm: add replace_page_cache_page() function
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 19, 2011 at 8:28 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 18 Jan 2011 12:18:11 +0100
> Miklos Szeredi <miklos@szeredi.hu> wrote:
>
>> +int replace_page_cache_page(struct page *old, struct page *new, gfp_t g=
fp_mask)
>> +{
>> + =A0 =A0 int error;
>> + =A0 =A0 struct mem_cgroup *memcg =3D NULL;
>
> I'm suspecting that the unneeded initialisation was added to suppress a
> warning?
>
> I removed it, and didn't get a warning. =A0I expected to.
>
> Really, uninitialized_var() is better. =A0It avoids adding extra code
> and, unlike "=3D 0" it is self-documenting.
>
>> + =A0 =A0 VM_BUG_ON(!PageLocked(old));
>> + =A0 =A0 VM_BUG_ON(!PageLocked(new));
>> + =A0 =A0 VM_BUG_ON(new->mapping);
>> +
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* This is not page migration, but prepare_migration and
>> + =A0 =A0 =A0* end_migration does enough work for charge replacement.
>> + =A0 =A0 =A0*
>> + =A0 =A0 =A0* In the longer term we probably want a specialized functio=
n
>> + =A0 =A0 =A0* for moving the charge from old to new in a more efficient
>> + =A0 =A0 =A0* manner.
>> + =A0 =A0 =A0*/
>> + =A0 =A0 error =3D mem_cgroup_prepare_migration(old, new, &memcg, gfp_m=
ask);
>> + =A0 =A0 if (error)
>> + =A0 =A0 =A0 =A0 =A0 =A0 return error;
>> +
>> + =A0 =A0 error =3D radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
>> + =A0 =A0 if (!error) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct address_space *mapping =3D old->mapping=
;
>> + =A0 =A0 =A0 =A0 =A0 =A0 pgoff_t offset =3D old->index;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 page_cache_get(new);
>> + =A0 =A0 =A0 =A0 =A0 =A0 new->mapping =3D mapping;
>> + =A0 =A0 =A0 =A0 =A0 =A0 new->index =3D offset;
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&mapping->tree_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 __remove_from_page_cache(old);
>> + =A0 =A0 =A0 =A0 =A0 =A0 error =3D radix_tree_insert(&mapping->page_tre=
e, offset, new);
>> + =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(error);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mapping->nrpages++;
>> + =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_page_state(new, NR_FILE_PAGES);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (PageSwapBacked(new))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_page_state(new, NR_=
SHMEM);
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&mapping->tree_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 radix_tree_preload_end();
>> + =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(old);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_end_migration(memcg, old, new, true=
);
>
> This is all pretty ugly and inefficient.
>
> We call __remove_from_page_cache() which does a radix-tree lookup and
> then fiddles a bunch of accounting things.
>
> Then we immediately do the same radix-tree lookup and then undo the
> accounting changes which we just did. =A0And we do it in an open-coded
> fashion, thus giving the kernel yet another code site where various
> operations need to be kept in sync.
>
> Would it not be better to do a single radix_tree_lookup_slot(),
> overwrite the pointer therein and just leave all the ancilliary
> accounting unaltered?

I agree single radix_tree_lookup but accounting still is needed since
newpage could be on another zone. What we can remove is just only
mapping->nrpages.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
