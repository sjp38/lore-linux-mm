Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73A8D6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 16:18:40 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id q8so75390385lfe.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 13:18:40 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id j207si27074394lfj.27.2016.04.15.13.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 13:18:39 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id j11so158041617lfb.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 13:18:38 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 16 Apr 2016 06:18:38 +1000
Message-ID: <CAPM=9twrh8wVin=A1Zva3DD0iBmM-G8GjdSnzOD-b0=h4SVxyw@mail.gmail.com>
Subject: making a COW mapping on the fly from existing vma
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, dri-devel <dri-devel@lists.freedesktop.org>

This was just a random thought process I was having last night, and
wondered if it was possible.

We have a scenario with OpenGL where certain APIs hand large amounts
of data from the user to the API and when you return from the API call
the user can then free/overwrite/do whatever they want with the data
they gave you, which pretty much means you have to straight away
process the data.

Now there have been attempts at threading the GL API, but one thing
they usually hit is they have to do a lot of unthreaded processing for
these scenarios, so I was wondering could we do some COW magic with
the data.

More than likely the data will be anonymous mappings though maybe some
filebacked, and my idea would be you'd in the main thread create a new
readonly VMA from the old pages and set the original mapping to do COW
on all of its pages. Then the thread would pick up the readonly VMA
mapping and do whatever background processing it wants while the main
thread continues happily on its way.

I'm not sure if anyone who's done glthread has thought around this, or
if the kernel APIs are in place to do something like this so I just
thought I'd throw it out there.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
