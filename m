Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 745C88E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 04:00:01 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s14so21457454qkl.16
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 01:00:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m13si3518501qvk.140.2019.01.22.01.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 01:00:00 -0800 (PST)
Subject: Re: [PATCH RFC 00/24] userfaultfd: write protection support
References: <20190121075722.7945-1-peterx@redhat.com>
 <c2485a2d-25b3-2fc0-4902-01fa278be9c7@redhat.com>
 <20190122031803.GB7669@xz-x1>
From: David Hildenbrand <david@redhat.com>
Message-ID: <c36071dd-da8a-22fa-8f9a-262c942fcdf4@redhat.com>
Date: Tue, 22 Jan 2019 09:59:34 +0100
MIME-Version: 1.0
In-Reply-To: <20190122031803.GB7669@xz-x1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On 22.01.19 04:18, Peter Xu wrote:
> On Mon, Jan 21, 2019 at 03:33:21PM +0100, David Hildenbrand wrote:
> 
> [...]
> 
>> Does this series fix the "false positives" case I experienced on early
>> prototypes of uffd-wp? (getting notified about a write access although
>> it was not a write access?)
> 
> Hi, David,
> 
> Yes it should solve it.

Terrific, as my use case for uffd-wp really rely on not having false
positives these are good news :)

... however it will take a while until I actually have time to look back
into it (too much stuff on my table).

Just for reference (we talked about this offline once):

My plan is to use this for virtio-mem in QEMU. Memory that a virtio-mem
device provides to a guest can either be plugged or unplugged. When
unplugging, memory will be MADVISE_DONTNEED'ed and uffd-wp'ed. The guest
can still read memory (e.g. for dumping) but writing to it is considered
bad (as the guest could this way consume more memory as intended). So I
can detect malicious guests without too much overhead this way.

False positives would mean that I would detect guests as malicious
although they are not. So it really would be harmful.

Thanks!

> 
> The early prototype in Andrea's tree hasn't yet applied the new
> PTE/swap bits for uffd-wp hence it was not able to avoid those fause
> positives.  This series has applied all those ideas (which actually
> come from Andrea as well) so the protection information will be
> persisent per PTE rather than per VMA and it will be kept even through
> swapping and page migrations.
> 
> Thanks,
> 


-- 

Thanks,

David / dhildenb
