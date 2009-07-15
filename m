Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6F3C26B004F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2009 19:33:35 -0400 (EDT)
Received: by pxi13 with SMTP id 13so1804118pxi.12
        for <linux-mm@kvack.org>; Tue, 14 Jul 2009 17:08:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090714102735.GD28569@csn.ul.ie>
References: <alpine.LFD.2.00.0907140258100.25576@casper.infradead.org>
	 <20090714102735.GD28569@csn.ul.ie>
Date: Wed, 15 Jul 2009 12:08:26 +1200
Message-ID: <202cde0e0907141708g51294247i7a201c34e97f5b66@mail.gmail.com>
Subject: Re: HugeTLB mapping for drivers (sample driver)
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel,

Thank you for review.
I'm about to renovate this sample driver in order to handle set of
different scenarios.
Please tell me if you have additional error scenarios. I'll try to
handle them as well.
After that there will be more or less clear picture about should we
involve hugetlbfs or not.

On Tue, Jul 14, 2009 at 10:27 PM, Mel Gorman<mel@csn.ul.ie> wrote:
> On Tue, Jul 14, 2009 at 03:07:47AM +0100, Alexey Korolev wrote:
>> Hi,
>>
>> This is a sample driver which provides huge page mapping to user space.
>> It might be useful for understanding purposes.
>>
>> Here we defined file operations for device driver.
>>
>> We must call htlbfs get_unmapped_area and hugetlbfs_file_mmap functions =
to
>> =C2=A0done some HTLB mapping preparations. (If proposed approach is more
>> or less Ok, it will be more accurate to avoid hugetlbfs calls at all - a=
nd
>> substitute them with htlb functions).
>> Allocated page get assiciated with mapping via add_to_page_cache call in
>> file->open.
>>
>
> I ran out of time to review this properly, but glancing through I would b=
e
> concerned with what happens on fork() and COW. At a short read, it would
> appear that pages get allocated from alloc_buddy_huge_page() instead of y=
our
> normal function altering the counters for hstate_nores.
>
>> ---
>> diff -Naurp empty/hpage_map.c hpage_map/hpage_map.c
>> --- empty/hpage_map.c 1970-01-01 12:00:00.000000000 +1200
>> +++ hpage_map/hpage_map.c =C2=A0 =C2=A0 2009-07-13 18:40:28.000000000 +1=
200
>> @@ -0,0 +1,137 @@
>> +#include <linux/module.h>
>> +#include <linux/mm.h>
>> +#include <linux/file.h>
>> +#include <linux/pagemap.h>
>> +#include <linux/hugetlb.h>
>> +#include <linux/pagevec.h>
>> +#include <linux/miscdevice.h>
>> +
>> +static void make_file_empty(struct file *file)
>> +{
>> + =C2=A0 =C2=A0struct address_space *mapping =3D file->f_mapping;
>> + =C2=A0 =C2=A0struct pagevec pvec;
>> + =C2=A0 =C2=A0pgoff_t next =3D 0;
>> + =C2=A0 =C2=A0int i;
>> +
>> + =C2=A0 =C2=A0pagevec_init(&pvec, 0);
>> + =C2=A0 =C2=A0while (1) {
>> + =C2=A0 =C2=A0 if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE))=
 {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!next)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 next =3D 0;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 for (i =3D 0; i < pagevec_count(&pvec); ++i) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct page *page =3D pvec.pages[i];
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 lock_page(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page->index > next)
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 next =3D page->index;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 ++next;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 remove_from_page_cache(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 unlock_page(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 hugetlb_free_pages(page);
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0}
>> + =C2=A0 =C2=A0BUG_ON(mapping->nrpages);
>> +}
>> +
>> +
>> +static int hpage_map_mmap(struct file *file, struct vm_area_struct
>> *vma)
>> +{
>> + =C2=A0 =C2=A0 unsigned long idx;
>> + =C2=A0 =C2=A0 struct address_space *mapping;
>> + =C2=A0 =C2=A0 int ret =3D VM_FAULT_SIGBUS;
>> +
>> + =C2=A0 =C2=A0 idx =3D vma->vm_pgoff >> huge_page_order(h);
>> + =C2=A0 =C2=A0 mapping =3D file->f_mapping;
>> + =C2=A0 =C2=A0 ret =3D hugetlbfs_file_mmap(file, vma);
>> +
>> + =C2=A0 =C2=A0 return ret;
>> +}
>> +
>> +
>> +static unsigned long hpage_map_get_unmapped_area(struct file *file,
>> + =C2=A0 =C2=A0 unsigned long addr, unsigned long len, unsigned long pgo=
ff,
>> + =C2=A0 =C2=A0 unsigned long flags)
>> +{
>> + =C2=A0 =C2=A0 return hugetlb_get_unmapped_area(file, addr, len, pgoff,=
 flags);
>> +}
>> +
>> +static int hpage_map_open(struct inode * inode, struct file * file)
>> +{
>> + =C2=A0 =C2=A0struct page *page;
>> + =C2=A0 =C2=A0int num_hpages =3D 10, cnt =3D 0;
>
> What happens if the mmap() call is more than 10 pages? What if the proces=
s
> fork()s, the mapping is MAP_PRIVATE and the child is long lived causing
> a COW fault on the parent process when it next writes the mapping and the
> subsequent allocation fails?
>
> Again, I'm worried that by avoiding hugetlbfs, your drivers end up
> trying to solve all the same problems.
>
>> + =C2=A0 =C2=A0int ret =3D 0;
>> +
>> + =C2=A0 =C2=A0/* Announce =C2=A0hugetlb file mapping */
>> + =C2=A0 =C2=A0mapping_set_hugetlb(file->f_mapping);
>> +
>> + =C2=A0 =C2=A0for (cnt =3D 0; cnt < num_hpages; cnt++ ) {
>> + =C2=A0 =C2=A0 page =3D hugetlb_alloc_pages_node(0,GFP_KERNEL);
>> + =C2=A0 =C2=A0 if (IS_ERR(page)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D -PTR_ERR(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_err;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 ret =3D add_to_page_cache(page, file->f_mapping, cnt, GF=
P_KERNEL);
>> + =C2=A0 =C2=A0 if (ret) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 hugetlb_free_pages(page);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto out_err;
>> + =C2=A0 =C2=A0 }
>> + =C2=A0 =C2=A0 SetPageUptodate(page);
>> + =C2=A0 =C2=A0 unlock_page(page);
>> + =C2=A0 =C2=A0}
>> + =C2=A0 =C2=A0return 0;
>> +out_err:
>> + =C2=A0 =C2=A0printk(KERN_ERR"%s : Error %d \n",__func__, ret);
>> + =C2=A0 =C2=A0make_file_empty(file);
>> + =C2=A0 =C2=A0return ret;
>> +}
>> +
>> +
>> +static int hpage_map_release(struct inode * inode, struct file * file)
>> +{
>> + =C2=A0 =C2=A0make_file_empty(file);
>> + =C2=A0 =C2=A0return 0;
>> +}
>> +/*
>> + * The file operations for /dev/hpage_map
>> + */
>> +static const struct file_operations hpage_map_fops =3D {
>> + =C2=A0 =C2=A0 .owner =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D THIS_MODULE=
,
>> + =C2=A0 =C2=A0 .mmap =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D hpage_map_m=
map,
>> + =C2=A0 =C2=A0 .open =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D hpage_map_o=
pen,
>> + =C2=A0 =C2=A0 .release =C2=A0 =C2=A0 =C2=A0 =C2=A0=3D hpage_map_releas=
e,
>> + =C2=A0 =C2=A0 .get_unmapped_area =C2=A0 =C2=A0 =C2=A0=3D hpage_map_get=
_unmapped_area,
>> +};
>> +
>> +static struct miscdevice hpage_map_dev =3D {
>> + =C2=A0 =C2=A0 MISC_DYNAMIC_MINOR,
>> + =C2=A0 =C2=A0 "hpage_map",
>> + =C2=A0 =C2=A0 &hpage_map_fops
>> +};
>> +
>> +static int __init
>> +hpage_map_init(void)
>> +{
>> + =C2=A0 =C2=A0 /* Create the device in the /sys/class/misc directory. *=
/
>> + =C2=A0 =C2=A0 if (misc_register(&hpage_map_dev))
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return -EIO;
>> + =C2=A0 =C2=A0 return 0;
>> +}
>> +
>> +module_init(hpage_map_init);
>> +
>> +static void __exit
>> +hpage_map_exit(void)
>> +{
>> + =C2=A0 =C2=A0 misc_deregister(&hpage_map_dev);
>> +}
>> +
>> +module_exit(hpage_map_exit);
>> +
>> +MODULE_LICENSE("GPL");
>> +MODULE_AUTHOR("Alexey Korolev");
>> +MODULE_DESCRIPTION("Example of driver with hugetlb mapping");
>> +MODULE_VERSION("1.0");
>> diff -Naurp empty/Makefile hpage_map/Makefile
>> --- empty/Makefile =C2=A0 =C2=A01970-01-01 12:00:00.000000000 +1200
>> +++ hpage_map/Makefile =C2=A0 =C2=A0 =C2=A0 =C2=A02009-07-13 18:31:27.00=
0000000 +1200
>> @@ -0,0 +1,7 @@
>> +obj-m :=3D hpage_map.o
>> +
>> +KDIR =C2=A0:=3D /lib/modules/$(shell uname -r)/build
>> +PWD =C2=A0 :=3D $(shell pwd)
>> +
>> +default:
>> + =C2=A0 =C2=A0 $(MAKE) -C $(KDIR) M=3D$(PWD) modules
>>
>
> --
> Mel Gorman
> Part-time Phd Student =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linux Technology Center
> University of Limerick =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 IBM Dublin Software Lab
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
