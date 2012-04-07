Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 1E05F6B004A
	for <linux-mm@kvack.org>; Sat,  7 Apr 2012 13:33:41 -0400 (EDT)
Date: Sat, 7 Apr 2012 19:33:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH RFC] mm: account VMA before forced-COW via /proc/pid/mem
Message-ID: <20120407173318.GA5076@redhat.com>
References: <20120402153631.5101.44091.stgit@zurg> <20120403143752.GA5150@redhat.com> <4F7C1B67.6030300@openvz.org> <20120404154148.GA7105@redhat.com> <4F7D5859.5050106@openvz.org> <alpine.LSU.2.00.1204062104090.4297@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1204062104090.4297@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roland Dreier <roland@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 04/06, Hugh Dickins wrote:
>
> I've long detested that behaviour of GUP write,force, and my strong
> preference would be not to layer more strangeness upon strangeness,
> but limit the damage by making GUP write,force fail in that case,
> instead of inserting a PageAnon page into a VM_SHARED mapping.
>
> I think it's unlikely that it will cause a regression in real life
> (it already fails if you did not open the mmap'ed file for writing),

Yes, and this is what looks confusing to me. Assuming I understand
you (and the code) correctly ;)

If we have a (PROT_READ, MAP_SHARED) file mapping, then FOLL_FORCE
works depending on "file->f_mode & FMODE_WRITE".

Afaics, because do_mmap_pgoff(MAP_SHARED) clears VM_MAYWRITE if
!FMODE_WRITE, and gup(FORCE) checks "vma->vm_flags & VM_MAYWRITE"
before follow_page/etc.

OTOH, if the file was opened without FMODE_WRITE, then I do not
really understand how (PROT_READ, MAP_SHARED) differs from
(PROT_READ, MAP_PRIVATE). However, in the latter case FOLL_FORCE
works, VM_MAYWRITE was not cleared.

Speaking of the difference above, I'd wish I could understand
what VM_MAYSHARE actually means except "MAP_SHARED was used".

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
