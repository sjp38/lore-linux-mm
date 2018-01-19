Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 52A236B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 06:38:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i2so1620852pgq.8
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 03:38:07 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0047.outbound.protection.outlook.com. [104.47.42.47])
        by mx.google.com with ESMTPS id e6si3036331pgt.621.2018.01.19.03.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 19 Jan 2018 03:38:06 -0800 (PST)
Subject: Re: [RFC] Per file OOM badness
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz> <20180118171355.GH6584@dhcp22.suse.cz>
 <87k1wfgcmb.fsf@anholt.net> <20180119082046.GL6584@dhcp22.suse.cz>
 <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com>
 <20180119104058.GU6584@dhcp22.suse.cz>
From: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>
Message-ID: <d4fe7e59-da2d-11a5-73e2-55f2f27cdfd8@amd.com>
Date: Fri, 19 Jan 2018 12:37:51 +0100
MIME-Version: 1.0
In-Reply-To: <20180119104058.GU6584@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Eric Anholt <eric@anholt.net>, Andrey Grodzovsky <andrey.grodzovsky@amd.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org

Am 19.01.2018 um 11:40 schrieb Michal Hocko:
> On Fri 19-01-18 09:39:03, Christian KA?nig wrote:
>> Am 19.01.2018 um 09:20 schrieb Michal Hocko:
> [...]
>>> OK, in that case I would propose a different approach. We already
>>> have rss_stat. So why do not we simply add a new counter there
>>> MM_KERNELPAGES and consider those in oom_badness? The rule would be
>>> that such a memory is bound to the process life time. I guess we will
>>> find more users for this later.
>> I already tried that and the problem with that approach is that some buffers
>> are not created by the application which actually uses them.
>>
>> For example X/Wayland is creating and handing out render buffers to
>> application which want to use OpenGL.
>>
>> So the result is when you always account the application who created the
>> buffer the OOM killer will certainly reap X/Wayland first. And that is
>> exactly what we want to avoid here.
> Then you have to find the target allocation context at the time of the
> allocation and account it.

And exactly that's the root of the problem: The target allocation 
context isn't known at the time of the allocation.

We could add callbacks so that when the memory is passed from the 
allocator to the actual user of the memory. In other words when the 
memory is passed from the X server to the client the driver would need 
to decrement the X servers accounting and increment the clients accounting.

But I think that would go deep into the file descriptor handling (we 
would at least need to handle dup/dup2 and passing the fd using unix 
domain sockets) and most likely would be rather error prone.

The per file descriptor badness is/was just the much easier approach to 
solve the issue, because the drivers already knew which client is 
currently using which buffer objects.

I of course agree that file descriptors can be shared between processes 
and are by themselves not killable. But at least for our graphics driven 
use case I don't see much of a problem killing all processes when a file 
descriptor is used by more than one at the same time.

Regards,
Christian.

> As follow up emails show, implementations
> might differ and any robust oom solution have to rely on the common
> counters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
