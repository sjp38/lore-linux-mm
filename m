Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 601E46B026C
	for <linux-mm@kvack.org>; Tue, 29 Dec 2015 15:24:23 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id f206so48248793wmf.0
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 12:24:23 -0800 (PST)
Received: from fmailer.gwdg.de (fmailer.gwdg.de. [134.76.11.16])
        by mx.google.com with ESMTPS id w2si55101520wma.29.2015.12.29.12.24.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 12:24:22 -0800 (PST)
Date: Tue, 29 Dec 2015 21:24:20 +0100
From: Martin Uecker <muecker@gwdg.de>
Subject: reliably detect writes to a file: mmap, mtime, ...
Message-ID: <20151229212420.004b315f@lemur>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>



Hi all,

I want to reliably detect changes to a file even when 
written to using mmap. Surprisingly, there seems to be
no API which would make this possible. Or at least I 
haven't found a way to do it... 


I looked at:

- mtime. What is missing here is an API which would
force mtime to be updated if there are dirty PTEs
in some mapping (which need to be cleared/transferred 
to struct page at this point). This would allow to 
reliably detect changes to the file. If I understand it 
correctly, there was patch from Andy Lutomirski which
made msync(ASYNC) do exactly this:

http://oss.sgi.com/archives/xfs/2013-08/msg00748.html

But it seems this never got in. The other problem with
this is that mtime has limited granularity.
(but maybe that could be worked around by having some
kind of counter + API which tells how often mtime has
been updated without changing its nominal value)



- I also looked at soft-dirty bits, but this API seems
to have several limitations:  1.) it tracks writes
through a specific mapping 2.) it can only have
a single user at the same time 3.) who has to have 
special privileges 4.) and it seems impossible read
and clear the soft-dirty bits at the same time (so you
might miss writes).


But maybe there are other ways... I am missing
something?


Martin



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
