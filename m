Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id CC9286B0092
	for <linux-mm@kvack.org>; Sun,  1 Apr 2012 08:10:32 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so1761326vcb.14
        for <linux-mm@kvack.org>; Sun, 01 Apr 2012 05:10:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201203311339.q2VDdJMD006254@farm-0012.internal.tilera.com>
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
	<CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com>
	<201203311339.q2VDdJMD006254@farm-0012.internal.tilera.com>
Date: Sun, 1 Apr 2012 20:10:31 +0800
Message-ID: <CAJd=RBBWx7uZcw=_oA06RVunPAGeFcJ7LY=RwFCyB_BreJb_kg@mail.gmail.com>
Subject: Re: [PATCH v2] hugetlb: fix race condition in hugetlb_fault()
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

On Sat, Mar 31, 2012 at 4:07 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> The race is as follows. =C2=A0Suppose a multi-threaded task forks a new
> process, thus bumping up the ref count on all the pages. =C2=A0While the =
fork
> is occurring (and thus we have marked all the PTEs as read-only), another
> thread in the original process tries to write to a huge page, taking an
> access violation from the write-protect and calling hugetlb_cow(). =C2=A0=
Now,
> suppose the fork() fails. =C2=A0It will undo the COW and decrement the re=
f
> count on the pages, so the ref count on the huge page drops back to 1.
> Meanwhile hugetlb_cow() also decrements the ref count by one on the
> original page, since the original address space doesn't need it any more,
> having copied a new page to replace the original page. =C2=A0This leaves =
the
> ref count at zero, and when we call unlock_page(), we panic.
>
> The solution is to take an extra reference to the page while we are
> holding the lock on it.
>
If the following chart matches the above description,

=3D=3D=3D
	fork on CPU A				fault on CPU B
	=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D				=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
	...
	down_write(&parent->mmap_sem);
	down_write_nested(&child->mmap_sem);
	...
	while duplicating vmas
		if error
			break;
	...
	up_write(&child->mmap_sem);
	up_write(&parent->mmap_sem);		...
						down_read(&parent->mmap_sem);
						...
						lock_page(page);
						handle COW
						page_mapcount(old_page) =3D=3D 2
						alloc and prepare new_page
	...
	handle error
	page_remove_rmap(page);
	put_page(page);
	...
						fold new_page into pte
						page_remove_rmap(page);
						put_page(page);
						...
				oops =3D=3D>	unlock_page(page);
						up_read(&parent->mmap_sem);
=3D=3D=3D

would you please spin with description refreshed?

> Cc: stable@kernel.org

Let Andrew do the stable work, ok?

Best Regards
-hd

> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> This change incorporates Hillf Danton's suggestion to just unconditionall=
y
> get and put the page around the region of code in question.
>
> =C2=A0mm/hugetlb.c | =C2=A0 =C2=A02 ++
> =C2=A01 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1871753..5f53d6b 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2701,6 +2701,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_a=
rea_struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * so no worry about deadlock.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D pte_page(entry);
> + =C2=A0 =C2=A0 =C2=A0 get_page(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page !=3D pagecache_page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lock_page(page);
>
> @@ -2732,6 +2733,7 @@ out_page_table_lock:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page !=3D pagecache_page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page(page);
> + =C2=A0 =C2=A0 =C2=A0 put_page(page);
>
> =C2=A0out_mutex:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mutex_unlock(&hugetlb_instantiation_mutex);
> --
> 1.6.5.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
