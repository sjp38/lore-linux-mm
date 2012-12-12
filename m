Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 47E5C6B0062
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 09:10:58 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id v19so712451obq.14
        for <linux-mm@kvack.org>; Wed, 12 Dec 2012 06:10:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121212145631.d03a40fd28d4b59b56009fe1@mxc.nes.nec.co.jp>
References: <20121211214859.GG5580@redhat.com>
	<104724866.46130887.1355264225876.JavaMail.root@redhat.com>
	<20121212145631.d03a40fd28d4b59b56009fe1@mxc.nes.nec.co.jp>
Date: Wed, 12 Dec 2012 23:10:57 +0900
Message-ID: <CAAmzW4PGD4QWVuL4zWLeZ3GLyetoD0NO8qgc1Rgfx-CtGS384w@mail.gmail.com>
Subject: Re: [RFC PATCH 0/8] remove vm_struct list management
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>
Cc: anderson@redhat.com, vgoyal@redhat.com, akpm@linux-foundation.org, rmk+kernel@arm.linux.org.uk, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Atsushi.

2012/12/12 Atsushi Kumagai <kumagai-atsushi@mxc.nes.nec.co.jp>:
> Hello,
>
> On Tue, 11 Dec 2012 17:17:05 -0500 (EST)
> Dave Anderson <anderson@redhat.com> wrote:
>
>>
>>
>> ----- Original Message -----
>> > On Mon, Dec 10, 2012 at 11:40:47PM +0900, JoonSoo Kim wrote:
>> >
>> > [..]
>> > > > So without knowing details of both the data structures, I think if vmlist
>> > > > is going away, then user space tools should be able to traverse vmap_area_root
>> > > > rb tree. I am assuming it is sorted using ->addr field and we should be
>> > > > able to get vmalloc area start from there. It will just be a matter of
>> > > > exporting right fields to user space (instead of vmlist).
>> > >
>> > > There is address sorted list of vmap_area, vmap_area_list.
>> > > So we can use it for traversing vmalloc areas if it is necessary.
>> > > But, as I mentioned before, kexec write *just* address of vmlist and
>> > > offset of vm_struct's address field.  It imply that they don't traverse vmlist,
>> > > because they didn't write vm_struct's next field which is needed for traversing.
>> > > Without vm_struct's next field, they have no method for traversing.
>> > > So, IMHO, assigning dummy vm_struct to vmlist which is implemented by [7/8] is
>> > > a safe way to maintain a compatibility of userspace tool. :)
>> >
>> > Actually the design of "makedumpfile" and "crash" tool is that they know
>> > about kernel data structures and they adopt to changes. So for major
>> > changes they keep track of kernel version numbers and if access the
>> > data structures accordingly.
>> >
>> > Currently we access first element of vmlist to determine start of vmalloc
>> > address. True we don't have to traverse the list.
>> >
>> > But as you mentioned we should be able to get same information by
>> > traversing to left most element of vmap_area_list rb tree. So I think
>> > instead of trying to retain vmlist first element just for backward
>> > compatibility, I will rather prefer get rid of that code completely
>> > from kernel and let user space tool traverse rbtree. Just export
>> > minimum needed info for traversal in user space.
>>
>> There's no need to traverse the rbtree.  There is a vmap_area_list
>> linked list of vmap_area structures that is also sorted by virtual
>> address.
>>
>> All that makedumpfile would have to do is to access the first vmap_area
>> in the vmap_area_list -- as opposed to the way that it does now, which is
>> by accessing the first vm_struct in the to-be-obsoleted vmlist list.
>>
>> So it seems silly to keep the dummy "vmlist" around.
>
> I think so, I will modify makedumpfile to get the start address of vmalloc
> with vmap_area_list if the related symbols are provided as VMCOREINFO like
> vmlist.
> BTW, have we to consider other tools ?
> If it is clear, I think we can get rid of the dummy vmlist.

Good!
In next spin, I will remove dummy vmlist and export vmap_area_list symbol
for makedumpfile.

I don't know any other tools.
If anyone knows it, please let me know.

Thanks! Atsushi, Dave and Vivek.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
