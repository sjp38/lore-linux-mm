Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5887C6B037E
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 17:10:45 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g13so18290324wmd.9
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 14:10:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 38si26220630wrv.67.2017.06.02.14.10.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 14:10:44 -0700 (PDT)
Date: Fri, 2 Jun 2017 14:10:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: make PR_SET_THP_DISABLE immediately active
Message-Id: <20170602141041.baace0cfa370b6bec6d411b4@linux-foundation.org>
In-Reply-To: <f9e8a159-7a25-6813-f909-11c4ae58adf3@suse.cz>
References: <1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com>
	<20170602125059.66209870607085b84c257593@linux-foundation.org>
	<8a810c81-6a72-2af0-a450-6f03c71d8cca@suse.cz>
	<20170602134038.13728cb77678ae1a7d7128a4@linux-foundation.org>
	<f9e8a159-7a25-6813-f909-11c4ae58adf3@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, 2 Jun 2017 22:55:12 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 06/02/2017 10:40 PM, Andrew Morton wrote:
> > On Fri, 2 Jun 2017 22:31:47 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> >>> Perhaps we should be adding new prctl modes to select this new
> >>> behaviour and leave the existing PR_SET_THP_DISABLE behaviour as-is?
> >>
> >> I think we can reasonably assume that most users of the prctl do just
> >> the fork() & exec() thing, so they will be unaffected.
> > 
> > That sounds optimistic.  Perhaps people are using the current behaviour
> > to set on particular mapping to MMF_DISABLE_THP, with
> > 
> > 	prctl(PR_SET_THP_DISABLE)
> > 	mmap()
> > 	prctl(PR_CLR_THP_DISABLE)
> > 
> > ?
> > 
> > Seems a reasonable thing to do.
> 
> Using madvise(MADV_NOHUGEPAGE) seems reasonabler to me, with the same
> effect. And it's older (2.6.38).
> 
> > But who knows - people do all sorts of
> > inventive things.
> 
> Yeah :( but we can hope they don't even know that the prctl currently
> behaves they way it does - man page doesn't suggest it would, and most
> of us in this thread found it surprising.

Well.  There might be such people and sometimes we do make people
unhappy.  it partly depends on how traumatic it would be to leave the
current behaviour as-is.  Have you evaluated such a patch?


> >> And as usual, if
> >> somebody does complain in the end, we revert and try the other way?
> > 
> > But by then it's too late - the new behaviour will be out in the field.
> 
> Revert in stable then?
> But I don't think this patch should go to stable. I understand right
> that CRIU will switch to the UFFDIO_COPY approach and doesn't need the
> prctl change/new madvise anymore?

What I mean is that the new behaviour will go out in 4.12 and it may
be many months before we find out that we broke someone.  By then, we
can't go back because others may be assuming the new behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
