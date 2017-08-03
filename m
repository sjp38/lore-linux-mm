Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 691A86B0687
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 06:03:20 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b20so11196591itd.1
        for <linux-mm@kvack.org>; Thu, 03 Aug 2017 03:03:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b7si5402312iof.29.2017.08.03.03.03.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Aug 2017 03:03:19 -0700 (PDT)
Subject: Re: suspicious __GFP_NOMEMALLOC in selinux
References: <20170802105018.GA2529@dhcp22.suse.cz>
 <CAGH-Kgt_9So8bDe=yDF3yLZHDfDgeXsnBEu_X6uE_nQnoi=5Vg@mail.gmail.com>
 <20170803081152.GC12521@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <5aca0179-3b04-aa1a-58cd-668a04f63ae7@I-love.SAKURA.ne.jp>
Date: Thu, 3 Aug 2017 19:02:57 +0900
MIME-Version: 1.0
In-Reply-To: <20170803081152.GC12521@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Paul Moore <pmoore@redhat.com>
Cc: Jeff Vander Stoep <jeffv@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, selinux@tycho.nsa.gov, Mel Gorman <mgorman@suse.de>

On 2017/08/03 17:11, Michal Hocko wrote:
> [CC Mel]
> 
> On Wed 02-08-17 17:45:56, Paul Moore wrote:
>> On Wed, Aug 2, 2017 at 6:50 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>> Hi,
>>> while doing something completely unrelated to selinux I've noticed a
>>> really strange __GFP_NOMEMALLOC usage pattern in selinux, especially
>>> GFP_ATOMIC | __GFP_NOMEMALLOC doesn't make much sense to me. GFP_ATOMIC
>>> on its own allows to access memory reserves while the later flag tells
>>> we cannot use memory reserves at all. The primary usecase for
>>> __GFP_NOMEMALLOC is to override a global PF_MEMALLOC should there be a
>>> need.
>>>
>>> It all leads to fa1aa143ac4a ("selinux: extended permissions for
>>> ioctls") which doesn't explain this aspect so let me ask. Why is the
>>> flag used at all? Moreover shouldn't GFP_ATOMIC be actually GFP_NOWAIT.
>>> What makes this path important to access memory reserves?
>>
>> [NOTE: added the SELinux list to the CC line, please include that list
>> when asking SELinux questions]
> 
> Sorry about that. Will keep it in mind for next posts
>  
>> The GFP_ATOMIC|__GFP_NOMEMALLOC use in SELinux appears to be limited
>> to security/selinux/avc.c, and digging a bit, I'm guessing commit
>> fa1aa143ac4a copied the combination from 6290c2c43973 ("selinux: tag
>> avc cache alloc as non-critical") and the avc_alloc_node() function.
> 
> Thanks for the pointer. That makes much more sense now. Back in 2012 we
> really didn't have a good way to distinguish non sleeping and atomic
> with reserves allocations.
>  
>> I can't say that I'm an expert at the vm subsystem and the variety of
>> different GFP_* flags, but your suggestion of moving to GFP_NOWAIT in
>> security/selinux/avc.c seems reasonable and in keeping with the idea
>> behind commit 6290c2c43973.
> 
> What do you think about the following? I haven't tested it but it should
> be rather straightforward.

Why not at least __GFP_NOWARN ? And why not also __GFP_NOMEMALLOC ?
http://lkml.kernel.org/r/201706302210.GCA05089.MFFOtQVJSOLHOF@I-love.SAKURA.ne.jp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
