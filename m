Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 55BE86B0088
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 12:55:18 -0500 (EST)
Received: by mail-wi0-f177.google.com with SMTP id cc10so1192887wib.4
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 09:55:17 -0800 (PST)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id v2si1740316wie.58.2013.12.06.09.55.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 09:55:16 -0800 (PST)
Received: by mail-wi0-f178.google.com with SMTP id bz8so1095250wib.11
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 09:55:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131206151944.GC2674@redhat.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
 <20131128063505.GN3556@cmpxchg.org> <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com>
 <20131128120018.GL2761@dhcp22.suse.cz> <20131128183830.GD20740@redhat.com>
 <20131202141203.GA31402@redhat.com> <alpine.DEB.2.02.1312041655370.13608@chino.kir.corp.google.com>
 <20131205172931.GA26018@redhat.com> <alpine.DEB.2.02.1312051531330.7717@chino.kir.corp.google.com>
 <20131206151944.GC2674@redhat.com>
From: Sameer Nanda <snanda@chromium.org>
Date: Fri, 6 Dec 2013 09:54:56 -0800
Message-ID: <CANMivWYe8sAvDRiS=K_UJQXC83P43uZTSFFc3zpDK823v2-Z2A@mail.gmail.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>

On Fri, Dec 6, 2013 at 7:19 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> On 12/05, David Rientjes wrote:
>>
>> On Thu, 5 Dec 2013, Oleg Nesterov wrote:
>>
>> > > Your v2 series looks good and I suspect anybody trying them doesn't have
>> > > additional reports of the infinite loop?  Should they be marked for
>> > > stable?
>> >
>> > Unlikely...
>> >
>> > I think the patch from Sameer makes more sense for stable as a temporary
>> > (and obviously incomplete) fix.
>>
>> There's a problem because none of this is currently even in linux-next.  I
>> think we could make a case for getting Sameer's patch at
>> http://marc.info/?l=linux-kernel&m=138436313021133 to be merged for
>> stable,
>
> Probably.
>
> Ah, I just noticed that this change
>
>         -       if (p->flags & PF_EXITING) {
>         +       if (p->flags & PF_EXITING || !pid_alive(p)) {
>
> is not needed. !pid_alive(p) obviously implies PF_EXITING.

Ah right.

>
>> but then we'd have to revert it in linux-next
>
> Or perhaps Sameer can just send his fix to stable/gregkh.
>
> Just the changelog should clearly explain that this is the minimal
> workaround for stable. Once again it doesn't (and can't) fix all
> problems even in oom_kill_process() paths, but it helps anyway to
> avoid the easy-to-trigger hang.

I don't mind doing that if that seems to be the consensus.  FWIW, I've
already added my patch to the Chrome OS kernel repo.

>
>> before merging your
>> series at http://marc.info/?l=linux-kernel&m=138616217925981.
>
> Just in case, I won't mind to rediff my patches on top of Sameer's
> patch and then add git-revert patch.
>
>> All of the
>> issues you present in that series seem to be stable material, so why not
>> just go ahead with your series and mark it for stable for 3.13?
>
> OK... I can do this too.
>
> I do not really like this because it adds thread_head/node but doesn't
> remove the old ->thread_group. We will do this later, but obviously
> this is not the stable material.
>
> IOW, if we send this to stable, thread_head/node/for_each_thread will
> be only used by oom_kill.c.
>
> And this is risky. For example, 1/4 depends on (at least) another patch
> I sent in preparation for this change, commit 81907739851
> "kernel/fork.c:copy_process(): don't add the uninitialized
> child to thread/task/pid lists", perhaps on something else.
>
> So personally I'd prefer to simply send the workaround for stable.
>
> Oleg.
>



-- 
Sameer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
