Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92C116B038B
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 09:43:34 -0500 (EST)
Received: by mail-lf0-f69.google.com with SMTP id j2so4735774lfe.3
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 06:43:34 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id t18si4365786lja.90.2017.02.24.06.43.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 06:43:33 -0800 (PST)
Subject: Re: [PATCH] staging, android: remove lowmemory killer from the tree
References: <20170222120121.12601-1-mhocko@kernel.org>
 <CANcMJZBNe10dtK8ANtLSWS3UXeePhndN=S5otADhQdfQKOAhOw@mail.gmail.com>
 <CA+_MTtzj9z3JEH528iTjAuNivKo9tNzAx9dwpAJo6U5kgf636g@mail.gmail.com>
 <855e929a-a891-a435-8f75-3674d8a3e96d@sonymobile.com>
 <20170224122830.GG19161@dhcp22.suse.cz>
 <9ffdcc79-12d4-00c5-182c-498b8ca951cc@sonymobile.com>
 <20170224141144.GI19161@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <3336a503-c73f-9fe4-a17a-36629a54a97b@sonymobile.com>
Date: Fri, 24 Feb 2017 15:42:49 +0100
MIME-Version: 1.0
In-Reply-To: <20170224141144.GI19161@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Martijn Coenen <maco@google.com>, John Stultz <john.stultz@linaro.org>, Greg KH <gregkh@linuxfoundation.org>, =?UTF-8?Q?Arve_Hj=c3=b8nnev=c3=a5g?= <arve@android.com>, Riley Andrews <riandrews@android.com>, devel@driverdev.osuosl.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Todd Kjos <tkjos@google.com>, Android Kernel Team <kernel-team@android.com>, Rom Lemarchand <romlem@google.com>, Tim Murray <timmurray@google.com>

On 02/24/2017 03:11 PM, Michal Hocko wrote:
> On Fri 24-02-17 14:16:34, peter enderborg wrote:
>> On 02/24/2017 01:28 PM, Michal Hocko wrote:
> [...]
>>> Yeah, I strongly believe that the chosen approach is completely wrong.
>>> Both in abusing the shrinker interface and abusing oom_score_adj as the
>>> only criterion for the oom victim selection.
>> No one is arguing that shrinker is not problematic. And would be great
>> if it is removed from lmk.  The oom_score_adj is the way user-space
>> tells the kernel what the user-space has as prio. And android is using
>> that very much. It's a core part.
> Is there any documentation which describes how this is done?
>
>> I have never seen it be used on
>> other linux system so what is the intended usage of oom_score_adj? Is
>> this really abusing?
> oom_score_adj is used to _adjust_ the calculated oom score. It is not a
> criterion on its own, well, except for the extreme sides of the range
> which are defined to enforce resp. disallow selecting the task. The
> global oom killer calculates the oom score as a function of the memory
> consumption. Your patch simply ignores the memory consumption (and uses
> pids to sort tasks with the same oom score which is just mind boggling)
How much it uses is of very little importance for android. The score
used are only for apps and their services. System related are not touched by
android lmk. The pid is only to have a unique key to be able to have it fast within a rbtree.
One idea was to use task_pid to get a strict age of process to get a round robin
but since it does not matter i skipped that idea since it does not matter.
> and that is what I call the abuse. The oom score calculation might
> change in future, of course, but all consumers of the oom_score_adj
> really have to agree on the base which is adjusted by this tunable
> otherwise you can see a lot of unexpected behavior.
Then can we just define a range that is strictly for user-space?
> I would even argue that nobody outside of mm/oom_kill.c should really
> have any business with this tunable.  You can of course tweak the value
> from the userspace and help to chose a better oom victim this way but
> that is it.
Why only help? If userspace can give an exact order to kernel that
must be a good thing; other wise kernel have to guess and when
can that be better? 
> Anyway, I guess we are getting quite off-topic here.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
