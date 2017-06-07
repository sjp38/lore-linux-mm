Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A89C6B0311
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 22:21:16 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id 185so964155itv.8
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 19:21:16 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id o79si324584iod.158.2017.06.06.19.21.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 19:21:15 -0700 (PDT)
Message-ID: <593762FF.10705@huawei.com>
Date: Wed, 7 Jun 2017 10:20:47 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: double call identical release when there is a race hitting
References: <5936B098.6020807@huawei.com> <20170606155600.GA17705@redhat.com>
In-Reply-To: <20170606155600.GA17705@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

On 2017/6/6 23:56, Oleg Nesterov wrote:
> I can't answer authoritatively, but
>
> On 06/06, zhong jiang wrote:
>> Hi
>>
>> when I review the code, I find the following scenario will lead to a race ,
>> but I am not sure whether the real issue will hit or not.
>>
>> cpu1                                                                      cpu2
>> exit_mmap                                               mmu_notifier_unregister
>>    __mmu_notifier_release                                 srcu_read_lock
>>             srcu_read_lock
>>             mm->ops->release(mn, mm)                 mm->ops->release(mn,mm)
>>            srcu_read_unlock                                         srcu_read_unlock
>>
>>
>> obviously,  the specified mm will call identical release function when
>> the related condition satisfy.  is it right?
> I think you are right, this is possible, perhaps the comments should mention
> this explicitly.
>
> See the changelog in d34883d4e35c0a994e91dd847a82b4c9e0c31d83 "mm: mmu_notifier:
> re-fix freed page still mapped in secondary MMU":
>
> 	"multiple ->release() callouts", we needn't care it too much ...
>
> Oleg.
>
>
> .
>
Thank you for clarification.
 yes,  I see that the author admit that this is a issue.   The patch describe that it is really rare.
 Anyway, this issue should be fixed in a separate patch.

but so far  the issue still exist unfortunately.

Regards
zhongjiang




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
