Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id AEA3C6B0075
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 12:03:43 -0400 (EDT)
Received: by qgh3 with SMTP id 3so176865243qgh.2
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 09:03:43 -0700 (PDT)
Received: from mail-qc0-x230.google.com (mail-qc0-x230.google.com. [2607:f8b0:400d:c01::230])
        by mx.google.com with ESMTPS id y62si2756528qky.22.2015.03.30.09.03.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 09:03:42 -0700 (PDT)
Received: by qcbjx9 with SMTP id jx9so75352593qcb.0
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 09:03:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <551412FB.4090406@akamai.com>
References: <alpine.DEB.2.10.1410221518160.31326@davide-lnx3>
 <alpine.LSU.2.11.1503251708530.5592@eggly.anvils> <alpine.DEB.2.10.1503251754320.26501@davide-lnx3>
 <alpine.DEB.2.10.1503251938170.16714@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1503260431290.2755@mbplnx> <551412FB.4090406@akamai.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 30 Mar 2015 12:03:21 -0400
Message-ID: <CAHGf_=p8yYDGVn-utH7UUOnoF9+W15_WG_xGwN-h3=hMKbYDyw@mail.gmail.com>
Subject: Re: [patch][resend] MAP_HUGETLB munmap fails with size not 2MB aligned
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Davide Libenzi <davidel@xmailserver.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Mar 26, 2015 at 10:08 AM, Eric B Munson <emunson@akamai.com> wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> On 03/26/2015 07:56 AM, Davide Libenzi wrote:
>> On Wed, 25 Mar 2015, David Rientjes wrote:
>>
>>> I looked at this thread at http://marc.info/?t=141392508800001
>>> since I didn't have it in my mailbox, and I didn't get a chance
>>> to actually run your test code.
>>>
>>> In short, I think what you're saying is that
>>>
>>> ptr = mmap(..., 4KB, ..., MAP_HUGETLB | ..., ...) munmap(ptr,
>>> 4KB) == EINVAL
>>
>> I am not sure you have read the email correctly:
>>
>> munmap(mmap(size, HUGETLB), size) = EFAIL
>>
>> For every size not multiple of the huge page size. Whereas:
>>
>> munmap(mmap(size, HUGETLB), ALIGN(size, HUGEPAGE_SIZE)) = OK
>
> I think Davide is right here, this is a long existing bug in the
> MAP_HUGETLB implementation.  Specifically, the mmap man page says:
>
> All pages containing a part of the indicated range are unmapped, and
> subsequent references to these pages will generate SIGSEGV.
>
> I realize that huge pages may not have been considered by those that
> wrote the spec.  But if I read this I would assume that all pages,
> regardless of size, touched by the munmap() request should be unmapped.
>
> Please include
> Acked-by: Eric B Munson <emunson@akamai.com>
> to the original patch.  I would like to see the mmap man page adjusted
> to make note of this behavior as well.

This is just a bug fix and I never think this has large risk. But
caution, we might revert immediately
if this patch arise some regression even if it's come from broken
application code.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
