Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7A64D6B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:49:52 -0400 (EDT)
Received: by wijp15 with SMTP id p15so82084118wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:49:52 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fi5si22183320wib.110.2015.08.24.08.49.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 08:49:51 -0700 (PDT)
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <alpine.DEB.2.11.1508211109460.27769@east.gentwo.org>
 <20150821193109.GA14785@node.dhcp.inet.fi>
 <20150821123458.b3a6947135d5b506a34abc61@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DB3D19.8070009@suse.cz>
Date: Mon, 24 Aug 2015 17:49:45 +0200
MIME-Version: 1.0
In-Reply-To: <20150821123458.b3a6947135d5b506a34abc61@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/21/2015 09:34 PM, Andrew Morton wrote:
> On Fri, 21 Aug 2015 22:31:09 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
>
>> On Fri, Aug 21, 2015 at 11:11:27AM -0500, Christoph Lameter wrote:
>>> On Fri, 21 Aug 2015, Kirill A. Shutemov wrote:
>>>
>>>>> Is this really true?  For example if it's a slab page, will that page
>>>>> ever be inspected by code which is looking for the PageTail bit?
>>>>
>>>> +Christoph.
>>>>
>>>> What we know for sure is that space is not used in tail pages, otherwise
>>>> it would collide with current compound_dtor.
>>>
>>> Sl*b allocators only do a virt_to_head_page on tail pages.
>>
>> The question was whether it's safe to assume that the bit 0 is always zero
>> in the word as this bit will encode PageTail().
>
> That wasn't my question actually...
>
> What I'm wondering is: if this page is being used for slab, will any
> code path ever run PageTail() against it?  If not, we don't need to be
> concerned about that bit.

Pfn scanners such as compaction might inspect such pages and run 
compound_head() (and thus PageTail) on them. I think no kind of page 
within a zone (slab or otherwise) is "protected" from this, which is why 
it needs to be robust.

> And slab was just the example I chose.  The same question petains to
> all other uses of that union.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
