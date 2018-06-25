Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 878D26B000C
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 10:02:25 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id g82-v6so4010023lfg.4
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 07:02:25 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id y15-v6si6023924lfd.304.2018.06.25.07.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 07:02:21 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180620115531.GL13685@dhcp22.suse.cz>
 <3d27f26e-68ba-d3c0-9518-cebeb2689aec@sony.com>
 <20180625130756.GK28965@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <4c6f9bd5-e959-c0bd-53db-988e07644754@sony.com>
Date: Mon, 25 Jun 2018 16:02:20 +0200
MIME-Version: 1.0
In-Reply-To: <20180625130756.GK28965@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On 06/25/2018 03:07 PM, Michal Hocko wrote:
> On Mon 25-06-18 15:03:40, peter enderborg wrote:
>> On 06/20/2018 01:55 PM, Michal Hocko wrote:
>>> On Wed 20-06-18 20:20:38, Tetsuo Handa wrote:
>>>> Sleeping with oom_lock held can cause AB-BA lockup bug because
>>>> __alloc_pages_may_oom() does not wait for oom_lock. Since
>>>> blocking_notifier_call_chain() in out_of_memory() might sleep, sleepin=
g
>>>> with oom_lock held is currently an unavoidable problem.
>>> Could you be more specific about the potential deadlock? Sleeping while
>>> holding oom lock is certainly not nice but I do not see how that would
>>> result in a deadlock assuming that the sleeping context doesn't sleep o=
n
>>> the memory allocation obviously.
>> It is a mutex you are supposed to be able to sleep.=C2=A0 It's even expo=
rted.
> What do you mean? oom_lock is certainly not exported for general use. It
> is not local to oom_killer.c just because it is needed in other _mm_
> code.
> =20

It=C2=A0 is in the oom.h file include/linux/oom.h, if it that sensitive it =
should
be in mm/ and a documented note about the special rules. It is only used
in drivers/tty/sysrq.c and that be replaced by a help function in mm that
do the=C2=A0 oom stuff.


>>>> As a preparation for not to sleep with oom_lock held, this patch bring=
s
>>>> OOM notifier callbacks to outside of OOM killer, with two small behavi=
or
>>>> changes explained below.
>>> Can we just eliminate this ugliness and remove it altogether? We do not
>>> have that many notifiers. Is there anything fundamental that would
>>> prevent us from moving them to shrinkers instead?
>>
>> @Hocko Do you remember the lowmemorykiller from android? Some things
>> might not be the right thing for shrinkers.
> Just that lmk did it wrong doesn't mean others have to follow.
>
If all you have is a hammer, everything looks like a nail. (I don=E2=80=99t=
 argument that it was right)
But if you don=E2=80=99t have a way to interact with the memory system we w=
ill get attempts like lmk.=C2=A0
Oom notifiers and vmpressure is for this task better than shrinkers.
