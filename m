Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id A3D4A280245
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 11:10:33 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so54755977qge.3
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 08:10:33 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 80si12210431qhg.131.2015.08.06.08.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 08:10:32 -0700 (PDT)
Message-ID: <55C37852.8030600@oracle.com>
Date: Thu, 06 Aug 2015 11:08:02 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 05/11] mm: debug: dump page into a string rather than
 directly on screen
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com> <1431623414-1905-6-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.10.1506301627030.5359@chino.kir.corp.google.com> <55943DC1.6010209@oracle.com> <alpine.DEB.2.10.1507011422070.14014@chino.kir.corp.google.com> <55946EA9.2080805@oracle.com> <alpine.DEB.2.10.1507081653220.16585@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1507081653220.16585@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name

On 07/08/2015 07:58 PM, David Rientjes wrote:
> On Wed, 1 Jul 2015, Sasha Levin wrote:
> 
>> > Since we'd BUG at VM_BUG_ON(), this would be something closer to:
>> > 
>> > 	if (unlikely(compound_head(page) != head)) {
>> > 		dump_page(page);
>> > 		dump_page(head);
>> > 		VM_BUG_ON(1);
>> > 	}
>> > 
> I was thinking closer to
> 
> 	if (VM_WARN_ON(compound_head(page) != head)) {
> 		...
> 		BUG();
> 	}
> 
> so we prefix all output with the typical warning diagnostics, emit 
> whatever page, vma, etc output we want, and then finally die.  The final 
> BUG() here would have to be replaced by something that suppresses the 
> repeated output.
> 
> If it's really just a warning, then no BUG() needed.

How is that simpler than getting it all under VM_BUG()? Just like the regular
WARN() does.

>> > But my point here was that while one *could* do it that way, no one does because
>> > it's not intuitive. We both agree that in the example above it would be useful to
>> > see both 'page' and 'head', and yet the code that was written didn't dump any of
>> > them. Why? No one wants to write debug code unless it's easy and short.
>> > 
> pr_alert("%pZp %pZv", page, vma) isn't shorter than dump_page(page); 
> dump_vma(vma), but it would be a line shorter.  I'm not sure that the 
> former is easier, though, and it prevents us from ever expanding dump_*() 
> functions for conditional output.

I'm not objecting to leaving dump_*() for these trivial cases.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
