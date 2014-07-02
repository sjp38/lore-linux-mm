Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
	by kanga.kvack.org (Postfix) with ESMTP id C7C156B0036
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 14:12:04 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id x48so11599671wes.9
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 11:12:04 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id cx3si20867867wib.33.2014.07.02.11.12.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 11:12:03 -0700 (PDT)
Received: by mail-wg0-f48.google.com with SMTP id n12so11521901wgh.7
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 11:12:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
References: <53B3D3AA.3000408@samsung.com>
	<x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
Date: Wed, 2 Jul 2014 21:12:03 +0300
Message-ID: <CACE9dm_YF+aYSDXQg=JV2b4i7Uw9AcpsTt4DRCC+F7zUt_qO-w@mail.gmail.com>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
From: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dmitry Kasatkin <d.kasatkin@samsung.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>

Hi Jeff,

Thanks for reply.

On 2 July 2014 18:55, Jeff Moyer <jmoyer@redhat.com> wrote:
> Hi, Dmitry,
>
> Dmitry Kasatkin <d.kasatkin@samsung.com> writes:
>
>> Hi,
>>
>> We are looking for advice on reading files opened for direct_io.
>
> [snip]
>
>> 2. Temporarily clear O_DIRECT in file->f_flags.
>
> [snip]
>
>> 3. Open another instance of the file with 'dentry_open'
>
> [snip]
>
>> Is temporarily clearing O_DIRECT flag really unacceptable or not?
>
> It's acceptable.  However, what you're proposing to do is read the
> entire file into the page cache to calculate your checksum.  Then, when
> the application goes to read the file using O_DIRECT, it will ignore the
> cached copy and re-read the portions of the file it wants from disk.  So
> yes, you can do that, but it's not going to be fast.  If you want to
> avoid polluting the cache, you can call invalidate_inode_pages2_range
> after you're done calculating your checksum.
>

Ok. If I understand correctly, after reading chunck/range like
kernel_read(offset, len),
just always drop loaded pages like

invalidate_inode_pages2_range(inode->i_mapping, offset, offset + len);

I see that generic_file_direct_write() calls this function too, before
doing direct IO and after...

Thanks!

>> Or may be there is a way to allocate "special" user-space like buffer
>> for kernel and use it with O_DIRECT?
>
> In-kernel O_DIRECT support has been proposed in the past, but there is
> no solution for that yet.
>
> Cheers,
> Jeff



-- 
Thanks,
Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
