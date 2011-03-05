Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 265228D0039
	for <linux-mm@kvack.org>; Sat,  5 Mar 2011 06:22:37 -0500 (EST)
Date: Sat, 5 Mar 2011 12:21:40 +0100
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: [PATCH] tmpfs: implement security.capability xattrs
Message-ID: <20110305122140.010ef7f8@neptune.home>
In-Reply-To: <AANLkTi=7GyY=O2eTupPXQijcnT_55a3RnHAruJpm_5Jo@mail.gmail.com>
References: <20110111210710.32348.1642.stgit@paris.rdu.redhat.com>
	<AANLkTi=wyaLP6gFmNxajp+HtYu3B9_KGf2o4BnYA+rwy@mail.gmail.com>
	<AANLkTi=7GyY=O2eTupPXQijcnT_55a3RnHAruJpm_5Jo@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Paris <eparis@parisplace.org>
Cc: Eric Paris <eparis@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 02 March 2011 Eric Paris <eparis@parisplace.org> wrote:
> I know there exist thoughts on this patch somewhere on the internets.
> Let 'em rip!  I can handle it!

Hi Eric,

I have not read the code behind CONFIG_TMPFS_POSIX_ACL in depth but it
does seem to already use some XATTR support for making posix acls
available.

Your patch looks like not touching/using that support, maybe there is
already some of your work previously done (according to comment in
mm/shmem.c offered for free by VFS).

Did I miss something essential?

Regards,
Bruno

> -Eric
>=20
> On Thu, Feb 17, 2011 at 4:27 PM, Eric Paris <eparis@parisplace.org> wrote:
> > Bueller? =C2=A0Bueller? =C2=A0Any thoughts? =C2=A0Any problems?
> >
> > On Tue, Jan 11, 2011 at 4:07 PM, Eric Paris <eparis@redhat.com> wrote:
> >> This patch implements security.capability xattrs for tmpfs filesystems=
. =C2=A0The
> >> feodra project, while trying to replace suid apps with file capabiliti=
es,
> >> realized that tmpfs, which is used on my build systems, does not suppo=
rt file
> >> capabilities and thus cannot be used to build packages which use file
> >> capabilities. =C2=A0The patch only implements security.capability but =
there is no
> >> reason it could not be easily expanded to support *.* xattrs as most o=
f the
> >> work is already done. =C2=A0I don't know what other xattrs are in use =
in the world
> >> or if they necessarily make sense on tmpfs so I didn't make this
> >> implementation completely generic.
> >>
> >> The basic implementation is that I attach a
> >> struct shmem_xattr {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head list; /* anchored by shmem=
_inode_info->xattr_list */
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0char *name;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t size;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0char value[0];
> >> };
> >> Into the struct shmem_inode_info for each xattr that is set. =C2=A0Sin=
ce I only
> >> allow security.capability obviously this list is only every 0 or 1 ent=
ry long.
> >> I could have been a little simpler, but then the next person having to
> >> implement an xattr would have to redo everything I did instead of me j=
ust
> >> doing 90% of their work =C2=A0:)
> >>
> >> Signed-off-by: Eric Paris <eparis@redhat.com>
> >> ---
> >>
> >> =C2=A0include/linux/shmem_fs.h | =C2=A0 =C2=A08 +++
> >> =C2=A0mm/shmem.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =
=C2=A0112 ++++++++++++++++++++++++++++++++++++++++++++--
> >> =C2=A02 files changed, 116 insertions(+), 4 deletions(-)
> >>
> >> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> >> index 399be5a..6f2ebb8 100644
> >> --- a/include/linux/shmem_fs.h
> >> +++ b/include/linux/shmem_fs.h
> >> @@ -9,6 +9,13 @@
> >>
> >> =C2=A0#define SHMEM_NR_DIRECT 16
> >>
> >> +struct shmem_xattr {
> >> + =C2=A0 =C2=A0 =C2=A0 struct list_head list; /* anchored by shmem_ino=
de_info->xattr_list */
> >> + =C2=A0 =C2=A0 =C2=A0 char *name;
> >> + =C2=A0 =C2=A0 =C2=A0 size_t size;
> >> + =C2=A0 =C2=A0 =C2=A0 char value[0];
> >> +};
> >> +
> >> =C2=A0struct shmem_inode_info {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0lock;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 flags;
> >> @@ -19,6 +26,7 @@ struct shmem_inode_info {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 *i_indirect; =C2=A0 =C2=A0/* top indirect blocks page */
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0swp_entry_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 i_direct[SHMEM_NR_DIRECT]; /* first blocks */
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=
=A0swaplist; =C2=A0 =C2=A0 =C2=A0 /* chain of maybes on swap */
> >> + =C2=A0 =C2=A0 =C2=A0 struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=A0xat=
tr_list; =C2=A0 =C2=A0 /* list of shmem_xattr */
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct inode =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0vfs_inode;
> >> =C2=A0};
> >>
> >> diff --git a/mm/shmem.c b/mm/shmem.c
> >> index 86cd21d..d2bacd6 100644
> >> --- a/mm/shmem.c
> >> +++ b/mm/shmem.c
> >> @@ -822,6 +822,7 @@ static int shmem_notify_change(struct dentry *dent=
ry, struct iattr *attr)
> >> =C2=A0static void shmem_evict_inode(struct inode *inode)
> >> =C2=A0{
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct shmem_inode_info *info =3D SHMEM_I(i=
node);
> >> + =C2=A0 =C2=A0 =C2=A0 struct shmem_xattr *xattr, *nxattr;
> >>
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (inode->i_mapping->a_ops =3D=3D &shmem_a=
ops) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0truncate_inode_=
pages(inode->i_mapping, 0);
> >> @@ -834,6 +835,9 @@ static void shmem_evict_inode(struct inode *inode)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0mutex_unlock(&shmem_swaplist_mutex);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry_safe(xattr, nxattr, &info->=
xattr_list, list)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 kfree(xattr);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(inode->i_blocks);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0shmem_free_inode(inode->i_sb);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0end_writeback(inode);
> >> @@ -1597,6 +1601,7 @@ static struct inode *shmem_get_inode(struct supe=
r_block *sb, const struct inode
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock_init(=
&info->lock);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0info->flags =3D=
 flags & VM_NORESERVE;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(=
&info->swaplist);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&inf=
o->xattr_list);
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0cache_no_acl(in=
ode);
> >>
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (mode & =
S_IFMT) {
> >> @@ -2071,24 +2076,123 @@ static size_t shmem_xattr_security_list(struc=
t dentry *dentry, char *list,
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t=
 list_len, const char *name,
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0size_t=
 name_len, int handler_flags)
> >> =C2=A0{
> >> - =C2=A0 =C2=A0 =C2=A0 return security_inode_listsecurity(dentry->d_in=
ode, list, list_len);
> >> + =C2=A0 =C2=A0 =C2=A0 struct shmem_xattr *xattr;
> >> + =C2=A0 =C2=A0 =C2=A0 struct shmem_inode_info *shmem_i;
> >> + =C2=A0 =C2=A0 =C2=A0 size_t used;
> >> + =C2=A0 =C2=A0 =C2=A0 char *buf =3D NULL;
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 used =3D security_inode_listsecurity(dentry->d_=
inode, list, list_len);
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 shmem_i =3D SHMEM_I(dentry->d_inode);
> >> + =C2=A0 =C2=A0 =C2=A0 if (list)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 buf =3D list + used;
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&dentry->d_inode->i_lock);
> >> + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(xattr, &shmem_i->xattr_list=
, list) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 size_t len =3D XATT=
R_SECURITY_PREFIX_LEN;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 len +=3D strlen(xat=
tr->name) + 1;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (list_len - (use=
d + len) >=3D 0 && buf) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 strncpy(buf, XATTR_SECURITY_PREFIX, XATTR_SECURITY_PREFIX_LEN);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 buf +=3D XATTR_SECURITY_PREFIX_LEN;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 strncpy(buf, xattr->name, strlen(xattr->name) + 1);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 buf +=3D strlen(xattr->name) + 1;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 used +=3D len;
> >> + =C2=A0 =C2=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&dentry->d_inode->i_lock);
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 return used;
> >> =C2=A0}
> >>
> >> =C2=A0static int shmem_xattr_security_get(struct dentry *dentry, const=
 char *name,
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0void *buffer, s=
ize_t size, int handler_flags)
> >> =C2=A0{
> >> + =C2=A0 =C2=A0 =C2=A0 struct shmem_inode_info *shmem_i;
> >> + =C2=A0 =C2=A0 =C2=A0 struct shmem_xattr *xattr;
> >> + =C2=A0 =C2=A0 =C2=A0 int ret;
> >> +
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (strcmp(name, "") =3D=3D 0)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;
> >> - =C2=A0 =C2=A0 =C2=A0 return xattr_getsecurity(dentry->d_inode, name,=
 buffer, size);
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 ret =3D xattr_getsecurity(dentry->d_inode, name=
, buffer, size);
> >> + =C2=A0 =C2=A0 =C2=A0 if (ret !=3D -EOPNOTSUPP)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 /* if we make this generic this needs to go... =
*/
> >> + =C2=A0 =C2=A0 =C2=A0 if (strcmp(name, XATTR_CAPS_SUFFIX))
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EOPNOTSUPP;
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 ret =3D -ENODATA;
> >> + =C2=A0 =C2=A0 =C2=A0 shmem_i =3D SHMEM_I(dentry->d_inode);
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&dentry->d_inode->i_lock);
> >> + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(xattr, &shmem_i->xattr_list=
, list) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!strcmp(name, x=
attr->name)) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 ret =3D xattr->size;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (buffer) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (size < xattr->size)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D =
-ERANGE;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 memcpy(b=
uffer, xattr->value, xattr->size);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 break;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&dentry->d_inode->i_lock);
> >> + =C2=A0 =C2=A0 =C2=A0 return ret;
> >> =C2=A0}
> >>
> >> =C2=A0static int shmem_xattr_security_set(struct dentry *dentry, const=
 char *name,
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0const void *val=
ue, size_t size, int flags, int handler_flags)
> >> =C2=A0{
> >> + =C2=A0 =C2=A0 =C2=A0 int ret;
> >> + =C2=A0 =C2=A0 =C2=A0 struct inode *inode =3D dentry->d_inode;
> >> + =C2=A0 =C2=A0 =C2=A0 struct shmem_inode_info *shmem_i =3D SHMEM_I(in=
ode);
> >> + =C2=A0 =C2=A0 =C2=A0 struct shmem_xattr *xattr;
> >> + =C2=A0 =C2=A0 =C2=A0 struct shmem_xattr *new_xattr;
> >> + =C2=A0 =C2=A0 =C2=A0 size_t len;
> >> +
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (strcmp(name, "") =3D=3D 0)
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL;
> >> - =C2=A0 =C2=A0 =C2=A0 return security_inode_setsecurity(dentry->d_ino=
de, name, value,
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s=
ize, flags);
> >> + =C2=A0 =C2=A0 =C2=A0 ret =3D security_inode_setsecurity(inode, name,=
 value, size, flags);
> >> + =C2=A0 =C2=A0 =C2=A0 if (ret !=3D -EOPNOTSUPP)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return ret;
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 /*
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We only store fcaps for now, but this c=
ould be a lot more generic.
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We could hold the prefix as well as the=
 suffix in the xattr struct
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* We would also need to hold a copy of th=
e suffix rather than a
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* pointer to XATTR_CAPS_SUFFIX
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> >> + =C2=A0 =C2=A0 =C2=A0 if (strcmp(name, XATTR_CAPS_SUFFIX))
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EOPNOTSUPP;
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 /* wrap around? */
> >> + =C2=A0 =C2=A0 =C2=A0 len =3D sizeof(*new_xattr) + size;
> >> + =C2=A0 =C2=A0 =C2=A0 if (len <=3D sizeof(*new_xattr))
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 new_xattr =3D kmalloc(GFP_NOFS, len);
> >> + =C2=A0 =C2=A0 =C2=A0 if (!new_xattr)
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -ENOMEM;
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 new_xattr->name =3D XATTR_CAPS_SUFFIX;
> >> + =C2=A0 =C2=A0 =C2=A0 new_xattr->size =3D size;
> >> + =C2=A0 =C2=A0 =C2=A0 memcpy(new_xattr->value, value, size);
> >> +
> >> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&inode->i_lock);
> >> + =C2=A0 =C2=A0 =C2=A0 list_for_each_entry(xattr, &shmem_i->xattr_list=
, list) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!strcmp(name, x=
attr->name)) {
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 list_replace(&xattr->list, &new_xattr->list);
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 goto out;
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 =C2=A0 }
> >> + =C2=A0 =C2=A0 =C2=A0 list_add(&new_xattr->list, &shmem_i->xattr_list=
);
> >> + =C2=A0 =C2=A0 =C2=A0 xattr =3D NULL;
> >> +out:
> >> + =C2=A0 =C2=A0 =C2=A0 spin_unlock(&inode->i_lock);
> >> + =C2=A0 =C2=A0 =C2=A0 kfree(xattr);
> >> + =C2=A0 =C2=A0 =C2=A0 return 0;
> >> =C2=A0}
> >>
> >> =C2=A0static const struct xattr_handler shmem_xattr_security_handler =
=3D {
> >>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
