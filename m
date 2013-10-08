Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DAC386B0032
	for <linux-mm@kvack.org>; Tue,  8 Oct 2013 10:47:45 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so9027448pab.27
        for <linux-mm@kvack.org>; Tue, 08 Oct 2013 07:47:45 -0700 (PDT)
Date: Tue, 08 Oct 2013 10:47:00 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1381243620-hjcyg13o-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131008144030.GA19040@moon>
References: <20131008090019.527108154@gmail.com>
 <20131008090236.951114091@gmail.com>
 <1381241500-bfdgpu61-mutt-n-horiguchi@ah.jp.nec.com>
 <20131008144030.GA19040@moon>
Subject: Re: [patch 1/3] [PATCH] mm: migration -- Do not loose soft dirty bit
 if page is in migration state
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Andy Lutomirski <luto@amacapital.net>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Tue, Oct 08, 2013 at 06:40:30PM +0400, Cyrill Gorcunov wrote:
> On Tue, Oct 08, 2013 at 10:11:40AM -0400, Naoya Horiguchi wrote:
> > > Index: linux-2.6.git/mm/memory.c
> > > ===================================================================
> > > --- linux-2.6.git.orig/mm/memory.c
> > > +++ linux-2.6.git/mm/memory.c
> > > @@ -837,6 +837,8 @@ copy_one_pte(struct mm_struct *dst_mm, s
> > >  					 */
> > >  					make_migration_entry_read(&entry);
> > >  					pte = swp_entry_to_pte(entry);
> > > +					if (pte_swp_soft_dirty(*src_pte))
> > > +						pte = pte_swp_mksoft_dirty(pte);
> > >  					set_pte_at(src_mm, addr, src_pte, pte);
> > >  				}
> > >  			}
> > 
> > When we convert pte to swap_entry, we convert soft-dirty bit in
> > pte_to_swp_entry(). So I think that it's better to convert it back
> > in swp_entry_to_pte() when we do swap_entry-to-pte conversion.
> 
> No, soft dirty bit lays _only_ inside pte entry in memory, iow
> swp_entry_t never has this bit, thus to be able to find soft dirty
> status in swp_entry_to_pte you need to extend this function and
> pass pte entry itself as an argument, which eventually will bring
> more massive patch and will be a way more confusing I think.

OK, you're right. Thanks for explanation.

> Or I misunderstood you?

No, I misread the code, sorry.

Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
