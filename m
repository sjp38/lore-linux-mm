Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id B323B6B006C
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 19:50:07 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <john.stultz@linaro.org>;
	Fri, 7 Dec 2012 19:50:06 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E0BFC38C807C
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 19:50:02 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB80o2ln308728
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 19:50:02 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB80o0V3000880
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 22:50:02 -0200
Message-ID: <50C28EB4.6030505@linaro.org>
Date: Fri, 07 Dec 2012 16:49:56 -0800
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [RFC v2] Support volatile range for anon vma
References: <1351560594-18366-1-git-send-email-minchan@kernel.org> <50AD739A.30804@linaro.org> <50B6E1F9.5010301@linaro.org> <20121204000042.GB20395@bbox> <50BD4A70.9060506@linaro.org> <20121204072207.GA9782@blaptop> <50BE4B64.6000003@linaro.org> <20121205041855.GB9782@blaptop>
In-Reply-To: <20121205041855.GB9782@blaptop>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On 12/04/2012 08:18 PM, Minchan Kim wrote:
> On Tue, Dec 04, 2012 at 11:13:40AM -0800, John Stultz wrote:
>> I don't think the problem is when vmas being marked VM_VOLATILE are
>> being merged, its that when we mark the vma as *non-volatile*, and
>> remove the VM_VOLATILE flag we merge the non-volatile vmas with
>> neighboring vmas. So preserving the purged flag during that merge is
>> important. Again, the example I used to trigger this was an
>> alternating pattern of volatile and non volatile vmas, then marking
>> the entire range non-volatile (though sometimes in two overlapping
>> passes).
> Understood. Thanks.
> Below patch solves your problems? It's simple than yours.

Yea, this is nicer then my fix.
Although I still need the purged handling in the vma merge code for me 
to see the behavior I expect in my tests.

I've integrated your patch and repushed my queue here:
http://git.linaro.org/gitweb?p=people/jstultz/android-dev.git;a=shortlog;h=refs/heads/dev/minchan-anonvol

git://git.linaro.org/people/jstultz/android-dev.git dev/minchan-anonvol

> Anyway, both yours and mine are not right fix.
> As I mentioned, locking scheme is broken.
> We need anon_vma_lock to handle purged and we should consider fork
> case, too.
Hrm. I'm sure you're right, as I've not yet fully grasped all the 
locking rules here.  Could you clarify how it is broken? And why is the 
anon_vma_lock needed to manage the purged state that is part of the vma 
itself?

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
