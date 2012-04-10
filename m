Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 693F46B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 20:34:52 -0400 (EDT)
Received: by iajr24 with SMTP id r24so8903196iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 17:34:51 -0700 (PDT)
Date: Mon, 9 Apr 2012 17:34:29 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC] mm: account VMA before forced-COW via
 /proc/pid/mem
In-Reply-To: <4F7FCC8A.6050707@openvz.org>
Message-ID: <alpine.LSU.2.00.1204091648490.2079@eggly.anvils>
References: <20120402153631.5101.44091.stgit@zurg> <20120403143752.GA5150@redhat.com> <4F7C1B67.6030300@openvz.org> <20120404154148.GA7105@redhat.com> <4F7D5859.5050106@openvz.org> <alpine.LSU.2.00.1204062104090.4297@eggly.anvils>
 <4F7FCC8A.6050707@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Roland Dreier <roland@kernel.org>, Stephen Wilson <wilsons@start.ca>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sat, 7 Apr 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > 
> > I've long detested that behaviour of GUP write,force, and my strong
> > preference would be not to layer more strangeness upon strangeness,
> > but limit the damage by making GUP write,force fail in that case,
> > instead of inserting a PageAnon page into a VM_SHARED mapping.
> > 
> > I think it's unlikely that it will cause a regression in real life
> > (it already fails if you did not open the mmap'ed file for writing),
> > but it would be a user-visible change in behaviour, and I've research
> > to do before arriving at a conclusion.
> 
> Agree, but this stuff is very weak. Even if sysctl vm.overcommit_memory=2,
> probably we should fixup accounting in /proc/pid/mem only for this case,
> because vm.overcommit_memory=2 supposed to protect against overcommit, but it
> does not.

You are right (and it's not the first time I've had to say so!).

At first I was puzzled by your answer, then went back to your initial
mail, which clearly says "Currently kernel does not account read-only
private mappings into memory commitment.  But these mappings can be
force-COW-ed in get_user_pages()" and realized (a) that I'd forgotten
about that weakness in the overcommit stuff, and (b) that I'd therefore
let my obsession with the anon-in-shared issue blind me to what you were
actually saying.  "private", yes, sorry about that.  Let's set aside the
shared issue for the moment, then, though I'll need to answer Oleg after
(and writing to /proc/pid/mem makes that more serious than before too).

Yes, GUP force-write into private-readonly can violate no-overcommit.

Force-write was originally intended just for setting breakpoints with
ptrace(2), and we've taken the view that fixing the no-overcommit issue
is simply more trouble than it's worth.  But I agree with you that once
writing to /proc/pid/mem was enabled a year ago, it became a more serious
defect: I don't think /proc/pid/mem makes anything new possible, but it
does make it easier - I imagine dd(1) could achieve the same as your
little program.

I was hoping to find that writing to /proc/pid/mem was enabled solely
because "why not?", and the 198214a7ee commit message does suggest so;
but I see there was a 0/12 mail which never reached git, which makes
clear that it was intended for debuggers to use instead of ptrace(2).
So I think my first reaction, to disallow write-force on readonly via
/proc/pid/mem, would not be helpful.

I think all solutions to this are unsatifactory, and most ugly.
I'd better pull up your original mail to review in detail, but I'd
say yours is no exception: ugly and unsatisfactory, but quite possibly
less ugly and less unsatisfactory than most.  I was quite happy to be
doing nothing at all about this, but now that you've raised the matter,
I can understand that you won't want it to rest there.

Of course, the issue can be dealt with by an additional data structure;
but extending vm_area_struct or anon_vma (if only by one usually-NULL
pointer), and adding the code to handle it, would itself be
unsatisfactory - and I guess you felt the same.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
