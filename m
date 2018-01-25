Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B7B76800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 21:15:34 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id v10so3461099wrv.22
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 18:15:34 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 90sor2039746wrp.23.2018.01.24.18.15.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 18:15:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180125015441.GS13338@ZenIV.linux.org.uk>
References: <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
 <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com> <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
 <afa2dc80-16a3-d3d1-5090-9430eaafc841@alibaba-inc.com> <20171115093131.GA17359@quack2.suse.cz>
 <CALvZod6HJO73GUfLemuAXJfr4vZ8xMOmVQpFO3vJRog-s2T-OQ@mail.gmail.com>
 <CAOQ4uxg-mTgQfTv-qO6EVwfttyOy+oFyAHyFDKTQsDOkQPyyfA@mail.gmail.com>
 <20180124103454.ibuqt3njaqbjnrfr@quack2.suse.cz> <CAOQ4uxhDpBBUrr0JWRBaNQTTaUeJ4=gnM0iij2KivaGgp1ggtg@mail.gmail.com>
 <CALvZod4PyqfaqgEswegF5uOjNwVwbY1C4ptJB0Ouvgchv2aVFg@mail.gmail.com> <20180125015441.GS13338@ZenIV.linux.org.uk>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 24 Jan 2018 18:15:31 -0800
Message-ID: <CALvZod4r4hC2A47WP1AwwDCkcPSeoV1GBJL2Dr8SC0H9fm8BHA@mail.gmail.com>
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Amir Goldstein <amir73il@gmail.com>, Jan Kara <jack@suse.cz>, Yang Shi <yang.s@alibaba-inc.com>, Michal Hocko <mhocko@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 24, 2018 at 5:54 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Wed, Jan 24, 2018 at 05:08:27PM -0800, Shakeel Butt wrote:
>> First, let me apologize, I think I might have led the discussion in
>> wrong direction by giving one wrong information. The current upstream
>> kernel, from the syscall context, does not invoke oom-killer when a
>> memcg hits its limit and fails to reclaim memory, instead ENOMEM is
>> returned. The memcg oom-killer is only invoked on page faults. However
>> in a separate effort I do plan to converge the behavior, long
>> discussion at <https://patchwork.kernel.org/patch/9988063/>.
>
> Correct me if I'm misinterpreting you, but your rationale in there
> appears to be along the lines of "userland applications might not
> be ready to handle -ENOMEM gracefully, so let's hit them with
> kill -9 instead - that will be handled properly, 'cuz M4G1C!!1!!!!"
>

Nah, the motivation is something like: In the memory overcommitted
system (or memcg) where jobs of different priorities are running, it
is preferable to kill a low priority job than to return an ENOMEM to
high priority job.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
