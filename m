Subject: [PATCH 09/23] lib: percpu_counter_init error handling
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070817155659.GD24323@filer.fsl.cs.sunysb.edu>
References: <20070816074525.065850000@chello.nl>
	 <20070816074626.739944000@chello.nl>
	 <20070817155659.GD24323@filer.fsl.cs.sunysb.edu>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-udGAS9+EExMDI/FMsiLl"
Date: Sat, 18 Aug 2007 10:09:34 +0200
Message-Id: <1187424574.6114.136.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

--=-udGAS9+EExMDI/FMsiLl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2007-08-17 at 11:56 -0400, Josef Sipek wrote:
> On Thu, Aug 16, 2007 at 09:45:34AM +0200, Peter Zijlstra wrote:

> > Index: linux-2.6/fs/ext2/super.c
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > --- linux-2.6.orig/fs/ext2/super.c
> > +++ linux-2.6/fs/ext2/super.c
> > @@ -725,6 +725,7 @@ static int ext2_fill_super(struct super_
> >  	int db_count;
> >  	int i, j;
> >  	__le32 features;
> > +	int err;
> > =20
> >  	sbi =3D kzalloc(sizeof(*sbi), GFP_KERNEL);
> >  	if (!sbi)
> > @@ -996,12 +997,16 @@ static int ext2_fill_super(struct super_
> >  	sbi->s_rsv_window_head.rsv_goal_size =3D 0;
> >  	ext2_rsv_window_add(sb, &sbi->s_rsv_window_head);
> > =20
> > -	percpu_counter_init(&sbi->s_freeblocks_counter,
> > +	err =3D percpu_counter_init(&sbi->s_freeblocks_counter,
> >  				ext2_count_free_blocks(sb));
> > -	percpu_counter_init(&sbi->s_freeinodes_counter,
> > +	err |=3D percpu_counter_init(&sbi->s_freeinodes_counter,
> >  				ext2_count_free_inodes(sb));
> > -	percpu_counter_init(&sbi->s_dirs_counter,
> > +	err |=3D percpu_counter_init(&sbi->s_dirs_counter,
> >  				ext2_count_dirs(sb));
> > +	if (err) {
> > +		printk(KERN_ERR "EXT2-fs: insufficient memory\n");
> > +		goto failed_mount3;
> > +	}
>=20
> Can percpu_counter_init fail with only one error code? If not, the error
> code potentially used in future at failed_mount3 could be nonsensical
> because of the bitwise or-ing.

The actual value of err is irrelevant, it is not used after this not
zero check.

But how about this:
---
Subject: lib: percpu_counter_init error handling

alloc_percpu can fail, propagate that error.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/ext2/super.c                |   15 ++++++++++++---
 fs/ext3/super.c                |   21 +++++++++++++++------
 fs/ext4/super.c                |   21 +++++++++++++++------
 include/linux/percpu_counter.h |    5 +++--
 lib/percpu_counter.c           |    8 +++++++-
 5 files changed, 52 insertions(+), 18 deletions(-)

Index: linux-2.6/fs/ext2/super.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/fs/ext2/super.c
+++ linux-2.6/fs/ext2/super.c
@@ -725,6 +725,7 @@ static int ext2_fill_super(struct super_
 	int db_count;
 	int i, j;
 	__le32 features;
+	int err;
=20
 	sbi =3D kzalloc(sizeof(*sbi), GFP_KERNEL);
 	if (!sbi)
@@ -996,12 +997,20 @@ static int ext2_fill_super(struct super_
 	sbi->s_rsv_window_head.rsv_goal_size =3D 0;
 	ext2_rsv_window_add(sb, &sbi->s_rsv_window_head);
=20
-	percpu_counter_init(&sbi->s_freeblocks_counter,
+	err =3D percpu_counter_init(&sbi->s_freeblocks_counter,
 				ext2_count_free_blocks(sb));
-	percpu_counter_init(&sbi->s_freeinodes_counter,
+	if (!err) {
+		err =3D percpu_counter_init(&sbi->s_freeinodes_counter,
 				ext2_count_free_inodes(sb));
-	percpu_counter_init(&sbi->s_dirs_counter,
+	}
+	if (!err) {
+		err =3D percpu_counter_init(&sbi->s_dirs_counter,
 				ext2_count_dirs(sb));
+	}
+	if (err) {
+		printk(KERN_ERR "EXT2-fs: insufficient memory\n");
+		goto failed_mount3;
+	}
 	/*
 	 * set up enough so that it can read an inode
 	 */
Index: linux-2.6/fs/ext3/super.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/fs/ext3/super.c
+++ linux-2.6/fs/ext3/super.c
@@ -1485,6 +1485,7 @@ static int ext3_fill_super (struct super
 	int i;
 	int needs_recovery;
 	__le32 features;
+	int err;
=20
 	sbi =3D kzalloc(sizeof(*sbi), GFP_KERNEL);
 	if (!sbi)
@@ -1745,12 +1746,20 @@ static int ext3_fill_super (struct super
 	get_random_bytes(&sbi->s_next_generation, sizeof(u32));
 	spin_lock_init(&sbi->s_next_gen_lock);
=20
-	percpu_counter_init(&sbi->s_freeblocks_counter,
-		ext3_count_free_blocks(sb));
-	percpu_counter_init(&sbi->s_freeinodes_counter,
-		ext3_count_free_inodes(sb));
-	percpu_counter_init(&sbi->s_dirs_counter,
-		ext3_count_dirs(sb));
+	err =3D percpu_counter_init(&sbi->s_freeblocks_counter,
+			ext3_count_free_blocks(sb));
+	if (!err) {
+		err =3D percpu_counter_init(&sbi->s_freeinodes_counter,
+				ext3_count_free_inodes(sb));
+	}
+	if (!err) {
+		err =3D percpu_counter_init(&sbi->s_dirs_counter,
+				ext3_count_dirs(sb));
+	}
+	if (err) {
+		printk(KERN_ERR "EXT3-fs: insufficient memory\n");
+		goto failed_mount3;
+	}
=20
 	/* per fileystem reservation list head & lock */
 	spin_lock_init(&sbi->s_rsv_window_lock);
Index: linux-2.6/fs/ext4/super.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/fs/ext4/super.c
+++ linux-2.6/fs/ext4/super.c
@@ -1576,6 +1576,7 @@ static int ext4_fill_super (struct super
 	int needs_recovery;
 	__le32 features;
 	__u64 blocks_count;
+	int err;
=20
 	sbi =3D kzalloc(sizeof(*sbi), GFP_KERNEL);
 	if (!sbi)
@@ -1857,12 +1858,20 @@ static int ext4_fill_super (struct super
 	get_random_bytes(&sbi->s_next_generation, sizeof(u32));
 	spin_lock_init(&sbi->s_next_gen_lock);
=20
-	percpu_counter_init(&sbi->s_freeblocks_counter,
-		ext4_count_free_blocks(sb));
-	percpu_counter_init(&sbi->s_freeinodes_counter,
-		ext4_count_free_inodes(sb));
-	percpu_counter_init(&sbi->s_dirs_counter,
-		ext4_count_dirs(sb));
+	err =3D percpu_counter_init(&sbi->s_freeblocks_counter,
+			ext4_count_free_blocks(sb));
+	if (!err) {
+		err =3D percpu_counter_init(&sbi->s_freeinodes_counter,
+				ext4_count_free_inodes(sb));
+	}
+	if (!err) {
+		err =3D percpu_counter_init(&sbi->s_dirs_counter,
+				ext4_count_dirs(sb));
+	}
+	if (err) {
+		printk(KERN_ERR "EXT4-fs: insufficient memory\n");
+		goto failed_mount3;
+	}
=20
 	/* per fileystem reservation list head & lock */
 	spin_lock_init(&sbi->s_rsv_window_lock);
Index: linux-2.6/include/linux/percpu_counter.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/include/linux/percpu_counter.h
+++ linux-2.6/include/linux/percpu_counter.h
@@ -30,7 +30,7 @@ struct percpu_counter {
 #define FBC_BATCH	(NR_CPUS*4)
 #endif
=20
-void percpu_counter_init(struct percpu_counter *fbc, s64 amount);
+int percpu_counter_init(struct percpu_counter *fbc, s64 amount);
 void percpu_counter_destroy(struct percpu_counter *fbc);
 void percpu_counter_set(struct percpu_counter *fbc, s64 amount);
 void __percpu_counter_add(struct percpu_counter *fbc, s64 amount, s32 batc=
h);
@@ -78,9 +78,10 @@ struct percpu_counter {
 	s64 count;
 };
=20
-static inline void percpu_counter_init(struct percpu_counter *fbc, s64 amo=
unt)
+static inline int percpu_counter_init(struct percpu_counter *fbc, s64 amou=
nt)
 {
 	fbc->count =3D amount;
+	return 0;
 }
=20
 static inline void percpu_counter_destroy(struct percpu_counter *fbc)
Index: linux-2.6/lib/percpu_counter.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.orig/lib/percpu_counter.c
+++ linux-2.6/lib/percpu_counter.c
@@ -68,21 +68,27 @@ s64 __percpu_counter_sum(struct percpu_c
 }
 EXPORT_SYMBOL(__percpu_counter_sum);
=20
-void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
+int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
 {
 	spin_lock_init(&fbc->lock);
 	fbc->count =3D amount;
 	fbc->counters =3D alloc_percpu(s32);
+	if (!fbc->counters)
+		return -ENOMEM;
 #ifdef CONFIG_HOTPLUG_CPU
 	mutex_lock(&percpu_counters_lock);
 	list_add(&fbc->list, &percpu_counters);
 	mutex_unlock(&percpu_counters_lock);
 #endif
+	return 0;
 }
 EXPORT_SYMBOL(percpu_counter_init);
=20
 void percpu_counter_destroy(struct percpu_counter *fbc)
 {
+	if (!fbc->counters)
+		return;
+
 	free_percpu(fbc->counters);
 #ifdef CONFIG_HOTPLUG_CPU
 	mutex_lock(&percpu_counters_lock);


--=-udGAS9+EExMDI/FMsiLl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGxqk+XA2jU0ANEf4RAlyFAJ44s8rqWuwg+fYvwooKsX+DGOW6ZgCfT8sh
gysDjgShL+Uq65rXR/z7mRY=
=dHoU
-----END PGP SIGNATURE-----

--=-udGAS9+EExMDI/FMsiLl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
