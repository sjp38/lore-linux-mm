Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 5FA376B004D
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 18:16:34 -0500 (EST)
Date: Wed, 4 Jan 2012 15:16:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: hugetlb: undo change to page mapcount in fault
 handler
Message-Id: <20120104151632.05e6b3b0.akpm@linux-foundation.org>
In-Reply-To: <CAJd=RBBY0sKdtdx9d8KXTchjaN6au0_hvMfE2+9JkdhvJe7eAw@mail.gmail.com>
References: <CAJd=RBBF=K5hHvEwb6uwZJwS4=jHKBCNYBTJq-pSbJ9j_ZaiaA@mail.gmail.com>
	<20111222163604.GB14983@tiehlicka.suse.cz>
	<CAJd=RBBY0sKdtdx9d8KXTchjaN6au0_hvMfE2+9JkdhvJe7eAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, 23 Dec 2011 21:00:41 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> Page mapcount should be updated only if we are sure that the page ends
> up in the page table otherwise we would leak if we couldn't COW due to
> reservations or if idx is out of bounds.

It would be much nicer if we could run vma_needs_reservation() before
even looking up or allocating the page.

And afaict the interface is set up to do that: you run
vma_needs_reservation() before allocating the page and then
vma_commit_reservation() afterwards.

But hugetlb_no_page() and hugetlb_fault() appear to have forgotten to
run vma_commit_reservation() altogether.  Why isn't this as busted as
it appears to be?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
