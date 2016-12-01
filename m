Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 466626B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 22:11:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c4so333426333pfb.7
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 19:11:14 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id 90si38505924pla.214.2016.11.30.19.11.11
        for <linux-mm@kvack.org>;
        Wed, 30 Nov 2016 19:11:13 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com> <20161129112304.90056-23-kirill.shutemov@linux.intel.com> <017501d24aee$d9a189c0$8ce49d40$@alibaba-inc.com> <20161130131534.3k35cigsn36d7ku6@black.fi.intel.com>
In-Reply-To: <20161130131534.3k35cigsn36d7ku6@black.fi.intel.com>
Subject: Re: [PATCHv5 22/36] mm, hugetlb: switch hugetlbfs to multi-order radix-tree entries
Date: Thu, 01 Dec 2016 11:10:52 +0800
Message-ID: <018c01d24b80$86b85490$9428fdb0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>
Cc: 'Theodore Ts'o' <tytso@mit.edu>, 'Andreas Dilger' <adilger.kernel@dilger.ca>, 'Jan Kara' <jack@suse.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, 'Hugh Dickins' <hughd@google.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Dave Hansen' <dave.hansen@intel.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Matthew Wilcox' <willy@infradead.org>, 'Ross Zwisler' <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>

On Wednesday, November 30, 2016 9:16 PM Kirill A. Shutemov wrote:
> On Wed, Nov 30, 2016 at 05:48:05PM +0800, Hillf Danton wrote:
> > On Tuesday, November 29, 2016 7:23 PM Kirill A. Shutemov wrote:
> > > @@ -607,10 +605,10 @@ static long hugetlbfs_fallocate(struct file *file, int mode, loff_t offset,
> > >  		}
> > >
> > >  		/* Set numa allocation policy based on index */
> > > -		hugetlb_set_vma_policy(&pseudo_vma, inode, index);
> > > +		hugetlb_set_vma_policy(&pseudo_vma, inode, index >> huge_page_order(h));
> > >
> > >  		/* addr is the offset within the file (zero based) */
> > > -		addr = index * hpage_size;
> > > +		addr = index << PAGE_SHIFT & ~huge_page_mask(h);
> > >
> > >  		/* mutex taken here, fault path and hole punch */
> > >  		hash = hugetlb_fault_mutex_hash(h, mm, &pseudo_vma, mapping,
> >
> > Seems we can't use index in computing hash as long as it isn't in huge page size.
> 
> Look at changes in hugetlb_fault_mutex_hash(): we shift the index right by
> huge_page_order(), before calculating the hash. I don't see a problem
> here.
> 
You are right. I missed that critical point.

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
