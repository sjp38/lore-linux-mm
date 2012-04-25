Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id A69536B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 17:01:33 -0400 (EDT)
Received: by iajr24 with SMTP id r24so844523iaj.14
        for <linux-mm@kvack.org>; Wed, 25 Apr 2012 14:01:33 -0700 (PDT)
Date: Wed, 25 Apr 2012 14:01:29 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] thp, memcg: split hugepage for memcg oom on cow
In-Reply-To: <alpine.DEB.2.00.1204231612060.17030@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1204251359440.29822@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1204031854530.30629@chino.kir.corp.google.com> <4F838385.9070309@jp.fujitsu.com> <alpine.DEB.2.00.1204092241180.27689@chino.kir.corp.google.com> <alpine.DEB.2.00.1204092242050.27689@chino.kir.corp.google.com> <20120411142023.GB1789@redhat.com>
 <alpine.DEB.2.00.1204231612060.17030@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

On Mon, 23 Apr 2012, David Rientjes wrote:

> > Can you instead put a __split_huge_page_pmd(mm, pmd) here?  It has to
> > redo the get-page-ref-through-pagetable dance, but it's more robust
> > and obvious than splitting the COW page before returning OOM in the
> > thp wp handler.
> > 
> 
> I agree it's more robust if do_huge_pmd_wp_page() were modified later and 
> mistakenly returned VM_FAULT_OOM without the page being split, but 
> __split_huge_page_pmd() has the drawback of also requiring to retake 
> mm->page_table_lock to test whether orig_pmd is still legitimate so it 
> will be slower.  Do you feel strongly about the way it's currently written 
> which will be faster at runtime?
> 

Andrew, please merge this patch.  I'd rather not unnecessarily take 
another reference on the cow page and unnecessarily take 
mm->page_table_lock in the page fault handler so the code is cleaner.  
It's faster this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
