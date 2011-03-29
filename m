Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 93E0F8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 07:06:56 -0400 (EDT)
Received: by qwa26 with SMTP id 26so35677qwa.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 04:06:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110328170220.fc61fb5c.akpm@linux-foundation.org>
References: <1301290355-8980-1-git-send-email-lliubbo@gmail.com>
	<20110328170220.fc61fb5c.akpm@linux-foundation.org>
Date: Tue, 29 Mar 2011 19:06:52 +0800
Message-ID: <AANLkTi=B9w9B7eKVbC60=-rRjqrhXMXHwGeCPuwK=3oe@mail.gmail.com>
Subject: Re: [PATCH] ramfs: fix memleak on no-mmu arch
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, hughd@google.com, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, dhowells@redhat.com, lethal@linux-sh.org, magnus.damm@gmail.com

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
>

Yes,
And in my understanding in nommu deallocation phase:

1. iput() call default generate_drop_inode().
2. and then in evict() call truncate_inode_pages() which just remove
pages from_lru and pagecache.

There is no pace call put_page() so pages can't be freed at last.

Maybe we need to implement evict_inode() or drop_inode() in ramfs.
I will try it soon but I am not familiar with fs, any ideas is welcome.


Thanks
--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
