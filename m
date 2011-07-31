Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE3F900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 14:50:52 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p6VIomTb013993
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 11:50:49 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz1.hot.corp.google.com with ESMTP id p6VIofvJ002236
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 11:50:47 -0700
Received: by pzk5 with SMTP id 5so15304172pzk.31
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 11:50:41 -0700 (PDT)
Date: Sun, 31 Jul 2011 11:50:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <alpine.DEB.2.00.1107291002570.16178@router.home>
Message-ID: <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 29 Jul 2011, Christoph Lameter wrote:

> > We haven't come up with a solution to keep struct page size the same but I
> > think it's a reasonable trade-off.
> 

We won't be coming up with a solution to that since the alignment is a 
requirement for cmpxchg16b, unfortunately.

> The change requires the page struct to be aligned to a double word
> boundary. There is actually no variable added to the page struct. Its just
> the alignment requirement that causes padding to be added after each page
> struct.
> 

Well, the counters variable is added although it doesn't increase the size 
of the unaligned struct page because of how it is restructured.  The end 
result of the alignment for CONFIG_CMPXCHG_LOCAL is that struct page will 
increase from 56 bytes to 64 bytes on my config.  That's a cost of 128MB 
on each of my client and server 64GB machines for the netperf benchmark 
for the ~2.3% speedup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
