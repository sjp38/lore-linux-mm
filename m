Date: Wed, 23 May 2001 04:33:35 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: write drop behind effect on active scanning 
Message-ID: <Pine.LNX.4.21.0105221910361.864-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi, 

I just noticed a "bad" effect of write drop behind yesterday during some
tests.

The problem is that we deactivate written pages, thus making the inactive
list become pretty big (full of unfreeable pages) under write intensive IO
workloads.

So what happens is that we don't do _any_ aging on the active list, and in
the meantime the inactive list (which should have "easily" freeable
pages) is full of locked pages. 

I'm going to fix this one by replacing "deactivate_page(page)" to
"ClearPageReferenced(page)" in generic_file_write(). This way the written
pages are aged faster but we avoid the bad effect just described.

Any comments on the fix ?  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
