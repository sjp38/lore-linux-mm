Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 531FF6B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 08:27:48 -0400 (EDT)
Received: by vbbey12 with SMTP id ey12so1309646vbb.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:27:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
References: <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
Date: Sat, 31 Mar 2012 20:27:46 +0800
Message-ID: <CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com>
Subject: Re: [PATCH] hugetlb: fix race condition in hugetlb_fault()
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
> Cc: stable@kernel.org
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---
> =C2=A0mm/hugetlb.c | =C2=A0 =C2=A08 ++++++--
> =C2=A01 files changed, 6 insertions(+), 2 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4531be2..ab674fc 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2703,8 +2703,10 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_=
area_struct *vma,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * so no worry about deadlock.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D pte_page(entry);
> - =C2=A0 =C2=A0 =C2=A0 if (page !=3D pagecache_page)
> + =C2=A0 =C2=A0 =C2=A0 if (page !=3D pagecache_page) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 get_page(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0lock_page(page);
> + =C2=A0 =C2=A0 =C2=A0 }
>
Perhaps, directly get page?

	page =3D pte_page(entry);
+	get_page(page);
	if (page !=3D pagecache_page)
		lock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
