Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC906B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 07:54:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 10so12995161wml.4
        for <linux-mm@kvack.org>; Mon, 29 May 2017 04:54:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i30si9286956edc.234.2017.05.29.04.54.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 May 2017 04:54:03 -0700 (PDT)
Date: Mon, 29 May 2017 13:53:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v3 0/9] parallelized "struct page" zeroing
Message-ID: <20170529115358.GJ19725@dhcp22.suse.cz>
References: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
 <20170509181234.GA4397@dhcp22.suse.cz>
 <e19b241d-be27-3c9a-8984-2fb20211e2e1@oracle.com>
 <20170515193817.GC7551@dhcp22.suse.cz>
 <9b3d68aa-d2b6-2b02-4e75-f8372cbeb041@oracle.com>
 <20170516083601.GB2481@dhcp22.suse.cz>
 <07a6772b-711d-4fdc-f688-db76f1ec4c45@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07a6772b-711d-4fdc-f688-db76f1ec4c45@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

On Fri 26-05-17 12:45:55, Pasha Tatashin wrote:
> Hi Michal,
> 
> I have considered your proposals:
> 
> 1. Making memset(0) unconditional inside __init_single_page() is not going
> to work because it slows down SPARC, and ppc64. On SPARC even the BSTI
> optimization that I have proposed earlier won't work, because after
> consulting with other engineers I was told that stores (without loads!)
> after BSTI without membar are unsafe

Could you be more specific? E.g. how are other stores done in
__init_single_page safe then? I am sorry to be dense here but how does
the full 64B store differ from other stores done in the same function.

[...]
> So, at the moment I cannot really find a better solution compared to what I
> have proposed: do memset() inside __init_single_page() only when deferred
> initialization is enabled.

As I've already said I am not going to block your approach I was just
hoping for something that doesn't depend on the deferred initialization.
Especially when the struct page is a small objects and it makes sense to
initialize it completely at a single page. Writing to a single cache
line should simply not add memory traffic for exclusive cache line and
struct pages are very likely to exclusive at that stage.

If that doesn't fly then be it but I have to confess I still do not
understand why that is not the case.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
