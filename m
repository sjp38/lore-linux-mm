Date: Wed, 23 Oct 2002 10:55:25 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: install_page() lockup
Message-ID: <65490000.1035388525@baldur.austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0210230847190.2334-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0210230847190.2334-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@digeo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Wednesday, October 23, 2002 08:49:11 +0200 Ingo Molnar <mingo@elte.hu>
wrote:

> i added install_page() for fremap()'s purposes so i'd be surprised if
> anything else used it. I have shared-pte turned off in my tests, will try
> with it on as well.

As I sent in an earlier mail, I found the bug.  do_file_page needs to
unlock the pte_page_lock, not the page_table_lock.

If I understand the use of install_page correctly, I don't see a reason why
it should be calling pte_unshare.  If it's only installing pages from
existing shared regions it should leave the pte page shared.  The only
reason to call pte_unshare is if the vma for that mm has changed, making
the sharing decision invalid.  Am I missing how this is being used?

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
