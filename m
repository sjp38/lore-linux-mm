Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F1CF6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 16:02:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 81so33643481wms.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 13:02:48 -0700 (PDT)
Received: from mail-lf0-x242.google.com (mail-lf0-x242.google.com. [2a00:1450:4010:c07::242])
        by mx.google.com with ESMTPS id f134si32029938lfe.186.2016.05.23.13.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 13:02:46 -0700 (PDT)
Received: by mail-lf0-x242.google.com with SMTP id z203so3906817lfd.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 13:02:46 -0700 (PDT)
Date: Mon, 23 May 2016 23:02:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] mm, thp: make swapin readahead under down_read of
 mmap_sem
Message-ID: <20160523200244.GA4289@node.shutemov.name>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
 <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
 <20160523184246.GE32715@dhcp22.suse.cz>
 <1464029349.16365.58.camel@redhat.com>
 <20160523190154.GA79357@black.fi.intel.com>
 <1464031607.16365.60.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464031607.16365.60.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com

On Mon, May 23, 2016 at 03:26:47PM -0400, Rik van Riel wrote:
> On Mon, 2016-05-23 at 22:01 +0300, Kirill A. Shutemov wrote:
> > On Mon, May 23, 2016 at 02:49:09PM -0400, Rik van Riel wrote:
> > > 
> > > On Mon, 2016-05-23 at 20:42 +0200, Michal Hocko wrote:
> > > > 
> > > > On Mon 23-05-16 20:14:11, Ebru Akagunduz wrote:
> > > > > 
> > > > > 
> > > > > Currently khugepaged makes swapin readahead under
> > > > > down_write. This patch supplies to make swapin
> > > > > readahead under down_read instead of down_write.
> > > > You are still keeping down_write. Can we do without it
> > > > altogether?
> > > > Blocking mmap_sem of a remote proces for write is certainly not
> > > > nice.
> > > Maybe Andrea can explain why khugepaged requires
> > > a down_write of mmap_sem?
> > > 
> > > If it were possible to have just down_read that
> > > would make the code a lot simpler.
> > You need a down_write() to retract page table. We need to make sure
> > that
> > nobody sees the page table before we can replace it with huge pmd.
> 
> Good point.
> 
> I guess the alternative is to have the page_table_lock
> taken by a helper function (everywhere) that can return
> failure if the page table was changed while the caller
> was waiting for the lock.

Not page table was changed, but pmd is now pointing to something else.
Basically, we would need to nest all pte-ptl's within pmd_lock().
That's not good for scalability.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
