Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C67B06B002D
	for <linux-mm@kvack.org>; Wed, 19 Oct 2011 21:01:53 -0400 (EDT)
References: <CALCETrXbPWsgaZmsvHZGEX-CxB579tG+zusXiYhR-13RcEnGvQ@mail.gmail.com>
In-Reply-To: <CALCETrXbPWsgaZmsvHZGEX-CxB579tG+zusXiYhR-13RcEnGvQ@mail.gmail.com>
Mime-Version: 1.0 (iPhone Mail 8L1)
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <ACE78D84-0E94-4E7A-99BF-C20583018697@dilger.ca>
Content-Transfer-Encoding: quoted-printable
From: Andreas Dilger <adilger@dilger.ca>
Subject: Re: Latency writing to an mlocked ext4 mapping
Date: Wed, 19 Oct 2011 19:02:46 -0600
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

What kernel are you using?  A change to keep pages consistent during writeou=
t was landed not too long ago (maybe Linux 3.0) in order to allow checksummi=
ng of the data.=20

We discussed doing copy-on-write, but there are relatively few mmap users an=
d it wasn't clear whether the complexity was worth it.=20

Cheers, Andreas

On 2011-10-19, at 6:39 PM, Andy Lutomirski <luto@amacapital.net> wrote:

> I have a real-time program that has everything mlocked (i.e.
> mlockall(MCL_CURRENT | MCL_FUTURE)).  It has some log files opened for
> writing.  Those files are opened and memset to zero in another thread
> to fault everything in.  The system is under light I/O load with very
> little memory pressure.
>=20
> Latencytop shows frequent latency in the real-time threads.  The main
> offenders are:
>=20
> schedule sleep_on_page wait_on_page_bit ext4_page_mkwrite do_wp_page
> handle_pte_fault handle_mm_fault do_page_fault page_fault
>=20
> schedule do_get_write_access jbd2_journal_get_write_access
> __ext4_journal_get_write_access ext4_reserve_inode_write
> ext4_mark_inode_dirty ext4_dirty_inode __mark_inode_dirty
> file_update_time do_wp_page handle_pte_fault handle_mm_fault
>=20
>=20
> I imagine the problem is that the system is periodically writing out
> my dirty pages and marking them clean (and hence write protected).
> When I try to write to them, the kernel makes them writable again,
> which causes latency either due to updating the inode mtime or because
> the file is being written to disk when I try to write to it.
>=20
> Is there any way to prevent this?  One possibility would be a way to
> ask the kernel not to write the file out to disk.  Another would be a
> way to ask the kernel to make a copy of the file when it writes it
> disk and leave the original mapping writable.
>=20
> Obviously I can fix this by mapping anonymous memory, but then I need
> another thread to periodically write my logs out to disk, and if that
> crashes, I lose data.
>=20
> --=20
> Andy Lutomirski
> AMA Capital Management, LLC
> Office: (310) 553-5322
> Mobile: (650) 906-0647
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
