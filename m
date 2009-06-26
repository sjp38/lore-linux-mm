Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 938846B005D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 03:23:12 -0400 (EDT)
Received: by gxk3 with SMTP id 3so2688191gxk.14
        for <linux-mm@kvack.org>; Thu, 25 Jun 2009 22:37:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090625000359.7e201c58.akpm@linux-foundation.org>
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se>
	 <20090624195647.9d0064c7.akpm@linux-foundation.org>
	 <aec7e5c30906242306x64832a8dtfd78fa00ba751ca9@mail.gmail.com>
	 <20090625000359.7e201c58.akpm@linux-foundation.org>
Date: Fri, 26 Jun 2009 14:37:14 +0900
Message-ID: <aec7e5c30906252237x2f4d4f48teca1209e827f7640@mail.gmail.com>
Subject: Re: [PATCH] video: arch specific page protection support for deferred
	io
From: Magnus Damm <magnus.damm@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org, lethal@linux-sh.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 25, 2009 at 4:03 PM, Andrew Morton<akpm@linux-foundation.org> w=
rote:
> On Thu, 25 Jun 2009 15:06:24 +0900 Magnus Damm <magnus.damm@gmail.com> wr=
ote:
>
>> On Thu, Jun 25, 2009 at 11:56 AM, Andrew
>> Morton<akpm@linux-foundation.org> wrote:
>> > On Wed, 24 Jun 2009 19:54:13 +0900 Magnus Damm <magnus.damm@gmail.com>=
 wrote:
>> >
>> >> From: Magnus Damm <damm@igel.co.jp>
>> >>
>> >> This patch adds arch specific page protection support to deferred io.
>> >>
>> >> Instead of overwriting the info->fbops->mmap pointer with the
>> >> deferred io specific mmap callback, modify fb_mmap() to include
>> >> a #ifdef wrapped call to fb_deferred_io_mmap(). __The function
>> >> fb_deferred_io_mmap() is extended to call fb_pgprotect() in the
>> >> case of non-vmalloc() frame buffers.
>> >>
>> >> With this patch uncached deferred io can be used together with
>> >> the sh_mobile_lcdcfb driver. Without this patch arch specific
>> >> page protection code in fb_pgprotect() never gets invoked with
>> >> deferred io.
>> >>
>> >> Signed-off-by: Magnus Damm <damm@igel.co.jp>
>> >> ---
>> >>
>> >> __For proper runtime operation with uncached vmas make sure
>> >> __"[PATCH][RFC] mm: uncached vma support with writenotify"
>> >> __is applied. There are no merge order dependencies.
>> >
>> > So this is dependent upon a patch which is in your tree, which is in
>> > linux-next?
>>
>> I tried to say that there were _no_ dependencies merge wise. =3D)
>>
>> There are 3 levels of dependencies:
>> 1: pgprot_noncached() patches from Arnd
>> 2: mm: uncached vma support with writenotify
>> 3: video: arch specfic page protection support for deferred io
>>
>> 2 depends on 1 to compile, but 3 (this one) is disconnected from 2 and
>> 1. So this patch can be merged independently.
>
> OIC. =A0I didn't like the idea of improper runtime operation ;)
>
> Still, it's messy. =A0If only because various trees might be running
> untested combinations of patches. =A0Can we get these all into the same
> tree? =A0Paul's?

There may also be some dependencies related to other patches posted to
linux-fbdev-devel, for instance:
[PATCH] add mutex to fbdev for fb_mmap locking (v2)
The fb_mmap() locking will conflict with this patch.

So it may make sense to group the fbdev patches together.

>>
>> The code is fbmem.c is currently filled with #ifdefs today, want me
>> create inline versions for fb_deferred_io_open() and
>> fb_deferred_io_fsync() as well?
>
> It was a minor point. =A0Your call.

I'd prefer to submit a patch on top of this one if possible.

Cheers,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
