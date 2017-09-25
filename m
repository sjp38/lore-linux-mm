Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C07EB6B0253
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 08:52:10 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m127so8523088wmm.3
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 05:52:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j88si5374600edd.203.2017.09.25.05.52.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Sep 2017 05:52:09 -0700 (PDT)
Date: Mon, 25 Sep 2017 14:52:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mremap.2: Add description of old_size == 0 functionality
Message-ID: <20170925125207.4tu24sbpnihljknu@dhcp22.suse.cz>
References: <20170915213745.6821-1-mike.kravetz@oracle.com>
 <a6e59a7f-fd15-9e49-356e-ed439f17e9df@oracle.com>
 <fb013ae6-6f47-248b-db8b-a0abae530377@redhat.com>
 <ee87215d-9704-7269-4ec1-226f2e32a751@oracle.com>
 <a5d279cb-a015-f74c-2e40-a231aa7f7a8c@redhat.com>
 <20170925123508.pzjbe7wgwagnr5li@dhcp22.suse.cz>
 <e301609c-b2ac-24d1-c349-8d25e5123258@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e301609c-b2ac-24d1-c349-8d25e5123258@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>, mtk.manpages@gmail.com, linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org

On Mon 25-09-17 14:40:42, Florian Weimer wrote:
> On 09/25/2017 02:35 PM, Michal Hocko wrote:
> > What would be the usecase. I mean why don't you simply create a new
> > mapping by a plain mmap when you have no guarantee about the same
> > content?
> 
> I plan to use it for creating an unbounded number of callback thunks at run
> time, from a single set of pages in libc.so, in case we need this
> functionality.
> 
> The idea is to duplicate existing position-independent machine code in
> libc.so, prefixed by a data mapping which controls its behavior.  Each
> data/code combination would only give us a fixed number of thunks, so we'd
> need to create a new mapping to increase the total number.
> 
> Instead, we could re-map the code from the executable in disk, but not if
> chroot has been called or glibc has been updated on disk.  Creating an alias
> mapping does not have these problems.
> 
> Another application (but that's for anonymous memory) would be to duplicate
> class metadata in a Java-style VM, so that you can use bits in the class
> pointer in each Java object (which is similar to the vtable pointer in C++)
> for the garbage collector, without having to mask it when accessing the
> class metadata in regular (mutator) code.

So, how are you going to deal with the CoW and the implementation which
basically means that the newm mmap content is not the same as the
original one?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
