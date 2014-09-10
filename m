Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0176B0081
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 15:41:08 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so6332906pad.23
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 12:41:07 -0700 (PDT)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id rf9si12587914pbc.221.2014.09.10.12.41.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 12:41:07 -0700 (PDT)
Message-ID: <1410377428.28990.260.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 2/6] x86, mm, pat: Change reserve_memtype() to handle
 WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 10 Sep 2014 13:30:28 -0600
In-Reply-To: <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
References: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
	 <1410367910-6026-3-git-send-email-toshi.kani@hp.com>
	 <CALCETrXRjU3HvHogpm5eKB3Cogr5QHUvE67JOFGbOmygKYEGyA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Yigal Korman <yigal@plexistor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Wed, 2014-09-10 at 11:26 -0700, Andy Lutomirski wrote:
> On Wed, Sep 10, 2014 at 9:51 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> > This patch changes reserve_memtype() to handle the WT cache mode.
> > When PAT is not enabled, it continues to set UC- to *new_type for
> > any non-WB request.
> >
> > When a target range is RAM, reserve_ram_pages_type() fails for WT
> > for now.  This function may not reserve a RAM range for WT since
> > reserve_ram_pages_type() uses the page flags limited to three memory
> > types, WB, WC and UC.
> 
> Should it fail if WT is unavailable due to errata?  More generally,
> how are all of the do_something_wc / do_something_wt /
> do_something_nocache helpers supposed to handle unsupported types?

When WT is unavailable due to the PAT errata, it does not fail but gets
redirected to UC-.  Similarly, when PAT is disabled, WT gets redirected
to UC- as well.

The failure case above is a run-time error when WT is enabled and is
targeted to RAM.  In this case, reserve_memtype() fails and sets UC- to
*new_type due to the limitation in page tables.  set_memory_xzy()
interfaces do not retry with new_type, but return an error.  I think
this makes sense since the caller should receive this error as this case
is a bug in the code (while running it on an old system is not a bug).

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
