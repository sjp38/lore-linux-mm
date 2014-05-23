Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 32C7F6B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 05:45:10 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so3558332eek.3
        for <linux-mm@kvack.org>; Fri, 23 May 2014 02:45:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h42si5433765eea.133.2014.05.23.02.45.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 02:45:08 -0700 (PDT)
Message-ID: <537F18A2.4010709@suse.cz>
Date: Fri, 23 May 2014 11:45:06 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: 3.15.0-rc6: VM_BUG_ON_PAGE(PageTail(page), page)
References: <20140522135828.GA24879@redhat.com> <537E12D9.6090709@suse.cz> <20140522154100.GA30273@redhat.com>
In-Reply-To: <20140522154100.GA30273@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On 05/22/2014 05:41 PM, Dave Jones wrote:
> On Thu, May 22, 2014 at 05:08:09PM +0200, Vlastimil Babka wrote:
>
>   > > RIP: 0010:[<ffffffffbb718d98>]  [<ffffffffbb718d98>] PageTransHuge.part.23+0xb/0xd
>   > > Call Trace:
>   > >   [<ffffffffbb1728a3>] isolate_migratepages_range+0x7a3/0x870
>   > >   [<ffffffffbb172d90>] compact_zone+0x370/0x560
>   > >   [<ffffffffbb173022>] compact_zone_order+0xa2/0x110
>   > >   [<ffffffffbb1733f1>] try_to_compact_pages+0x101/0x130
>   > > ...
>   > > Code: 75 1d 55 be 6c 00 00 00 48 c7 c7 8a 2f a2 bb 48 89 e5 e8 6c 49 95 ff 5d c6 05 74 16 65 00 01 c3 55 31 f6 48 89 e5 e8 28 bd a3 ff <0f> 0b 0f 1f 44 00 00 55 48 89 e5 41 57 45 31 ff 41 56 49 89 fe
>   > > RIP  [<ffffffffbb718d98>]
>   > >
>   > > That BUG is..
>   > >
>   > > 413 static inline int PageTransHuge(struct page *page)
>   > > 414 {
>   > > 415         VM_BUG_ON_PAGE(PageTail(page), page);
>   > > 416         return PageHead(page);
>   > > 417 }
>   >
>   > Any idea which of the two PageTransHuge() calls in
>   > isolate_migratepages_range() that is? Offset far in the function suggest
>   > it's where the lru lock is already held, but I'm not sure as decodecode
>   > of your dump and objdump of my own compile look widely different.
>
> Yeah, the only thing the code: matches is the BUG() which is in another section.

Oh right, it's not a simple BUG_ON that would be inlined.

> (see end of file at http://paste.fedoraproject.org/104155/40077293/raw/)
>
> Maybe you can make more sense of that disassembly than I can..

Could you try adding -r to objdump, as now I have no idea where all 
those calls go :/

> 	Dave
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
