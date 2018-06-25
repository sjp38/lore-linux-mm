Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C56146B0006
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 05:29:40 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s16-v6so564331pgq.4
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 02:29:40 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id c7-v6si11329995pgn.132.2018.06.25.02.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 02:29:39 -0700 (PDT)
Date: Mon, 25 Jun 2018 12:29:38 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 15/17] x86/mm: Implement sync_direct_mapping()
Message-ID: <20180625092937.gmu6m7kwet5s5w6m@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-16-kirill.shutemov@linux.intel.com>
 <848a6836-1f54-4775-0b87-e926d7b7991d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <848a6836-1f54-4775-0b87-e926d7b7991d@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 18, 2018 at 04:28:27PM +0000, Dave Hansen wrote:
> > index 17383f9677fa..032b9a1ba8e1 100644
> > --- a/arch/x86/mm/init_64.c
> > +++ b/arch/x86/mm/init_64.c
> > @@ -731,6 +731,8 @@ kernel_physical_mapping_init(unsigned long paddr_start,
> >  		pgd_changed = true;
> >  	}
> >  
> > +	sync_direct_mapping();
> > +
> >  	if (pgd_changed)
> >  		sync_global_pgds(vaddr_start, vaddr_end - 1);
> >  
> > @@ -1142,10 +1144,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
> >  static void __meminit
> >  kernel_physical_mapping_remove(unsigned long start, unsigned long end)
> >  {
> > +	int ret;
> >  	start = (unsigned long)__va(start);
> >  	end = (unsigned long)__va(end);
> >  
> >  	remove_pagetable(start, end, true, NULL);
> > +	ret = sync_direct_mapping();
> > +	WARN_ON(ret);
> >  }
> 
> I understand why you implemented it this way, I really do.  It's
> certainly the quickest way to hack something together and make a
> standalone piece of code.  But, I don't think it's maintainable.
> 
> For instance, this call to sync_direct_mapping() could be entirely
> replaced by a call to:
> 
> 	for_each_keyid(k)...
> 		remove_pagetable(start + offset_per_keyid * k,
> 			         end   + offset_per_keyid * k,
> 				 true, NULL);
> 
> No?

Yes. But what's the point if we need to have the sync routine anyway for
the add path?


> >  int __ref arch_remove_memory(u64 start, u64 size, struct vmem_altmap *altmap)
> > @@ -1290,6 +1295,7 @@ void mark_rodata_ro(void)
> >  			(unsigned long) __va(__pa_symbol(rodata_end)),
> >  			(unsigned long) __va(__pa_symbol(_sdata)));
> >  
> > +	sync_direct_mapping();
> >  	debug_checkwx();
> 
> Huh, checking the return code in some cases and not others.  Curious.
> Why is it that way?

There's no sensible way to handle failure in any of these path. But in
remove path we don't expect the failure -- no allocation required.
It can only happen if we missed sync_direct_mapping() somewhere else.

-- 
 Kirill A. Shutemov
