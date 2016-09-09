Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44C466B0069
	for <linux-mm@kvack.org>; Fri,  9 Sep 2016 14:38:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so19643148wmz.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 11:38:01 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id o133si1783286lfo.33.2016.09.09.11.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Sep 2016 11:38:00 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id s64so3111560lfs.2
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 11:37:59 -0700 (PDT)
Date: Fri, 9 Sep 2016 21:37:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 RESEND 0/2] Align mmap address for DAX pmd mappings
Message-ID: <20160909183756.GA30528@node>
References: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
 <20160829204842.GA27286@node.shutemov.name>
 <1472506310.1532.47.camel@hpe.com>
 <1472508000.1532.59.camel@hpe.com>
 <20160908105707.GA17331@node>
 <1473342519.2092.42.camel@hpe.com>
 <1473376846.2092.69.camel@hpe.com>
 <20160909123608.GA75965@black.fi.intel.com>
 <1473441640.2092.74.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1473441640.2092.74.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "hughd@google.com" <hughd@google.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "tytso@mit.edu" <tytso@mit.edu>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

On Fri, Sep 09, 2016 at 05:21:40PM +0000, Kani, Toshimitsu wrote:
> On Fri, 2016-09-09 at 15:36 +0300, Kirill A. Shutemov wrote:
> > On Thu, Sep 08, 2016 at 11:21:46PM +0000, Kani, Toshimitsu wrote:
> > > 
> > > On Thu, 2016-09-08 at 07:48 -0600, Kani, Toshimitsu wrote:
> > > > 
> > > > On Thu, 2016-09-08 at 13:57 +0300, Kirill A. Shutemov wrote:
> > > > > 
> > > > > On Mon, Aug 29, 2016 at 10:00:43PM +0000, Kani, Toshimitsu
> > > > > wrote:
> > >  :
> > > > > > Looking further, these shmem_huge handlings only check pre-
> > > > > > conditions.  So, we should be able to make shmem_get_unmapped
> > > > > > _are a() as a wrapper, which checks such shmem-specific
> > > > > > conitions, and then call __thp_get_unmapped_area() for the
> > > > > > actual work.  All DAX-specific checks are performed in
> > > > > > thp_get_unmapped_area() as well.  We can make
> > > > > >  __thp_get_unmapped_area() as a common
> > > > > > function.
> > > > > > 
> > > > > > I'd prefer to make such change as a separate item,
> > > > > 
> > > > > Do you have plan to submit such change?
> > > > 
> > > > Yes, I will submit the change once I finish testing.
> > > 
> > > I found a bug in the current code, and need some clarification.
> > >  The if-statement below is reverted.
> > 
> > <two-hands-facepalm>
> > 
> > Yeah. It was repored by Hillf[1]. The fixup got lost. :(
> > 
> > Could you post a proper patch with the fix?
> >
> > I would be nice to credit Hillf there too.
> > 
> > [1] http://lkml.kernel.org/r/054f01d1c86f$2994d5c0$7cbe8140$@alibaba-
> > inc.com
> 
> Yes, I will submit the fix as well.
> 
> I will not change the default value of sbinfo->huge in this fix.  So,
> user will have to specify "huge=" option to enable huge page mappings.
>  If this is not desireable, we will need a separate patch.

That's okay. I only screwed up part wich make vma aligned. Allocation of
huge page happens under right condition.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
