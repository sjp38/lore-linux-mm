Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C67316B0292
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 11:56:05 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id x53so85137687qtx.14
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 08:56:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z7si16902708qka.218.2017.06.06.08.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 08:56:04 -0700 (PDT)
Date: Tue, 6 Jun 2017 17:56:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: double call identical release when there is a race hitting
Message-ID: <20170606155600.GA17705@redhat.com>
References: <5936B098.6020807@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5936B098.6020807@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

I can't answer authoritatively, but

On 06/06, zhong jiang wrote:
>
> Hi
>
> when I review the code, I find the following scenario will lead to a race ,
> but I am not sure whether the real issue will hit or not.
>
> cpu1                                                                      cpu2
> exit_mmap                                               mmu_notifier_unregister
>    __mmu_notifier_release                                 srcu_read_lock
>             srcu_read_lock
>             mm->ops->release(mn, mm)                 mm->ops->release(mn,mm)
>            srcu_read_unlock                                         srcu_read_unlock
>
>
> obviously,  the specified mm will call identical release function when
> the related condition satisfy.  is it right?

I think you are right, this is possible, perhaps the comments should mention
this explicitly.

See the changelog in d34883d4e35c0a994e91dd847a82b4c9e0c31d83 "mm: mmu_notifier:
re-fix freed page still mapped in secondary MMU":

	"multiple ->release() callouts", we needn't care it too much ...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
