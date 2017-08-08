Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2096B04D7
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 05:00:04 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b130so2591130oii.4
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 02:00:04 -0700 (PDT)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id z83si564416oiz.148.2017.08.08.02.00.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 02:00:03 -0700 (PDT)
Received: by mail-io0-x241.google.com with SMTP id q64so2076706ioi.0
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 02:00:03 -0700 (PDT)
MIME-Version: 1.0
Reply-To: fdmanana@gmail.com
In-Reply-To: <20170808084548.18963-47-ming.lei@redhat.com>
References: <20170808084548.18963-1-ming.lei@redhat.com> <20170808084548.18963-47-ming.lei@redhat.com>
From: Filipe Manana <fdmanana@gmail.com>
Date: Tue, 8 Aug 2017 10:00:02 +0100
Message-ID: <CAL3q7H5=f5MAZRN1SzkEhBSHbyXCexVHQPnj=PnWioChYQz7rg@mail.gmail.com>
Subject: Re: [PATCH v3 46/49] fs/btrfs: convert to bio_for_each_segment_all_sp()
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Huang Ying <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.com>, "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>

On Tue, Aug 8, 2017 at 9:45 AM, Ming Lei <ming.lei@redhat.com> wrote:
> Cc: Chris Mason <clm@fb.com>
> Cc: Josef Bacik <jbacik@fb.com>
> Cc: David Sterba <dsterba@suse.com>
> Cc: linux-btrfs@vger.kernel.org
> Signed-off-by: Ming Lei <ming.lei@redhat.com>

Can you please add some meaningful changelog? E.g., why is this
conversion needed.

> ---
>  fs/btrfs/compression.c |  3 ++-
>  fs/btrfs/disk-io.c     |  3 ++-
>  fs/btrfs/extent_io.c   | 12 ++++++++----
>  fs/btrfs/inode.c       |  6 ++++--
>  fs/btrfs/raid56.c      |  1 +
>  5 files changed, 17 insertions(+), 8 deletions(-)
>
> diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
> index 28746588f228..55f251a83d0b 100644
> --- a/fs/btrfs/compression.c
> +++ b/fs/btrfs/compression.c
> @@ -147,13 +147,14 @@ static void end_compressed_bio_read(struct bio *bio=
)
>         } else {
>                 int i;
>                 struct bio_vec *bvec;
> +               struct bvec_iter_all bia;
>
>                 /*
>                  * we have verified the checksum already, set page
>                  * checked so the end_io handlers know about it
>                  */
>                 ASSERT(!bio_flagged(bio, BIO_CLONED));
> -               bio_for_each_segment_all(bvec, cb->orig_bio, i)
> +               bio_for_each_segment_all_sp(bvec, cb->orig_bio, i, bia)
>                         SetPageChecked(bvec->bv_page);
>
>                 bio_endio(cb->orig_bio);
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index 080e2ebb8aa0..a9cd75e6383d 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -963,9 +963,10 @@ static blk_status_t btree_csum_one_bio(struct bio *b=
io)
>         struct bio_vec *bvec;
>         struct btrfs_root *root;
>         int i, ret =3D 0;
> +       struct bvec_iter_all bia;
>
>         ASSERT(!bio_flagged(bio, BIO_CLONED));
> -       bio_for_each_segment_all(bvec, bio, i) {
> +       bio_for_each_segment_all_sp(bvec, bio, i, bia) {
>                 root =3D BTRFS_I(bvec->bv_page->mapping->host)->root;
>                 ret =3D csum_dirty_buffer(root->fs_info, bvec->bv_page);
>                 if (ret)
> diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
> index c8f6a8657bf2..4de9cfd1c385 100644
> --- a/fs/btrfs/extent_io.c
> +++ b/fs/btrfs/extent_io.c
> @@ -2359,8 +2359,9 @@ static unsigned int get_bio_pages(struct bio *bio)
>  {
>         unsigned i;
>         struct bio_vec *bv;
> +       struct bvec_iter_all bia;
>
> -       bio_for_each_segment_all(bv, bio, i)
> +       bio_for_each_segment_all_sp(bv, bio, i, bia)
>                 ;
>
>         return i;
> @@ -2463,9 +2464,10 @@ static void end_bio_extent_writepage(struct bio *b=
io)
>         u64 start;
>         u64 end;
>         int i;
> +       struct bvec_iter_all bia;
>
>         ASSERT(!bio_flagged(bio, BIO_CLONED));
> -       bio_for_each_segment_all(bvec, bio, i) {
> +       bio_for_each_segment_all_sp(bvec, bio, i, bia) {
>                 struct page *page =3D bvec->bv_page;
>                 struct inode *inode =3D page->mapping->host;
>                 struct btrfs_fs_info *fs_info =3D btrfs_sb(inode->i_sb);
> @@ -2534,9 +2536,10 @@ static void end_bio_extent_readpage(struct bio *bi=
o)
>         int mirror;
>         int ret;
>         int i;
> +       struct bvec_iter_all bia;
>
>         ASSERT(!bio_flagged(bio, BIO_CLONED));
> -       bio_for_each_segment_all(bvec, bio, i) {
> +       bio_for_each_segment_all_sp(bvec, bio, i, bia) {
>                 struct page *page =3D bvec->bv_page;
>                 struct inode *inode =3D page->mapping->host;
>                 struct btrfs_fs_info *fs_info =3D btrfs_sb(inode->i_sb);
> @@ -3693,9 +3696,10 @@ static void end_bio_extent_buffer_writepage(struct=
 bio *bio)
>         struct bio_vec *bvec;
>         struct extent_buffer *eb;
>         int i, done;
> +       struct bvec_iter_all bia;
>
>         ASSERT(!bio_flagged(bio, BIO_CLONED));
> -       bio_for_each_segment_all(bvec, bio, i) {
> +       bio_for_each_segment_all_sp(bvec, bio, i, bia) {
>                 struct page *page =3D bvec->bv_page;
>
>                 eb =3D (struct extent_buffer *)page->private;
> diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
> index 084ed99dd308..eeb2ff662ec4 100644
> --- a/fs/btrfs/inode.c
> +++ b/fs/btrfs/inode.c
> @@ -8047,6 +8047,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bi=
o)
>         struct bio_vec *bvec;
>         struct extent_io_tree *io_tree, *failure_tree;
>         int i;
> +       struct bvec_iter_all bia;
>
>         if (bio->bi_status)
>                 goto end;
> @@ -8064,7 +8065,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bi=
o)
>
>         done->uptodate =3D 1;
>         ASSERT(!bio_flagged(bio, BIO_CLONED));
> -       bio_for_each_segment_all(bvec, bio, i)
> +       bio_for_each_segment_all_sp(bvec, bio, i, bia)
>                 clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_t=
ree,
>                                  io_tree, done->start, bvec->bv_page,
>                                  btrfs_ino(BTRFS_I(inode)), 0);
> @@ -8143,6 +8144,7 @@ static void btrfs_retry_endio(struct bio *bio)
>         int uptodate;
>         int ret;
>         int i;
> +       struct bvec_iter_all bia;
>
>         if (bio->bi_status)
>                 goto end;
> @@ -8162,7 +8164,7 @@ static void btrfs_retry_endio(struct bio *bio)
>         failure_tree =3D &BTRFS_I(inode)->io_failure_tree;
>
>         ASSERT(!bio_flagged(bio, BIO_CLONED));
> -       bio_for_each_segment_all(bvec, bio, i) {
> +       bio_for_each_segment_all_sp(bvec, bio, i, bia) {
>                 ret =3D __readpage_endio_check(inode, io_bio, i, bvec->bv=
_page,
>                                              bvec->bv_offset, done->start=
,
>                                              bvec->bv_len);
> diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
> index 208638384cd2..9247226a2efd 100644
> --- a/fs/btrfs/raid56.c
> +++ b/fs/btrfs/raid56.c
> @@ -1365,6 +1365,7 @@ static int find_logical_bio_stripe(struct btrfs_rai=
d_bio *rbio,
>         u64 logical =3D bio->bi_iter.bi_sector;
>         u64 stripe_start;
>         int i;
> +       struct bvec_iter_all bia;

Unused variable.

Thanks.

>
>         logical <<=3D 9;
>
> --
> 2.9.4
>



--=20
Filipe David Manana,

=E2=80=9CWhether you think you can, or you think you can't =E2=80=94 you're=
 right.=E2=80=9D

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
