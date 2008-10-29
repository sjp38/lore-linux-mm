Received: by wa-out-1112.google.com with SMTP id j37so1958990waf.22
        for <linux-mm@kvack.org>; Wed, 29 Oct 2008 00:17:19 -0700 (PDT)
Message-ID: <2f11576a0810290017g310e4469gd27aa857866849bd@mail.gmail.com>
Date: Wed, 29 Oct 2008 16:17:19 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] lru_add_drain_all() don't use schedule_on_each_cpu()
In-Reply-To: <1225229366.6343.74.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <2f11576a0810210851g6e0d86benef5d801871886dd7@mail.gmail.com>
	 <2f11576a0810211018g5166c1byc182f1194cfdd45d@mail.gmail.com>
	 <20081023235425.9C40.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20081027145509.ebffcf0e.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0810280914010.15939@quilx.com>
	 <20081028134536.9a7a5351.akpm@linux-foundation.org>
	 <1225229366.6343.74.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, npiggin@suse.de, linux-kernel@vger.kernel.org, hugh@veritas.com, torvalds@linux-foundation.org, riel@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I believe that we still  have the lru_drain_all() called from the fault
> path [with mmap_sem held] in clear_page_mlock().  We call
> clear_page_mlock() on COW of an mlocked page in a VM_LOCKED vma to
> ensure that we don't end up with an mlocked page in some other task's
> non-VM_LOCKED vma where we'd then fail to munlock it later.  During
> development testing, Rik encountered scenarios where a page would
> encounter a COW fault while it was still making its way to the LRU via
> the pagevecs.  So, he added the 'drain_all() and that seemed to avoid
> this scenario.

Agreed.


> Now, in the current upstream version of the unevictable mlocked pages
> patches, we just count any mlocked pages [vmstat] that make their way to
> free*page() instead of BUGging out, as we were doing earlier during
> development.  So, maybe we can drop the lru_drain_add()s in the
> unevictable mlocked pages work and live with the occasional freed
> mlocked page, or mlocked page on the active/inactive lists to be dealt
> with by vmscan.

hm, okey.
maybe, I was wrong.

I'll make "dropping lru_add_drain_all()" patch soon.
I expect I need few days.
  make the patch:                  1 day
  confirm by stress workload:  2-3 days

because rik's original problem only happend on heavy wokload, I think.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
