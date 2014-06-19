Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6F4D46B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 09:59:54 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y13so1847133pdi.41
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 06:59:54 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id hb8si5912017pbc.8.2014.06.19.06.59.53
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 06:59:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20140619132240.GF25975@nuc-i3427.alporthouse.com>
References: <20140616134124.0ED73E00A2@blue.fi.intel.com>
 <1403162349-14512-1-git-send-email-chris@chris-wilson.co.uk>
 <20140619115018.412D2E00A3@blue.fi.intel.com>
 <20140619120004.GC25975@nuc-i3427.alporthouse.com>
 <20140619125746.25A03E00A3@blue.fi.intel.com>
 <20140619132240.GF25975@nuc-i3427.alporthouse.com>
Subject: Re: [PATCH] mm: Report attempts to overwrite PTE from
 remap_pfn_range()
Content-Transfer-Encoding: 7bit
Message-Id: <20140619135944.20837E00A3@blue.fi.intel.com>
Date: Thu, 19 Jun 2014 16:59:44 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Chris Wilson wrote:
> On Thu, Jun 19, 2014 at 03:57:46PM +0300, Kirill A. Shutemov wrote:
> > One possible option is to create a variant of remap_pfn_range() which will
> > return how many PTEs it was able to setup, before hitting the !pte_none().
> > Caller will decide what to do with partially filled range.
> 
> Looked at just returning the address remap_pfn_range() got up to, which is
> easy enough, but I think given that remap_pfn_range() will clean up
> correctly after a failed remap, any EBUSY from partway through would be
> a pathological driver error. 

I would prefer keep remap_pfn_range() interface intact with BUG_ON() on
unexpected !pte_none() and introduce new function with more flexible
behaviour (sharing underlying infrastructure).
This way we can avoid changing every remap_pfn_range() caller.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
