Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 572256B0038
	for <linux-mm@kvack.org>; Mon,  1 May 2017 03:13:03 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id m91so26280359qte.10
        for <linux-mm@kvack.org>; Mon, 01 May 2017 00:13:03 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id y7si2563091wmg.1.2017.05.01.00.13.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 May 2017 00:13:02 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id u65so22113132wmu.3
        for <linux-mm@kvack.org>; Mon, 01 May 2017 00:13:02 -0700 (PDT)
Date: Mon, 1 May 2017 09:12:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v2] mm, zone_device: replace {get,
 put}_zone_device_page() with a single reference
Message-ID: <20170501071259.5vya524wcdddm42b@gmail.com>
References: <20170428063913.iz6xjcxblecofjlq@gmail.com>
 <149339998297.24933.1129582806028305912.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170429141838.tkyfxhldmwypyipz@gmail.com>
 <CAPcyv4i8WrNPzu_-Lu1uKi8NT-vj1PF0h0SW_Pi=QGn5PPhQfQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4i8WrNPzu_-Lu1uKi8NT-vj1PF0h0SW_Pi=QGn5PPhQfQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>


* Dan Williams <dan.j.williams@intel.com> wrote:

> On Sat, Apr 29, 2017 at 7:18 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > * Dan Williams <dan.j.williams@intel.com> wrote:
> >
> >> Kirill points out that the calls to {get,put}_dev_pagemap() can be
> >> removed from the mm fast path if we take a single get_dev_pagemap()
> >> reference to signify that the page is alive and use the final put of the
> >> page to drop that reference.
> >>
> >> This does require some care to make sure that any waits for the
> >> percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
> >> since it now maintains its own elevated reference.
> >>
> >> Cc: Ingo Molnar <mingo@redhat.com>
> >> Cc: Jerome Glisse <jglisse@redhat.com>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> Reviewed-by: Logan Gunthorpe <logang@deltatee.com>
> >> Suggested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> >> Tested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> >> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >
> > This changelog is lacking an explanation about how this solves the crashes you
> > were seeing.
> 
> Kirill? It wasn't clear to me why the conversion to generic 
> get_user_pages_fast() caused the reference counts to be off.

Ok, the merge window is open and we really need this fix for x86/mm, so this is 
what I've decoded:

 The x86 conversion to the generic GUP code included a small change which causes
 crashes and data corruption in the pmem code - not good.

 The root cause is that the /dev/pmem driver code implicitly relies on the x86
 get_user_pages() implementation doing a get_page() on the page refcount, because
 get_page() does a get_zone_device_page() which properly refcounts pmem's separate
 page struct arrays that are not present in the regular page struct structures.
 (The pmem driver does this because it can cover huge memory areas.)

 But the x86 conversion to the generic GUP code changed the get_page() to
 page_cache_get_speculative() which is faster but doesn't do the
 get_zone_device_page() call the pmem code relies on.

 One way to solve the regression would be to change the generic GUP code to use 
 get_page(), but that would slow things down a bit and punish other generic-GUP 
 using architectures for an x86-ism they did not care about. (Arguably the pmem 
 driver was probably not working reliably for them: but nvdimm is an Intel
 feature, so non-x86 exposure is probably still limited.)

 So restructure the pmem code's interface with the MM instead: get rid of the 
 get/put_zone_device_page() distinction, integrate put_zone_device_page() into 
 __put_page() and and restructure the pmem completion-wait and teardown machinery.

 This speeds up things while also making the pmem refcounting more robust going 
 forward.

... is this extension to the changelog correct?

I'll apply this for the time being - but can still amend the text before sending 
it to Linus later today.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
