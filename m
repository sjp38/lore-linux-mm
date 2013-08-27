Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id B425E6B006C
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 01:44:32 -0400 (EDT)
Received: by mail-lb0-f179.google.com with SMTP id v1so3159702lbd.10
        for <linux-mm@kvack.org>; Mon, 26 Aug 2013 22:44:30 -0700 (PDT)
Date: Tue, 27 Aug 2013 09:44:28 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: unused swap offset / bad page map.
Message-ID: <20130827054428.GB7416@moon>
References: <CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
 <20130823032127.GA5098@redhat.com>
 <CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
 <20130823035344.GB5098@redhat.com>
 <CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
 <20130826190757.GB27768@redhat.com>
 <CA+55aFw_bhMOP73owFHRFHZDAYEdWgF9j-502Aq9tZe3tEfmwg@mail.gmail.com>
 <CA+55aFwQbJbR3xij1+iGbvj3EQggF9NLGAfDbmA54FkKz9xfew@mail.gmail.com>
 <alpine.LNX.2.00.1308261448490.4982@eggly.anvils>
 <CA+55aFyPbSjVbE4v4ak_GEbA0Mn3T5ZcC6CFs-jfKfMkbC+qNw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyPbSjVbE4v4ak_GEbA0Mn3T5ZcC6CFs-jfKfMkbC+qNw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Dave Jones <davej@redhat.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>

On Mon, Aug 26, 2013 at 04:15:00PM -0700, Linus Torvalds wrote:
> On Mon, Aug 26, 2013 at 3:08 PM, Hugh Dickins <hughd@google.com> wrote:
> >
> > I just did a quick diff of 3.11-rc7/mm against 3.10, and here's
> > a line in mremap which worries me.  That set_pte_at() is operating
> > on anything that isn't pte_none(), so the pte_mksoft_dirty() looks
> > prone to corrupt a swap entry.
> 
> Uhhuh. I think you hit the nail on the head here.
> 
> I checked all the pte_swp_*soft_dirty() users (they should be used on
> swp entries), because that came up in another thread. But you're
> right, the non-swp ones only work on present pte entries (or on
> file-offset entries, I guess), and at least that mremap() case seems
> bogus.

Oh my :( Indeed it sets _PAGE_SOFT_DIRTY unconditionally, sigh. This
nit comes from former soft-dirty commit. Let me check all other places
we set soft dirty bit (Pavel CC'ed).

> I'm not seeing the point of marking the thing soft-dirty at all,
> although I guess it's "dirty" in the sense that it changed the
> contents at that virtual address. But for that code to work, it would
> have to have the same bit for swap entries as for present pages (and
> for file mapping entries), and that's not true. They are two different
> bits (_PAGE_SOFT_DIRTY is bit #11 vs _PAGE_SWP_SOFT_DIRTY is bit #7).
> 
> Ugh. Cyrill, this is a mess.

Linus, I simply had no place in pte entry to carry soft-dirty status
when pte incoded in swap format, so it was unpleasant but necessary
decision. That's why bits access are wrapped in own macros with
'swp' prefix thus reader would easily grep for them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
