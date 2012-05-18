Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C83BD6B00E8
	for <linux-mm@kvack.org>; Thu, 17 May 2012 20:55:04 -0400 (EDT)
Received: by ggm4 with SMTP id 4so3521749ggm.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 17:55:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FB580A9.6020305@linux.vnet.ibm.com>
References: <alpine.DEB.2.00.1205171605001.19076@router.home> <4FB580A9.6020305@linux.vnet.ibm.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 17 May 2012 20:54:42 -0400
Message-ID: <CAHGf_=r6rBR=R00+ktJO9Ad0fytOgjY3YUcrY+3pfYfM=iwjKQ@mail.gmail.com>
Subject: Re: Huge pages: Memory leak on mmap failure
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Alexey Dobriyan <adobriyan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On Thu, May 17, 2012 at 6:50 PM, Dave Hansen <dave@linux.vnet.ibm.com> wrot=
e:
> On 05/17/2012 02:07 PM, Christoph Lameter wrote:
>>
>> On 2.6.32 and 3.4-rc6 mmap failure of a huge page causes a memory
>> leak. The 32 byte kmalloc cache grows by 10 mio entries if running
>> the following code:
>
> When called for anonymous (non-shared) mappings, hugetlb_reserve_pages()
> does a resv_map_alloc(). =A0It depends on code in hugetlbfs's
> vm_ops->close() to release that allocation.
>
> However, in the mmap() failure path, we do a plain unmap_region()
> without the remove_vma() which actually calls vm_ops->close().
>
> As the code stands today, I think we can fix this by just making sure we
> release the resv_map after hugetlb_acct_memory() fails. =A0But, this seem=
s
> like a bit of a superficial fix and if we end up with another path or
> two that can return -ESOMETHING, this might get reintroduced. =A0The
> assumption that vm_ops->close() will get called on all VMAs passed in to
> hugetlbfs_file_mmap() seems like something that needs to get corrected.

I agree. Now, resv_map_alloc() is called file open path and
resv_map_free() is called vma close path. It seems asymmetry.
It would be nice if resv_map_alloc can use vma->open ops.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
