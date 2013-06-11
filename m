Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id D14D56B0031
	for <linux-mm@kvack.org>; Tue, 11 Jun 2013 02:28:51 -0400 (EDT)
Received: by mail-we0-f178.google.com with SMTP id u53so5586842wes.9
        for <linux-mm@kvack.org>; Mon, 10 Jun 2013 23:28:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51B67553.6020205@oracle.com>
References: <1370891880-2644-1-git-send-email-sasha.levin@oracle.com>
	<CAOJsxLGDH2iwznRkP-iwiMZw7Ee3mirhjLvhShrWLHR0qguRxA@mail.gmail.com>
	<51B62F6B.8040308@oracle.com>
	<0000013f3075f90d-735942a8-b4b8-413f-a09e-57d1de0c4974-000000@email.amazonses.com>
	<51B67553.6020205@oracle.com>
Date: Tue, 11 Jun 2013 09:28:50 +0300
Message-ID: <CAOJsxLH56xqCoDikYYaY_guqCX=S4rcVfDJQ4ki=r-PkNQW9ug@mail.gmail.com>
Subject: Re: [PATCH] slab: prevent warnings when allocating with __GFP_NOWARN
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Christoph Lameter <cl@gentwo.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Sasha,

On Tue, Jun 11, 2013 at 3:54 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
> On 06/10/2013 07:40 PM, Christoph Lameter wrote:
>>
>> On Mon, 10 Jun 2013, Sasha Levin wrote:
>>
>>> [ 1691.807621] Call Trace:
>>> [ 1691.809473]  [<ffffffff83ff4041>] dump_stack+0x4e/0x82
>>> [ 1691.812783]  [<ffffffff8111fe12>] warn_slowpath_common+0x82/0xb0
>>> [ 1691.817011]  [<ffffffff8111fe55>] warn_slowpath_null+0x15/0x20
>>> [ 1691.819936]  [<ffffffff81243dcf>] kmalloc_slab+0x2f/0xb0
>>> [ 1691.824942]  [<ffffffff81278d54>] __kmalloc+0x24/0x4b0
>>> [ 1691.827285]  [<ffffffff8196ffe3>] ? security_capable+0x13/0x20
>>> [ 1691.829405]  [<ffffffff812a26b7>] ? pipe_fcntl+0x107/0x210
>>> [ 1691.831827]  [<ffffffff812a26b7>] pipe_fcntl+0x107/0x210
>>> [ 1691.833651]  [<ffffffff812b7ea0>] ? fget_raw_light+0x130/0x3f0
>>> [ 1691.835343]  [<ffffffff812aa5fb>] SyS_fcntl+0x60b/0x6a0
>>> [ 1691.837008]  [<ffffffff8403ca98>] tracesys+0xe1/0xe6
>>>
>>> The caller specifically sets __GFP_NOWARN presumably to avoid this
>>> warning on
>>> slub but I'm not sure if there's any other reason.
>>
>>
>> There must be another reason. Lets fix this.
>
> My, I feel silly now.
>
> I was the one who added __GFP_NOFAIL in the first place in
> 2ccd4f4d ("pipe: fail cleanly when root tries F_SETPIPE_SZ
> with big size").
>
> What happens is that root can go ahead and specify any size
> it wants to be used as buffer size - and the kernel will
> attempt to comply by allocation that buffer. Which fails
> if the size is too big.
>
> Either way, even if we do end up doing something different,
> shouldn't we prevent slab from spewing a warning if
> __GFP_NOWARN is passed?

Yeah, this is the size-from-userspace case I was thinking about. I think
we have two options: either use your patch or drop the WARN_ON
completely.

Christoph, which one do you prefer?

                                Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
