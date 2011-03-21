Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 385178D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 01:18:08 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p2L5I1rB018847
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 22:18:06 -0700
Received: from iyf13 (iyf13.prod.google.com [10.241.50.77])
	by kpbe16.cbf.corp.google.com with ESMTP id p2L5HSoO021223
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 22:18:00 -0700
Received: by iyf13 with SMTP id 13so8206227iyf.14
        for <linux-mm@kvack.org>; Sun, 20 Mar 2011 22:17:55 -0700 (PDT)
Date: Sun, 20 Mar 2011 22:17:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: implement security.capability xattrs
In-Reply-To: <AANLkTi=7GyY=O2eTupPXQijcnT_55a3RnHAruJpm_5Jo@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1103202108160.21738@sister.anvils>
References: <20110111210710.32348.1642.stgit@paris.rdu.redhat.com> <AANLkTi=wyaLP6gFmNxajp+HtYu3B9_KGf2o4BnYA+rwy@mail.gmail.com> <AANLkTi=7GyY=O2eTupPXQijcnT_55a3RnHAruJpm_5Jo@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-2088098251-1300684679=:21738"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Paris <eparis@parisplace.org>
Cc: Eric Paris <eparis@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Christoph Hellwig <hch@infradead.org>, James Morris <jmorris@namei.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-2088098251-1300684679=:21738
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Wed, 2 Mar 2011, Eric Paris wrote:
> I know there exist thoughts on this patch somewhere on the internets.
> Let 'em rip!  I can handle it!
>=20
> -Eric
>=20
> On Thu, Feb 17, 2011 at 4:27 PM, Eric Paris <eparis@parisplace.org> wrote=
:
> > Bueller? =A0Bueller? =A0Any thoughts? =A0Any problems?
> >

Sorry, Eric, I did spot it months ago, kept on picking it up and
putting it down, never quite got to grips with it.  I did try it out,
and so far as I could tell, it was working correctly.

> > On Tue, Jan 11, 2011 at 4:07 PM, Eric Paris <eparis@redhat.com> wrote:
> >> This patch implements security.capability xattrs for tmpfs filesystems=
=2E =A0The
> >> feodra project, while trying to replace suid apps with file capabiliti=
es,
> >> realized that tmpfs, which is used on my build systems, does not suppo=
rt file
> >> capabilities and thus cannot be used to build packages which use file
> >> capabilities. =A0The patch only implements security.capability but the=
re is no
> >> reason it could not be easily expanded to support *.* xattrs as most o=
f the
> >> work is already done. =A0I don't know what other xattrs are in use in =
the world
> >> or if they necessarily make sense on tmpfs so I didn't make this
> >> implementation completely generic.
> >>
> >> The basic implementation is that I attach a
> >> struct shmem_xattr {
> >> =A0 =A0 =A0 =A0struct list_head list; /* anchored by shmem_inode_info-=
>xattr_list */
> >> =A0 =A0 =A0 =A0char *name;
> >> =A0 =A0 =A0 =A0size_t size;
> >> =A0 =A0 =A0 =A0char value[0];
> >> };
> >> Into the struct shmem_inode_info for each xattr that is set. =A0Since =
I only
> >> allow security.capability obviously this list is only every 0 or 1 ent=
ry long.
> >> I could have been a little simpler, but then the next person having to
> >> implement an xattr would have to redo everything I did instead of me j=
ust
> >> doing 90% of their work =A0:)
> >>
> >> Signed-off-by: Eric Paris <eparis@redhat.com>

I'm unfamiliar with xattrs, and found the security hooks, the way we
dip into and out of them, quite confusing: not to mean that you need
to add lots of comments, no, so long as it works, and is what people
familiar the territory expect, that's okay.

We do like tmpfs to be useful, but it was unclear to me from your
comments above, whether this is just a toy implementation good for
packaging, or a real implementation of security.capability.  I hope
the latter - we do not want something half-baked that will cause
trouble by breaking expectations down the line.

If you can get Acks from James and Christoph, both of whom have been
here before, then it's mostly fine by me; but a few comments below.

> >> ---
> >>
> >> =A0include/linux/shmem_fs.h | =A0 =A08 +++
> >> =A0mm/shmem.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0112 +++++++++++++++++++=
+++++++++++++++++++++++++--
> >> =A02 files changed, 116 insertions(+), 4 deletions(-)

No change to fs/Kconfig?  You seem to smuggle the xattr and security
support in under CONFIG_TMPFS_POSIX_ACL, and leave it unsupported
without.  It's probably a fair assumption that the people with that
option selected are the people who will be interested in this, so
no need for the maze of separate config options which a grownup
filesystem would have here.  But at the very least you need to say
more in the TMPFS_POSIX_ACL Kconfig entry (a new name may be more
trouble than it's worth).

> >>
> >> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
> >> index 399be5a..6f2ebb8 100644
> >> --- a/include/linux/shmem_fs.h
> >> +++ b/include/linux/shmem_fs.h
> >> @@ -9,6 +9,13 @@
> >>
> >> =A0#define SHMEM_NR_DIRECT 16
> >>
> >> +struct shmem_xattr {
> >> + =A0 =A0 =A0 struct list_head list; /* anchored by shmem_inode_info->=
xattr_list */
> >> + =A0 =A0 =A0 char *name;
> >> + =A0 =A0 =A0 size_t size;
> >> + =A0 =A0 =A0 char value[0];
> >> +};
> >> +
> >> =A0struct shmem_inode_info {
> >> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lock;
> >> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags;
> >> @@ -19,6 +26,7 @@ struct shmem_inode_info {
> >> =A0 =A0 =A0 =A0struct page =A0 =A0 =A0 =A0 =A0 =A0 *i_indirect; =A0 =
=A0/* top indirect blocks page */
> >> =A0 =A0 =A0 =A0swp_entry_t =A0 =A0 =A0 =A0 =A0 =A0 i_direct[SHMEM_NR_D=
IRECT]; /* first blocks */
> >> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0swaplist; =A0 =A0 =A0 /=
* chain of maybes on swap */
> >> + =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0xattr_list; =A0 =A0 /* l=
ist of shmem_xattr */
> >> =A0 =A0 =A0 =A0struct inode =A0 =A0 =A0 =A0 =A0 =A0vfs_inode;
> >> =A0};
> >>
> >> diff --git a/mm/shmem.c b/mm/shmem.c
> >> index 86cd21d..d2bacd6 100644
> >> --- a/mm/shmem.c
> >> +++ b/mm/shmem.c
> >> @@ -822,6 +822,7 @@ static int shmem_notify_change(struct dentry *dent=
ry, struct iattr *attr)
> >> =A0static void shmem_evict_inode(struct inode *inode)
> >> =A0{
> >> =A0 =A0 =A0 =A0struct shmem_inode_info *info =3D SHMEM_I(inode);
> >> + =A0 =A0 =A0 struct shmem_xattr *xattr, *nxattr;
> >>
> >> =A0 =A0 =A0 =A0if (inode->i_mapping->a_ops =3D=3D &shmem_aops) {
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0truncate_inode_pages(inode->i_mapping, =
0);
> >> @@ -834,6 +835,9 @@ static void shmem_evict_inode(struct inode *inode)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&shmem_swa=
plist_mutex);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> >> =A0 =A0 =A0 =A0}
> >> +
> >> + =A0 =A0 =A0 list_for_each_entry_safe(xattr, nxattr, &info->xattr_lis=
t, list)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(xattr);
> >> =A0 =A0 =A0 =A0BUG_ON(inode->i_blocks);
> >> =A0 =A0 =A0 =A0shmem_free_inode(inode->i_sb);
> >> =A0 =A0 =A0 =A0end_writeback(inode);
> >> @@ -1597,6 +1601,7 @@ static struct inode *shmem_get_inode(struct supe=
r_block *sb, const struct inode
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_init(&info->lock);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->flags =3D flags & VM_NORESERVE;
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_LIST_HEAD(&info->swaplist);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&info->xattr_list);
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cache_no_acl(inode);
> >>
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (mode & S_IFMT) {
> >> @@ -2071,24 +2076,123 @@ static size_t shmem_xattr_security_list(struc=
t dentry *dentry, char *list,
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0size_t list_len, const char *name,
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0size_t name_len, int handler_flags)
> >> =A0{
> >> - =A0 =A0 =A0 return security_inode_listsecurity(dentry->d_inode, list=
, list_len);
> >> + =A0 =A0 =A0 struct shmem_xattr *xattr;
> >> + =A0 =A0 =A0 struct shmem_inode_info *shmem_i;

It's a nit, but (almost) everywhere else in shmem.c the shmem_inode_info
pointer is known as "info": easy for me to fix up if I care, but nicer
if you follow local custom.

> >> + =A0 =A0 =A0 size_t used;
> >> + =A0 =A0 =A0 char *buf =3D NULL;
> >> +
> >> + =A0 =A0 =A0 used =3D security_inode_listsecurity(dentry->d_inode, li=
st, list_len);
> >> +
> >> + =A0 =A0 =A0 shmem_i =3D SHMEM_I(dentry->d_inode);
> >> + =A0 =A0 =A0 if (list)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf =3D list + used;

This is the place that caused me most trouble.  On a minor note:
it worried me that security_inode_listsecurity() might return an
error, whereas I think you know and assume that the worst it can
return is 0 - might be worth a comment.

But more major: I found it very odd that you collect one set of things
from security_inode_listsecurity(), then proceed to tack on some more
below from the shmem inode.  I looked at other filesystems (well, ext2!)
and couldn't find a precedent.  What's this about?  Is it because other
filesystems have an on-disk format which determines what they're capable
of, whereas tmpfs is plastic and can reflect what the running system has?
Or is it to allow for future xattrs which might be added to tmpfs, but
frankly I'd rather do without until they're defined?

If it needs to be like this, then please, I do want a comment on
what's going on here.  If it need not be like this, then please
delete what's not needed.

> >> +
> >> + =A0 =A0 =A0 spin_lock(&dentry->d_inode->i_lock);
> >> + =A0 =A0 =A0 list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t len =3D XATTR_SECURITY_PREFIX_LEN=
;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D strlen(xattr->name) + 1;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (list_len - (used + len) >=3D 0 && bu=
f) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strncpy(buf, XATTR_SECUR=
ITY_PREFIX, XATTR_SECURITY_PREFIX_LEN);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf +=3D XATTR_SECURITY_=
PREFIX_LEN;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strncpy(buf, xattr->name=
, strlen(xattr->name) + 1);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf +=3D strlen(xattr->n=
ame) + 1;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 used +=3D len;
> >> + =A0 =A0 =A0 }
> >> + =A0 =A0 =A0 spin_unlock(&dentry->d_inode->i_lock);
> >> +
> >> + =A0 =A0 =A0 return used;
> >> =A0}
> >>
> >> =A0static int shmem_xattr_security_get(struct dentry *dentry, const ch=
ar *name,
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *buffer, size_t size, int handler_=
flags)
> >> =A0{
> >> + =A0 =A0 =A0 struct shmem_inode_info *shmem_i;

"info" as above.

> >> + =A0 =A0 =A0 struct shmem_xattr *xattr;
> >> + =A0 =A0 =A0 int ret;
> >> +
> >> =A0 =A0 =A0 =A0if (strcmp(name, "") =3D=3D 0)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> >> - =A0 =A0 =A0 return xattr_getsecurity(dentry->d_inode, name, buffer, =
size);
> >> +
> >> + =A0 =A0 =A0 ret =3D xattr_getsecurity(dentry->d_inode, name, buffer,=
 size);
> >> + =A0 =A0 =A0 if (ret !=3D -EOPNOTSUPP)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> >> +
> >> + =A0 =A0 =A0 /* if we make this generic this needs to go... */
> >> + =A0 =A0 =A0 if (strcmp(name, XATTR_CAPS_SUFFIX))
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
> >> +
> >> + =A0 =A0 =A0 ret =3D -ENODATA;
> >> + =A0 =A0 =A0 shmem_i =3D SHMEM_I(dentry->d_inode);
> >> +
> >> + =A0 =A0 =A0 spin_lock(&dentry->d_inode->i_lock);
> >> + =A0 =A0 =A0 list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(name, xattr->name)) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D xattr->size;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (buffer) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (size=
 < xattr->size)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 ret =3D -ERANGE;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 memcpy(buffer, xattr->value, xattr->size);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> >> + =A0 =A0 =A0 }
> >> + =A0 =A0 =A0 spin_unlock(&dentry->d_inode->i_lock);
> >> + =A0 =A0 =A0 return ret;
> >> =A0}
> >>
> >> =A0static int shmem_xattr_security_set(struct dentry *dentry, const ch=
ar *name,
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const void *value, size_t size, int fla=
gs, int handler_flags)
> >> =A0{
> >> + =A0 =A0 =A0 int ret;
> >> + =A0 =A0 =A0 struct inode *inode =3D dentry->d_inode;
> >> + =A0 =A0 =A0 struct shmem_inode_info *shmem_i =3D SHMEM_I(inode);

"info" as above.

> >> + =A0 =A0 =A0 struct shmem_xattr *xattr;
> >> + =A0 =A0 =A0 struct shmem_xattr *new_xattr;
> >> + =A0 =A0 =A0 size_t len;
> >> +
> >> =A0 =A0 =A0 =A0if (strcmp(name, "") =3D=3D 0)
> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
> >> - =A0 =A0 =A0 return security_inode_setsecurity(dentry->d_inode, name,=
 value,
> >> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 size, flags);
> >> + =A0 =A0 =A0 ret =3D security_inode_setsecurity(inode, name, value, s=
ize, flags);
> >> + =A0 =A0 =A0 if (ret !=3D -EOPNOTSUPP)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> >> +
> >> + =A0 =A0 =A0 /*
> >> + =A0 =A0 =A0 =A0* We only store fcaps for now, but this could be a lo=
t more generic.
> >> + =A0 =A0 =A0 =A0* We could hold the prefix as well as the suffix in t=
he xattr struct
> >> + =A0 =A0 =A0 =A0* We would also need to hold a copy of the suffix rat=
her than a
> >> + =A0 =A0 =A0 =A0* pointer to XATTR_CAPS_SUFFIX
> >> + =A0 =A0 =A0 =A0*/
> >> + =A0 =A0 =A0 if (strcmp(name, XATTR_CAPS_SUFFIX))
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
> >> +
> >> + =A0 =A0 =A0 /* wrap around? */
> >> + =A0 =A0 =A0 len =3D sizeof(*new_xattr) + size;
> >> + =A0 =A0 =A0 if (len <=3D sizeof(*new_xattr))
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> >> +
> >> + =A0 =A0 =A0 new_xattr =3D kmalloc(GFP_NOFS, len);
> >> + =A0 =A0 =A0 if (!new_xattr)
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
> >> +
> >> + =A0 =A0 =A0 new_xattr->name =3D XATTR_CAPS_SUFFIX;
> >> + =A0 =A0 =A0 new_xattr->size =3D size;
> >> + =A0 =A0 =A0 memcpy(new_xattr->value, value, size);
> >> +
> >> + =A0 =A0 =A0 spin_lock(&inode->i_lock);
> >> + =A0 =A0 =A0 list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(name, xattr->name)) {
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_replace(&xattr->lis=
t, &new_xattr->list);
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> >> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> >> + =A0 =A0 =A0 }
> >> + =A0 =A0 =A0 list_add(&new_xattr->list, &shmem_i->xattr_list);
> >> + =A0 =A0 =A0 xattr =3D NULL;
> >> +out:
> >> + =A0 =A0 =A0 spin_unlock(&inode->i_lock);
> >> + =A0 =A0 =A0 kfree(xattr);
> >> + =A0 =A0 =A0 return 0;
> >> =A0}
> >>
> >> =A0static const struct xattr_handler shmem_xattr_security_handler =3D =
{

I'm sorry if my incomprehension depresses you: it did me!

You'll laugh or cry if I admit to you that I was naive enough
to believe that comment above shmem_xattr_security_list() which says
 * Superblocks without xattr inode operations will get security.* xattr
 * support from the VFS "for free".
and wondered why you had to add any code at all.  Maybe you could say
something better there.

Thanks,
Hugh
--8323584-2088098251-1300684679=:21738--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
