Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8906B007E
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 17:48:27 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id p65so8664710wmp.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 14:48:27 -0800 (PST)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id je3si6201875wjb.14.2016.03.04.14.48.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 14:48:26 -0800 (PST)
Received: by mail-wm0-x231.google.com with SMTP id l68so10388095wml.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 14:48:26 -0800 (PST)
Date: Sat, 5 Mar 2016 01:48:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: THP-enabled filesystem vs. FALLOC_FL_PUNCH_HOLE
Message-ID: <20160304224823.GA12498@node.shutemov.name>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160304112603.GA9790@node.shutemov.name>
 <56D9C882.3040808@intel.com>
 <alpine.LSU.2.11.1603041100320.6011@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1603041100320.6011@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 04, 2016 at 11:38:47AM -0800, Hugh Dickins wrote:
> On Fri, 4 Mar 2016, Dave Hansen wrote:
> > On 03/04/2016 03:26 AM, Kirill A. Shutemov wrote:
> > > On Thu, Mar 03, 2016 at 07:51:50PM +0300, Kirill A. Shutemov wrote:
> > >> Truncate and punch hole that only cover part of THP range is implemented
> > >> by zero out this part of THP.
> > >>
> > >> This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE) behaviour.
> > >> As we don't really create hole in this case, lseek(SEEK_HOLE) may have
> > >> inconsistent results depending what pages happened to be allocated.
> > >> Not sure if it should be considered ABI break or not.
> > > 
> > > Looks like this shouldn't be a problem. man 2 fallocate:
> > > 
> > > 	Within the specified range, partial filesystem blocks are zeroed,
> > > 	and whole filesystem blocks are removed from the file.  After a
> > > 	successful call, subsequent reads from this range will return
> > > 	zeroes.
> > > 
> > > It means we effectively have 2M filesystem block size.
> > 
> > The question is still whether this will case problems for apps.
> > 
> > Isn't 2MB a quote unusual block size?  Wouldn't some files on a tmpfs
> > filesystem act like they have a 2M blocksize and others like they have
> > 4k?  Would that confuse apps?
> 
> At risk of addressing the tip of an iceberg, before diving down to
> scope out the rest of the iceberg...
> 
> So far as the behaviour of lseek(,,SEEK_HOLE) goes, I agree with Kirill:
> I don't think it matters to anyone if it skips some zeroed small pages
> within a hugepage.  It may cause some artificial tests of holepunch and
> SEEK_HOLE to fail, and it ought to be documented as a limitation from
> choosing to enable THP (Kirill's way) on a filesystem, but I don't think
> it's an ABI break to worry about: anyone who cares just shouldn't enable.
> 
> (Though in the case of my huge tmpfs, it's the reverse: the small hole
> punch splits the hugepage; but it's natural that Kirill's way would try
> to hold on to its compound pages for longer than I do, and that's fine
> so long as it's all consistent.)
> 
> But I may disagree with "we effectively have 2M filesystem block size",
> beyond the SEEK_HOLE case.  If we're emulating hugetlbfs in tmpfs, sure,
> we would have 2M filesystem block size.  But if we're enabling THP
> (emphasis on T for Transparent) in tmpfs (or another filesystem), then
> when it matters it must act as if the block size is the 4k (or whatever)
> it usually is.  When it matters?  Approaching memcg limit or ENOSPC
> spring to mind.
> 
> Ah, but suppose someone holepunches out most of each 2M page: they would
> expect the memcg not to be charged for those holes (just as when they
> munmap most of an anonymous THP) - that does suggest splitting is needed.

Hmm.. As split_huge_pages() can fail, we wound need to propagate this
error to userspace. This potentially triggers some other user-visible
effect. EBUSY is not on list of fallocate(2) errror codes.

I think we can invent a way to track if a THP has punch-holed subpages and
prevent the compound page from being mapped as PMD or mapping these
subpages.

But I'm reluctant doing it upfront until real users emerge.

I would propose to see what user demands will be. May be we overthink the
situation.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
