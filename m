Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 338EB6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 03:05:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y13so1465608pgc.1
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 00:05:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p23si6495072pli.429.2017.06.05.00.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 00:05:25 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5573QX1133987
	for <linux-mm@kvack.org>; Mon, 5 Jun 2017 03:05:24 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2aw05fde2q-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 05 Jun 2017 03:05:24 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 5 Jun 2017 08:05:20 +0100
Date: Mon, 5 Jun 2017 10:05:14 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: make PR_SET_THP_DISABLE immediately active
References: <1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20170602125059.66209870607085b84c257593@linux-foundation.org>
 <8a810c81-6a72-2af0-a450-6f03c71d8cca@suse.cz>
 <20170602134038.13728cb77678ae1a7d7128a4@linux-foundation.org>
 <f9e8a159-7a25-6813-f909-11c4ae58adf3@suse.cz>
 <CAAB5A6A-D7A1-4C06-9A07-D7EF56278EE5@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAB5A6A-D7A1-4C06-9A07-D7EF56278EE5@linux.vnet.ibm.com>
Message-Id: <20170605070513.GA4159@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux API <linux-api@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Sat, Jun 03, 2017 at 01:34:52PM +0300, Mike Rapoprt wrote:
> 
> 
> On June 2, 2017 11:55:12 PM GMT+03:00, Vlastimil Babka <vbabka@suse.cz> wrote:
> >On 06/02/2017 10:40 PM, Andrew Morton wrote:
> >> On Fri, 2 Jun 2017 22:31:47 +0200 Vlastimil Babka <vbabka@suse.cz>
> >wrote:
> >>>> Perhaps we should be adding new prctl modes to select this new
> >>>> behaviour and leave the existing PR_SET_THP_DISABLE behaviour
> >as-is?
> >>>
> >>> I think we can reasonably assume that most users of the prctl do
> >just
> >>> the fork() & exec() thing, so they will be unaffected.
> >> 
> >> That sounds optimistic.  Perhaps people are using the current
> >behaviour
> >> to set on particular mapping to MMF_DISABLE_THP, with
> >> 
> >> 	prctl(PR_SET_THP_DISABLE)
> >> 	mmap()
> >> 	prctl(PR_CLR_THP_DISABLE)
> >> 
> >> ?
> >> 
> >> Seems a reasonable thing to do.
> >
> >Using madvise(MADV_NOHUGEPAGE) seems reasonabler to me, with the same
> >effect. And it's older (2.6.38).
> >
> >> But who knows - people do all sorts of
> >> inventive things.
> >
> >Yeah :( but we can hope they don't even know that the prctl currently
> >behaves they way it does - man page doesn't suggest it would, and most
> >of us in this thread found it surprising.
> >
> >>> And as usual, if
> >>> somebody does complain in the end, we revert and try the other way?
> >> 
> >> But by then it's too late - the new behaviour will be out in the
> >field.
> >
> >Revert in stable then?
> >But I don't think this patch should go to stable. I understand right
> >that CRIU will switch to the UFFDIO_COPY approach and doesn't need the
> >prctl change/new madvise anymore?
> 
> Yes, we are going to use UFFDIO_COPY. We still might want to have control
> over THP in the future without changing per-VMA flags, though.

Unfortunately, I was over optimistic about ability of CRIU to use
UFFDIO_COPY for pre-copy part :(
I was too concentrated on the simplified flow and overlooked some important
details. After I've spent some time trying to actually implement usage of
UFFDIO_COPY, I realized that registering memory with userfault at that
point of the restore flow quite contradicts CRIU architecture :(

That said, we would really want to have the interface this patch proposes.
 
-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
