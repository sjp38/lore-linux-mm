Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 218436B00A0
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 12:57:51 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o9KGvlkj026875
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:57:49 -0700
Received: from pxi8 (pxi8.prod.google.com [10.243.27.8])
	by hpaq7.eem.corp.google.com with ESMTP id o9KGvFLi030238
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:57:45 -0700
Received: by pxi8 with SMTP id 8so1150199pxi.15
        for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:57:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTikn_44WcCBmWUW=8E3q3=cznZNx=dHdOcgZSKgH@mail.gmail.com>
References: <AANLkTikn_44WcCBmWUW=8E3q3=cznZNx=dHdOcgZSKgH@mail.gmail.com>
Date: Wed, 20 Oct 2010 09:57:44 -0700
Message-ID: <AANLkTin32b4SaC0PTJpX8Pg4anQ3aSMUZFe0QFbt9y36@mail.gmail.com>
Subject: Re: TMPFS Maximum File Size
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 20, 2010 at 6:44 AM, Tharindu Rukshan Bamunuarachchi
<btharindu@gmail.com> wrote:
>
> Is there any kind of file size limitation in TMPFS ?

There is, but it should not be affecting you.  In your x86_64 case,
the tmpfs filesize limit should be slightly over 256GB.

(There's no good reason for that limit when CONFIG_SWAP is not set,
and it's then just a waste of memory on those swap vectors: I've long
wanted to #iifdef CONFIG_SWAP them, but never put in the work to do so
cleanly.)

> Our application SEGFAULT inside write() after filling 70% of TMPFS
> mount. (re-creatable but does not happen every time).

I've no idea why that should be happening: I wonder if your case is
actually triggering some memory corruption, in application or in
kernel, that manifests in that way.

But I don't quite understand what you're seeing either: a segfault in
the write() library call of your libc?  an EFAULT from the kernel's
sys_write()?

Hugh

>
> We are using 98GB TMPFS without swap device. i.e. SWAP is turned off.
> Applications does not take approx. 20GB memory.
>
> we have Physical RAM of 128GB Intel x86 box running SLES 11 64bit.
> We use Infiniband, export TMPFS over NFS and IBM GPFS in same box.
> (hope those won't affect)
>
> Bit confused about "triple-indirect swap vector" ?
>
> Extracted from shmem.c ....
>
> /*
> =C2=A0* The maximum size of a shmem/tmpfs file is limited by the maximum =
size of
> =C2=A0* its triple-indirect swap vector - see illustration at shmem_swp_e=
ntry().
> =C2=A0*
> =C2=A0* With 4kB page size, maximum file size is just over 2TB on a 32-bi=
t kernel,
> =C2=A0* but one eighth of that on a 64-bit kernel.=C2=A0 With 8kB page si=
ze, maximum
> =C2=A0* file size is just over 4TB on a 64-bit kernel, but 16TB on a 32-b=
it kernel,
> =C2=A0* MAX_LFS_FILESIZE being then more restrictive than swap vector lay=
out.
> =C2=A0*
>
> Thankx a lot.
> __
> Tharindu R Bamunuarachchi.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
