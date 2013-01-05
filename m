Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 5711E6B0070
	for <linux-mm@kvack.org>; Sat,  5 Jan 2013 07:24:46 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fb1so9771796pad.25
        for <linux-mm@kvack.org>; Sat, 05 Jan 2013 04:24:45 -0800 (PST)
Message-ID: <1357388687.9001.3.camel@kernel.cn.ibm.com>
Subject: Re: [PATCH] mm: thp: Acquire the anon_vma rwsem for lock during
 split
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sat, 05 Jan 2013 06:24:47 -0600
In-Reply-To: <CANN689E8S5mmszQoeaYgL_SYe1piBDTWCk-Gy1kxcg6hPfUPwA@mail.gmail.com>
References: <1621091901.34838094.1356409676820.JavaMail.root@redhat.com>
	 <535932623.34838584.1356410331076.JavaMail.root@redhat.com>
	 <20130103175737.GA3885@suse.de> <20130104140815.GA26005@suse.de>
	 <CANN689E8S5mmszQoeaYgL_SYe1piBDTWCk-Gy1kxcg6hPfUPwA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Mel Gorman <mgorman@suse.de>, Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Johannes Weiner <jweiner@redhat.com>, hughd@google.com, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Fri, 2013-01-04 at 17:32 -0800, Michel Lespinasse wrote:
> On Fri, Jan 4, 2013 at 6:08 AM, Mel Gorman <mgorman@suse.de> wrote:
> > Despite the reason for these commits, NUMA balancing is not the direct
> > source of the problem. split_huge_page() expected the anon_vma lock to be
> > exclusive to serialise the whole split operation. Ordinarily it is expected
> > that the anon_vma lock would only be required when updating the avcs but
> > THP also uses it. The locking requirements for THP are complex and there
> > is some overlap but broadly speaking they include the following
> >
> > 1. mmap_sem for read or write prevents THPs being created underneath
> > 2. anon_vma is taken for write if collapsing a huge page
> > 3. mm->page_table_lock should be taken when checking if pmd_trans_huge as
> >    split_huge_page can run in parallel
> > 4. wait_split_huge_page uses anon_vma taken for write mode to serialise
> >    against other THP operations
> > 5. compound_lock is used to serialise between
> >    __split_huge_page_refcount() and gup
> >
> > split_huge_page takes anon_vma for read but that does not serialise against
> > parallel split_huge_page operations on the same page (rule 2). One process
> > could be modifying the ref counts while the other modifies the page tables
> > leading to counters not being reliable. This patch takes the anon_vma
> > lock for write to serialise against parallel split_huge_page and parallel
> > collapse operations as it is the most fine-grained lock available that
> > protects against both.
> 
> Your comment about this being the most fine-grained lock made me
> think, couldn't we use lock_page() on the THP page here ?
> 
> Now I don't necessarily want to push you that direction, because I
> haven't fully thought it trough and because what you propose brings us
> closer to what happened before anon_vma became an rwlock, which is
> more obviously safe. But I felt I should still mention it, since we're
> really only trying to protect from concurrent operations on the same
> THP page, so locking at just that granularity would seem desirable.

Why you said that anon_vma lock who will protect page associated to a
list of vmas is fine-grained then page lock who just protect one page?

> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
