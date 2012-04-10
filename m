Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 49DD36B004A
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 21:04:17 -0400 (EDT)
Received: by iajr24 with SMTP id r24so8943014iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 18:04:16 -0700 (PDT)
Date: Mon, 9 Apr 2012 18:04:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC] mm: account VMA before forced-COW via
 /proc/pid/mem
In-Reply-To: <20120407173318.GA5076@redhat.com>
Message-ID: <alpine.LSU.2.00.1204091734530.2079@eggly.anvils>
References: <20120402153631.5101.44091.stgit@zurg> <20120403143752.GA5150@redhat.com> <4F7C1B67.6030300@openvz.org> <20120404154148.GA7105@redhat.com> <4F7D5859.5050106@openvz.org> <alpine.LSU.2.00.1204062104090.4297@eggly.anvils>
 <20120407173318.GA5076@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roland Dreier <roland@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sat, 7 Apr 2012, Oleg Nesterov wrote:
> On 04/06, Hugh Dickins wrote:
> >
> > I've long detested that behaviour of GUP write,force, and my strong
> > preference would be not to layer more strangeness upon strangeness,
> > but limit the damage by making GUP write,force fail in that case,
> > instead of inserting a PageAnon page into a VM_SHARED mapping.

Let me reiterate here that I was off at a tangent in bringing this up,
so sorry for any confusion I spread.

> >
> > I think it's unlikely that it will cause a regression in real life
> > (it already fails if you did not open the mmap'ed file for writing),
> 
> Yes, and this is what looks confusing to me. Assuming I understand
> you (and the code) correctly ;)
> 
> If we have a (PROT_READ, MAP_SHARED) file mapping, then FOLL_FORCE
> works depending on "file->f_mode & FMODE_WRITE".
> 
> Afaics, because do_mmap_pgoff(MAP_SHARED) clears VM_MAYWRITE if
> !FMODE_WRITE, and gup(FORCE) checks "vma->vm_flags & VM_MAYWRITE"
> before follow_page/etc.
> 
> OTOH, if the file was opened without FMODE_WRITE, then I do not
> really understand how (PROT_READ, MAP_SHARED) differs from
> (PROT_READ, MAP_PRIVATE).

For normal msyscalls(), !FMODE_WRITE PROT_READ,MAP_SHARED and
PROT_READ,MAP_PRIVATE behave much the same: the difference is that
you can mprotect(PROT_WRITE) the MAP_PRIVATE one, but you cannot
mprotect(PROT_WRITE) the MAP_SHARED - because writes to the latter
would go to the file, and you don't have permission for that.

> However, in the latter case FOLL_FORCE
> works, VM_MAYWRITE was not cleared.

When it comes to __get_user_pages(), FOLL_FORCE allows you to
read from or write to an area to which you don't at present have
read or write access, but could be mprotect()ed to give you that
access (whereas !FOLL_FORCE respects the current mprotection).

So FOLL_FORCE allows reading from any mapped area, even PROT_NONE;
and FOLL_FORCE allows writing to any MAP_PRIVATE area, and writing
to any MAP_SHARED area whose file had been opened with FMODE_WRITE.

The strange weird confusing part is that having checked that you have
permission to write to the file, it then avoids doing so (unless the
area currently has PROT_WRITE): it COWs pages for you instead,
leaving unexpected anon pages in the shared area.

This is believed to be a second line of defence when setting
breakpoints, in case the executable file happened to  have been opened
for writing, to prevent those breakpoints getting back into the file.

> 
> Speaking of the difference above, I'd wish I could understand
> what VM_MAYSHARE actually means except "MAP_SHARED was used".

That's precisely it: so it's very useful in /proc/pid/maps, for
deciding whether to show an 's' or a 'p', but not so often when
real decisions are made (where, as you've observed, private readonly
and shared readonly are treated very similarly, without VM_SHARED).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
