Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 554196B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 16:46:46 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so26154028wic.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 13:46:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id pi9si5565132wic.102.2015.08.25.13.46.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 13:46:44 -0700 (PDT)
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi> <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DCD434.9000704@suse.cz>
Date: Tue, 25 Aug 2015 22:46:44 +0200
MIME-Version: 1.0
In-Reply-To: <20150825201113.GK11078@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On 25.8.2015 22:11, Paul E. McKenney wrote:
> On Tue, Aug 25, 2015 at 09:33:54PM +0300, Kirill A. Shutemov wrote:
>> On Tue, Aug 25, 2015 at 01:44:13PM +0200, Vlastimil Babka wrote:
>>> On 08/21/2015 02:10 PM, Kirill A. Shutemov wrote:
>>>> On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
>>>>> On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>>>>>
>>>>>> The patch introduces page->compound_head into third double word block in
>>>>>> front of compound_dtor and compound_order. That means it shares storage
>>>>>> space with:
>>>>>>
>>>>>>  - page->lru.next;
>>>>>>  - page->next;
>>>>>>  - page->rcu_head.next;
>>>>>>  - page->pmd_huge_pte;
>>>>>>
>>>
>>> We should probably ask Paul about the chances that rcu_head.next would like
>>> to use the bit too one day?
>>
>> +Paul.
> 
> The call_rcu() function does stomp that bit, but if you stop using that
> bit before you invoke call_rcu(), no problem.

You mean that it sets the bit 0 of rcu_head.next during its processing? That's
bad news then. It's not that we would trigger that bit when the rcu_head part of
the union is "active". It's that pfn scanners could inspect such page at
arbitrary time, see the bit 0 set (due to RCU processing) and think that it's a
tail page of a compound page, and interpret the rest of the pointer as a pointer
to the head page (to test it for flags etc).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
