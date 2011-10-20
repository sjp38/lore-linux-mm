Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 81B4C6B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 20:39:40 -0400 (EDT)
Received: by yxs7 with SMTP id 7so2994249yxs.14
        for <linux-mm@kvack.org>; Wed, 19 Oct 2011 17:39:38 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 19 Oct 2011 17:39:37 -0700
Message-ID: <CALCETrXbPWsgaZmsvHZGEX-CxB579tG+zusXiYhR-13RcEnGvQ@mail.gmail.com>
Subject: Latency writing to an mlocked ext4 mapping
From: Andy Lutomirski <luto@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org

I have a real-time program that has everything mlocked (i.e.
mlockall(MCL_CURRENT | MCL_FUTURE)).  It has some log files opened for
writing.  Those files are opened and memset to zero in another thread
to fault everything in.  The system is under light I/O load with very
little memory pressure.

Latencytop shows frequent latency in the real-time threads.  The main
offenders are:

schedule sleep_on_page wait_on_page_bit ext4_page_mkwrite do_wp_page
handle_pte_fault handle_mm_fault do_page_fault page_fault

schedule do_get_write_access jbd2_journal_get_write_access
__ext4_journal_get_write_access ext4_reserve_inode_write
ext4_mark_inode_dirty ext4_dirty_inode __mark_inode_dirty
file_update_time do_wp_page handle_pte_fault handle_mm_fault


I imagine the problem is that the system is periodically writing out
my dirty pages and marking them clean (and hence write protected).
When I try to write to them, the kernel makes them writable again,
which causes latency either due to updating the inode mtime or because
the file is being written to disk when I try to write to it.

Is there any way to prevent this?  One possibility would be a way to
ask the kernel not to write the file out to disk.  Another would be a
way to ask the kernel to make a copy of the file when it writes it
disk and leave the original mapping writable.

Obviously I can fix this by mapping anonymous memory, but then I need
another thread to periodically write my logs out to disk, and if that
crashes, I lose data.

-- 
Andy Lutomirski
AMA Capital Management, LLC
Office: (310) 553-5322
Mobile: (650) 906-0647

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
