Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 41D2C6B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 11:56:08 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id bs8so773907wib.9
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 08:56:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id be1si20403378wib.94.2014.07.02.08.55.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jul 2014 08:55:54 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: IMA: kernel reading files opened with O_DIRECT
References: <53B3D3AA.3000408@samsung.com>
Date: Wed, 02 Jul 2014 11:55:41 -0400
In-Reply-To: <53B3D3AA.3000408@samsung.com> (Dmitry Kasatkin's message of
	"Wed, 02 Jul 2014 12:40:58 +0300")
Message-ID: <x49y4wbu54y.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Kasatkin <d.kasatkin@samsung.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, viro@ZenIV.linux.org.uk, Mimi Zohar <zohar@linux.vnet.ibm.com>, linux-security-module <linux-security-module@vger.kernel.org>, Greg KH <gregkh@linuxfoundation.org>, Dmitry Kasatkin <dmitry.kasatkin@gmail.com>

Hi, Dmitry,

Dmitry Kasatkin <d.kasatkin@samsung.com> writes:

> Hi,
>
> We are looking for advice on reading files opened for direct_io.

[snip]

> 2. Temporarily clear O_DIRECT in file->f_flags.

[snip]

> 3. Open another instance of the file with 'dentry_open'

[snip]

> Is temporarily clearing O_DIRECT flag really unacceptable or not?

It's acceptable.  However, what you're proposing to do is read the
entire file into the page cache to calculate your checksum.  Then, when
the application goes to read the file using O_DIRECT, it will ignore the
cached copy and re-read the portions of the file it wants from disk.  So
yes, you can do that, but it's not going to be fast.  If you want to
avoid polluting the cache, you can call invalidate_inode_pages2_range
after you're done calculating your checksum.

> Or may be there is a way to allocate "special" user-space like buffer
> for kernel and use it with O_DIRECT?

In-kernel O_DIRECT support has been proposed in the past, but there is
no solution for that yet.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
