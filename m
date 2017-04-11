Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15C406B03C4
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 15:03:53 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z109so645300wrb.12
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:03:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f75si4295478wmi.54.2017.04.11.12.03.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 12:03:51 -0700 (PDT)
Subject: Re: [RFC 2/6] mm, mempolicy: stop adjusting current->il_next in
 mpol_rebind_nodemask()
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-3-vbabka@suse.cz>
 <alpine.DEB.2.20.1704111227080.25069@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <9665a022-197a-4b02-8813-66aca252f0f9@suse.cz>
Date: Tue, 11 Apr 2017 21:03:53 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1704111227080.25069@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 11.4.2017 19:32, Christoph Lameter wrote:
> On Tue, 11 Apr 2017, Vlastimil Babka wrote:
> 
>> The task->il_next variable remembers the last allocation node for task's
>> MPOL_INTERLEAVE policy. mpol_rebind_nodemask() updates interleave and
>> bind mempolicies due to changing cpuset mems. Currently it also tries to
>> make sure that current->il_next is valid within the updated nodemask. This is
>> bogus, because 1) we are updating potentially any task's mempolicy, not just
>> current, and 2) we might be updating per-vma mempolicy, not task one.
>>
>> The interleave_nodes() function that uses il_next can cope fine with the value
>> not being within the currently allowed nodes, so this hasn't manifested as an
>> actual issue. Thus it also won't be an issue if we just remove this adjustment
>> completely.
> 
> Well, interleave_nodes() will then potentially return a node outside of
> the allowed memory policy when its called for the first time after
> mpol_rebind_.. . But thenn it will find the next node within the
> nodemask and work correctly for the next invocations.

Hmm, you're right. But that could be easily fixed if il_next became il_prev, so
we would return the result of next_node_in(il_prev) and also store it as the new
il_prev, right? I somehow assumed it already worked that way.

> But yea the race can probably be ignored. The idea was that the
> application has a stable memory footprint during rebinding.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
