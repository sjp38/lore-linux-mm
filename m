Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4018E6B0253
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 10:39:04 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id l68so154251512wml.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:39:04 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id a3si14862412wmc.122.2016.03.21.07.39.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 07:39:03 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id l68so154250909wml.0
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 07:39:03 -0700 (PDT)
Date: Mon, 21 Mar 2016 17:39:00 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 08/25] thp: support file pages in zap_huge_pmd()
Message-ID: <20160321143900.GA12917@node.shutemov.name>
References: <1457737157-38573-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1457737157-38573-9-git-send-email-kirill.shutemov@linux.intel.com>
 <87a8lvao4a.fsf@linux.vnet.ibm.com>
 <20160319010239.GB29883@node.shutemov.name>
 <87a8lsv49y.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87a8lsv49y.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, Mar 21, 2016 at 10:03:29AM +0530, Aneesh Kumar K.V wrote:
> "Kirill A. Shutemov" <kirill@shutemov.name> writes:
> 
> > [ text/plain ]
> > On Fri, Mar 18, 2016 at 07:23:41PM +0530, Aneesh Kumar K.V wrote:
> >> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> >> 
> >> > [ text/plain ]
> >> > split_huge_pmd() for file mappings (and DAX too) is implemented by just
> >> > clearing pmd entry as we can re-fill this area from page cache on pte
> >> > level later.
> >> >
> >> > This means we don't need deposit page tables when file THP is mapped.
> >> > Therefore we shouldn't try to withdraw a page table on zap_huge_pmd()
> >> > file THP PMD.
> >> 
> >> Archs like ppc64 use deposited page table to track the hardware page
> >> table slot information. We probably may want to add hooks which arch can
> >> use to achieve the same even with file THP 
> >
> > Could you describe more on what kind of information you're talking about?
> >
> 
> Hardware page table in ppc64 requires us to map each subpage of the huge
> page. This is needed because at low level we use segment base page size
> to find the hash slot and on TLB miss, we use the faulting address and
> base page size (which is 64k even with THP) to find whether we have
> the page mapped in hash page table. Since we use base page size of 64K,
> we need to make sure that subpages are mapped (on demand) in hash page
> table. If we have then mapped we also need to track their hash table
> slot information so that we can clear it on invalidate of hugepage.
> 
> With THP we used the deposited page table to store the hash slot
> information.

Could you prepare the patch with these hooks so we can discuss it details?
I still have hard time wrap my had around this.

I think you have the same problem with DAX huge pages. Or you don't care
about DAX?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
