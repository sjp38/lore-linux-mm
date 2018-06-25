Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 973016B0005
	for <linux-mm@kvack.org>; Mon, 25 Jun 2018 09:03:43 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id f126-v6so3967049lfg.5
        for <linux-mm@kvack.org>; Mon, 25 Jun 2018 06:03:43 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id z13-v6si5773642lff.54.2018.06.25.06.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jun 2018 06:03:41 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180620115531.GL13685@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <3d27f26e-68ba-d3c0-9518-cebeb2689aec@sony.com>
Date: Mon, 25 Jun 2018 15:03:40 +0200
MIME-Version: 1.0
In-Reply-To: <20180620115531.GL13685@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On 06/20/2018 01:55 PM, Michal Hocko wrote:
> On Wed 20-06-18 20:20:38, Tetsuo Handa wrote:
>> Sleeping with oom_lock held can cause AB-BA lockup bug because
>> __alloc_pages_may_oom() does not wait for oom_lock. Since
>> blocking_notifier_call_chain() in out_of_memory() might sleep, sleeping
>> with oom_lock held is currently an unavoidable problem.
> Could you be more specific about the potential deadlock? Sleeping while
> holding oom lock is certainly not nice but I do not see how that would
> result in a deadlock assuming that the sleeping context doesn't sleep on
> the memory allocation obviously.

It is a mutex you are supposed to be able to sleep.=C2=A0 It's even exporte=
d.

>> As a preparation for not to sleep with oom_lock held, this patch brings
>> OOM notifier callbacks to outside of OOM killer, with two small behavior
>> changes explained below.
> Can we just eliminate this ugliness and remove it altogether? We do not
> have that many notifiers. Is there anything fundamental that would
> prevent us from moving them to shrinkers instead?


@Hocko Do you remember the lowmemorykiller from android? Some things might =
not be the right thing for shrinkers.
