Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 0A38B6B0033
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 20:18:30 -0400 (EDT)
Date: Tue, 20 Aug 2013 17:18:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/4] mm/pgtable: Fix continue to preallocate pmds
 even if failure occurrence
Message-Id: <20130820171816.1b759e87.akpm@linux-foundation.org>
In-Reply-To: <5213fe45.660c420a.4066.ffffd8c7SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1376981696-4312-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<20130820160418.5639c4f9975b84dc8dede014@linux-foundation.org>
	<5213fe45.660c420a.4066.ffffd8c7SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 21 Aug 2013 07:39:35 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> >Nope.  If the error path is taken, free_pmds() will free uninitialised
> >items from pmds[], which is a local in pgd_alloc() and contains random
> >stack junk.  The kernel will crash.
> >
> >You could pass an nr_pmds argument to free_pmds(), or zero out the
> >remaining items on the error path.  However, although the current code
> >is a bit kooky, I don't see that it is harmful in any way.
> >
> 
> There is a check in free_pmds():
> 
> if (pmds[i])
> 	free_page((unsigned long)pmds[i]);
> 
> which will avoid the issue you mentioned.

pmds[i] is uninitialized.  It gets allocated
on the stack in pgd_alloc() and does not get zeroed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
