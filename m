Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id AB34E6B0256
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 11:39:16 -0400 (EDT)
Received: by wijn1 with SMTP id n1so28487849wij.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 08:39:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wu10si5768193wjb.190.2015.08.26.08.39.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 08:39:15 -0700 (PDT)
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi> <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com> <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com>
 <20150826150412.GA16412@node.dhcp.inet.fi>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DDDDA1.4090407@suse.cz>
Date: Wed, 26 Aug 2015 17:39:13 +0200
MIME-Version: 1.0
In-Reply-To: <20150826150412.GA16412@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On 08/26/2015 05:04 PM, Kirill A. Shutemov wrote:
>>>                                                                          That's
>>> bad news then. It's not that we would trigger that bit when the rcu_head part of
>>> the union is "active". It's that pfn scanners could inspect such page at
>>> arbitrary time, see the bit 0 set (due to RCU processing) and think that it's a
>>> tail page of a compound page, and interpret the rest of the pointer as a pointer
>>> to the head page (to test it for flags etc).
>>
>> On the other hand, if you avoid scanning rcu_head structures for pages
>> that are currently waiting for a grace period, no problem.  RCU does
>> not use the rcu_head structure at all except for during the time between
>> when call_rcu() is invoked on that rcu_head structure and the time that
>> the callback is invoked.
>>
>> Is there some other page state that indicates that the page is waiting
>> for a grace period?  If so, you could simply avoid testing that bit in
>> that case.
>
> No, I don't think so.
>
> For compound pages most of info of its state is stored in head page (e.g.
> page_count(), flags, etc). So if we examine random page (pfn scanner case)
> the very first thing we want to know if we stepped on tail page.
> PageTail() is what I wanted to encode in the bit...
>
> What if we change order of fields within rcu_head and put ->func first?

Or change the order of compound_head wrt the rest?

> Can we expect this pointer to have bit 0 always clear?

That's probably a question whether $compiler is guaranteed to align 
functions on all architectures...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
