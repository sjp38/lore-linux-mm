Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2FE6B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 18:22:58 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id l43so3044500wrl.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:22:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 98si427880wrb.362.2017.06.15.15.22.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 15:22:56 -0700 (PDT)
Date: Fri, 16 Jun 2017 00:22:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: improve readability of
 transparent_hugepage_enabled()
Message-ID: <20170615222253.GD22341@dhcp22.suse.cz>
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170614124520.GA8537@dhcp22.suse.cz>
 <CAPcyv4hEYJrW=Pv+ON5+EG4iLUjX2XRW3u+kSsMa8J5qh-KeVg@mail.gmail.com>
 <20170615080738.GB1486@dhcp22.suse.cz>
 <CAPcyv4hQJ3-Qgy9ketKYyeZzd+fYixA9LhANDVtEso1HoPHFzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hQJ3-Qgy9ketKYyeZzd+fYixA9LhANDVtEso1HoPHFzA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu 15-06-17 13:21:46, Dan Williams wrote:
> On Thu, Jun 15, 2017 at 1:07 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 14-06-17 12:26:46, Dan Williams wrote:
> >> On Wed, Jun 14, 2017 at 5:45 AM, Michal Hocko <mhocko@kernel.org> wrote:
> >> > On Tue 13-06-17 16:08:26, Dan Williams wrote:
> >> >> Turn the macro into a static inline and rewrite the condition checks for
> >> >> better readability in preparation for adding another condition.
> >> >>
> >> >> Cc: Jan Kara <jack@suse.cz>
> >> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> >> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
> >> >> [ross: fix logic to make conversion equivalent]
> >> >> Acked-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >> >> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> >> >
> >> > This is really a nice deobfuscation! Please note this will conflict with
> >> > http://lkml.kernel.org/r/1496415802-30944-1-git-send-email-rppt@linux.vnet.ibm.com
> >> >
> >> >
> >> > Trivial to resolve but I thought I should give you a heads up.
> >>
> >> Hmm, I'm assuming that vma_is_dax() should override PRCTL_THP_DISABLE?
> >> ...and while we're there should vma_is_dax() also override
> >> VM_NOHUGEPAGE? This is with the assumption that the reason to turn off
> >> huge pages is to avoid mm pressure, dax exerts no such pressure.
> >
> > As the changelog of the referenced patch says another reason is to stop
> > khugepaged from interfering and collapsing smaller pages into THP. If
> > DAX mappings are subject to khugepaged then we really need to exclude
> > it. Why would you want to override user's decision to disable THP
> > anyway? I can see why the global knob should be ignored but if the
> > disable is targeted for the specific VMA or the process then we should
> > obey that, no?
> 
> I don't think DAX mappings have any interaction with THP machinery
> outside of piggybacking on some of the paths in the fault handling and
> the helpers to manage huge page table entries. Since DAX disables the
> page cache, and all DAX mappings are file-backed I don't see a need
> for a user to disable THP... does anybody else?

So let me ask differently. If the VMA is explicitly marked to not use
THP resp. the process explicitly asked to be opted out from THP why
should we make any exception for DAX? What makes DAX so special to
ignore what an user asked for? 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
