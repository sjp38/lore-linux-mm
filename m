Date: Fri, 12 Mar 2004 19:46:01 +0000
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH] 2.6.4-rc2-mm1: vm-split-active-lists
Message-ID: <20040312194601.GE18799@mail.shareable.org>
References: <OF9DC8F5B1.0044A21E-ON86256E55.004DF368@raytheon.com> <4051C8BF.1050001@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4051C8BF.1050001@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Mark_H_Johnson@Raytheon.com, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mfedyk@matchmail.com, m.c.p@wolk-project.de, owner-linux-mm@kvack.org, plate@gmx.tm
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> One thing you could do is re read swapped pages when you have
> plenty of free memory and the disks are idle.

Better: re-read swapped pages _and_ file-backed pages that are likely
to be used in future, when you have plenty of free memory and the
disks are idle.

updatedb would push plenty of memory out overnight.  But after the
cron jobs and before people wake up in the morning, the kernel would
gradually re-read the pages corresponding to mapped regions in
processes.  Possibly with emphasis on some processes more than others.
Possibly remembering some of that likelihood information even when a
particular executable isn't currently running.

During the day, after a big compile the kernel would gradually re-read
pages for processes which are running on your desktop but which you're
not actively using.  The editor you were using during the compile will
still be responsive because it wasn't swapped out.  The Nautilus or
Mozilla that you weren't using will appear responsive when you switch
to it, because the kernel was re-reading their mapped pages after the
compile, while you didn't notice because you were still using the
editor.

The intention is to avoid those long stalls where you switch to a
Mozilla window and it takes 30 seconds to page in all those libraries
randomly.  It's not necessary to keep Mozilla in memory all the time,
even when the memory is specifically useful for a compile, to provide
that illusion of snappy response most of the time.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
