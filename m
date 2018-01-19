Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28ACD6B0253
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 11:48:29 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id l6so956196lfg.9
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 08:48:29 -0800 (PST)
Received: from netline-mail3.netline.ch (mail.netline.ch. [148.251.143.178])
        by mx.google.com with ESMTP id r141si568176lfr.7.2018.01.19.08.48.26
        for <linux-mm@kvack.org>;
        Fri, 19 Jan 2018 08:48:27 -0800 (PST)
Subject: Re: [RFC] Per file OOM badness
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
 <20180118170006.GG6584@dhcp22.suse.cz> <20180118171355.GH6584@dhcp22.suse.cz>
 <87k1wfgcmb.fsf@anholt.net> <20180119082046.GL6584@dhcp22.suse.cz>
 <0cfaf256-928c-4cb8-8220-b8992592071b@amd.com>
 <20180119104058.GU6584@dhcp22.suse.cz>
 <d4fe7e59-da2d-11a5-73e2-55f2f27cdfd8@amd.com>
From: =?UTF-8?Q?Michel_D=c3=a4nzer?= <michel@daenzer.net>
Message-ID: <d1e54376-6ed4-dceb-1dfa-1b95a11ab3c8@daenzer.net>
Date: Fri, 19 Jan 2018 17:48:24 +0100
MIME-Version: 1.0
In-Reply-To: <d4fe7e59-da2d-11a5-73e2-55f2f27cdfd8@amd.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org

On 2018-01-19 12:37 PM, Christian KA?nig wrote:
> Am 19.01.2018 um 11:40 schrieb Michal Hocko:
>> On Fri 19-01-18 09:39:03, Christian KA?nig wrote:
>>> Am 19.01.2018 um 09:20 schrieb Michal Hocko:
>> [...]
>>>> OK, in that case I would propose a different approach. We already
>>>> have rss_stat. So why do not we simply add a new counter there
>>>> MM_KERNELPAGES and consider those in oom_badness? The rule would be
>>>> that such a memory is bound to the process life time. I guess we will
>>>> find more users for this later.
>>> I already tried that and the problem with that approach is that some
>>> buffers
>>> are not created by the application which actually uses them.
>>>
>>> For example X/Wayland is creating and handing out render buffers to
>>> application which want to use OpenGL.
>>>
>>> So the result is when you always account the application who created the
>>> buffer the OOM killer will certainly reap X/Wayland first. And that is
>>> exactly what we want to avoid here.
>> Then you have to find the target allocation context at the time of the
>> allocation and account it.
> 
> And exactly that's the root of the problem: The target allocation
> context isn't known at the time of the allocation.
> 
> We could add callbacks so that when the memory is passed from the
> allocator to the actual user of the memory. In other words when the
> memory is passed from the X server to the client the driver would need
> to decrement the X servers accounting and increment the clients accounting.
> 
> But I think that would go deep into the file descriptor handling (we
> would at least need to handle dup/dup2 and passing the fd using unix
> domain sockets) and most likely would be rather error prone.
> 
> The per file descriptor badness is/was just the much easier approach to
> solve the issue, because the drivers already knew which client is
> currently using which buffer objects.
> 
> I of course agree that file descriptors can be shared between processes
> and are by themselves not killable. But at least for our graphics driven
> use case I don't see much of a problem killing all processes when a file
> descriptor is used by more than one at the same time.

In that case, accounting a BO as suggested by Michal above, in every
process that shares it, should work fine, shouldn't it?

The OOM killer will first select the process which has more memory
accounted for other things than the BOs shared with another process.


-- 
Earthling Michel DA?nzer               |               http://www.amd.com
Libre software enthusiast             |             Mesa and X developer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
