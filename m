Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F9816B0279
	for <linux-mm@kvack.org>; Tue, 30 May 2017 00:51:37 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v195so27822207qka.1
        for <linux-mm@kvack.org>; Mon, 29 May 2017 21:51:37 -0700 (PDT)
Received: from mail-qt0-x242.google.com (mail-qt0-x242.google.com. [2607:f8b0:400d:c0d::242])
        by mx.google.com with ESMTPS id i26si11866327qti.269.2017.05.29.21.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 May 2017 21:51:36 -0700 (PDT)
Received: by mail-qt0-x242.google.com with SMTP id j13so11178016qta.3
        for <linux-mm@kvack.org>; Mon, 29 May 2017 21:51:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1705292129170.9353@chino.kir.corp.google.com>
References: <149570810989.203600.9492483715840752937.stgit@buzz> <alpine.DEB.2.10.1705292129170.9353@chino.kir.corp.google.com>
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 30 May 2017 07:51:35 +0300
Message-ID: <CALYGNiPPaVJ8XDkbrJA2V87tsRQRQuX9heRcMsffCBBrnJLAfQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm/oom_kill: count global and memory cgroup oom kills
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Roman Guschin <guroan@gmail.com>

On Tue, May 30, 2017 at 7:29 AM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 25 May 2017, Konstantin Khlebnikov wrote:
>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 04c9143a8625..dd30a045ef5b 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -876,6 +876,11 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>>       /* Get a reference to safely compare mm after task_unlock(victim) */
>>       mm = victim->mm;
>>       mmgrab(mm);
>> +
>> +     /* Raise event before sending signal: reaper must see this */
>
> How is the oom reaper involved here?

Task reaper - OOM event should happens before SIGCHLD.

>
>> +     count_vm_event(OOM_KILL);
>> +     mem_cgroup_count_vm_event(mm, OOM_KILL);
>> +
>>       /*
>>        * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
>>        * the OOM victim from depleting the memory reserves from the user
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
