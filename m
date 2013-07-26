Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 943F16B005C
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:18:48 -0400 (EDT)
Received: by mail-la0-f46.google.com with SMTP id es20so2729431lab.33
        for <linux-mm@kvack.org>; Fri, 26 Jul 2013 14:18:46 -0700 (PDT)
Date: Sat, 27 Jul 2013 01:18:44 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130726211844.GB8508@moon>
References: <20130726201807.GJ8661@moon>
 <CALCETrUJa-Y40vnb6YOPry0dCXb3zCQ0y19i2yHWdzKR75HUzg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUJa-Y40vnb6YOPry0dCXb3zCQ0y19i2yHWdzKR75HUzg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Fri, Jul 26, 2013 at 01:55:04PM -0700, Andy Lutomirski wrote:
> On Fri, Jul 26, 2013 at 1:18 PM, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> > Andy reported that if file page get reclaimed we loose soft-dirty bit
> > if it was there, so save _PAGE_BIT_SOFT_DIRTY bit when page address
> > get encoded into pte entry. Thus when #pf happens on such non-present
> > pte we can restore it back.
> >
> 
> Unless I'm misunderstanding this, it's saving the bit in the
> non-present PTE.  This sounds wrong -- what happens if the entire pmd

It's the same as encoding pgoff in pte entry (pte is not present),
but together with pgoff we save soft-bit status, later on #pf we decode
pgoff and restore softbit back if it was there, pte itself can't disappear
since it holds pgoff information.

> (or whatever the next level is called) gets zapped?  (Also, what
> happens if you unmap a file and map a different file there?)

If file pages are remapped to a new place we remember softdity
bit status previously has and propagate it to a new pte (as in
install_file_pte, old ptes are cleared).

If file unmapped then new one mapped, pmd/ptes are cleared
(including softbit) and it remains clear until new write
happens, if only i've not missed something obvious.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
