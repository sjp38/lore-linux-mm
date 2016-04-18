Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2535D6B007E
	for <linux-mm@kvack.org>; Mon, 18 Apr 2016 09:58:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c20so329529951pfc.2
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 06:58:21 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id p126si5492591pfb.228.2016.04.18.06.58.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Apr 2016 06:58:19 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id c20so81177037pfc.1
        for <linux-mm@kvack.org>; Mon, 18 Apr 2016 06:58:19 -0700 (PDT)
Date: Mon, 18 Apr 2016 15:58:06 +0200
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: making a COW mapping on the fly from existing vma
Message-ID: <20160418135805.GA9238@gmail.com>
References: <CAPM=9twrh8wVin=A1Zva3DD0iBmM-G8GjdSnzOD-b0=h4SVxyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPM=9twrh8wVin=A1Zva3DD0iBmM-G8GjdSnzOD-b0=h4SVxyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Airlie <airlied@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, dri-devel <dri-devel@lists.freedesktop.org>

On Sat, Apr 16, 2016 at 06:18:38AM +1000, Dave Airlie wrote:
> This was just a random thought process I was having last night, and
> wondered if it was possible.
> 
> We have a scenario with OpenGL where certain APIs hand large amounts
> of data from the user to the API and when you return from the API call
> the user can then free/overwrite/do whatever they want with the data
> they gave you, which pretty much means you have to straight away
> process the data.
> 
> Now there have been attempts at threading the GL API, but one thing
> they usually hit is they have to do a lot of unthreaded processing for
> these scenarios, so I was wondering could we do some COW magic with
> the data.
> 
> More than likely the data will be anonymous mappings though maybe some
> filebacked, and my idea would be you'd in the main thread create a new
> readonly VMA from the old pages and set the original mapping to do COW
> on all of its pages. Then the thread would pick up the readonly VMA
> mapping and do whatever background processing it wants while the main
> thread continues happily on its way.
> 
> I'm not sure if anyone who's done glthread has thought around this, or
> if the kernel APIs are in place to do something like this so I just
> thought I'd throw it out there.
> 

So iirc, i discussed doing that with Thomas while upstreaming ttm, a long
time ago in a far far away universe. There is 2 issues, for file back page
we just do not have any infrastructure to write protect a valid & uptodate
page. Even if we did, such file back page might be map so many times that
the cost of walking all the mapping and tlb flushing might be worse then
doing just memcpy. Finaly handling things like write() syscall would also
be problematic and require major code overhaul (especialy if we consider
direct io). So for file back page i would say this is a no go, unless i
am unaware of some magic kernel infrastructure that just do that already.

For anonymous memory issue mostly revolve around tlb flush, if we are
talking about few pages then you very likely better of doing memcpy. So
it would need some heuristic for that. That being said, the reason why i
never tried to implement it in the end is because you end up to defer the
memcpy. So the application still pay the memcpy cost, you can not expect
userspace free to do an munmap() after uploading texture. So i am not sure
it is worth doing. One thing that might make sense is some new madvise
kind of like MADV_DONTNEED, maybe MADV_STEAL or MADV_GIFT which would mean
that memory with that flag can be steal and replace by zero page. I know
this sounds like splice(SPLICE_F_MOVE) but we can not use splice here
because we can not change the OpenGL API.

So we could add a new get_user_pages_steal or get_user_pages_cow, and
probably best to implement the latter first and see if it already helps
with real world apps but i have my doubts.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
