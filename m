Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9F8766B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 14:38:57 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj10so40009214pad.2
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 11:38:57 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id g15si7608211pfg.40.2016.03.04.11.38.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 11:38:56 -0800 (PST)
Received: by mail-pa0-x22d.google.com with SMTP id fl4so39770699pad.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 11:38:56 -0800 (PST)
Date: Fri, 4 Mar 2016 11:38:47 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: THP-enabled filesystem vs. FALLOC_FL_PUNCH_HOLE
In-Reply-To: <56D9C882.3040808@intel.com>
Message-ID: <alpine.LSU.2.11.1603041100320.6011@eggly.anvils>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com> <20160304112603.GA9790@node.shutemov.name> <56D9C882.3040808@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 4 Mar 2016, Dave Hansen wrote:
> On 03/04/2016 03:26 AM, Kirill A. Shutemov wrote:
> > On Thu, Mar 03, 2016 at 07:51:50PM +0300, Kirill A. Shutemov wrote:
> >> Truncate and punch hole that only cover part of THP range is implemented
> >> by zero out this part of THP.
> >>
> >> This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
> >> As we don't really create hole in this case, lseek(SEEK_HOLE) may have
> >> inconsistent results depending what pages happened to be allocated.
> >> Not sure if it should be considered ABI break or not.
> > 
> > Looks like this shouldn't be a problem. man 2 fallocate:
> > 
> > 	Within the specified range, partial filesystem blocks are zeroed,
> > 	and whole filesystem blocks are removed from the file.  After a
> > 	successful call, subsequent reads from this range will return
> > 	zeroes.
> > 
> > It means we effectively have 2M filesystem block size.
> 
> The question is still whether this will case problems for apps.
> 
> Isn't 2MB a quote unusual block size?  Wouldn't some files on a tmpfs
> filesystem act like they have a 2M blocksize and others like they have
> 4k?  Would that confuse apps?

At risk of addressing the tip of an iceberg, before diving down to
scope out the rest of the iceberg...

So far as the behaviour of lseek(,,SEEK_HOLE) goes, I agree with Kirill:
I don't think it matters to anyone if it skips some zeroed small pages
within a hugepage.  It may cause some artificial tests of holepunch and
SEEK_HOLE to fail, and it ought to be documented as a limitation from
choosing to enable THP (Kirill's way) on a filesystem, but I don't think
it's an ABI break to worry about: anyone who cares just shouldn't enable.

(Though in the case of my huge tmpfs, it's the reverse: the small hole
punch splits the hugepage; but it's natural that Kirill's way would try
to hold on to its compound pages for longer than I do, and that's fine
so long as it's all consistent.)

But I may disagree with "we effectively have 2M filesystem block size",
beyond the SEEK_HOLE case.  If we're emulating hugetlbfs in tmpfs, sure,
we would have 2M filesystem block size.  But if we're enabling THP
(emphasis on T for Transparent) in tmpfs (or another filesystem), then
when it matters it must act as if the block size is the 4k (or whatever)
it usually is.  When it matters?  Approaching memcg limit or ENOSPC
spring to mind.

Ah, but suppose someone holepunches out most of each 2M page: they would
expect the memcg not to be charged for those holes (just as when they
munmap most of an anonymous THP) - that does suggest splitting is needed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
