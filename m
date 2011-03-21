Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B4C198D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 02:26:06 -0400 (EDT)
Received: by qwa26 with SMTP id 26so5276426qwa.14
        for <linux-mm@kvack.org>; Sun, 20 Mar 2011 23:26:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1103201258280.3776@sister.anvils>
References: <1299575863-7069-1-git-send-email-lliubbo@gmail.com>
	<alpine.LSU.2.00.1103201258280.3776@sister.anvils>
Date: Mon, 21 Mar 2011 14:26:03 +0800
Message-ID: <AANLkTi=a2R+72rp2sO4gt72ATxHsE71zkCF6_ScSu_a+@mail.gmail.com>
Subject: Re: [BUG?] shmem: memory leak on NO-MMU arch
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, hch@lst.de, npiggin@kernel.dk, tj@kernel.org, David Howells <dhowells@redhat.com>, Paul Mundt <lethal@linux-sh.org>, Magnus Damm <magnus.damm@gmail.com>

Hi, Hugh

On Mon, Mar 21, 2011 at 4:35 AM, Hugh Dickins <hughd@google.com> wrote:
> On Tue, 8 Mar 2011, Bob Liu wrote:
>> Hi, folks
>
> Of course I agree with Al and Andrew about your other patch,
> I don't know of any shmem inode leak in the MMU case.
>
> I'm afraid we MM folks tend to be very ignorant of the NOMMU case.
> I've sometimes wished we had a NOMMU variant of the x86 architecture,
> that we could at least build and test changes on.
>
> Let's Cc David, Paul and Magnus: they do understand NOMMU.
>
>>
>> I got a problem about shmem on NO-MMU arch, it seems memory leak
>> happened.
>>
>> A simple test file is like this:
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>> #include <stdio.h>
>> #include <stdlib.h>
>> #include <sys/types.h>
>> #include <sys/ipc.h>
>> #include <sys/shm.h>
>> #include <errno.h>
>> #include <string.h>
>>
>> int main(void)
>> {
>> =C2=A0 =C2=A0 =C2=A0 int i;
>> =C2=A0 =C2=A0 =C2=A0 key_t k =3D ftok("/etc", 42);
>>
>> =C2=A0 =C2=A0 =C2=A0 for ( i=3D0; i<2; ++i) {
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
>> The test results:
>> root:/> free
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 share=
d =C2=A0 =C2=A0 =C2=A0buffers
>> =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
13876 =C2=A0 =C2=A0 =C2=A0 =C2=A046652 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> root:/> ./shmem
>> run ok...
>> root:/> free
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 share=
d =C2=A0 =C2=A0 =C2=A0buffers
>> =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
15104 =C2=A0 =C2=A0 =C2=A0 =C2=A045424 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> root:/> ./shmem
>> run ok...
>> root:/> free
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 share=
d =C2=A0 =C2=A0 =C2=A0buffers
>> =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
16292 =C2=A0 =C2=A0 =C2=A0 =C2=A044236 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> root:/> ./shmem
>> run ok...
>> root:/> free
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 share=
d =C2=A0 =C2=A0 =C2=A0buffers
>> =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
17496 =C2=A0 =C2=A0 =C2=A0 =C2=A043032 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> root:/> ./shmem
>> run ok...
>> root:/> free
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 share=
d =C2=A0 =C2=A0 =C2=A0buffers
>> =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
18700 =C2=A0 =C2=A0 =C2=A0 =C2=A041828 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> root:/> ./shmem
>> run ok...
>> root:/> free
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 share=
d =C2=A0 =C2=A0 =C2=A0buffers
>> =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
19904 =C2=A0 =C2=A0 =C2=A0 =C2=A040624 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> root:/> ./shmem
>> run ok...
>> root:/> free
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 used =C2=A0 =C2=A0 =C2=A0 =C2=A0 free =C2=A0 =C2=A0 =C2=A0 share=
d =C2=A0 =C2=A0 =C2=A0buffers
>> =C2=A0 Mem: =C2=A0 =C2=A0 =C2=A0 =C2=A060528 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
21104 =C2=A0 =C2=A0 =C2=A0 =C2=A039424 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>> root:/>
>>
>> It seems the shmem didn't free it's memory after using shmctl(IPC_RMID) =
to rm
>> it.
>
> There does indeed appear to be a leak there. =C2=A0But I'm feeling very
> stupid, the leak of ~1200kB per run looks a lot more than the ~20kB
> that each run of your test program would lose if the bug is as you say.
> Maybe I can't count today.
>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> Patch below can work, but I know it's too simple and may cause other pro=
blems.
>> Any ideas is welcome.
>>
>> Thanks!
>>
>> Signed-off-by: Bob Liu <lliubbo@gmail.com>
>
> I don't think any patch with a global ramfs_pages, ignoring the
> inode in question, can possibly work beyond the simplest of cases.
>
>
> Yet it does look to me that you're right that ramfs_nommu_expand_for_mapp=
ing
> forgets to release a reference to its pages; though it's hard to believe
> that could go unnoticed for so long - more likely we're both overlooking
> something.
>
>> ---
>> diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
>> index 9eead2c..831e6d5 100644
>> --- a/fs/ramfs/file-nommu.c
>> +++ b/fs/ramfs/file-nommu.c
>> @@ -59,6 +59,8 @@ const struct inode_operations ramfs_file_inode_operati=
ons =3D {
>> =C2=A0 * size 0 on the assumption that it's going to be used for an mmap=
 of shared
>> =C2=A0 * memory
>> =C2=A0 */
>> +struct page *ramfs_pages;
>> +unsigned long ramfs_nr_pages;
>> =C2=A0int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t new=
size)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 unsigned long npages, xpages, loop;
>> @@ -114,6 +116,8 @@ int ramfs_nommu_expand_for_mapping(struct inode *ino=
de, size_t newsize)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlock_page(page);
>> =C2=A0 =C2=A0 =C2=A0 }
>>
>> + =C2=A0 =C2=A0 ramfs_pages =3D pages;
>> + =C2=A0 =C2=A0 ramfs_nr_pages =3D loop;
>> =C2=A0 =C2=A0 =C2=A0 return 0;
>>
>> =C2=A0add_error:
>> diff --git a/fs/ramfs/inode.c b/fs/ramfs/inode.c
>> index eacb166..2eb33e5 100644
>> --- a/fs/ramfs/inode.c
>> +++ b/fs/ramfs/inode.c
>> @@ -139,6 +139,23 @@ static int ramfs_symlink(struct inode * dir, struct=
 dentry *dentry, const char *
>> =C2=A0 =C2=A0 =C2=A0 return error;
>> =C2=A0}
>>
>> +static void ramfs_delete_inode(struct inode *inode)
>> +{
>> + =C2=A0 =C2=A0 int loop;
>> + =C2=A0 =C2=A0 struct page *page;
>> +
>> + =C2=A0 =C2=A0 truncate_inode_pages(&inode->i_data, 0);
>> + =C2=A0 =C2=A0 clear_inode(inode);
>> +
>> + =C2=A0 =C2=A0 for (loop =3D 0; loop < ramfs_nr_pages; loop++ ){
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page =3D ramfs_pages[loop];
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 page->flags &=3D ~PAGE_FLAGS=
_CHECK_AT_FREE;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if(page)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
__free_pages(page, 0);
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 kfree(ramfs_pages);
>> +}
>> +
>> =C2=A0static const struct inode_operations ramfs_dir_inode_operations =
=3D {
>> =C2=A0 =C2=A0 =C2=A0 .create =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D ramfs_creat=
e,
>> =C2=A0 =C2=A0 =C2=A0 .lookup =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D simple_look=
up,
>> @@ -153,6 +170,7 @@ static const struct inode_operations ramfs_dir_inode=
_operations =3D {
>>
>> =C2=A0static const struct super_operations ramfs_ops =3D {
>> =C2=A0 =C2=A0 =C2=A0 .statfs =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D simple_stat=
fs,
>> + =C2=A0 =C2=A0 .delete_inode =C2=A0 =3D ramfs_delete_inode,
>> =C2=A0 =C2=A0 =C2=A0 .drop_inode =C2=A0 =C2=A0 =3D generic_delete_inode,
>> =C2=A0 =C2=A0 =C2=A0 .show_options =C2=A0 =3D generic_show_options,
>> =C2=A0};
>> diff --git a/fs/ramfs/internal.h b/fs/ramfs/internal.h
>> index 6b33063..0b7b222 100644
>> --- a/fs/ramfs/internal.h
>> +++ b/fs/ramfs/internal.h
>> @@ -12,3 +12,5 @@
>>
>> =C2=A0extern const struct address_space_operations ramfs_aops;
>> =C2=A0extern const struct inode_operations ramfs_file_inode_operations;
>> +extern struct page *ramfs_pages;
>> +extern unsigned long ramfs_nr_pages;
>> --
>> 1.6.3.3
>
> Here's my own suggestion for a patch; but I've not even tried to
> compile it, let alone test it, so I'm certainly not signing it.
>

Great.
I have compiled and tested this patch and it works fine.
Would you please sign and commit it ?

Thanks.

root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13852        46660            0            0
root:/> ./shmem
run ok...
root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13892        46620            0            0
root:/> ./shmem
run ok...
root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13868        46644            0            0
root:/> ./shmem
run ok...
root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13860        46652            0            0
root:/> ./shmem
run ok...
root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13860        46652            0            0
root:/> ./shmem
run ok...
root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13864        46648            0            0
root:/> ./shmem
run ok...
root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13868        46644            0            0
root:/> ./shmem
run ok...
root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13868        46644            0            0
root:/> ./shmem
run ok...
root:/> free
              total         used         free       shared      buffers
  Mem:        60512        13868        46644            0            0
root:/>

> ---
>
> =C2=A0fs/ramfs/file-nommu.c | =C2=A0 19 +++++++++----------
> =C2=A01 file changed, 9 insertions(+), 10 deletions(-)
>
> --- 2.6.38/fs/ramfs/file-nommu.c =C2=A0 =C2=A0 =C2=A0 =C2=A02010-10-20 13=
:30:22.000000000 -0700
> +++ linux/fs/ramfs/file-nommu.c 2011-03-20 12:55:35.000000000 -0700
> @@ -90,23 +90,19 @@ int ramfs_nommu_expand_for_mapping(struc
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0split_page(pages, order);
>
> - =C2=A0 =C2=A0 =C2=A0 /* trim off any pages we don't actually require */
> - =C2=A0 =C2=A0 =C2=A0 for (loop =3D npages; loop < xpages; loop++)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __free_page(pages + lo=
op);
> -
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* clear the memory we allocated */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0newsize =3D PAGE_SIZE * npages;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0data =3D page_address(pages);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0memset(data, 0, newsize);
>
> - =C2=A0 =C2=A0 =C2=A0 /* attach all the pages to the inode's address spa=
ce */
> + =C2=A0 =C2=A0 =C2=A0 /* attach the pages we require to the inode's addr=
ess space */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0for (loop =3D 0; loop < npages; loop++) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page =
=3D pages + loop;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ret =3D add_to_pag=
e_cache_lru(page, inode->i_mapping, loop,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0GFP_KERNE=
L);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (ret < 0)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto add_error;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 break;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* prevent the pag=
e from being discarded on memory pressure */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SetPageDirty(page)=
;
> @@ -114,11 +110,14 @@ int ramfs_nommu_expand_for_mapping(struc
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unlock_page(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> - =C2=A0 =C2=A0 =C2=A0 return 0;
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* release our reference to the pages now add=
ed to cache,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* and trim off any pages we don't actually r=
equire.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* truncate inode back to 0 if not all pages =
could be added??
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 for (loop =3D 0; loop < xpages; loop++)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 put_page(pages + loop)=
;
>
> -add_error:
> - =C2=A0 =C2=A0 =C2=A0 while (loop < npages)
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __free_page(pages + lo=
op++);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
> =C2=A0}
>
>

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
