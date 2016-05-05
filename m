Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 304A26B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 11:09:11 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id o133so46783389vka.3
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:09:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j123si1649035qkj.185.2016.05.05.08.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 08:09:10 -0700 (PDT)
Date: Thu, 5 May 2016 17:09:07 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160505150907.GF28755@redhat.com>
References: <20160429005106.GB2847@node.shutemov.name>
 <20160428204542.5f2053f7@ul30vt.home>
 <20160429070611.GA4990@node.shutemov.name>
 <20160429163444.GM11700@redhat.com>
 <20160502104119.GA23305@node.shutemov.name>
 <20160502152307.GA12310@redhat.com>
 <20160502160042.GC24419@node.shutemov.name>
 <20160502180307.GB12310@redhat.com>
 <20160504191927.095cdd90@t450s.home>
 <20160505143924.GC28755@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160505143924.GC28755@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Williamson <alex.williamson@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, May 05, 2016 at 04:39:24PM +0200, Andrea Arcangeli wrote:
> I'm currently testing this:

I must have been testing an earlier version, this below has better
chance not to oops. There's a reason I didn't attempt a proper submit
yet.. this is just for testing until we're sure this ok.

I also had a version of it initially that added a "*local_rmap"
instead of a *total_mapcount parameter to reuse_swap_page but then I
don't think gcc would have optimized things away enough depending on
the kernel config. reuse_swap_page couldn't just forward the
"total_mapcount" pointer from caller to callee anymore. So this
results in less code at the very least but then we've to check
"total_mapcount == 1" instead of just a true/false "local_rmap" (which
might have been more self explanatory) if reuse_swap_page returns
true.
