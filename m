Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBAC8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 23:25:10 -0400 (EDT)
Date: Wed, 30 Mar 2011 05:25:04 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH]mmap: avoid unnecessary anon_vma lock
Message-ID: <20110330032504.GD21838@one.firstfloor.org>
References: <1301277532.3981.25.camel@sli10-conroe> <m2fwq718u4.fsf@firstfloor.org> <20110329153517.3b87842f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110329153517.3b87842f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Tue, Mar 29, 2011 at 03:35:17PM -0700, Andrew Morton wrote:
> On Mon, 28 Mar 2011 09:57:39 -0700
> Andi Kleen <andi@firstfloor.org> wrote:
> 
> > Shaohua Li <shaohua.li@intel.com> writes:
> > 
> > > If we only change vma->vm_end, we can avoid taking anon_vma lock even 'insert'
> > > isn't NULL, which is the case of split_vma.
> > > From my understanding, we need the lock before because rmap must get the
> > > 'insert' VMA when we adjust old VMA's vm_end (the 'insert' VMA is linked to
> > > anon_vma list in __insert_vm_struct before).
> > > But now this isn't true any more. The 'insert' VMA is already linked to
> > > anon_vma list in __split_vma(with anon_vma_clone()) instead of
> > > __insert_vm_struct. There is no race rmap can't get required VMAs.
> > > So the anon_vma lock is unnecessary, and this can reduce one locking in brk
> > > case and improve scalability.
> > 
> > Looks good to me.
> 
> Looks way too tricky to me.
> 
> Please review this code for maintainability.  Have we documented what
> we're doing as completely and as clearly as we are able?

I agree the comments could be improved, but the code change looked good
to me. I don't think it impacts maintainability by itself because
we already do similar magic.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
