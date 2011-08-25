Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9889E6B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 13:47:27 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <46a0d040-bae2-4a6b-a896-bc3dadce3cd0@default>
Date: Thu, 25 Aug 2011 10:46:52 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V7 3/4] mm: frontswap: add swap hooks and extend
 try_to_unuse
References: <20110823145835.GA23222@ca-server1.us.oracle.com
 20110825153347.1e42a607.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110825153347.1e42a607.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, akpm@linux-foundation.org, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, jackdachef@gmail.com, cyclonusj@gmail.com

> From: KAMEZAWA Hiroyuki [mailto:kamezawa.hiroyu@jp.fujitsu.com]
> Subject: Re: Subject: [PATCH V7 3/4] mm: frontswap: add swap hooks and ex=
tend try_to_unuse

Thanks again for the great review!  I think the only change required
for V8 is the addition of a comment in find_next_to_unuse (see below).
After reading all of my replies, please let me know if you disagree.

Dan

> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> >
> > This third patch of four in the frontswap series adds hooks in the swap
> > subsystem and extends try_to_unuse so that frontswap_shrink can do a
> > "partial swapoff".  Also, declarations for the extern-ified swap variab=
les
> > in the first patch are declared.
> >
> > Note that failed frontswap_map allocation is safe... failure is noted
> > by lack of "FS" in the subsequent printk.
> >
> > [v7: rebase to 3.0-rc3]
> > [v7: JBeulich@novell.com: use new static inlines, no-ops if not config'=
d]
> > [v6: rebase to 3.1-rc1]
> > [v6: lliubbo@gmail.com: use vzalloc]
> > [v5: accidentally posted stale code for v4 that failed to compile :-(]
> > [v4: rebase to 2.6.39]
> > Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
> > Acked-by: Jan Beulich <JBeulich@novell.com>
> > Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Nitin Gupta <ngupta@vflare.org>
> > Cc: Matthew Wilcox <matthew@wil.cx>
> > Cc: Chris Mason <chris.mason@oracle.com>
> > Cc: Rik Riel <riel@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> >
> > --- linux/mm/swapfile.c=092011-08-08 08:19:26.336684746 -0600
> > +++ frontswap/mm/swapfile.c=092011-08-23 08:21:15.301998803 -0600
> > @@ -32,6 +32,8 @@
> >  #include <linux/memcontrol.h>
> >  #include <linux/poll.h>
> >  #include <linux/oom.h>
> > +#include <linux/frontswap.h>
> > +#include <linux/swapfile.h>
> >
> >  #include <asm/pgtable.h>
> >  #include <asm/tlbflush.h>
> > @@ -43,7 +45,7 @@ static bool swap_count_continued(struct
> >  static void free_swap_count_continuations(struct swap_info_struct *);
> >  static sector_t map_swap_entry(swp_entry_t, struct block_device**);
> >
> > -static DEFINE_SPINLOCK(swap_lock);
> > +DEFINE_SPINLOCK(swap_lock);
> >  static unsigned int nr_swapfiles;
> >  long nr_swap_pages;
> >  long total_swap_pages;
> > @@ -54,9 +56,9 @@ static const char Unused_file[] =3D "Unuse
> >  static const char Bad_offset[] =3D "Bad swap offset entry ";
> >  static const char Unused_offset[] =3D "Unused swap offset entry ";
> >
> > -static struct swap_list_t swap_list =3D {-1, -1};
> > +struct swap_list_t swap_list =3D {-1, -1};
> >
> > -static struct swap_info_struct *swap_info[MAX_SWAPFILES];
> > +struct swap_info_struct *swap_info[MAX_SWAPFILES];
> >
> >  static DEFINE_MUTEX(swapon_mutex);
> >
> > @@ -557,6 +559,7 @@ static unsigned char swap_entry_free(str
> >  =09=09=09swap_list.next =3D p->type;
> >  =09=09nr_swap_pages++;
> >  =09=09p->inuse_pages--;
> > +=09=09frontswap_flush_page(p->type, offset);
> >  =09=09if ((p->flags & SWP_BLKDEV) &&
> >  =09=09=09=09disk->fops->swap_slot_free_notify)
> >  =09=09=09disk->fops->swap_slot_free_notify(p->bdev, offset);
> > @@ -1022,7 +1025,7 @@ static int unuse_mm(struct mm_struct *mm
> >   * Recycle to start on reaching the end, returning 0 when empty.
> >   */
> >  static unsigned int find_next_to_unuse(struct swap_info_struct *si,
> > -=09=09=09=09=09unsigned int prev)
> > +=09=09=09=09=09unsigned int prev, bool frontswap)
> >  {
> >  =09unsigned int max =3D si->max;
> >  =09unsigned int i =3D prev;
> > @@ -1048,6 +1051,12 @@ static unsigned int find_next_to_unuse(s
> >  =09=09=09prev =3D 0;
> >  =09=09=09i =3D 1;
> >  =09=09}
>=20
> > +=09=09if (frontswap) {
> > +=09=09=09if (frontswap_test(si, i))
> > +=09=09=09=09break;
> > +=09=09=09else
> > +=09=09=09=09continue;
> > +=09=09}
>=20
> Could you add comment ? If frontswap=3D=3Dtrue, only scan frontswap ?

Yes, thank you, this is a good comment to add.

> > @@ -1059,8 +1068,12 @@ static unsigned int find_next_to_unuse(s
> >   * We completely avoid races by reading each swap page in advance,
> >   * and then search for the process using it.  All the necessary
> >   * page table adjustments can then be made atomically.
> > + *
> > + * if the boolean frontswap is true, only unuse pages_to_unuse pages;
> > + * pages_to_unuse=3D=3D0 means all pages; ignored if frontswap is fals=
e
> >   */
> > -static int try_to_unuse(unsigned int type)
> > +int try_to_unuse(unsigned int type, bool frontswap,
> > +=09=09 unsigned long pages_to_unuse)
> >  {
> >  =09struct swap_info_struct *si =3D swap_info[type];
> >  =09struct mm_struct *start_mm;
> > @@ -1093,7 +1106,7 @@ static int try_to_unuse(unsigned int typ
> >  =09 * one pass through swap_map is enough, but not necessarily:
> >  =09 * there are races when an instance of an entry might be missed.
> >  =09 */
> > -=09while ((i =3D find_next_to_unuse(si, i)) !=3D 0) {
> > +=09while ((i =3D find_next_to_unuse(si, i, frontswap)) !=3D 0) {
> >  =09=09if (signal_pending(current)) {
> >  =09=09=09retval =3D -EINTR;
> >  =09=09=09break;
> > @@ -1260,6 +1273,10 @@ static int try_to_unuse(unsigned int typ
> >  =09=09 * interactive performance.
> >  =09=09 */
> >  =09=09cond_resched();
> > +=09=09if (frontswap && pages_to_unuse > 0) {
> > +=09=09=09if (!--pages_to_unuse)
> > +=09=09=09=09break;
> > +=09=09}
> >  =09}
>=20
> Is this a best-effort function and doesn't need to return condition
> of pages_to_unuse ?
> Caller of try_to_unuse(si, true....) is frontswap_shrink(). Right ?

Right.  This function is best-effort with frontswap or without frontswap.
In a non-frontswap system, a swapoff command may fail because try_to_unuse
wasn't able to swap in all pages.  The same is true of a "partial swapoff"
when frontswap_shrink() is called.  Since this behavior didn't change,
I didn't add a comment for that.  A return condition isn't needed because
frontswap_curr_pages can be queried.

Thanks!
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
