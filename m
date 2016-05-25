Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id EAA3D6B026A
	for <linux-mm@kvack.org>; Wed, 25 May 2016 17:25:16 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gw7so83088852pac.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 14:25:16 -0700 (PDT)
Received: from mail-lf0-f68.google.com (mail-lf0-f68.google.com. [209.85.215.68])
        by mx.google.com with ESMTPS id s7si15153459pas.203.2016.05.25.14.25.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 14:25:15 -0700 (PDT)
Received: by mail-lf0-f68.google.com with SMTP id w16so2174119lfd.0
        for <linux-mm@kvack.org>; Wed, 25 May 2016 14:25:15 -0700 (PDT)
Date: Thu, 26 May 2016 00:21:30 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv8 00/32] THP-enabled tmpfs/shmem using compound pages
Message-ID: <20160525212129.GB15857@node.shutemov.name>
References: <1463067672-134698-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CADf8yx+YMM7DZ8icem2RMQMgtJ8TfGCjGc56xUrBpeY1xLZ4SQ@mail.gmail.com>
 <20160525200356.GA15857@node.shutemov.name>
 <CADf8yx+_EEwys7mip0HspKGMGpacws93afX1zKtHLOmF6-Lj1g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADf8yx+_EEwys7mip0HspKGMGpacws93afX1zKtHLOmF6-Lj1g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: neha agarwal <neha.agbk@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Wed, May 25, 2016 at 05:11:03PM -0400, neha agarwal wrote:
> On Wed, May 25, 2016 at 4:03 PM, Kirill A. Shutemov <kirill@shutemov.name>
> wrote:
> 
> > On Wed, May 25, 2016 at 03:11:55PM -0400, neha agarwal wrote:
> > > Hi All,
> > >
> > > I have been testing Hugh's and Kirill's huge tmpfs patch sets with
> > > Cassandra (NoSQL database). I am seeing significant performance gap
> > between
> > > these two implementations (~30%). Hugh's implementation performs better
> > > than Kirill's implementation. I am surprised why I am seeing this
> > > performance gap. Following is my test setup.
> >
> > Thanks for the report. I'll look into it.
> >
> 
> Thanks Kirill for looking into it.
> 
> 
> > > Patchsets
> > > ========
> > > - For Hugh's:
> > > I checked out 4.6-rc3, applied Hugh's preliminary patches (01 to 10
> > > patches) from here: https://lkml.org/lkml/2016/4/5/792 and then applied
> > the
> > > THP patches posted on April 16 (01 to 29 patches).
> > >
> > > - For Kirill's:
> > > I am using his branch  "git://
> > > git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git hugetmpfs/v8",
> > which
> > > is based off of 4.6-rc3, posted on May 12.
> > >
> > >
> > > Khugepaged settings
> > > ================
> > > cd /sys/kernel/mm/transparent_hugepage
> > > echo 10 >khugepaged/alloc_sleep_millisecs
> > > echo 10 >khugepaged/scan_sleep_millisecs
> > > echo 511 >khugepaged/max_ptes_none
> >
> > Do you make this for both setup?
> >
> > It's not really nessesary for Hugh's, but it makes sense to have this
> > idenatical for testing.
> >
> 
> Yeah right, Hugh's will not be impacted by these settings but for identical
> testing I did that.

Could you try to drop this changes and leave khugepaged with defaults.

One theory is that you just create additional load on the system without
any gain. As pages wasn't swapped out we have nothing to collapse back,
but scanning takes CPU time.

Hugh didn't change khugepaged, so it would not need to look into tmpfs
mapping to check if there's something to collapse...

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
