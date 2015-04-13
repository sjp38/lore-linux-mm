Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id E904F6B0038
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 19:42:58 -0400 (EDT)
Received: by iejt8 with SMTP id t8so2237981iej.2
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 16:42:58 -0700 (PDT)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id k9si8737578igx.24.2015.04.13.16.42.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Apr 2015 16:42:58 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so60469844igb.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 16:42:58 -0700 (PDT)
Date: Mon, 13 Apr 2015 16:42:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH v2] mm: show free pages per each migrate type
In-Reply-To: <COL130-W77A7613DB3EA1820D92CBABAF80@phx.gbl>
Message-ID: <alpine.DEB.2.10.1504131639290.20336@chino.kir.corp.google.com>
References: <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>,<alpine.DEB.2.10.1504101944440.9879@chino.kir.corp.google.com> <COL130-W77A7613DB3EA1820D92CBABAF80@phx.gbl>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-857007855-1428968577=:20336"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ZhangNeil <neilzhang1123@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-857007855-1428968577=:20336
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 12 Apr 2015, ZhangNeil wrote:

> > Sorry, this is just way too verbose. This output is emitted to the kernel
> > log on oom kill and since we lack a notification mechanism on system oom,
> > the _only_ way for userspace to detect oom kills that have occurred is by
> > scraping the kernel log. This is exactly what we do, and we have missed
> > oom kill events because they scroll from the ring buffer due to excessive
> > output such as this, which is why output was limited with the
> > show_free_areas() filter in the first place. Just because oom kill output
> > is much less than it has been in the past, for precisely this reason,
> > doesn't mean we can make it excessive again.
> >
> 
> Just like you said, OOM kill is much less than before, but we still need to analyze it when 
> it happens on a mobile device. It can give more detailed info for us when debugging.
>  

There is a very large amount of data that would be true for, and we simply 
can't make oom killing more verbose in the kernel log because it is the 
_only_ mechanism we have to determine that the kernel killed a user 
process and what that process was.  You could make the same argument for 
dumping all of /proc/slabinfo, which people have proposed before and it's 
been nacked, to discover slab leaks.  We simply can't make it more 
verbose, it's that easy.

> Besides OOM kill, we also can check the memory usages in runtime by echo 'm' to sysRq.
> It can help us to  find out code defect sometimes, for example, we even found that the NR_FREE_CMA
> memory was not align with the total CMA pages in the free list showed by this patch.
> 

Sysrq is an entirely different usecase and the natural response would be 
to export this information for sysrq but not oom kill, but in this case 
there is no compelling reason to dump it in the ring buffer in the first 
place: it should be in procfs where it can easily be read and parsed.
--531381512-857007855-1428968577=:20336--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
