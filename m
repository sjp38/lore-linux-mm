Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9DE6B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 06:52:03 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so12847449wid.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 03:52:02 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id s9si14143125wju.150.2015.08.21.03.52.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Aug 2015 03:52:01 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so12741060wic.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 03:52:01 -0700 (PDT)
Date: Fri, 21 Aug 2015 12:51:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv3 3/5] mm: pack compound_dtor and compound_order into one
 word in struct page
Message-ID: <20150821105159.GA8868@dhcp22.suse.cz>
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820162604.1a1dbbfeafefcda4327587af@linux-foundation.org>
 <20150821071341.GE23723@dhcp22.suse.cz>
 <20150821104059.GA12016@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150821104059.GA12016@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 21-08-15 13:40:59, Kirill A. Shutemov wrote:
> On Fri, Aug 21, 2015 at 09:13:42AM +0200, Michal Hocko wrote:
> > On Thu 20-08-15 16:26:04, Andrew Morton wrote:
[...]
> > > Why not use ushort for 64-bit as well?
> > 
> > Yeah, I have asked the same in the previous round. So I've tried to
> > compile with ushort. The resulting code was slightly larger
> >    text    data     bss     dec     hex filename
> >  476370   90811   44632  611813   955e5 mm/built-in.o.prev
> >  476418   90811   44632  611861   95615 mm/built-in.o.after
> > 
> > E.g. prep_compound_page
> > before:
> > 4c6b:       c7 47 68 01 00 00 00    movl   $0x1,0x68(%rdi)
> > 4c72:       89 77 6c                mov    %esi,0x6c(%rdi)
> > after:
> > 4c6c:       66 c7 47 68 01 00       movw   $0x1,0x68(%rdi)
> > 4c72:       66 89 77 6a             mov    %si,0x6a(%rdi)
> > 
> > which looks very similar to me but I am not an expert here so it might
> > possible that movw is slower.
> > 
> > __free_pages_ok
> > before:
> > 63af:       8b 77 6c                mov    0x6c(%rdi),%esi
> > after:
> > 63b1:       0f b7 77 6a             movzwl 0x6a(%rdi),%esi
> > 
> > which looks like a worse code to me. Whether this all is measurable or
> > worth it I dunno. The ifdef is ugly but maybe the ugliness is a destiny
> > for struct page.
> 
> I don't care about the ifdef that much. If you guys prefer to drop it I'm
> fine with that.

I can live with it. It makes the struct more complicated which is what
struck me. If there is a good reason and a better generated code is a
good one then I do not object but please make it a separate patch so
that we do not wonder why this has been done in the future.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
