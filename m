Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 096A06B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 02:33:54 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so422206pdj.29
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 23:33:54 -0700 (PDT)
Date: Wed, 16 Oct 2013 09:33:51 +0300 (EEST)
From: =?UTF-8?B?0JjQstCw0LnQu9C+INCU0LjQvNC40YLRgNC+0LI=?= <freemangordon@abv.bg>
Message-ID: <1046037275.21008.1381905231138.JavaMail.apache@mail83.abv.bg>
Subject: Re: OMAPFB: CMA allocation failures
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: pali.rohar@gmail.com, pc+n900@asdf.org, pavel@ucw.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

 Hi Tomi,

 >I think we should somehow find out what the pages are that cannot be
 >migrated, and where they come from.
 >
 >So there are &quot;anonymous pages without mapping&quot; with page_count(page) !=
 >1. I have to say I don't know what that means =). I need to find some
 >time to study the mm.

I put some more traces in the point of failure, the result:

page_count(page) == 2, page->flags == 0x0008025D, which is:

PG_locked, PG_referenced, PG_uptodate, PG_dirty, PG_active, PG_arch_1, PG_unevictable

Whatever those mean :). I have no idea how to identify where those pages come from.

 >Well, as I said, you're the first one to report any errors, after the
 >change being in use for a year. Maybe people just haven't used recent
 >enough kernels, and the issue is only now starting to emerge, but I
 >wouldn't draw any conclusions yet.

I am (almost) sure I am the first one to test video playback on OMAP3 with DSP video
acceleration, using recent kernel and Maemo5 on n900 :). So there is high probability the issue was not reported earlier because noone have tested it thoroughly after the change.

 >If the CMA would have big generic issues, I think we would've seen
 >issues earlier. So I'm guessing it's some driver or app in your setup
 >that's causing the issues. Maybe the driver/app is broken, or maybe that
 >specific behavior is not handled well by CMA. In both case I think we
 >need to identify what that driver/app is.

What I know is going on, is that there is heavy fs I/O at the same time - there is
a thumbnailer process running in background which tries to extract thumbnails of all video
files in the system. Also, there are other processes doing various jobs (e-mail fetching, IM
accounts login, whatnot). And in addition Xorg mlocks parts of its address space. Of course all
this happens with lots of memory being swapped in and out. I guess all this is related.

However, even after the system has settled, the CMA failures continue to happen. It looks like
some pages are allocated from CMA which should not be.

 >I wonder how I could try to reproduce this with a generic omap3 board...

I can always reproduce it here (well, not on generic board, but I guess it is even better to test in real-life conditions), so if you need some specific tests or traces or whatever, I
can do them for you.

Regards,
Ivo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
