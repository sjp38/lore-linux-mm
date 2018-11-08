Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6D3C86B067A
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 18:07:08 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id 129-v6so19309750pfx.11
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 15:07:08 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c6-v6si5468637pfi.110.2018.11.08.15.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 15:07:07 -0800 (PST)
Date: Thu, 8 Nov 2018 15:07:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] tmpfs: let lseek return ENXIO with a negative offset
Message-Id: <20181108150700.f9c321f8853053877d3f3fe6@linux-foundation.org>
In-Reply-To: <EDFDF8C6-F164-4C5A-A5D3-010802D02DC2@oracle.com>
References: <1540434176-14349-1-git-send-email-yuyufen@huawei.com>
	<20181107151955.777fcbcf9a5932677e245287@linux-foundation.org>
	<EDFDF8C6-F164-4C5A-A5D3-010802D02DC2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Yufen Yu <yuyufen@huawei.com>, viro@zeniv.linux.org.uk, hughd@google.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-unionfs@vger.kernel.org

On Thu, 8 Nov 2018 03:46:35 -0700 William Kucharski <william.kucharski@oracle.com> wrote:

> 
> 
> > On Nov 7, 2018, at 4:19 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > 
> > man 2 lseek says
> > 
> > :      EINVAL whence  is  not  valid.   Or: the resulting file offset would be
> > :             negative, or beyond the end of a seekable device.
> > :
> > :      ENXIO  whence is SEEK_DATA or SEEK_HOLE, and the file offset is  beyond
> > :             the end of the file.
> > 
> > 
> > Make tmpfs return ENXIO under these circumstances as well.  After this,
> > tmpfs also passes xfstests's generic/448.
> 
> As I objected to last week, despite the fact that other file systems do this, is
> this in fact the desired behavior?
> 
> I'll let you reread that message rather than repeat it in its entirety here, but
> certainly a negative offset is not "beyond the end of the file," and the end
> result is errno is set to ENXIO for a reason that does not match what the
> lseek(2) man page describes.
> 
> I also mentioned if a negative offset is used with SEEK_CUR or SEEK_WHENCE,
> arguably the negative offset should actually be treated as "0" given lseek(2)
> also states:
> 
>       SEEK_DATA
>              Adjust the file offset to the next location in the file
>              greater than or equal to offset containing data.  If offset
>              points to data, then the file offset is set to offset.
> 
>       SEEK_HOLE
>              Adjust the file offset to the next hole in the file greater
>              than or equal to offset.  If offset points into the middle of
>              a hole, then the file offset is set to offset.  If there is no
>              hole past offset, then the file offset is adjusted to the end
>              of the file (i.e., there is an implicit hole at the end of any
>              file).
> 
> Since the "next location" or "next hole" will never be at a negative offset, the
> "greater than" clause of both descriptions would mean the resulting offset should
> be treated as if it were passed as zero.
> 
> However, if xfstest-compliant behavior is desired, the lseek(2) man page
> description for ENXIO should be updated to something like:
> 
>        ENXIO  whence is SEEK_DATA or SEEK_HOLE, and the file offset is negative or
>               beyond the end of the file.
> 
> I don't mean to be pedantic, but I also know how frustrating it can be when a system
> call returns with errno set for a reason that doesn't correspond to the man page.

I think that at this stage we should make tmpfs behaviour match the
other filesystems.

If the manpage doesn't match the kernel's behaviour for this
linux-specific feature(?) then we should fix the manpage.

If we find that the behaviour should actually change (and there's a way
of doing that in a reasonably back-compatible manner) then let's change
all filesystems and the manpage.

OK?
