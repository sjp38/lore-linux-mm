Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id l0SKRorV027882
	for <linux-mm@kvack.org>; Sun, 28 Jan 2007 20:27:50 GMT
Received: from ug-out-1314.google.com (ugfj3.prod.google.com [10.66.186.3])
	by spaceape10.eur.corp.google.com with ESMTP id l0SKRnJd020925
	for <linux-mm@kvack.org>; Sun, 28 Jan 2007 20:27:49 GMT
Received: by ug-out-1314.google.com with SMTP id j3so964446ugf
        for <linux-mm@kvack.org>; Sun, 28 Jan 2007 12:27:49 -0800 (PST)
Message-ID: <b040c32a0701281227r11fe02eblba07df7aa7400787@mail.gmail.com>
Date: Sun, 28 Jan 2007 12:27:48 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH] Don't allow the stack to grow into hugetlb reserved regions
In-Reply-To: <Pine.LNX.4.64.0701270904360.15686@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070125214052.22841.33449.stgit@localhost.localdomain>
	 <Pine.LNX.4.64.0701262025590.22196@blonde.wat.veritas.com>
	 <b040c32a0701261448k122f5cc7q5368b3b16ee1dc1f@mail.gmail.com>
	 <Pine.LNX.4.64.0701270904360.15686@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Adam Litke <agl@us.ibm.com>, Andrew Morton <akpm@osdl.org>, William Irwin <wli@holomorphy.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 1/27/07, Hugh Dickins <hugh@veritas.com> wrote:
> Thanks, that's reassuring for the hugetlb case, and therefore Adam's
> patch should not be delayed.  But it does leave open the question I
> was raising in the text you've snipped: if ia64 needs those stringent
> REGION checks in its ia64_do_page_fault path, don't we need to add
> them some(messy)how in the get_user_pages find_extend_vma path?

I left it out because I need more time to digest what you said. After
looked through ia64's page fault and get_user_pages, I've concluded
that the bug scenario Adam described is impossible to trigger on ia64
due to various constrains and how the virtual address is laid out.

For ia64, the hugetlb address region is reserved at the top of user
space address.  Stacks are below that region.  Throw in the mix, we
have two stacks, one memory stack that grows down and one register
stack backing store that grows up.  These two stacks are always in
pair and grow towards each other. And lastly, we have virtual address
holes in between regions.  It's just impossible to grow any of these
two stacks into hugetlb region no matter how I played it.

So, AFAICS this bug doesn't apply to ia64 (and certainly not x86). The
new check of is_hugepage_only_range() is really a noop for both arches.

    - Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
