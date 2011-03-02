Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ADD718D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 14:30:09 -0500 (EST)
Received: by iyf13 with SMTP id 13so312793iyf.14
        for <linux-mm@kvack.org>; Wed, 02 Mar 2011 11:29:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=wyaLP6gFmNxajp+HtYu3B9_KGf2o4BnYA+rwy@mail.gmail.com>
References: <20110111210710.32348.1642.stgit@paris.rdu.redhat.com>
	<AANLkTi=wyaLP6gFmNxajp+HtYu3B9_KGf2o4BnYA+rwy@mail.gmail.com>
Date: Wed, 2 Mar 2011 14:29:59 -0500
Message-ID: <AANLkTi=7GyY=O2eTupPXQijcnT_55a3RnHAruJpm_5Jo@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: implement security.capability xattrs
From: Eric Paris <eparis@parisplace.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Paris <eparis@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

I know there exist thoughts on this patch somewhere on the internets.
Let 'em rip!  I can handle it!

-Eric

On Thu, Feb 17, 2011 at 4:27 PM, Eric Paris <eparis@parisplace.org> wrote:
> Bueller? =A0Bueller? =A0Any thoughts? =A0Any problems?
>
> On Tue, Jan 11, 2011 at 4:07 PM, Eric Paris <eparis@redhat.com> wrote:
>> This patch implements security.capability xattrs for tmpfs filesystems. =
=A0The
>> feodra project, while trying to replace suid apps with file capabilities=
,
>> realized that tmpfs, which is used on my build systems, does not support=
 file
>> capabilities and thus cannot be used to build packages which use file
>> capabilities. =A0The patch only implements security.capability but there=
 is no
>> reason it could not be easily expanded to support *.* xattrs as most of =
the
>> work is already done. =A0I don't know what other xattrs are in use in th=
e world
>> or if they necessarily make sense on tmpfs so I didn't make this
>> implementation completely generic.
>>
>> The basic implementation is that I attach a
>> struct shmem_xattr {
>> =A0 =A0 =A0 =A0struct list_head list; /* anchored by shmem_inode_info->x=
attr_list */
>> =A0 =A0 =A0 =A0char *name;
>> =A0 =A0 =A0 =A0size_t size;
>> =A0 =A0 =A0 =A0char value[0];
>> };
>> Into the struct shmem_inode_info for each xattr that is set. =A0Since I =
only
>> allow security.capability obviously this list is only every 0 or 1 entry=
 long.
>> I could have been a little simpler, but then the next person having to
>> implement an xattr would have to redo everything I did instead of me jus=
t
>> doing 90% of their work =A0:)
>>
>> Signed-off-by: Eric Paris <eparis@redhat.com>
>> ---
>>
>> =A0include/linux/shmem_fs.h | =A0 =A08 +++
>> =A0mm/shmem.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0112 +++++++++++++++++++++=
+++++++++++++++++++++++--
>> =A02 files changed, 116 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
>> index 399be5a..6f2ebb8 100644
>> --- a/include/linux/shmem_fs.h
>> +++ b/include/linux/shmem_fs.h
>> @@ -9,6 +9,13 @@
>>
>> =A0#define SHMEM_NR_DIRECT 16
>>
>> +struct shmem_xattr {
>> + =A0 =A0 =A0 struct list_head list; /* anchored by shmem_inode_info->xa=
ttr_list */
>> + =A0 =A0 =A0 char *name;
>> + =A0 =A0 =A0 size_t size;
>> + =A0 =A0 =A0 char value[0];
>> +};
>> +
>> =A0struct shmem_inode_info {
>> =A0 =A0 =A0 =A0spinlock_t =A0 =A0 =A0 =A0 =A0 =A0 =A0lock;
>> =A0 =A0 =A0 =A0unsigned long =A0 =A0 =A0 =A0 =A0 flags;
>> @@ -19,6 +26,7 @@ struct shmem_inode_info {
>> =A0 =A0 =A0 =A0struct page =A0 =A0 =A0 =A0 =A0 =A0 *i_indirect; =A0 =A0/=
* top indirect blocks page */
>> =A0 =A0 =A0 =A0swp_entry_t =A0 =A0 =A0 =A0 =A0 =A0 i_direct[SHMEM_NR_DIR=
ECT]; /* first blocks */
>> =A0 =A0 =A0 =A0struct list_head =A0 =A0 =A0 =A0swaplist; =A0 =A0 =A0 /* =
chain of maybes on swap */
>> + =A0 =A0 =A0 struct list_head =A0 =A0 =A0 =A0xattr_list; =A0 =A0 /* lis=
t of shmem_xattr */
>> =A0 =A0 =A0 =A0struct inode =A0 =A0 =A0 =A0 =A0 =A0vfs_inode;
>> =A0};
>>
>> diff --git a/mm/shmem.c b/mm/shmem.c
>> index 86cd21d..d2bacd6 100644
>> --- a/mm/shmem.c
>> +++ b/mm/shmem.c
>> @@ -822,6 +822,7 @@ static int shmem_notify_change(struct dentry *dentry=
, struct iattr *attr)
>> =A0static void shmem_evict_inode(struct inode *inode)
>> =A0{
>> =A0 =A0 =A0 =A0struct shmem_inode_info *info =3D SHMEM_I(inode);
>> + =A0 =A0 =A0 struct shmem_xattr *xattr, *nxattr;
>>
>> =A0 =A0 =A0 =A0if (inode->i_mapping->a_ops =3D=3D &shmem_aops) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0truncate_inode_pages(inode->i_mapping, 0)=
;
>> @@ -834,6 +835,9 @@ static void shmem_evict_inode(struct inode *inode)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mutex_unlock(&shmem_swapl=
ist_mutex);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>> =A0 =A0 =A0 =A0}
>> +
>> + =A0 =A0 =A0 list_for_each_entry_safe(xattr, nxattr, &info->xattr_list,=
 list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(xattr);
>> =A0 =A0 =A0 =A0BUG_ON(inode->i_blocks);
>> =A0 =A0 =A0 =A0shmem_free_inode(inode->i_sb);
>> =A0 =A0 =A0 =A0end_writeback(inode);
>> @@ -1597,6 +1601,7 @@ static struct inode *shmem_get_inode(struct super_=
block *sb, const struct inode
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_lock_init(&info->lock);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0info->flags =3D flags & VM_NORESERVE;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0INIT_LIST_HEAD(&info->swaplist);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 INIT_LIST_HEAD(&info->xattr_list);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cache_no_acl(inode);
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0switch (mode & S_IFMT) {
>> @@ -2071,24 +2076,123 @@ static size_t shmem_xattr_security_list(struct =
dentry *dentry, char *list,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0size_t list_len, const char *name,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0size_t name_len, int handler_flags)
>> =A0{
>> - =A0 =A0 =A0 return security_inode_listsecurity(dentry->d_inode, list, =
list_len);
>> + =A0 =A0 =A0 struct shmem_xattr *xattr;
>> + =A0 =A0 =A0 struct shmem_inode_info *shmem_i;
>> + =A0 =A0 =A0 size_t used;
>> + =A0 =A0 =A0 char *buf =3D NULL;
>> +
>> + =A0 =A0 =A0 used =3D security_inode_listsecurity(dentry->d_inode, list=
, list_len);
>> +
>> + =A0 =A0 =A0 shmem_i =3D SHMEM_I(dentry->d_inode);
>> + =A0 =A0 =A0 if (list)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf =3D list + used;
>> +
>> + =A0 =A0 =A0 spin_lock(&dentry->d_inode->i_lock);
>> + =A0 =A0 =A0 list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t len =3D XATTR_SECURITY_PREFIX_LEN;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 len +=3D strlen(xattr->name) + 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (list_len - (used + len) >=3D 0 && buf)=
 {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strncpy(buf, XATTR_SECURIT=
Y_PREFIX, XATTR_SECURITY_PREFIX_LEN);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf +=3D XATTR_SECURITY_PR=
EFIX_LEN;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 strncpy(buf, xattr->name, =
strlen(xattr->name) + 1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 buf +=3D strlen(xattr->nam=
e) + 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 used +=3D len;
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 spin_unlock(&dentry->d_inode->i_lock);
>> +
>> + =A0 =A0 =A0 return used;
>> =A0}
>>
>> =A0static int shmem_xattr_security_get(struct dentry *dentry, const char=
 *name,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0void *buffer, size_t size, int handler_fl=
ags)
>> =A0{
>> + =A0 =A0 =A0 struct shmem_inode_info *shmem_i;
>> + =A0 =A0 =A0 struct shmem_xattr *xattr;
>> + =A0 =A0 =A0 int ret;
>> +
>> =A0 =A0 =A0 =A0if (strcmp(name, "") =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>> - =A0 =A0 =A0 return xattr_getsecurity(dentry->d_inode, name, buffer, si=
ze);
>> +
>> + =A0 =A0 =A0 ret =3D xattr_getsecurity(dentry->d_inode, name, buffer, s=
ize);
>> + =A0 =A0 =A0 if (ret !=3D -EOPNOTSUPP)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> +
>> + =A0 =A0 =A0 /* if we make this generic this needs to go... */
>> + =A0 =A0 =A0 if (strcmp(name, XATTR_CAPS_SUFFIX))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
>> +
>> + =A0 =A0 =A0 ret =3D -ENODATA;
>> + =A0 =A0 =A0 shmem_i =3D SHMEM_I(dentry->d_inode);
>> +
>> + =A0 =A0 =A0 spin_lock(&dentry->d_inode->i_lock);
>> + =A0 =A0 =A0 list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(name, xattr->name)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D xattr->size;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (buffer) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (size <=
 xattr->size)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 ret =3D -ERANGE;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 memcpy(buffer, xattr->value, xattr->size);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 spin_unlock(&dentry->d_inode->i_lock);
>> + =A0 =A0 =A0 return ret;
>> =A0}
>>
>> =A0static int shmem_xattr_security_set(struct dentry *dentry, const char=
 *name,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0const void *value, size_t size, int flags=
, int handler_flags)
>> =A0{
>> + =A0 =A0 =A0 int ret;
>> + =A0 =A0 =A0 struct inode *inode =3D dentry->d_inode;
>> + =A0 =A0 =A0 struct shmem_inode_info *shmem_i =3D SHMEM_I(inode);
>> + =A0 =A0 =A0 struct shmem_xattr *xattr;
>> + =A0 =A0 =A0 struct shmem_xattr *new_xattr;
>> + =A0 =A0 =A0 size_t len;
>> +
>> =A0 =A0 =A0 =A0if (strcmp(name, "") =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>> - =A0 =A0 =A0 return security_inode_setsecurity(dentry->d_inode, name, v=
alue,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 size, flags);
>> + =A0 =A0 =A0 ret =3D security_inode_setsecurity(inode, name, value, siz=
e, flags);
>> + =A0 =A0 =A0 if (ret !=3D -EOPNOTSUPP)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> +
>> + =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0* We only store fcaps for now, but this could be a lot =
more generic.
>> + =A0 =A0 =A0 =A0* We could hold the prefix as well as the suffix in the=
 xattr struct
>> + =A0 =A0 =A0 =A0* We would also need to hold a copy of the suffix rathe=
r than a
>> + =A0 =A0 =A0 =A0* pointer to XATTR_CAPS_SUFFIX
>> + =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 if (strcmp(name, XATTR_CAPS_SUFFIX))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
>> +
>> + =A0 =A0 =A0 /* wrap around? */
>> + =A0 =A0 =A0 len =3D sizeof(*new_xattr) + size;
>> + =A0 =A0 =A0 if (len <=3D sizeof(*new_xattr))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> +
>> + =A0 =A0 =A0 new_xattr =3D kmalloc(GFP_NOFS, len);
>> + =A0 =A0 =A0 if (!new_xattr)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOMEM;
>> +
>> + =A0 =A0 =A0 new_xattr->name =3D XATTR_CAPS_SUFFIX;
>> + =A0 =A0 =A0 new_xattr->size =3D size;
>> + =A0 =A0 =A0 memcpy(new_xattr->value, value, size);
>> +
>> + =A0 =A0 =A0 spin_lock(&inode->i_lock);
>> + =A0 =A0 =A0 list_for_each_entry(xattr, &shmem_i->xattr_list, list) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!strcmp(name, xattr->name)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_replace(&xattr->list,=
 &new_xattr->list);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 }
>> + =A0 =A0 =A0 list_add(&new_xattr->list, &shmem_i->xattr_list);
>> + =A0 =A0 =A0 xattr =3D NULL;
>> +out:
>> + =A0 =A0 =A0 spin_unlock(&inode->i_lock);
>> + =A0 =A0 =A0 kfree(xattr);
>> + =A0 =A0 =A0 return 0;
>> =A0}
>>
>> =A0static const struct xattr_handler shmem_xattr_security_handler =3D {
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" =
in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
