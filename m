Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AD16F8D0040
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 04:25:04 -0400 (EDT)
Received: by qyk30 with SMTP id 30so2783631qyk.14
        for <linux-mm@kvack.org>; Fri, 01 Apr 2011 01:25:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110328170220.fc61fb5c.akpm@linux-foundation.org>
References: <1301290355-8980-1-git-send-email-lliubbo@gmail.com>
	<20110328170220.fc61fb5c.akpm@linux-foundation.org>
Date: Fri, 1 Apr 2011 16:25:01 +0800
Message-ID: <AANLkTikN2DFtZWTR=+Fq8GWaXJLaQOFuUsmYQLTo04Hd@mail.gmail.com>
Subject: Re: [PATCH] ramfs: fix memleak on no-mmu arch
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hughd@google.com, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, dhowells@redhat.com, lethal@linux-sh.org, magnus.damm@gmail.com, Mike Frysinger <vapier@gentoo.org>, horms@verge.net.au, gerg@uclinux.org, ithamar.adema@team-embedded.nl

Hi, Andrew

cc'd some folks working on nommu.

On Tue, Mar 29, 2011 at 8:02 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 28 Mar 2011 13:32:35 +0800
> Bob Liu <lliubbo@gmail.com> wrote:
>
>> On no-mmu arch, there is a memleak duirng shmem test.
>> The cause of this memleak is ramfs_nommu_expand_for_mapping() added page
>> refcount to 2 which makes iput() can't free that pages.
>>
>> The simple test file is like this:
>> int main(void)
>> {
>> =C2=A0 =C2=A0 =C2=A0 int i;
>> =C2=A0 =C2=A0 =C2=A0 key_t k =3D ftok("/etc", 42);
>>
>> =C2=A0 =C2=A0 =C2=A0 for ( i=3D0; i<100; ++i) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int id =3D shmget(k, 10=
000, 0644|IPC_CREAT);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (id =3D=3D -1) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 printf("shmget error\n");
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if(shmctl(id, IPC_RMID,=
 NULL ) =3D=3D -1) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 printf("shm =C2=A0rm error\n");
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return -1;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 printf("run ok...\n");
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>> }
>>
>> ...
>>
>> diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
>> index 9eead2c..fbb0b47 100644
>> --- a/fs/ramfs/file-nommu.c
>> +++ b/fs/ramfs/file-nommu.c
>> @@ -112,6 +112,7 @@ int ramfs_nommu_expand_for_mapping(struct inode *ino=
de, size_t newsize)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageDirty(page);
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlock_page(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_page(page);
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>
> Something is still wrong here.
>
> A live, in-use page should have a refcount of three. =C2=A0One for the
> existence of the page, one for its presence on the page LRU and one for
> its existence in the pagecache radix tree.
>
> So allocation should do:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0alloc_pages()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_page_cache()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0add_to_lru()
>
> and deallocation should do
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_from_lru()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_from_page_cache()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0put_page()
>
> If this protocol is followed correctly, there is no need to do a
> put_page() during the allocation/setup phase!
>
> I suspect that the problem in nommu really lies in the
> deallocation/teardown phase.
>

What about below patch ?

BTW: It seems that in MMU cases shmem pages are freed during memory reclaim=
,
since I didn't find the direct free place.
I am not sure maybe I got something wrong ?

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 fs/ramfs/file-nommu.c |    1 +
 fs/ramfs/inode.c      |   22 ++++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index fbb0b47..11f48eb 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -114,6 +114,7 @@ int ramfs_nommu_expand_for_mapping(struct inode
*inode, size_t newsize)
 		unlock_page(page);
 		put_page(page);
 	}
+	inode->i_private =3D pages;

 	return 0;

diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
index eacb166..e446d9f 100644
--- a/fs/ramfs/inode.c
+++ b/fs/ramfs/inode.c
@@ -151,9 +151,31 @@ static const struct inode_operations
ramfs_dir_inode_operations =3D {
 	.rename		=3D simple_rename,
 };

+#ifndef CONFIG_MMU
+static void ramfs_evict_inode(struct inode *inode)
+{
+	int i;
+	struct page *free_pages =3D (struct page *)inode->i_private;
+
+	/*
+	 * for nommu arch, need an extra put_page so that pages gotten
+	 * by ramfs_nommu_expand_for_mapping() can be freed
+	 */
+	for (i =3D 0; i < inode->i_data.nrpages; i++)
+		put_page(free_pages + i);
+
+	if (inode->i_data.nrpages)
+		truncate_inode_pages(&inode->i_data, 0);
+	end_writeback(inode);
+}
+#endif
+
 static const struct super_operations ramfs_ops =3D {
 	.statfs		=3D simple_statfs,
 	.drop_inode	=3D generic_delete_inode,
+#ifndef CONFIG_MMU
+	.evict_inode    =3D ramfs_evict_inode,
+#endif
 	.show_options	=3D generic_show_options,
 };

--=20
1.6.3.3

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
