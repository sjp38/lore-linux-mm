Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 921676B0292
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 02:46:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g46so17827455wrd.3
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 23:46:03 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id k34si853532wre.244.2017.06.23.23.46.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 23:46:02 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id z45so17458031wrb.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 23:46:02 -0700 (PDT)
Date: Sat, 24 Jun 2017 08:45:59 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] x86/mm/hotplug: fix BUG_ON() after hotremove by not
 freeing pud v2
Message-ID: <20170624064559.3upsr2temhjlw2jb@gmail.com>
References: <1496846780-17393-1-git-send-email-jglisse@redhat.com>
 <20170607170325.65ex46hoqjalprnu@black.fi.intel.com>
 <20170607170651.exful7yvxvrjaolz@node.shutemov.name>
 <1169495863.31360420.1496857080560.JavaMail.zimbra@redhat.com>
 <20170607181705.7jortbns732jtiba@node.shutemov.name>
 <20170623194805.GD3128@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170623194805.GD3128@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Logan Gunthorpe <logang@deltatee.com>


* Jerome Glisse <jglisse@redhat.com> wrote:

> On Wed, Jun 07, 2017 at 09:17:06PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Jun 07, 2017 at 01:38:00PM -0400, Jerome Glisse wrote:
> > > > On Wed, Jun 07, 2017 at 08:03:25PM +0300, Kirill A. Shutemov wrote:
> > > > > On Wed, Jun 07, 2017 at 10:46:20AM -0400, jglisse@redhat.com wrote:
> > > > > > From: Jerome Glisse <jglisse@redhat.com>
> > > > > > 
> > > > > > With commit af2cf278ef4f we no longer free pud so that we do not
> > > > > > have synchronize all pgd on hotremove/vfree. But the new 5 level
> > > > > > page table patchset reverted that for 4 level page table.
> > > > > > 
> > > > > > This patch restore af2cf278ef4f and disable free_pud() if we are
> > > > > > in the 4 level page table case thus avoiding BUG_ON() after hot-
> > > > > > remove.
> > > > > > 
> > > > > > af2cf278ef4f x86/mm/hotplug: Don't remove PGD entries in
> > > > > > remove_pagetable()
> > > > > > 
> > > > > > Changed since v1:
> > > > > >   - make free_pud() conditional on the number of page table
> > > > > >     level
> > > > > >   - improved commit message
> > > > > > 
> > > > > > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > > > > > Cc: Andy Lutomirski <luto@kernel.org>
> > > > > > Cc: Ingo Molnar <mingo@kernel.org>
> > > > > > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > > > > Cc: Logan Gunthorpe <logang@deltatee.com>
> > > > > > > thus we now trigger a BUG_ON() l128 in sync_global_pgds()
> > > > > > >
> > > > > > > This patch remove free_pud() like in af2cf278ef4f
> > > > > > ---
> > > > > >  arch/x86/mm/init_64.c | 11 +++++++++++
> > > > > >  1 file changed, 11 insertions(+)
> > > > > > 
> > > > > > diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> > > > > > index 95651dc..61028bc 100644
> > > > > > --- a/arch/x86/mm/init_64.c
> > > > > > +++ b/arch/x86/mm/init_64.c
> > > > > > @@ -771,6 +771,16 @@ static void __meminit free_pmd_table(pmd_t
> > > > > > *pmd_start, pud_t *pud)
> > > > > >  	spin_unlock(&init_mm.page_table_lock);
> > > > > >  }
> > > > > >  
> > > > > > +/*
> > > > > > + * For 4 levels page table we do not want to free puds but for 5 levels
> > > > > > + * we should free them. This code also need to change to adapt for boot
> > > > > > + * time switching between 4 and 5 level.
> > > > > > + */
> > > > > > +#if CONFIG_PGTABLE_LEVELS == 4
> > > > > > +static inline void free_pud_table(pud_t *pud_start, p4d_t *p4d)
> > > > > > +{
> > > > > > +}
> > > > > 
> > > > > Just "if (CONFIG_PGTABLE_LEVELS > 4)" before calling free_pud_table(), but
> > > > > okay -- I'll rework it anyway for boot-time switching.
> > > > 
> > > > Err. "if (CONFIG_PGTABLE_LEVELS == 4)" obviously.
> > > 
> > > You want me to respawn a v3 or is that good enough until you finish
> > > boot time 5 level page table ?
> > 
> > It doesn't matter for me. Upto Ingo.
> 
> Andrew any news on this ? This fix a regression in 4.12 so it would be nice to
> have this fix or similar in. I can repost a v3 without inline ie directly ifdefing
> the callsite.
> 
> Note that Kyrill will rework that but i think this is 4.13 material.

Please don't #ifdef the call site or tweak the inlines - isn't what Kirill 
suggested:

	if (CONFIG_PGTABLE_LEVELS == 4)

at the call site enough to fix the bug?

BTW., how can this be a regression, if in v4.12 CONFIG_PGTABLE_LEVELS is always 4?

For CONFIG_PGTABLE_LEVELS == 5 it won't work - but we don't have 
CONFIG_PGTABLE_LEVELS == 5 upstream yet.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
