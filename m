Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id B06FB6B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:15:01 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id ib11so2568265vcb.14
        for <linux-mm@kvack.org>; Mon, 26 Aug 2013 16:15:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LNX.2.00.1308261448490.4982@eggly.anvils>
References: <20130807153030.GA25515@redhat.com>
	<CAJd=RBCyZU8PR7mbFUdKsWq3OH+5HccEWKMEH5u7GNHNy3esWg@mail.gmail.com>
	<20130819231836.GD14369@redhat.com>
	<CAJd=RBA-UZmSTxNX63Vni+UPZBHwP4tvzE_qp1ZaHBqcNG7Fcw@mail.gmail.com>
	<20130821204901.GA19802@redhat.com>
	<CAJd=RBBNCf5_V-nHjK0gOqS4OLMszgB7Rg_WMf4DvL-De+ZdHA@mail.gmail.com>
	<20130823032127.GA5098@redhat.com>
	<CAJd=RBArkh3sKVoOJUZBLngXtJubjx4-a3G6s7Tn0N=Pr1gU4g@mail.gmail.com>
	<20130823035344.GB5098@redhat.com>
	<CAJd=RBBtY-nJfo9nzG5gtgcvB2bz+sxpK5kX33o1sLeLhvEU1Q@mail.gmail.com>
	<20130826190757.GB27768@redhat.com>
	<CA+55aFw_bhMOP73owFHRFHZDAYEdWgF9j-502Aq9tZe3tEfmwg@mail.gmail.com>
	<CA+55aFwQbJbR3xij1+iGbvj3EQggF9NLGAfDbmA54FkKz9xfew@mail.gmail.com>
	<alpine.LNX.2.00.1308261448490.4982@eggly.anvils>
Date: Mon, 26 Aug 2013 16:15:00 -0700
Message-ID: <CA+55aFyPbSjVbE4v4ak_GEbA0Mn3T5ZcC6CFs-jfKfMkbC+qNw@mail.gmail.com>
Subject: Re: unused swap offset / bad page map.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Hillf Danton <dhillf@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

On Mon, Aug 26, 2013 at 3:08 PM, Hugh Dickins <hughd@google.com> wrote:
>
> I just did a quick diff of 3.11-rc7/mm against 3.10, and here's
> a line in mremap which worries me.  That set_pte_at() is operating
> on anything that isn't pte_none(), so the pte_mksoft_dirty() looks
> prone to corrupt a swap entry.

Uhhuh. I think you hit the nail on the head here.

I checked all the pte_swp_*soft_dirty() users (they should be used on
swp entries), because that came up in another thread. But you're
right, the non-swp ones only work on present pte entries (or on
file-offset entries, I guess), and at least that mremap() case seems
bogus.

I'm not seeing the point of marking the thing soft-dirty at all,
although I guess it's "dirty" in the sense that it changed the
contents at that virtual address. But for that code to work, it would
have to have the same bit for swap entries as for present pages (and
for file mapping entries), and that's not true. They are two different
bits (_PAGE_SOFT_DIRTY is bit #11 vs _PAGE_SWP_SOFT_DIRTY is bit #7).

Ugh. Cyrill, this is a mess.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
