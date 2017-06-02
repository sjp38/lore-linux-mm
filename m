Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A14BF6B0314
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 16:55:51 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k57so3294564wrk.6
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 13:55:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s11si23496173edd.47.2017.06.02.13.55.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Jun 2017 13:55:50 -0700 (PDT)
Subject: Re: [PATCH] mm: make PR_SET_THP_DISABLE immediately active
References: <1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170602125059.66209870607085b84c257593@linux-foundation.org>
 <8a810c81-6a72-2af0-a450-6f03c71d8cca@suse.cz>
 <20170602134038.13728cb77678ae1a7d7128a4@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f9e8a159-7a25-6813-f909-11c4ae58adf3@suse.cz>
Date: Fri, 2 Jun 2017 22:55:12 +0200
MIME-Version: 1.0
In-Reply-To: <20170602134038.13728cb77678ae1a7d7128a4@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/02/2017 10:40 PM, Andrew Morton wrote:
> On Fri, 2 Jun 2017 22:31:47 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>>> Perhaps we should be adding new prctl modes to select this new
>>> behaviour and leave the existing PR_SET_THP_DISABLE behaviour as-is?
>>
>> I think we can reasonably assume that most users of the prctl do just
>> the fork() & exec() thing, so they will be unaffected.
> 
> That sounds optimistic.  Perhaps people are using the current behaviour
> to set on particular mapping to MMF_DISABLE_THP, with
> 
> 	prctl(PR_SET_THP_DISABLE)
> 	mmap()
> 	prctl(PR_CLR_THP_DISABLE)
> 
> ?
> 
> Seems a reasonable thing to do.

Using madvise(MADV_NOHUGEPAGE) seems reasonabler to me, with the same
effect. And it's older (2.6.38).

> But who knows - people do all sorts of
> inventive things.

Yeah :( but we can hope they don't even know that the prctl currently
behaves they way it does - man page doesn't suggest it would, and most
of us in this thread found it surprising.

>> And as usual, if
>> somebody does complain in the end, we revert and try the other way?
> 
> But by then it's too late - the new behaviour will be out in the field.

Revert in stable then?
But I don't think this patch should go to stable. I understand right
that CRIU will switch to the UFFDIO_COPY approach and doesn't need the
prctl change/new madvise anymore?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
