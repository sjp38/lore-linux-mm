Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20E046B0292
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 14:17:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z70so2374440wrc.1
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 11:17:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k44sor449363eda.3.2017.06.07.11.17.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Jun 2017 11:17:08 -0700 (PDT)
Date: Wed, 7 Jun 2017 21:17:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove by not
 freeing pud v2
Message-ID: <20170607181705.7jortbns732jtiba@node.shutemov.name>
References: <1496846780-17393-1-git-send-email-jglisse@redhat.com>
 <20170607170325.65ex46hoqjalprnu@black.fi.intel.com>
 <20170607170651.exful7yvxvrjaolz@node.shutemov.name>
 <1169495863.31360420.1496857080560.JavaMail.zimbra@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1169495863.31360420.1496857080560.JavaMail.zimbra@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>, Logan Gunthorpe <logang@deltatee.com>

On Wed, Jun 07, 2017 at 01:38:00PM -0400, Jerome Glisse wrote:
> > On Wed, Jun 07, 2017 at 08:03:25PM +0300, Kirill A. Shutemov wrote:
> > > On Wed, Jun 07, 2017 at 10:46:20AM -0400, jglisse@redhat.com wrote:
> > > > From: Jerome Glisse <jglisse@redhat.com>
> > > > 
> > > > With commit af2cf278ef4f we no longer free pud so that we do not
> > > > have synchronize all pgd on hotremove/vfree. But the new 5 level
> > > > page table patchset reverted that for 4 level page table.
> > > > 
> > > > This patch restore af2cf278ef4f and disable free_pud() if we are
> > > > in the 4 level page table case thus avoiding BUG_ON() after hot-
> > > > remove.
> > > > 
> > > > af2cf278ef4f x86/mm/hotplug: Don't remove PGD entries in
> > > > remove_pagetable()
> > > > 
> > > > Changed since v1:
> > > >   - make free_pud() conditional on the number of page table
> > > >     level
> > > >   - improved commit message
> > > > 
> > > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > > Cc: Andy Lutomirski <luto@kernel.org>
> > > > Cc: Ingo Molnar <mingo@kernel.org>
> > > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > Cc: Logan Gunthorpe <logang@deltatee.com>
> > > > > thus we now trigger a BUG_ON() l128 in sync_global_pgds()
> > > > >
> > > > > This patch remove free_pud() like in af2cf278ef4f
> > > > ---
> > > >  arch/x86/mm/init_64.c | 11 +++++++++++
> > > >  1 file changed, 11 insertions(+)
> > > > 
> > > > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> > > > index 95651dc..61028bc 100644
> > > > --- a/arch/x86/mm/init_64.c
> > > > +++ b/arch/x86/mm/init_64.c
> > > > @@ -771,6 +771,16 @@ static void __meminit free_pmd_table(pmd_t
> > > > *pmd_start, pud_t *pud)
> > > >  	spin_unlock(&init_mm.page_table_lock);
> > > >  }
> > > >  
> > > > +/*
> > > > + * For 4 levels page table we do not want to free puds but for 5 levels
> > > > + * we should free them. This code also need to change to adapt for boot
> > > > + * time switching between 4 and 5 level.
> > > > + */
> > > > +#if CONFIG_PGTABLE_LEVELS == 4
> > > > +static inline void free_pud_table(pud_t *pud_start, p4d_t *p4d)
> > > > +{
> > > > +}
> > > 
> > > Just "if (CONFIG_PGTABLE_LEVELS > 4)" before calling free_pud_table(), but
> > > okay -- I'll rework it anyway for boot-time switching.
> > 
> > Err. "if (CONFIG_PGTABLE_LEVELS == 4)" obviously.
> 
> You want me to respawn a v3 or is that good enough until you finish
> boot time 5 level page table ?

It doesn't matter for me. Upto Ingo.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
