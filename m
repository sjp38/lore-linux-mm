Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8B1096B0070
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 17:46:41 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rr13so55280pbb.28
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 14:46:41 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id qe5si17106805pbc.324.2014.04.22.14.46.40
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 14:46:40 -0700 (PDT)
Message-ID: <5356E33F.3000908@intel.com>
Date: Tue, 22 Apr 2014 14:46:39 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Dirty/Access bits vs. page content
References: <1398032742.19682.11.camel@pasglop>	<CA+55aFz1sK+PF96LYYZY7OB7PBpxZu-uNLWLvPiRz-tJsBqX3w@mail.gmail.com>	<1398054064.19682.32.camel@pasglop>	<1398057630.19682.38.camel@pasglop>	<CA+55aFwWHBtihC3w9E4+j4pz+6w7iTnYhTf4N3ie15BM9thxLQ@mail.gmail.com>	<53558507.9050703@zytor.com>	<CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>	<53559F48.8040808@intel.com>	<CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>	<CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>	<20140422075459.GD11182@twins.programming.kicks-ass.net> <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
In-Reply-To: <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>

On 04/22/2014 02:36 PM, Linus Torvalds wrote:
> That said, Dave Hansen did report a BUG_ON() in
> mpage_prepare_extent_to_map(). His line number was odd, but I assume
> it's this one:
> 
>         BUG_ON(PageWriteback(page));
> 
> which may be indicative of some oddity here wrt the dirty bit.

I just triggered it a second time.  It only happens with my debugging
config[1] *and* those two fix patches.  It doesn't happen on the vanilla
kernel with lost dirty bit.

The line numbers point to the

	head = page_buffers(page);

which is:

#define page_buffers(page)                                      \
        ({                                                      \
                BUG_ON(!PagePrivate(page));                     \
                ((struct buffer_head *)page_private(page));     \
        })

1.
http://sr71.net/~dave/intel/20140422-lostdirtybit/config-ext4-bugon.20140422
Config that doesn't trigger it:
http://sr71.net/~dave/intel/20140422-lostdirtybit/config-ext4-nobug.20140422





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
