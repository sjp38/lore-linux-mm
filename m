Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE006B0008
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 08:34:44 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id k76so14284698iod.12
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 05:34:44 -0800 (PST)
Received: from h3cmg01-ex.h3c.com (smtp.h3c.com. [60.191.123.56])
        by mx.google.com with ESMTP id q42si5182517ioi.17.2018.01.31.05.34.40
        for <linux-mm@kvack.org>;
        Wed, 31 Jan 2018 05:34:42 -0800 (PST)
From: Changwei Ge <ge.changwei@h3c.com>
Subject: Re: [linux-next:master 10644/11012] fs/ocfs2/alloc.c:6761
 ocfs2_reuse_blk_from_dealloc() warn: potentially one past the end of array
 'new_eb_bh[i]'
Date: Wed, 31 Jan 2018 13:22:45 +0000
Message-ID: <63ADC13FD55D6546B7DECE290D39E373F29196AE@H3CMLB12-EX.srv.huawei-3com.com>
References: <20180131105004.xdig2mzgrmiagf5l@mwanda>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>, "kbuild@01.org" <kbuild@01.org>
Cc: "kbuild-all@01.org" <kbuild-all@01.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Dan,=0A=
=0A=
In order to make static checker happy, I wanna give a fix to silence those =
warning.=0A=
Could you please help to trigger the checker again to see if they are gone.=
=0A=
=0A=
If any further warning shows up, please feel free to let me know.=0A=
=0A=
Subject: [PATCH] ocfs2: fix static checker warnning=0A=
=0A=
Signed-off-by: Changwei Ge <ge.changwei@h3c.com>=0A=
---=0A=
  fs/ocfs2/alloc.c | 4 ++--=0A=
  1 file changed, 2 insertions(+), 2 deletions(-)=0A=
=0A=
diff --git a/fs/ocfs2/alloc.c b/fs/ocfs2/alloc.c=0A=
index ec1ebbf..084b8b9 100644=0A=
--- a/fs/ocfs2/alloc.c=0A=
+++ b/fs/ocfs2/alloc.c=0A=
@@ -6765,8 +6765,8 @@ static int ocfs2_reuse_blk_from_dealloc(handle_t *han=
dle,=0A=
  	*blk_given =3D i;=0A=
  =0A=
  bail:=0A=
-	if (unlikely(status)) {=0A=
-		for (; i >=3D 0; i--) {=0A=
+	if (unlikely(status < 0)) {=0A=
+		for (i =3D 0; i < blk_wanted; i++) {=0A=
  			if (new_eb_bh[i])=0A=
  				brelse(new_eb_bh[i]);=0A=
  		}=0A=
-- =0A=
2.7.4=0A=
=0A=
=0A=
On 2018/1/31 18:55, Dan Carpenter wrote:=0A=
> =0A=
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.g=
it master=0A=
> head:   761914dd2975bc443024f0ec10a66a26b7186ec2=0A=
> commit: 0d3e622b2ac768ac5a94f8d9ede80a051154ea9e [10644/11012] ocfs2: try=
 to reuse extent block in dealloc without meta_alloc=0A=
> =0A=
> New smatch warnings:=0A=
> fs/ocfs2/alloc.c:6761 ocfs2_reuse_blk_from_dealloc() warn: potentially on=
e past the end of array 'new_eb_bh[i]'=0A=
> fs/ocfs2/alloc.c:6761 ocfs2_reuse_blk_from_dealloc() warn: potentially on=
e past the end of array 'new_eb_bh[i]'=0A=
> =0A=
> Old smatch warnings:=0A=
> fs/ocfs2/alloc.c:6762 ocfs2_reuse_blk_from_dealloc() warn: potentially on=
e past the end of array 'new_eb_bh[i]'=0A=
> fs/ocfs2/alloc.c:6762 ocfs2_reuse_blk_from_dealloc() warn: potentially on=
e past the end of array 'new_eb_bh[i]'=0A=
> fs/ocfs2/alloc.c:6887 ocfs2_zero_cluster_pages() warn: should '(page->ind=
ex + 1) << 12' be a 64 bit type?=0A=
> =0A=
> # https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/com=
mit/?id=3D0d3e622b2ac768ac5a94f8d9ede80a051154ea9e=0A=
> git remote add linux-next https://git.kernel.org/pub/scm/linux/kernel/git=
/next/linux-next.git=0A=
> git remote update linux-next=0A=
> git checkout 0d3e622b2ac768ac5a94f8d9ede80a051154ea9e=0A=
> vim +6761 fs/ocfs2/alloc.c=0A=
> =0A=
> 0d3e622b Changwei Ge 2018-01-19  6662=0A=
> 0d3e622b Changwei Ge 2018-01-19  6663  /* If extent was deleted from tree=
 due to extent rotation and merging, and=0A=
> 0d3e622b Changwei Ge 2018-01-19  6664   * no metadata is reserved ahead o=
f time. Try to reuse some extents=0A=
> 0d3e622b Changwei Ge 2018-01-19  6665   * just deleted. This is only used=
 to reuse extent blocks.=0A=
> 0d3e622b Changwei Ge 2018-01-19  6666   * It is supposed to find enough e=
xtent blocks in dealloc if our estimation=0A=
> 0d3e622b Changwei Ge 2018-01-19  6667   * on metadata is accurate.=0A=
> 0d3e622b Changwei Ge 2018-01-19  6668   */=0A=
> 0d3e622b Changwei Ge 2018-01-19  6669  static int ocfs2_reuse_blk_from_de=
alloc(handle_t *handle,=0A=
> 0d3e622b Changwei Ge 2018-01-19  6670  					struct ocfs2_extent_tree *et,=
=0A=
> 0d3e622b Changwei Ge 2018-01-19  6671  					struct buffer_head **new_eb_b=
h,=0A=
> 0d3e622b Changwei Ge 2018-01-19  6672  					int blk_wanted, int *blk_give=
n)=0A=
> 0d3e622b Changwei Ge 2018-01-19  6673  {=0A=
> 0d3e622b Changwei Ge 2018-01-19  6674  	int i, status =3D 0, real_slot;=
=0A=
> 0d3e622b Changwei Ge 2018-01-19  6675  	struct ocfs2_cached_dealloc_ctxt =
*dealloc;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6676  	struct ocfs2_per_slot_free_list *=
fl;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6677  	struct ocfs2_cached_block_free *b=
f;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6678  	struct ocfs2_extent_block *eb;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6679  	struct ocfs2_super *osb =3D=0A=
> 0d3e622b Changwei Ge 2018-01-19  6680  		OCFS2_SB(ocfs2_metadata_cache_ge=
t_super(et->et_ci));=0A=
> 0d3e622b Changwei Ge 2018-01-19  6681=0A=
> 0d3e622b Changwei Ge 2018-01-19  6682  	*blk_given =3D 0;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6683=0A=
> 0d3e622b Changwei Ge 2018-01-19  6684  	/* If extent tree doesn't have a =
dealloc, this is not faulty. Just=0A=
> 0d3e622b Changwei Ge 2018-01-19  6685  	 * tell upper caller dealloc can'=
t provide any block and it should=0A=
> 0d3e622b Changwei Ge 2018-01-19  6686  	 * ask for alloc to claim more sp=
ace.=0A=
> 0d3e622b Changwei Ge 2018-01-19  6687  	 */=0A=
> 0d3e622b Changwei Ge 2018-01-19  6688  	dealloc =3D et->et_dealloc;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6689  	if (!dealloc)=0A=
> 0d3e622b Changwei Ge 2018-01-19  6690  		goto bail;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6691=0A=
> 0d3e622b Changwei Ge 2018-01-19  6692  	for (i =3D 0; i < blk_wanted; i++=
) {=0A=
> 0d3e622b Changwei Ge 2018-01-19  6693  		/* Prefer to use local slot */=
=0A=
> 0d3e622b Changwei Ge 2018-01-19  6694  		fl =3D ocfs2_find_preferred_free=
_list(EXTENT_ALLOC_SYSTEM_INODE,=0A=
> 0d3e622b Changwei Ge 2018-01-19  6695  						    osb->slot_num, &real_slo=
t,=0A=
> 0d3e622b Changwei Ge 2018-01-19  6696  						    dealloc);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6697  		/* If no more block can be reuse=
d, we should claim more=0A=
> 0d3e622b Changwei Ge 2018-01-19  6698  		 * from alloc. Just return here =
normally.=0A=
> 0d3e622b Changwei Ge 2018-01-19  6699  		 */=0A=
> 0d3e622b Changwei Ge 2018-01-19  6700  		if (!fl) {=0A=
> 0d3e622b Changwei Ge 2018-01-19  6701  			status =3D 0;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6702  			break;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6703  		}=0A=
> 0d3e622b Changwei Ge 2018-01-19  6704=0A=
> 0d3e622b Changwei Ge 2018-01-19  6705  		bf =3D fl->f_first;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6706  		fl->f_first =3D bf->free_next;=
=0A=
> 0d3e622b Changwei Ge 2018-01-19  6707=0A=
> 0d3e622b Changwei Ge 2018-01-19  6708  		new_eb_bh[i] =3D sb_getblk(osb->=
sb, bf->free_blk);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6709  		if (new_eb_bh[i] =3D=3D NULL) {=
=0A=
> 0d3e622b Changwei Ge 2018-01-19  6710  			status =3D -ENOMEM;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6711  			mlog_errno(status);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6712  			goto bail;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6713  		}=0A=
> 0d3e622b Changwei Ge 2018-01-19  6714=0A=
> 0d3e622b Changwei Ge 2018-01-19  6715  		mlog(0, "Reusing block(%llu) fro=
m "=0A=
> 0d3e622b Changwei Ge 2018-01-19  6716  		     "dealloc(local slot:%d, rea=
l slot:%d)\n",=0A=
> 0d3e622b Changwei Ge 2018-01-19  6717  		     bf->free_blk, osb->slot_num=
, real_slot);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6718=0A=
> 0d3e622b Changwei Ge 2018-01-19  6719  		ocfs2_set_new_buffer_uptodate(et=
->et_ci, new_eb_bh[i]);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6720=0A=
> 0d3e622b Changwei Ge 2018-01-19  6721  		status =3D ocfs2_journal_access_=
eb(handle, et->et_ci,=0A=
> 0d3e622b Changwei Ge 2018-01-19  6722  						 new_eb_bh[i],=0A=
> 0d3e622b Changwei Ge 2018-01-19  6723  						 OCFS2_JOURNAL_ACCESS_CREATE=
);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6724  		if (status < 0) {=0A=
>                                                      ^^^^^^^^^^=0A=
> The warning is a false positive.  It's caused because the check here is=
=0A=
> for less than zero and the check at the end is for non-zero.  The static=
=0A=
> checker is thinking that status can be > 0 here.=0A=
> =0A=
> If both checks were written the same way, that would silence the=0A=
> warning.=0A=
> =0A=
> Also if you rebuild your cross function DB a bunch of time that silences=
=0A=
> the warning because then Smatch know that ocfs2_journal_access_eb()=0A=
> returns (-30),(-22),(-5), or 0.  I rebuild my DB every morning on the=0A=
> latest linux-next so I don't see this warning on my system.=0A=
> =0A=
> 0d3e622b Changwei Ge 2018-01-19  6725  			mlog_errno(status);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6726  			goto bail;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6727  		}=0A=
> 0d3e622b Changwei Ge 2018-01-19  6728=0A=
> 0d3e622b Changwei Ge 2018-01-19  6729  		memset(new_eb_bh[i]->b_data, 0, =
osb->sb->s_blocksize);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6730  		eb =3D (struct ocfs2_extent_bloc=
k *) new_eb_bh[i]->b_data;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6731=0A=
> 0d3e622b Changwei Ge 2018-01-19  6732  		/* We can't guarantee that buffe=
r head is still cached, so=0A=
> 0d3e622b Changwei Ge 2018-01-19  6733  		 * polutlate the extent block ag=
ain.=0A=
> 0d3e622b Changwei Ge 2018-01-19  6734  		 */=0A=
> 0d3e622b Changwei Ge 2018-01-19  6735  		strcpy(eb->h_signature, OCFS2_EX=
TENT_BLOCK_SIGNATURE);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6736  		eb->h_blkno =3D cpu_to_le64(bf->=
free_blk);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6737  		eb->h_fs_generation =3D cpu_to_l=
e32(osb->fs_generation);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6738  		eb->h_suballoc_slot =3D cpu_to_l=
e16(real_slot);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6739  		eb->h_suballoc_loc =3D cpu_to_le=
64(bf->free_bg);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6740  		eb->h_suballoc_bit =3D cpu_to_le=
16(bf->free_bit);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6741  		eb->h_list.l_count =3D=0A=
> 0d3e622b Changwei Ge 2018-01-19  6742  			cpu_to_le16(ocfs2_extent_recs_p=
er_eb(osb->sb));=0A=
> 0d3e622b Changwei Ge 2018-01-19  6743=0A=
> 0d3e622b Changwei Ge 2018-01-19  6744  		/* We'll also be dirtied by the =
caller, so=0A=
> 0d3e622b Changwei Ge 2018-01-19  6745  		 * this isn't absolutely necessa=
ry.=0A=
> 0d3e622b Changwei Ge 2018-01-19  6746  		 */=0A=
> 0d3e622b Changwei Ge 2018-01-19  6747  		ocfs2_journal_dirty(handle, new_=
eb_bh[i]);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6748=0A=
> 0d3e622b Changwei Ge 2018-01-19  6749  		if (!fl->f_first) {=0A=
> 0d3e622b Changwei Ge 2018-01-19  6750  			dealloc->c_first_suballocator =
=3D fl->f_next_suballocator;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6751  			kfree(fl);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6752  		}=0A=
> 0d3e622b Changwei Ge 2018-01-19  6753  		kfree(bf);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6754  	}=0A=
> 0d3e622b Changwei Ge 2018-01-19  6755=0A=
> 0d3e622b Changwei Ge 2018-01-19  6756  	*blk_given =3D i;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6757=0A=
> 0d3e622b Changwei Ge 2018-01-19  6758  bail:=0A=
> 0d3e622b Changwei Ge 2018-01-19  6759  	if (unlikely(status)) {=0A=
>                                                       ^^^^^^=0A=
> =0A=
> 0d3e622b Changwei Ge 2018-01-19  6760  		for (; i >=3D 0; i--) {=0A=
> 0d3e622b Changwei Ge 2018-01-19 @6761  			if (new_eb_bh[i])=0A=
> 0d3e622b Changwei Ge 2018-01-19  6762  				brelse(new_eb_bh[i]);=0A=
> 0d3e622b Changwei Ge 2018-01-19  6763  		}=0A=
> 0d3e622b Changwei Ge 2018-01-19  6764  	}=0A=
> 0d3e622b Changwei Ge 2018-01-19  6765=0A=
> 0d3e622b Changwei Ge 2018-01-19  6766  	return status;=0A=
> 0d3e622b Changwei Ge 2018-01-19  6767  }=0A=
> 0d3e622b Changwei Ge 2018-01-19  6768=0A=
> =0A=
> ---=0A=
> 0-DAY kernel test infrastructure                Open Source Technology Ce=
nter=0A=
> https://lists.01.org/pipermail/kbuild-all                   Intel Corpora=
tion=0A=
> =0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
