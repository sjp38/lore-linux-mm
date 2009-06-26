Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DD7D46B006A
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 03:48:37 -0400 (EDT)
Received: by yxe38 with SMTP id 38so911089yxe.12
        for <linux-mm@kvack.org>; Fri, 26 Jun 2009 00:50:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090625111233.f6f26050.akpm@linux-foundation.org>
References: <20090624105413.13925.65192.sendpatchset@rx1.opensource.se>
	 <20090624195647.9d0064c7.akpm@linux-foundation.org>
	 <aec7e5c30906242306x64832a8dtfd78fa00ba751ca9@mail.gmail.com>
	 <20090625000359.7e201c58.akpm@linux-foundation.org>
	 <20090625173806.GB25320@linux-sh.org>
	 <20090625111233.f6f26050.akpm@linux-foundation.org>
Date: Fri, 26 Jun 2009 16:50:09 +0900
Message-ID: <aec7e5c30906260050k176a6d5fi731306246d475d48@mail.gmail.com>
Subject: Re: [PATCH] video: arch specific page protection support for deferred
	io
From: Magnus Damm <magnus.damm@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, linux-fbdev-devel@lists.sourceforge.net, adaplas@gmail.com, arnd@arndb.de, linux-mm@kvack.org, jayakumar.lkml@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, Jun 26, 2009 at 3:12 AM, Andrew Morton<akpm@linux-foundation.org> w=
rote:
> On Fri, 26 Jun 2009 02:38:06 +0900
> Paul Mundt <lethal@linux-sh.org> wrote:
>
>> On Thu, Jun 25, 2009 at 12:03:59AM -0700, Andrew Morton wrote:
>> > On Thu, 25 Jun 2009 15:06:24 +0900 Magnus Damm <magnus.damm@gmail.com>=
 wrote:
>> > > There are 3 levels of dependencies:
>> > > 1: pgprot_noncached() patches from Arnd
>> > > 2: mm: uncached vma support with writenotify
>> > > 3: video: arch specfic page protection support for deferred io
>> > >
>> > > 2 depends on 1 to compile, but 3 (this one) is disconnected from 2 a=
nd
>> > > 1. So this patch can be merged independently.
>> >
>> > OIC. =A0I didn't like the idea of improper runtime operation ;)
>> >
>> > Still, it's messy. =A0If only because various trees might be running
>> > untested combinations of patches. =A0Can we get these all into the sam=
e
>> > tree? =A0Paul's?
>> >
>> #1 is a bit tricky. cris has already merged the pgprot_noncached() patch=
,
>> which means only m32r and xtensa are outstanding, and unfortunately
>> neither one of those is very fast to pick up changes. OTOH, both of thos=
e
>> do include asm-generic/pgtable.h, so the build shouldn't break in -next
>> for those two if I merge #2 and #3, even if the behaviour won't be
>> correct for those platforms until they merge their pgprot_noncached()
>> patches (I think this is ok, since it's not changing any behaviour they
>> experience today anyways).
>>
>> It would be nice to have an ack from someone for #2 before merging it,
>> but it's been out there long enough that people have had ample time to
>> raise objections.
>>
>> So I'll make this the last call for acks or nacks on #2 and #3, if none
>> show up in the next couple of days, I'll fold them in to my tree and
>> they'll show up in -next starting next week.
>
> Well my head span off ages ago. =A0Could someone please resend all three
> patches?
>
> <hunts around and finds #2>
>
> I don't really understand that one. =A0Have we heard fro Jaya recently?

Some f_op->mmap() callbacks invoked from mmap_region() may want to use
writenotify but also modify vma->vm_page_prot to for instance mark the
vma as uncached.

Without patch #2 the vma->vm_page_prot value set by f_op->mmap() gets
overwritten if writenotify is enabled. So in the case of writenotify
the vma will never be uncached even though f_op->mmap() marks it as
such. Patch #2 makes it possible to keep the uncached setting made by
f_op->mmap() and use writenotify.

On SuperH we want to use deferred io with an uncached vma, so patch #3
makes sure our arch specific fb_pgprotect() function gets called so we
can mark the vma as uncached.

Hope this clarifies a bit.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
