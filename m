Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 541866B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 21:42:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so188816663pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 18:42:13 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id ai2si6077395pad.98.2016.07.14.18.42.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jul 2016 18:42:12 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id t190so5560060pfb.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 18:42:12 -0700 (PDT)
Date: Fri, 15 Jul 2016 11:41:51 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH v2 02/11] mm: Hardened usercopy
Message-ID: <20160715014151.GA13944@balbir.ozlabs.ibm.com>
Reply-To: bsingharora@gmail.com
References: <1468446964-22213-1-git-send-email-keescook@chromium.org>
 <1468446964-22213-3-git-send-email-keescook@chromium.org>
 <20160714232019.GA28254@350D>
 <1468544658.30053.26.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1468544658.30053.26.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: bsingharora@gmail.com, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

On Thu, Jul 14, 2016 at 09:04:18PM -0400, Rik van Riel wrote:
> On Fri, 2016-07-15 at 09:20 +1000, Balbir Singh wrote:
> 
> > > ==
> > > +		   ((unsigned long)end & (unsigned
> > > long)PAGE_MASK)))
> > > +		return NULL;
> > > +
> > > +	/* Allow if start and end are inside the same compound
> > > page. */
> > > +	endpage = virt_to_head_page(end);
> > > +	if (likely(endpage == page))
> > > +		return NULL;
> > > +
> > > +	/* Allow special areas, device memory, and sometimes
> > > kernel data. */
> > > +	if (PageReserved(page) && PageReserved(endpage))
> > > +		return NULL;
> > 
> > If we came here, it's likely that endpage > page, do we need to check
> > that only the first and last pages are reserved? What about the ones
> > in
> > the middle?
> 
> I think this will be so rare, we can get away with just
> checking the beginning and the end.
>

But do we want to leave a hole where an aware user space
can try a longer copy_* to avoid this check? If it is unlikely
should we just bite the bullet and do the check for the entire
range?

Balbir Singh. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
