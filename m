Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 516E216B6D
	for <linux-mm@kvack.org>; Wed, 23 May 2001 12:39:32 -0300 (EST)
Date: Wed, 23 May 2001 12:39:31 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: write drop behind effect on active scanning 
In-Reply-To: <Pine.LNX.4.21.0105221910361.864-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33.0105231237510.311-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2001, Marcelo Tosatti wrote:

> I just noticed a "bad" effect of write drop behind yesterday during some
> tests.
>
> The problem is that we deactivate written pages, thus making the inactive
> list become pretty big (full of unfreeable pages) under write intensive IO
> workloads.
>
> So what happens is that we don't do _any_ aging on the active list, and in
> the meantime the inactive list (which should have "easily" freeable
> pages) is full of locked pages.
>
> I'm going to fix this one by replacing "deactivate_page(page)" to
> "ClearPageReferenced(page)" in generic_file_write(). This way the written
> pages are aged faster but we avoid the bad effect just described.
>
> Any comments on the fix ?

1) I agree with it, drop-behind should make the pages we write
   very likely for eviction, but we don't want that to stop the
   eviction of other not-used pages ...

2) OTOH, if writeout of dirty pages is a problem for the system,
   I guess we will want to fix that problem somehow ;)
   (but that's another issue)

regards,

Rik
--
Linux MM bugzilla: http://linux-mm.org/bugzilla.shtml

Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
