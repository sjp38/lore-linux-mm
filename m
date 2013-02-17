Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 5575B6B00CD
	for <linux-mm@kvack.org>; Sun, 17 Feb 2013 02:39:40 -0500 (EST)
Message-ID: <5120893D.6090705@freescale.com>
Date: Sun, 17 Feb 2013 15:39:41 +0800
From: Huang Shijie <b32955@freescale.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: introduce __linear_page_index()
References: <1360047819-6669-1-git-send-email-b32955@freescale.com> <20130205132741.1e1a4e04.akpm@linux-foundation.org>
In-Reply-To: <20130205132741.1e1a4e04.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8806=E6=97=A5 05:27, Andrew Morton =E5=86=
=99=E9=81=93:
> On Tue, 5 Feb 2013 15:03:39 +0800
> Huang Shijie<b32955@freescale.com>  wrote:
>
>> +static inline pgoff_t __linear_page_index(struct vm_area_struct *vma,
>>   					unsigned long address)
>>   {
>>   	pgoff_t pgoff;
>> +
>> +	pgoff =3D (address - vma->vm_start)>>  PAGE_SHIFT;
>> +	return pgoff + vma->vm_pgoff;
>> +}
>> +
>> +static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
>> +					unsigned long address)
>> +{
>>   	if (unlikely(is_vm_hugetlb_page(vma)))
>>   		return linear_hugepage_index(vma, address);
>> -	pgoff =3D (address - vma->vm_start)>>  PAGE_SHIFT;
>> -	pgoff +=3D vma->vm_pgoff;
>> -	return pgoff>>  (PAGE_CACHE_SHIFT - PAGE_SHIFT);
>> +	return __linear_page_index(vma, address)>>
>> +				(PAGE_CACHE_SHIFT - PAGE_SHIFT);
>>   }
> I don't think we need bother creating both linear_page_index() and
> __linear_page_index().  Realistically, we won't be supporting
Just as Hocko said, the unmap_ref_private() (in hugetlb.c) may also uses=20
the __linear_page_index().
So it's better to the two helpers : linear_page_index() and=20
__linear_page_index().
do you agree?

thanks
Huang Shijie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
