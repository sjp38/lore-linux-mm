From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200102150150.RAA62793@google.engr.sgi.com>
Subject: x86 ptep_get_and_clear question
Date: Wed, 14 Feb 2001 17:50:05 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: bcrl@redhat.com, mingo@redhat.com, alan@redhat.com
List-ID: <linux-mm.kvack.org>

I would like to understand how ptep_get_and_clear() works for x86 on
2.4.1.

I am assuming on x86, we do not implement software dirty bit, as is
implemented in the mips processors. Rather, the kernel relies on the
x86 hardware to update the dirty bit automatically (from looking at 
the implementation of pte_mkwrite()).

Say I have processors 1 and 2. Say both processors have pulled in the 
mapping into their tlbs.

processor 1 is doing change_pte_range(), as an exmaple. It does the
ptep_get_and_clear(pte), which atomically reads the hardware managed
dirty bit, then clears the pte in memory. Now say processor 2 dirties
the page, and I am not sure what will happen. One possibility is that
processor 2 will see in its tlb that the page hasn't been dirtied on 
that processor yet, so then it will go look into the in-memory copy,
see that the pte is not marked dirty, and hence will mark the pte 
dirty. Thus, this dirty bit update is lost. Hence, ptep_get_and_clear()
isn't doing what I assume it was designed to do (from the comments in
mm/mprotect.c) (There are alternative fixes possible)

The other possibility of course is that somehow processor 2 will interlock
out (via hardware), processor 1 will do the flush_tlb_range() out of 
change_protection(), and then processor 1 will continue. If this is 
the assumption, I would like to know if this is in some Intel x86 specs.

Am I missing something?

I am assuming Ben Lahaise wrote this code. I remember having an earlier 
conversation with Alan about this too (we did not know which scenario 
could happen), who suggested I ask Ingo. I do not remember what happened
after that.

Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
