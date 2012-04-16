Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 73E426B00FD
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 09:10:06 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so4826090vcb.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 06:10:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334578675-23445-9-git-send-email-mgorman@suse.de>
References: <1334578675-23445-1-git-send-email-mgorman@suse.de>
	<1334578675-23445-9-git-send-email-mgorman@suse.de>
Date: Mon, 16 Apr 2012 09:10:04 -0400
Message-ID: <CADnza444dTr=JEtqpL5wxHRNkEc7vBz1qq9TL7Z+5h749vNawg@mail.gmail.com>
Subject: Re: [PATCH 08/11] nfs: disable data cache revalidation for swapfiles
From: Fred Isaman <iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>

On Mon, Apr 16, 2012 at 8:17 AM, Mel Gorman <mgorman@suse.de> wrote:
> The VM does not like PG_private set on PG_swapcache pages. As suggested
> by Trond in http://lkml.org/lkml/2006/8/25/348, this patch disables
> NFS data cache revalidation on swap files. =A0as it does not make
> sense to have other clients change the file while it is being used as
> swap. This avoids setting PG_private on swap pages, since there ought
> to be no further races with invalidate_inode_pages2() to deal with.
>
> Since we cannot set PG_private we cannot use page->private which
> is already used by PG_swapcache pages to store the nfs_page. Thus
> augment the new nfs_page_find_request logic.
>
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
> =A0fs/nfs/inode.c | =A0 =A06 ++++++
> =A0fs/nfs/write.c | =A0 51 +++++++++++++++++++++++++++++++++++++---------=
-----
> =A02 files changed, 43 insertions(+), 14 deletions(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index e8bbfa5..af43ef6 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -880,6 +880,12 @@ int nfs_revalidate_mapping(struct inode *inode, stru=
ct address_space *mapping)
> =A0 =A0 =A0 =A0struct nfs_inode *nfsi =3D NFS_I(inode);
> =A0 =A0 =A0 =A0int ret =3D 0;
>
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* swapfiles are not supposed to be shared.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (IS_SWAPFILE(inode))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> =A0 =A0 =A0 =A0if ((nfsi->cache_validity & NFS_INO_REVAL_PAGECACHE)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|| nfs_attribute_cache_exp=
ired(inode)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0|| NFS_STALE(inode)) {
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 6a891eb..eea4ec0 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -111,15 +111,30 @@ static void nfs_context_set_write_error(struct nfs_=
open_context *ctx, int error)
> =A0 =A0 =A0 =A0set_bit(NFS_CONTEXT_ERROR_WRITE, &ctx->flags);
> =A0}
>
> -static struct nfs_page *nfs_page_find_request_locked(struct page *page)
> +static struct nfs_page *
> +nfs_page_find_request_locked(struct nfs_inode *nfsi, struct page *page)
> =A0{
> =A0 =A0 =A0 =A0struct nfs_page *req =3D NULL;
>
> - =A0 =A0 =A0 if (PagePrivate(page)) {
> + =A0 =A0 =A0 if (PagePrivate(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0req =3D (struct nfs_page *)page_private(pa=
ge);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (req !=3D NULL)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&req->wb_kref);
> + =A0 =A0 =A0 else if (unlikely(PageSwapCache(page))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct nfs_page *freq, *t;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Linearly search the commit list for the =
correct req */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_for_each_entry_safe(freq, t, &nfsi->co=
mmit_list, wb_list) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (freq->wb_page =3D=3D pa=
ge) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 req =3D fre=
q;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(req =3D=3D NULL);

I suspect I am missing something, but why is it guaranteed that the
req is on the commit list?

Fred

> =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 if (req)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kref_get(&req->wb_kref);
> +
> =A0 =A0 =A0 =A0return req;
> =A0}
>
> @@ -129,7 +144,7 @@ static struct nfs_page *nfs_page_find_request(struct =
page *page)
> =A0 =A0 =A0 =A0struct nfs_page *req =3D NULL;
>
> =A0 =A0 =A0 =A0spin_lock(&inode->i_lock);
> - =A0 =A0 =A0 req =3D nfs_page_find_request_locked(page);
> + =A0 =A0 =A0 req =3D nfs_page_find_request_locked(NFS_I(inode), page);
> =A0 =A0 =A0 =A0spin_unlock(&inode->i_lock);
> =A0 =A0 =A0 =A0return req;
> =A0}
> @@ -232,7 +247,7 @@ static struct nfs_page *nfs_find_and_lock_request(str=
uct page *page, bool nonblo
>
> =A0 =A0 =A0 =A0spin_lock(&inode->i_lock);
> =A0 =A0 =A0 =A0for (;;) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 req =3D nfs_page_find_request_locked(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 req =3D nfs_page_find_request_locked(NFS_I(=
inode), page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (req =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (nfs_lock_request_dontget(req))
> @@ -385,9 +400,15 @@ static void nfs_inode_add_request(struct inode *inod=
e, struct nfs_page *req)
> =A0 =A0 =A0 =A0spin_lock(&inode->i_lock);
> =A0 =A0 =A0 =A0if (!nfsi->npages && nfs_have_delegation(inode, FMODE_WRIT=
E))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0inode->i_version++;
> - =A0 =A0 =A0 set_bit(PG_MAPPED, &req->wb_flags);
> - =A0 =A0 =A0 SetPagePrivate(req->wb_page);
> - =A0 =A0 =A0 set_page_private(req->wb_page, (unsigned long)req);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Swap-space should not get truncated. Hence no need to =
plug the race
> + =A0 =A0 =A0 =A0* with invalidate/truncate.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (likely(!PageSwapCache(req->wb_page))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_bit(PG_MAPPED, &req->wb_flags);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPagePrivate(req->wb_page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_page_private(req->wb_page, (unsigned lo=
ng)req);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0nfsi->npages++;
> =A0 =A0 =A0 =A0kref_get(&req->wb_kref);
> =A0 =A0 =A0 =A0spin_unlock(&inode->i_lock);
> @@ -404,9 +425,11 @@ static void nfs_inode_remove_request(struct nfs_page=
 *req)
> =A0 =A0 =A0 =A0BUG_ON (!NFS_WBACK_BUSY(req));
>
> =A0 =A0 =A0 =A0spin_lock(&inode->i_lock);
> - =A0 =A0 =A0 set_page_private(req->wb_page, 0);
> - =A0 =A0 =A0 ClearPagePrivate(req->wb_page);
> - =A0 =A0 =A0 clear_bit(PG_MAPPED, &req->wb_flags);
> + =A0 =A0 =A0 if (likely(!PageSwapCache(req->wb_page))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_page_private(req->wb_page, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPagePrivate(req->wb_page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_bit(PG_MAPPED, &req->wb_flags);
> + =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0nfsi->npages--;
> =A0 =A0 =A0 =A0spin_unlock(&inode->i_lock);
> =A0 =A0 =A0 =A0nfs_release_request(req);
> @@ -646,7 +669,7 @@ static struct nfs_page *nfs_try_to_update_request(str=
uct inode *inode,
> =A0 =A0 =A0 =A0spin_lock(&inode->i_lock);
>
> =A0 =A0 =A0 =A0for (;;) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 req =3D nfs_page_find_request_locked(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 req =3D nfs_page_find_request_locked(NFS_I(=
inode), page);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (req =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_unlock;
>
> @@ -1690,7 +1713,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct =
page *page)
> =A0*/
> =A0int nfs_wb_page(struct inode *inode, struct page *page)
> =A0{
> - =A0 =A0 =A0 loff_t range_start =3D page_offset(page);
> + =A0 =A0 =A0 loff_t range_start =3D page_file_offset(page);
> =A0 =A0 =A0 =A0loff_t range_end =3D range_start + (loff_t)(PAGE_CACHE_SIZ=
E - 1);
> =A0 =A0 =A0 =A0struct writeback_control wbc =3D {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.sync_mode =3D WB_SYNC_ALL,
> --
> 1.7.9.2
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
