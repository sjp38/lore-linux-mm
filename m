Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E727D6B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 15:07:40 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so1019118wib.15
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 12:07:40 -0700 (PDT)
Received: from mail-wi0-x231.google.com (mail-wi0-x231.google.com [2a00:1450:400c:c05::231])
        by mx.google.com with ESMTPS id hc6si32978331wjc.68.2014.07.02.12.07.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 12:07:40 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id r20so1068647wiv.10
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 12:07:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x49tx6ztx9d.fsf@segfault.boston.devel.redhat.com>
References: <53B3D3AA.3000408@samsung.com>
	<x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
	<20140702184050.GA24583@infradead.org>
	<x49tx6ztx9d.fsf@segfault.boston.devel.redhat.com>
Date: Wed, 2 Jul 2014 22:07:38 +0300
Message-ID: <CACE9dm-NZqC_qz8ip-9wUamwK7daOnKs_dTKQrT+zG4E2BJ=Jw@mail.gmail.com>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
From: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dmitry Kasatkin <d.kasatkin@samsung.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On 2 July 2014 21:45, Jeff Moyer <jmoyer@redhat.com> wrote:
> Christoph Hellwig <hch@infradead.org> writes:
>
>> On Wed, Jul 02, 2014 at 11:55:41AM -0400, Jeff Moyer wrote:
>>> It's acceptable.
>>
>> It's not because it will then also affect other reads going on at the
>> same time.
>

> OK, that part I was fuzzy on.  I wasn't sure if they were preventing
> other reads/writes to the same file somehow.  I should have mentioned
> that.
>
> Cheers,
> Jeff


What Christoph says is not very correct.

At open there cannot be any reads going on at the same time. IMA
reading is guarded by mutex. Following opens do not perform any IMA
readings and do not do what he says...

If file was modified with direct-io, VFS code itself always invalidate
pages before and after any write. It is basically what Christoph says.
But that is not IMA problem but direct-io itself. As it is stupid
interface. I would be more looking to kind of fadvise interface to
control amount of page caching...

So I think what Jeff suggest suites well to IMA.

-- 
Thanks,
Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
