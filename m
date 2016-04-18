Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 949446B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 22:50:10 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id k200so104315957lfg.1
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 19:50:10 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id i9si28611309wjn.237.2016.04.17.19.50.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 19:50:09 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id a140so20893308wma.2
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 19:50:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1604150104350.5801@eggly.anvils>
References: <CADJHv_sawA8SXviUX6My5MKeqWMLbWLG=DrM7RCgrjkjGj2f5Q@mail.gmail.com>
	<alpine.LSU.2.11.1604150104350.5801@eggly.anvils>
Date: Mon, 18 Apr 2016 10:50:08 +0800
Message-ID: <CADJHv_ts7_Qu8oZ=kCbYPOR7NzbMFJxze31b9EdFj9gqWrRhEA@mail.gmail.com>
Subject: Re: binary execution from DAX mount hang since next-20160407
From: Xiong Zhou <jencce.kernel@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linux-Next <linux-next@vger.kernel.org>, linux-nvdimm@lists.01.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-Fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Apr 15, 2016 at 4:38 PM, Hugh Dickins <hughd@google.com> wrote:
> On Fri, 15 Apr 2016, Xiong Zhou wrote:
>
>> Hi, all
>>
>> Since tag next-20160407 in linux-next repo, executing binary
>> from/in DAX mount hangs.
>>
>> It does not hang if mount without dax option.
>> It hangs with both xfs and ext4.
>> It does not hang if execute from a -t tmpfs mount.
>> It does not hang on next-20160406 and still hangs on 0414 tree.
>>
>> # ps -axjf
>> ...
>> S+       0   0:00  |       \_ sh -x thl.sh
>> R+       0  42:33  |           \_ [hl]
>> ..
>> # cat thl.sh
>> mkfs.ext4 /dev/pmem0
>> mount -o dax /dev/pmem0 /daxmnt
>> cp hl /daxmnt
>> /daxmnt/hl
>> # cat hl.c
>> void main()
>> {
>>         printf("ok\n");
>> }
>> # cc hl.c -o hl
>>
>> Bisecting commits between 0406 and 0407 tag, points to this:
>>
>> d7c7d56ca61aec18e5e0cb3a64e50073c42195f7 is the first bad commit
>> commit d7c7d56ca61aec18e5e0cb3a64e50073c42195f7
>> Author: Hugh Dickins <hughd@google.com>
>> Date:   Thu Apr 7 14:00:12 2016 +1000
>>
>>     huge tmpfs: avoid premature exposure of new pagetable
>>
>> Bisect log and config are attatched.
>
> Excellent and very helpful bug report: thank you very much for taking
> the trouble to make such a good report.
>
> I see why this happens now: I've not been paying enough attention
> to the DAX changes.
>
> The fix requires a repositioning of where I allocate the new page
> table: which is a change we knew we had to make for other reasons,
> but it did not appear to be a high priority compared with other things
> - until your bug report showing that I have broken DAX rather badly.
>
> In return for your excellent bug report, I can immediately offer
> the most shameful patch I have ever posted: which has the virtue of
> simplicity, and will work so long as you have plenty of free memory;
> but might deadlock if it has to go into page reclaim (or maybe not:
> perhaps the DAXness would leave it as merely a lockdep violation).
>
> Maybe not so much worse than the current hang, but still shameful:
> I'm appending it here just in case you're in a hurry to see your "ok"
> program working on DAX; but I think I'd better rearrange priorities
> and try to provide a proper fix as soon as possible.

No hurry, :)  Take your time.

>
> Never-to-be-Signed-off-by: an anonymous hacker
>
> --- 4.6-rc2-mm1/mm/memory.c     2016-04-10 10:12:06.167769232 -0700
> +++ linux/mm/memory.c   2016-04-15 00:54:06.427085026 -0700
> @@ -2874,7 +2874,7 @@ static int __do_fault(struct vm_area_str
>                 ret = VM_FAULT_HWPOISON;
>                 goto err;
>         }
> -
> + out:
>         /*
>          * Use pte_alloc instead of pte_alloc_map, because we can't
>          * run pte_offset_map on the pmd, if an huge pmd could
> @@ -2892,7 +2892,7 @@ static int __do_fault(struct vm_area_str
>                 ret = VM_FAULT_NOPAGE;
>                 goto err;
>         }
> - out:
> +
>         *page = vmf.page;
>         return ret;
>  err:

Yes, "ok" is printed ok!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
