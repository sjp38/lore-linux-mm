Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id C22A76B026C
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 06:34:01 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id 65so179618872otq.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 03:34:01 -0800 (PST)
Received: from www62.your-server.de (www62.your-server.de. [213.133.104.62])
        by mx.google.com with ESMTPS id 72si1632610iog.73.2017.01.26.03.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 03:34:00 -0800 (PST)
Message-ID: <5889DEA3.7040106@iogearbox.net>
Date: Thu, 26 Jan 2017 12:33:55 +0100
From: Daniel Borkmann <daniel@iogearbox.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6 v3] kvmalloc
References: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com> <588907AA.1020704@iogearbox.net> <20170126074354.GB8456@dhcp22.suse.cz> <5889C331.7020101@iogearbox.net> <20170126100802.GF6590@dhcp22.suse.cz>
In-Reply-To: <20170126100802.GF6590@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, marcelo.leitner@gmail.com

On 01/26/2017 11:08 AM, Michal Hocko wrote:
> On Thu 26-01-17 10:36:49, Daniel Borkmann wrote:
>> On 01/26/2017 08:43 AM, Michal Hocko wrote:
>>> On Wed 25-01-17 21:16:42, Daniel Borkmann wrote:
> [...]
>>>> I assume that kvzalloc() is still the same from [1], right? If so, then
>>>> it would unfortunately (partially) reintroduce the issue that was fixed.
>>>> If you look above at flags, they're also passed to __vmalloc() to not
>>>> trigger OOM in these situations I've experienced.
>>>
>>> Pushing __GFP_NORETRY to __vmalloc doesn't have the effect you might
>>> think it would. It can still trigger the OOM killer becauset the flags
>>> are no propagated all the way down to all allocations requests (e.g.
>>> page tables). This is the same reason why GFP_NOFS is not supported in
>>> vmalloc.
>>
>> Ok, good to know, is that somewhere clearly documented (like for the
>> case with kmalloc())?
>
> I am afraid that we really suck on this front. I will add something.

Thanks for doing that, much appreciated!

>> If not, could we do that for non-mm folks, or
>> at least add a similar WARN_ON_ONCE() as you did for kvmalloc() to make
>> it obvious to users that a given flag combination is not supported all
>> the way down?
>
> I am not sure that triggering a warning that somebody has used
> __GFP_NOWARN is very helpful ;). I also do not think that covering all the
> supported flags is really feasible. Most of them will not have bad side
> effects. I have added the warning because this API is new and I wanted
> to catch new abusers. Old ones would have to die slowly.

Okay, makes sense then. Just the kdoc comment from your other
mail should help fine already.

>>>> This is effectively the
>>>> same requirement as in other networking areas f.e. that 5bad87348c70
>>>> ("netfilter: x_tables: avoid warn and OOM killer on vmalloc call") has.
>>>> In your comment in kvzalloc() you eventually say that some of the above
>>>> modifiers are not supported. So there would be two options, i) just leave
>>>> out the kvzalloc() chunk for BPF area to avoid the merge conflict and tackle
>>>> it later (along with similar code from 5bad87348c70), or ii) implement
>>>> support for these modifiers as well to your original set. I guess it's not
>>>> too urgent, so we could also proceed with i) if that is easier for you to
>>>> proceed (I don't mind either way).
>>>
>>> Could you clarify why the oom killer in vmalloc matters actually?
>>
>> For both mentioned commits, (privileged) user space can potentially
>> create large allocation requests, where we thus switch to vmalloc()
>> flavor eventually and then OOM starts killing processes to try to
>> satisfy the allocation request. This is bad, because we want the
>> request to just fail instead as it's non-critical and f.e. not kill
>> ssh connection et al. Failing is totally fine in this case, whereas
>> triggering OOM is not.
>
> I see your intention but does it really make any real difference?
> Consider you would back off right before you would have OOMed. Any
> parallel request would just hit the OOM for you. You are (almost) never
> doing an allocation in an isolation.
>
>> In my testing, __GFP_NORETRY did satisfy this
>> just fine, but as you say it seems it's not enough.
>
> Yeah, ptes have been most probably popullated already.
>
>> Given there are
>> multiple places like these in the kernel, could we instead add an
>> option such as __GFP_NOOOM, or just make __GFP_NORETRY supported?
>
> As said above I do not really think that suppressing the OOM killer
> makes any difference because it might be just somebody else doing that
> for you. Also the OOM killer is the MM internal implementation "detail"
> users shouldn't really care. I agree that callers should have a way to
> say they do not want to try really hard and that is not that simple
> for vmalloc unfortunatelly. The main problem here is that gfp mask
> propagation is not that easy to fix without a lot of code churn as some
> of those hardcoded allocation requests are deep in call chains.

I see, that's unfortunate. I understand that there are requests
in parallel and that we might end up with OOM eventually if we're
unlucky, but having some way to tell vmalloc to just not try as
hard as usual would be nice.

> I know this sucks and it would be great to support __GFP_NORETRY to
> [k]vmalloc and maybe we will get there eventually. But for the mean time
> I really think that using kvmalloc wherever possible is much better than
> open coded variants whith expectations which do not hold sometimes.

I totally agree with you that having kvmalloc() as helper is awesome
and probably long overdue as well. :)

> If you disagree I can drop the bpf part of course...

If we could consolidate these spots with kvmalloc() eventually, I'm
all for it. But even if __GFP_NORETRY is not covered down to all
possible paths, it kind of does have an effect already of saying
'don't try too hard', so would it be harmful to still keep that for
now? If it's not, I'd personally prefer to just leave it as is until
there's some form of support by kvmalloc() and friends.

Thanks for your input, Michal!

Cheers,
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
