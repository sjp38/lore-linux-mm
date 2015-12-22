Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 011BA6B002A
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 10:47:45 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id l126so115430933wml.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 07:47:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id kc7si11979438wjb.187.2015.12.22.07.47.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 07:47:43 -0800 (PST)
Subject: Re: isolate_lru_page on !head pages
References: <20151209130204.GD30907@dhcp22.suse.cz>
 <20151214120456.GA4201@node.shutemov.name>
 <20151215085232.GB14350@dhcp22.suse.cz>
 <20151215120318.GA11497@node.shutemov.name>
 <20151215165943.GB27880@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5679709B.8030908@suse.cz>
Date: Tue, 22 Dec 2015 16:47:39 +0100
MIME-Version: 1.0
In-Reply-To: <20151215165943.GB27880@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 12/15/2015 05:59 PM, Michal Hocko wrote:
>>
>> head page is what linked into LRU, but not nessesary the way we obtain the
>> page to check. If we check PageLRU(pte_page(*pte)) it should produce the
>> right result.
>
> I am not following you here. Any pfn walk could get to a tail page and
> if we happen to do e.g. isolate_lru_page we have to remember that we
> should always treat compound page differently. This is subtle.

I think the problem is that isolate_lru_page() is not the only reason 
for calling PageLRU(). And the other use cases have different 
expectations, to either way (PF_ANY or PF_HEAD) you pick for PageLRU(), 
somebody will have to be careful. IMHO usually it's pfn scanners who 
have to be careful for many reasons...

> Anyway I
> am far from understading other parts of the refcount rework so I will
> spend time studying the code as soon as the time permits. In the
> meantime I agree that VM_BUG_ON_PAGE(PageTail(page), page) would be
> useful to catch all the fallouts.

+1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
