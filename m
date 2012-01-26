Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id EEC106B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 19:59:56 -0500 (EST)
Received: by pbaa12 with SMTP id a12so320699pba.14
        for <linux-mm@kvack.org>; Wed, 25 Jan 2012 16:59:56 -0800 (PST)
Date: Wed, 25 Jan 2012 16:59:41 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Help] : RSS/PSS showing 0 during smaps for Xorg
In-Reply-To: <1327468926.52380.YahooMailNeo@web162002.mail.bf1.yahoo.com>
Message-ID: <alpine.LSU.2.00.1201251623340.2141@eggly.anvils>
References: <1327310360.96918.YahooMailNeo@web162003.mail.bf1.yahoo.com> <1327313719.76517.YahooMailNeo@web162002.mail.bf1.yahoo.com> <alpine.LSU.2.00.1201231125200.1677@eggly.anvils> <1327468926.52380.YahooMailNeo@web162002.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1564816580-1327539584=:2141"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1564816580-1327539584=:2141
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 24 Jan 2012, PINTU KUMAR wrote:
> =A0
> Is there a way to convert our mapped pages to a normal pages. I tried pfn=
_to_page() but no effect.
> I mean the page is considered normal only if it is associated with "struc=
t page" right???
> Is is possible to convert these pages to a normal struct pages so that we=
 can get the Rss/Pss value??

I don't understand why you are so anxious to see non-0 numbers there.

I don't know if the pages you are mapping with remap_pfn_range() are
ordinary pages in normal memory, and so already have struct pages, or not.

> =A0
> Also, the VM_PFNMAP is being set for all dirvers during remap_pfn_range a=
nd stills shows Rss/Pss for other drivers.

I'm surprised.  It is possible to set up a private-writable VM_PFNMAP area,
which can then contain ordinary private copies of the underlying pages,
and these copies will count to Rss.  But I thought that was very unusual.

You don't mention which drivers these are that use remap_pfn_range yet
show Rss (and I don't particularly want to spend time researching them).

I can see three or four places in drivers/ where VM_PFNMAP is set,
perhaps without going through remap_pfn_range(): that seems prone
to error, I wouldn't recommend going that route.

> Then why it is not shown for our driver?
> How to avoid remap_pfn_range to not to set VM_PFNMAP for our driver?

If these are ordinary pages with struct pages, then you could probably
use a loop of vm_insert_page()s to insert them at mmap time, or a fault
routine to insert them on fault.  But as I said, I don't know if this
memory is part of the ordinary page pool or not.

Really, the question has to be, why do you need to see non-0s there?

Hugh
--8323584-1564816580-1327539584=:2141--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
