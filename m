Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 11E816B010A
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 14:40:42 -0400 (EDT)
Date: Fri, 05 Apr 2013 14:40:35 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1365187235-chwg4d0m-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <515F18A8.7030102@gmail.com>
References: <1365014138-19589-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1365014138-19589-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <515F18A8.7030102@gmail.com>
Subject: Re: [PATCH v3 1/3] hugetlbfs: stop setting VM_DONTDUMP in
 initializing vma(VM_HUGETLB)
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Apr 05, 2013 at 02:32:08PM -0400, KOSAKI Motohiro wrote:
> (4/3/13 2:35 PM), Naoya Horiguchi wrote:
> > Currently we fail to include any data on hugepages into coredump,
> > because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
> > introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
> > mm->reserved_vm counter". This looks to me a serious regression,
> > so let's fix it.
> 
> I don't think this is enough explanations. Let's explain the code meaning
> time to time order.
> 
> First, we had no madvice(DONTDUMP) nor coredump_filter(HUGETLB). then hugetlb
> pages were never dumped.
> 
> Second, I added coredump_filter(HUGETLB). and then vm_dump_size became..
> 
> vm_dump_size()
> {
> 	/* Hugetlb memory check */
> 	if (vma->vm_flags & VM_HUGETLB) {
> 		..
> 		goto whole;
> 	}
> 	if (vma->vm_flags & VM_RESERVED)
> 		return 0;
> 
> The point is, hugetlb was checked before VM_RESERVED. i.e. hugetlb core dump ignored
> VM_RESERVED. At this time, "if (vma->vm_flags & VM_HUGETLB)" statement don't need
> return 0 because VM_RESERVED prevented to go into the subsequent flag checks.
> 
> Third, Jason added madvise(DONTDUMP). then vm_dump_size became...
> 
> vm_dump_size()
> {
>        if (vma->vm_flags & VM_NODUMP)
>                return 0;
> 
> 	/* Hugetlb memory check */
> 	if (vma->vm_flags & VM_HUGETLB) {
> 		..
> 		goto whole;
> 	}
> 	if (vma->vm_flags & VM_RESERVED)
> 		return 0;
> 
> Look, VM_NODUMP and VM_RESERVED had similar and different meanings at this time.
> 
> Finally, Konstantin removed VM_RESERVED and hugetlb coredump behavior
> has been changed.

Things were/are quite complicated, and this is a wonderful step-by-step explanation.
Thank you very much.

Naoya

> Thus, patch [1/3] and [2/3] should be marked [stable for v3.6 or later].
> 
> Anyway, this patch is correct. Thank you!
> 
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
