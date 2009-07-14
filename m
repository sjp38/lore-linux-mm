Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C19E96B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 08:25:48 -0400 (EDT)
Received: by wa-out-1112.google.com with SMTP id m16so456576waf.22
        for <linux-mm@kvack.org>; Tue, 14 Jul 2009 05:56:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090714100157.GC28569@csn.ul.ie>
References: <alpine.LFD.2.00.0907140249240.25576@casper.infradead.org>
	 <20090714100157.GC28569@csn.ul.ie>
Date: Wed, 15 Jul 2009 00:56:56 +1200
Message-ID: <202cde0e0907140556w4175039x5c01f812459c81c6@mail.gmail.com>
Subject: Re: [RFC][PATCH 2/2] HugeTLB mapping for drivers (export
	functions/identification of htlb mappings)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> This needs to be explained better. What non-hugetlbfs file can have a
> hugepage mapping? You might mean drivers but they don't exist at this
> point so someone looking at the changelog in isolation might get
> confused.
>
Right. I'll add more text explanations. We need to provide hugepage maping =
for
device nodes which are not the elements of hugetlbfs.

>> +EXPORT_SYMBOL(hugetlb_get_unmapped_area);
>>
>
> I think the patch that exports symbols from hugetlbfs needs to be a
> separate patch explaining why they need to be exported for drivers to
> take advantage of.
Agree. It will be splited.

>> =C2=A0 =C2=A0 =C2=A0 ima_counts_get(file);
>> + =C2=A0 =C2=A0 mapping_set_hugetlb(file->f_mapping);

> At a first reading, I was not getting why there needs to be a new way
> of identifying if a mapping is hugetlbfs-backed or not. =C2=A0I get that =
it's
> because drivers will have file_operations that we cannot possibly know ab=
out
> in advance, particularly if they are loaded as modules but this really ne=
eds
> it's own patch and changelog spelling it out.

Right! Indeed this should be a place of attention. We must identify that fi=
le
is hugepage to identify unaccunable_mapping before vma got created. Current=
ly
it is done for all files in hugetlbfs and there is a very special
workaround for
ipc/shm.c. If we have different drivers we workaround will not work
for us. So we
must find another approach to identify that file has very special
(huge page) mapping.
Currently I still in doubts if it is Ok to involve mapping flags or
not, but I did not find any other
option/marker to idenify that file has htlb mapping.

> It also again raises the
> question of why drivers would not use the internal hugetlbfs mount like
> shm does.
It is possible to use either ways. Unfortunately it is unclear which is bet=
ter.
If make something like shm does - driver code get much complicated and
hardreadible.
We need to export file operations structure. We need to do hack
looking tricks with substitution of file->f_mapping.
If make something like done in this patch - driver code get simplier.
We need to export two file operations functions.
Involving of which also looks inconsistent.
Probably the best way would be - moving some functionality of
hugetlb_get_unmapped_area and hugetlbfs_file_mmap out of hugetlbfs.
And represent it as interface functions of hugetlb.c. In fact
hugetlb_get_unmapped_area never need file argument. It only needs
hstate to make addresses aligned and set up some architecture specific
registers. For drivers we need very small part of hugetlbfs_file_mmap
function as well.
In this case we will have interfaces for drivers which are completely
isolated from hugetlbfs.

>> +struct page *hugetlb_alloc_pages_node(int nid, gfp_t gfp_mask);
>> +void hugetlb_free_pages(struct page *page);
>
> This looks like it belongs in the previous patch.
>
>> +#define hugetlb_alloc_pages_node(nid, gfp_mask) 0
>> +#define hugetlb_free_pages(page) BUG();
>> +
>> +
>
> Ditto and some unnecessary whitespace there.
>
Yep. Sorry. I had to split it up and clean.

>
> Having the new exports and the new method for identifying if a file or
> mapping is hugetlbfs in the same patch does make this harder. I see
> nothing wrong with the above changes as such but I'm hard-wired into
> thinking that everything in a patch is directly related.
>
Acked.
>> =C2=A0static inline struct hstate *hstate_inode(struct inode *i)
>> =C2=A0{
>> =C2=A0 =C2=A0 =C2=A0 struct hugetlbfs_sb_info *hsb;
>> - =C2=A0 =C2=A0 hsb =3D HUGETLBFS_SB(i->i_sb);
>> - =C2=A0 =C2=A0 return hsb->hstate;
>> + =C2=A0 =C2=A0 if (i->i_sb->s_magic =3D=3D HUGETLBFS_MAGIC) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 hsb =3D HUGETLBFS_SB(i->i_sb=
);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return hsb->hstate;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 return &hstate_nores;
>
> This needs a comment and the changelog needs to spell out better that you=
 are
> expanding what hugetlbfs is. This chunk is basically saying that it's pos=
sible
> to have an inode that is backed by hugepages but that is not a hugetlbfs
> file. Your changelog needs to explain why hugetlbfs files were not create=
d
> in the same way they are created for shared memory mappings on the intern=
al
> hugetlbfs mount. Maybe we discussed this before but I forget the reasonin=
g.

Yes. You are right. We did not discuss it before. It was one of the
problem being
faced during enbling Huge pages mapping for drivers. I've just
explained in the beginning of
this message.

>> +static inline int mapping_hugetlb(struct address_space *mapping)
>> +{
>> + =C2=A0 =C2=A0 if (likely(mapping))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return test_bit(AS_HUGETLB, =
&mapping->flags);
>> + =C2=A0 =C2=A0 return !!mapping;
>> +}
>
> That !!mapping looks a bit unnecessary. =C2=A0Why is !!NULL always going =
to
> evaluate to 0? =C2=A0I know it's copying from mapping_unevictable(), but =
that
> doesn't help me figure out why it looks like that.
This construction stunned me for a while also :). The only reason why this
construction could be used here is converting NULL to integer 0. IMHO
the best is "return 0"

Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
