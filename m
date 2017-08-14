Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48BCF6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 17:10:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z195so15226453wmz.8
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:10:03 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id p59si6250457edp.426.2017.08.14.14.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 14:10:02 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id t201so2279804wmt.1
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 14:10:01 -0700 (PDT)
Date: Tue, 15 Aug 2017 00:09:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: How can we share page cache pages for reflinked files?
Message-ID: <20170814210959.r4mdv3y4rdeolyxt@node.shutemov.name>
References: <20170810042849.GK21024@dastard>
 <20170810161159.GI31390@bombadil.infradead.org>
 <20170811042519.GS21024@dastard>
 <20170811170847.GK31390@bombadil.infradead.org>
 <20170814064838.GB21024@dastard>
 <alpine.DEB.2.20.1708141307380.32429@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1708141307380.32429@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 14, 2017 at 01:14:57PM -0500, Christopher Lameter wrote:
> On Mon, 14 Aug 2017, Dave Chinner wrote:
> 
> > > Use XFS+reflink+DAX on top of this loop device.  Now there's only one
> > > copy of each page in RAM.
> >
> > Yes, I can see how that could work. Crazy, out of the box, abuses
> > DAX for non-DAX purposes and uses stuff we haven't enabled yet
> > because nobody has done the work to validate it. Full points for
> > creativity! :)
> 
> Another not so crazy solution is to break the 1-1 relation between page
> structs and pages. We already have issues with huge pages where one struct
> page may represent 2m of memmory using 512 or so page struct.
> 
> Therer are also constantly attempts to expand struct page.
> 
> So how about an m->n relationship? Any page (may it be 4k, 2m or 1G) has
> one page struct for each mapping that it is a member of?
> 
> Maybe a the page state could consist of a base struct that describes
> the page state and then 1..n  pieces of mapping information? In the future
> other state info could be added to the end if we allow dynamic sizing of
> page structs.
> 
> This would also allow the inevitable creeping page struct bloat to get
> completely out of control.

Nice wish list. Add pony. :)

Any attempt to replace struct page with something more complex will have
severe performance implications. I'll be glad proved otherwise.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
