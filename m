Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id DAF3D6B009A
	for <linux-mm@kvack.org>; Fri, 29 May 2015 16:29:39 -0400 (EDT)
Received: by oifu123 with SMTP id u123so65156108oif.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 13:29:39 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id o87si4203993oik.97.2015.05.29.13.29.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 13:29:38 -0700 (PDT)
Message-ID: <1432930202.23540.87.camel@misato.fc.hp.com>
Subject: Re: [PATCH v10 12/12] drivers/block/pmem: Map NVDIMM with
 ioremap_wt()
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 29 May 2015 14:10:02 -0600
In-Reply-To: <CAPcyv4h82sjyXEz2GN=ttD3t-Z-owCyZTsfpkXc3D+KehwcAmg@mail.gmail.com>
References: <1432739944-22633-1-git-send-email-toshi.kani@hp.com>
	 <1432739944-22633-13-git-send-email-toshi.kani@hp.com>
	 <20150529091129.GC31435@pd.tnic>
	 <CAPcyv4jHbrUP7bDpw2Cja5x0eMQZBLmmzFXbotQWSEkAiL1s7Q@mail.gmail.com>
	 <1432911782.23540.55.camel@misato.fc.hp.com>
	 <CAPcyv4g+zYFkEYpa0HCh0Q+2C3wWNr6v3ZU143h52OKf=U=Qvw@mail.gmail.com>
	 <1432924340.23540.78.camel@misato.fc.hp.com>
	 <CAPcyv4h82sjyXEz2GN=ttD3t-Z-owCyZTsfpkXc3D+KehwcAmg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Borislav Petkov <bp@alien8.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "Elliott, Robert (Server Storage)" <Elliott@hp.com>, Luis Rodriguez <mcgrof@suse.com>, Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@linux.intel.com>

On Fri, 2015-05-29 at 12:34 -0700, Dan Williams wrote:
> On Fri, May 29, 2015 at 11:32 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> > On Fri, 2015-05-29 at 11:19 -0700, Dan Williams wrote:
> >> On Fri, May 29, 2015 at 8:03 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> >> > On Fri, 2015-05-29 at 07:43 -0700, Dan Williams wrote:
> >> >> On Fri, May 29, 2015 at 2:11 AM, Borislav Petkov <bp@alien8.de> wrote:
> >> >> > On Wed, May 27, 2015 at 09:19:04AM -0600, Toshi Kani wrote:
> >> >> >> The pmem driver maps NVDIMM with ioremap_nocache() as we cannot
> >  :
> >> >> >> -     pmem->virt_addr = ioremap_nocache(pmem->phys_addr, pmem->size);
> >> >> >> +     pmem->virt_addr = ioremap_wt(pmem->phys_addr, pmem->size);
> >> >> >>       if (!pmem->virt_addr)
> >> >> >>               goto out_release_region;
> >> >> >
> >> >> > Dan, Ross, what about this one?
> >> >> >
> >> >> > ACK to pick it up as a temporary solution?
> >> >>
> >> >> I see that is_new_memtype_allowed() is updated to disallow some
> >> >> combinations, but the manual seems to imply any mixing of memory types
> >> >> is unsupported.  Which worries me even in the current code where we
> >> >> have uncached mappings in the driver, and potentially cached DAX
> >> >> mappings handed out to userspace.
> >> >
> >> > is_new_memtype_allowed() is not to allow some combinations of mixing of
> >> > memory types.  When it is allowed, the requested type of ioremap_xxx()
> >> > is changed to match with the existing map type, so that mixing of memory
> >> > types does not happen.
> >>
> >> Yes, but now if the caller was expecting one memory type and gets
> >> another one that is something I think the driver would want to know.
> >> At a minimum I don't think we want to get emails about pmem driver
> >> performance problems when someone's platform is silently degrading WB
> >> to UC for example.
> >
> > The pmem driver creates an ioremap map to an NVDIMM range first.  So,
> > there will be no conflict at this point, unless there is a conflicting
> > driver claiming the same NVDIMM range.
> 
> Hmm, I thought it would be WB due to this comment in is_new_memtype_allowed()
> 
>         /*
>          * PAT type is always WB for untracked ranges, so no need to check.
>          */

This comment applies to the ISA range, where ioremap() does not create
any mapping to, i.e. untracked.  You can ignore this comment for NVDIMM.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
