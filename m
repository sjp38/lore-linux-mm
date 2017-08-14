Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 908DB6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:26:58 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id x64so14507178wmg.11
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:26:58 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id z44si6840622ede.201.2017.08.14.09.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 09:26:57 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id d40so14998920wma.3
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:26:57 -0700 (PDT)
Date: Mon, 14 Aug 2017 19:26:55 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: Fix personality(ADDR_NO_RANDOMIZE)
Message-ID: <20170814162655.5famb4r5e5epevhq@node.shutemov.name>
References: <20170814155719.74839-1-kirill.shutemov@linux.intel.com>
 <20170814161347.GO2005@uranus.lan>
 <20170814162002.GA9559@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814162002.GA9559@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Dmitry Safonov <dsafonov@virtuozzo.com>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable <stable@vger.kernel.org>

On Mon, Aug 14, 2017 at 06:20:02PM +0200, Oleg Nesterov wrote:
> On 08/14, Cyrill Gorcunov wrote:
> >
> > On Mon, Aug 14, 2017 at 06:57:19PM +0300, Kirill A. Shutemov wrote:
> > > In v4.12, during rework of infrastructure around mmap_base, disable-ASLR
> > > personality flag got accidentally broken.
> > >
> > > Let's make it work again.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Fixes: 1b028f784e8c ("x86/mm: Introduce mmap_compat_base() for 32-bit mmap()")
> > > Cc: stable <stable@vger.kernel.org> [4.12+]
> > > ---
> > >  arch/x86/mm/mmap.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > >
> > > diff --git a/arch/x86/mm/mmap.c b/arch/x86/mm/mmap.c
> > > index 229d04a83f85..779bdbe5e424 100644
> > > --- a/arch/x86/mm/mmap.c
> > > +++ b/arch/x86/mm/mmap.c
> > > @@ -127,6 +127,8 @@ static unsigned long mmap_legacy_base(unsigned long rnd,
> > >  static void arch_pick_mmap_base(unsigned long *base, unsigned long *legacy_base,
> > >  		unsigned long random_factor, unsigned long task_size)
> > >  {
> > > +	if (!(current->flags & PF_RANDOMIZE))
> > > +		random_factor = 0;
> > >  	*legacy_base = mmap_legacy_base(random_factor, task_size);
> > >  	if (mmap_is_legacy())
> > >  		*base = *legacy_base;
> >
> > Didn't Oleg's patch does the same?
> >
> > https://patchwork.kernel.org/patch/9832697/
> 
> at first glance yes, thanks Cyrill. And note that we do not need another
> PF_RANDOMIZE check.
> 
> > for some reason it's not yet merged.
> 
> because nobody cares ;)

Well, I do. :)

It took me few days to track down where huge variablity in micro benchmark
results comes from. :/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
