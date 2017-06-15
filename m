Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D23EF6B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 16:07:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id n18so4880270wra.11
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 13:07:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 69si211647wra.135.2017.06.15.13.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 13:07:01 -0700 (PDT)
Date: Thu, 15 Jun 2017 13:06:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/2] mm: improve readability of
 transparent_hugepage_enabled()
Message-Id: <20170615130658.009629c1fdeb087058b78333@linux-foundation.org>
In-Reply-To: <20170615080738.GB1486@dhcp22.suse.cz>
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
	<149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20170614124520.GA8537@dhcp22.suse.cz>
	<CAPcyv4hEYJrW=Pv+ON5+EG4iLUjX2XRW3u+kSsMa8J5qh-KeVg@mail.gmail.com>
	<20170615080738.GB1486@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, 15 Jun 2017 10:07:39 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Wed 14-06-17 12:26:46, Dan Williams wrote:
> > On Wed, Jun 14, 2017 at 5:45 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > > On Tue 13-06-17 16:08:26, Dan Williams wrote:
> > >> Turn the macro into a static inline and rewrite the condition checks for
> > >> better readability in preparation for adding another condition.
> > >>
> > >> Cc: Jan Kara <jack@suse.cz>
> > >> Cc: Andrew Morton <akpm@linux-foundation.org>
> > >> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> > >> [ross: fix logic to make conversion equivalent]
> > >> Acked-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > >> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > >
> > > This is really a nice deobfuscation! Please note this will conflict with
> > > http://lkml.kernel.org/r/1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com
> > >
> > >
> > > Trivial to resolve but I thought I should give you a heads up.
> > 
> > Hmm, I'm assuming that vma_is_dax() should override PRCTL_THP_DISABLE?
> > ...and while we're there should vma_is_dax() also override
> > VM_NOHUGEPAGE? This is with the assumption that the reason to turn off
> > huge pages is to avoid mm pressure, dax exerts no such pressure.
> 
> As the changelog of the referenced patch says another reason is to stop
> khugepaged from interfering and collapsing smaller pages into THP. If
> DAX mappings are subject to khugepaged then we really need to exclude
> it. Why would you want to override user's decision to disable THP
> anyway? I can see why the global knob should be ignored but if the
> disable is targeted for the specific VMA or the process then we should
> obey that, no?

So... Like this?

static inline bool transparent_hugepage_enabled(struct vm_area_struct *vma)
{
	if (vma->vm_flags & VM_NOHUGEPAGE))
		return false;

	if (is_vma_temporary_stack(vma))
		return false;

	if (test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags))
		return false;

	if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
		return true;

	if (transparent_hugepage_flags &
				(1 << TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG))
		return !!(vma->vm_flags & VM_HUGEPAGE);

	return false;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
