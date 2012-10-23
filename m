Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 594866B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 18:59:22 -0400 (EDT)
Date: Tue, 23 Oct 2012 15:59:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-Id: <20121023155915.7d5ef9d1.akpm@linux-foundation.org>
In-Reply-To: <20121023070018.GA18381@otc-wbsnb-06>
References: <1350280859-18801-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1350280859-18801-11-git-send-email-kirill.shutemov@linux.intel.com>
	<20121018164502.b32791e7.akpm@linux-foundation.org>
	<20121018235941.GA32397@shutemov.name>
	<20121023063532.GA15870@shutemov.name>
	<20121022234349.27f33f62.akpm@linux-foundation.org>
	<20121023070018.GA18381@otc-wbsnb-06>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Tue, 23 Oct 2012 10:00:18 +0300
"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> > Well, how hard is it to trigger the bad behavior?  One can easily
> > create a situation in which that page's refcount frequently switches
> > from 0 to 1 and back again.  And one can easily create a situation in
> > which the shrinkers are being called frequently.  Run both at the same
> > time and what happens?
> 
> If the goal is to trigger bad behavior then:
> 
> 1. read from an area where a huge page can be mapped to get huge zero page
>    mapped. hzp is allocated here. refcounter == 2.
> 2. write to the same page. refcounter == 1.
> 3. echo 3 > /proc/sys/vm/drop_caches. refcounter == 0 -> free the hzp.
> 4. goto 1.
> 
> But it's unrealistic. /proc/sys/vm/drop_caches is only root-accessible.

Yes, drop_caches is uninteresting.

> We can trigger shrinker only under memory pressure. But in this, most
> likely we will get -ENOMEM on hzp allocation and will go to fallback path
> (4k zero page).

I disagree.  If, for example, there is a large amount of clean
pagecache being generated then the shrinkers will be called frequently
and memory reclaim will be running at a 100% success rate.  The
hugepage allocation will be successful in such a situation?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
