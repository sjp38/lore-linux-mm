Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 326946B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 13:18:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 75so5893230pgf.3
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 10:18:22 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q12si80198656pgc.52.2017.01.06.10.18.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 10:18:21 -0800 (PST)
Date: Fri, 6 Jan 2017 11:18:19 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 0/4] Write protect DAX PMDs in *sync path
Message-ID: <20170106181819.GA3486@linux.intel.com>
References: <1482441536-14550-1-git-send-email-ross.zwisler@linux.intel.com>
 <20170104001349.GA8176@linux.intel.com>
 <20170105172734.23a7603ff19006b49e9ba01a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105172734.23a7603ff19006b49e9ba01a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-kernel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org

On Thu, Jan 05, 2017 at 05:27:34PM -0800, Andrew Morton wrote:
> On Tue, 3 Jan 2017 17:13:49 -0700 Ross Zwisler <ross.zwisler@linux.intel.com> wrote:
> 
> > On Thu, Dec 22, 2016 at 02:18:52PM -0700, Ross Zwisler wrote:
> > > Currently dax_mapping_entry_mkclean() fails to clean and write protect the
> > > pmd_t of a DAX PMD entry during an *sync operation.  This can result in
> > > data loss, as detailed in patch 4.
> > > 
> > > You can find a working tree here:
> > > 
> > > https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_clean_v2
> > > 
> > > This series applies cleanly to mmotm-2016-12-19-16-31.
> > > 
> > > Changes since v1:
> > >  - Included Dan's patch to kill DAX support for UML.
> > >  - Instead of wrapping the DAX PMD code in dax_mapping_entry_mkclean() in
> > >    an #ifdef, we now create a stub for pmdp_huge_clear_flush() for the case
> > >    when CONFIG_TRANSPARENT_HUGEPAGE isn't defined. (Dan & Jan)
> > > 
> > > Dan Williams (1):
> > >   dax: kill uml support
> > > 
> > > Ross Zwisler (3):
> > >   dax: add stub for pmdp_huge_clear_flush()
> > >   mm: add follow_pte_pmd()
> > >   dax: wrprotect pmd_t in dax_mapping_entry_mkclean
> > > 
> > >  fs/Kconfig                    |  2 +-
> > >  fs/dax.c                      | 49 ++++++++++++++++++++++++++++++-------------
> > >  include/asm-generic/pgtable.h | 10 +++++++++
> > >  include/linux/mm.h            |  4 ++--
> > >  mm/memory.c                   | 41 ++++++++++++++++++++++++++++--------
> > >  5 files changed, 79 insertions(+), 27 deletions(-)
> > 
> > Well, 0-day found another architecture that doesn't define pmd_pfn() et al.,
> > so we'll need some more fixes. (Thank you, 0-day, for the coverage!)
> > 
> > I have to apologize, I didn't understand that Dan intended his "dax: kill uml
> > support" patch to land in v4.11.  I thought he intended it as a cleanup to my
> > series, which really needs to land in v4.10.  That's why I folded them
> > together into this v2, along with the wrapper suggested by Jan.
> > 
> > Andrew, does it work for you to just keep v1 of this series, and eventually
> > send that to Linus for v4.10?
> > 
> > https://lkml.org/lkml/2016/12/20/649
> > 
> > You've already pulled that one into -mm, and it does correctly solve the data
> > loss issue.
> > 
> > That would let us deal with getting rid of the #ifdef, blacklisting
> > architectures and introducing the pmdp_huge_clear_flush() strub in a follow-on
> > series for v4.11.
> 
> I have mm-add-follow_pte_pmd.patch and
> dax-wrprotect-pmd_t-in-dax_mapping_entry_mkclean.patch queued for 4.10.
> Please (re)send any additional patches, indicating for each one
> whether you believe it should also go into 4.10?

The two patches that you already have queued are correct, and no additional
patches are necessary for v4.10 for this issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
