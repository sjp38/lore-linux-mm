Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC8616B0253
	for <linux-mm@kvack.org>; Mon, 23 May 2016 15:02:01 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id yl2so277363370pac.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 12:02:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id hy8si329037pab.190.2016.05.23.12.02.00
        for <linux-mm@kvack.org>;
        Mon, 23 May 2016 12:02:00 -0700 (PDT)
Date: Mon, 23 May 2016 22:01:54 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 3/3] mm, thp: make swapin readahead under down_read of
 mmap_sem
Message-ID: <20160523190154.GA79357@black.fi.intel.com>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
 <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
 <20160523184246.GE32715@dhcp22.suse.cz>
 <1464029349.16365.58.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464029349.16365.58.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Mon, May 23, 2016 at 02:49:09PM -0400, Rik van Riel wrote:
> On Mon, 2016-05-23 at 20:42 +0200, Michal Hocko wrote:
> > On Mon 23-05-16 20:14:11, Ebru Akagunduz wrote:
> > > 
> > > Currently khugepaged makes swapin readahead under
> > > down_write. This patch supplies to make swapin
> > > readahead under down_read instead of down_write.
> > You are still keeping down_write. Can we do without it altogether?
> > Blocking mmap_sem of a remote proces for write is certainly not nice.
> 
> Maybe Andrea can explain why khugepaged requires
> a down_write of mmap_sem?
> 
> If it were possible to have just down_read that
> would make the code a lot simpler.

You need a down_write() to retract page table. We need to make sure that
nobody sees the page table before we can replace it with huge pmd.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
