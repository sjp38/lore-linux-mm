From: Ulrich.Weigand@de.ibm.com
Message-ID: <C1256989.0066C1B8.00@d12mta01.de.ibm.com>
Date: Tue, 31 Oct 2000 19:42:21 +0100
Subject: Re: [PATCH] 2.4.0-test10-pre6 TLB flush race in establish_pte
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: slpratt@us.ibm.com, linux-kernel@vger.kernel.org, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



Andrea Arcangeli wrote:

>>On Mon, Oct 30, 2000 at 03:31:22PM -0600, Steve Pratt/Austin/IBM wrote:
>> [..] no patch ever
>> appeared. [..]
>
>You didn't followed l-k closely enough as the strict fix was submitted two
>times but it got not merged. (maybe because it had an #ifdef __s390__ that
was
>_necessary_ by that time?)


Unfortunately, the current code is racey even on the S/390.
We originally wanted to use the IPTE instruction to flush
a particular TLB entry, and this requires that the old PTE
value is still present at the time IPTE is performed.

Thus we wanted to place IPTE inside flush_tlb_page, and have
flush_tlb_page called before the new PTE is written.  However,
even with the current establish_pte routine this doesn't work,
as flush_tlb_page is called from several other places *after*
the PTE has been changed, so we still cannot actually use IPTE.

So, what we do now is simply flush the complete TLB in
flush_tlb_page, and don't use IPTE at all.  This is obviously
not ideal, but at least correct.  Except, that is, for the
race condition in establish_pte that we now share with the
other architectures :-/

IMO you should apply Steve's patch (without any #ifdef __s390__) now.
However, we'd like to look further for a more general solution
that would allow us to make use of IPTE again in the future.
This would possibly involve something like making establish_pte
architecture-specific.




Mit freundlichen Gruessen / Best Regards

Ulrich Weigand

--
  Dr. Ulrich Weigand
  Linux for S/390 Design & Development
  IBM Deutschland Entwicklung GmbH, Schoenaicher Str. 220, 71032 Boeblingen
  Phone: +49-7031/16-3727   ---   Email: Ulrich.Weigand@de.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
