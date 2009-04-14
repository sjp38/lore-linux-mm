Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 2FC6A5F0001
	for <linux-mm@kvack.org>; Tue, 14 Apr 2009 10:26:21 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC][PATCH v3 1/6] mm: Don't unmap gup()ed page
Date: Wed, 15 Apr 2009 00:26:34 +1000
References: <20090414151204.C647.A69D9226@jp.fujitsu.com> <2f11576a0904140639l426e137ewdc46296cdb377dd@mail.gmail.com> <20090414141209.GB31644@random.random>
In-Reply-To: <20090414141209.GB31644@random.random>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200904150026.36142.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 15 April 2009 00:12:09 Andrea Arcangeli wrote:
> On Tue, Apr 14, 2009 at 10:39:54PM +0900, KOSAKI Motohiro wrote:
> > I guess you dislike get_user_page_fast() grab pte_lock too, right?
> 
> If get_user_page_fast is vetoed to run a set_bit on the already cache
> hot and exclusive struct page, I doubt taking a potentially cache
> cold, mm-wide or pmd-wide pte_lock is ok.

Yes, I'd *really* rather not. I actually implemented gup_fast in
response to problem reported with DB2 workload hitting the ptl
(and not the more obvious mmap_sem, although certainly they had
some gain from removing that cacheline as well).

gup_fast iirc is worth nearly 10% on a 4 socket x86 system with
DB2. That's the same order of magnitude as the speedups quoted
to justify the addition of hugepages, or O_DIRECT itself.

Andrea: I didn't veto that set_bit change of yours as such. I just
noted there could be more atomic operations. Actually I would
welcome more comparison between our two approaches, but they seem
to be stuck with Linus refusing (I think) to copy the page at
fork() time :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
