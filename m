Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 331606B0005
	for <linux-mm@kvack.org>; Sun,  6 Mar 2016 18:33:34 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l68so87246649wml.0
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 15:33:34 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id p3si15834808wjp.160.2016.03.06.15.33.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Mar 2016 15:33:32 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id l68so87246388wml.0
        for <linux-mm@kvack.org>; Sun, 06 Mar 2016 15:33:32 -0800 (PST)
Date: Mon, 7 Mar 2016 02:33:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: THP-enabled filesystem vs. FALLOC_FL_PUNCH_HOLE
Message-ID: <20160306233330.GA23851@node.shutemov.name>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20160304112603.GA9790@node.shutemov.name>
 <56D9C882.3040808@intel.com>
 <alpine.LSU.2.11.1603041100320.6011@eggly.anvils>
 <20160304230548.GC11282@dastard>
 <20160304232412.GC12498@node.shutemov.name>
 <20160305223811.GD11282@dastard>
 <20160306003034.GA13704@node.shutemov.name>
 <20160306230336.GE11282@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160306230336.GE11282@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 07, 2016 at 10:03:36AM +1100, Dave Chinner wrote:
> On Sun, Mar 06, 2016 at 03:30:34AM +0300, Kirill A. Shutemov wrote:
> > On Sun, Mar 06, 2016 at 09:38:11AM +1100, Dave Chinner wrote:
> > > And it's not just hole punching that has this problem. Direct IO is
> > > going to have the same issue with invalidation of the mapped ranges
> > > over the IO being done. XFS already WARNs when page cache
> > > invalidation fails with EBUSY in direct IO, because that is
> > > indicative of an application with a potential data corruption vector
> > > and there's nothing we can do in the kernel code to prevent it.
> > 
> > My current understanding is that for filesystems with persistent storage,
> > in order to make THP any useful, we would need to implement writeback
> > without splitting the huge page.
> 
> Algorithmically it is no different to filesytem block size < page
> size writeback.
> 
> > At the moment, I have no idea how hard it would be..
> 
> THP support would effectively require us to remove PAGE_CACHE_SIZE
> assumptions from all of the filesystem and buffer code. That's a
> large chunk of work e.g.  fs/buffer.c and any filesystem that uses
> bufferheads for tracking filesystem block state through the page
> cache.

I'll try to learn more about the code before the summit.
I guess it's something worth descussion in person.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
