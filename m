Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A1F256B0008
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 05:29:13 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x20so4484062wmc.0
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 02:29:13 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s5sor2483978edj.24.2018.04.04.02.29.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Apr 2018 02:29:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180404062340.GD6312@dhcp22.suse.cz>
References: <1522320104-6573-1-git-send-email-zhaoyang.huang@spreadtrum.com>
 <20180330102038.2378925b@gandalf.local.home> <20180403110612.GM5501@dhcp22.suse.cz>
 <20180403075158.0c0a2795@gandalf.local.home> <20180403121614.GV5501@dhcp22.suse.cz>
 <20180403082348.28cd3c1c@gandalf.local.home> <20180403123514.GX5501@dhcp22.suse.cz>
 <20180403093245.43e7e77c@gandalf.local.home> <20180403135607.GC5501@dhcp22.suse.cz>
 <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com> <20180404062340.GD6312@dhcp22.suse.cz>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Wed, 4 Apr 2018 17:29:11 +0800
Message-ID: <CAGWkznGht+9dh_37QNC+qkrhOF1_AuJVh6vVcG-50=oOVX6ecw@mail.gmail.com>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, linux-kernel@vger.kernel.org, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, Joel Fernandes <joelaf@google.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

On Wed, Apr 4, 2018 at 2:23 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 04-04-18 10:58:39, Zhaoyang Huang wrote:
>> On Tue, Apr 3, 2018 at 9:56 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Tue 03-04-18 09:32:45, Steven Rostedt wrote:
>> >> On Tue, 3 Apr 2018 14:35:14 +0200
>> >> Michal Hocko <mhocko@kernel.org> wrote:
>> > [...]
>> >> > Being clever is OK if it doesn't add a tricky code. And relying on
>> >> > si_mem_available is definitely tricky and obscure.
>> >>
>> >> Can we get the mm subsystem to provide a better method to know if an
>> >> allocation will possibly succeed or not before trying it? It doesn't
>> >> have to be free of races. Just "if I allocate this many pages right
>> >> now, will it work?" If that changes from the time it asks to the time
>> >> it allocates, that's fine. I'm not trying to prevent OOM to never
>> >> trigger. I just don't want to to trigger consistently.
>> >
>> > How do you do that without an actuall allocation request? And more
>> > fundamentally, what if your _particular_ request is just fine but it
>> > will get us so close to the OOM edge that the next legit allocation
>> > request simply goes OOM? There is simply no sane interface I can think
>> > of that would satisfy a safe/sensible "will it cause OOM" semantic.
>> >
>> The point is the app which try to allocate the size over the line will escape
>> the OOM and let other innocent to be sacrificed. However, the one which you
>> mentioned above will be possibly selected by OOM that triggered by consequnce
>> failed allocation.
>
> If you are afraid of that then you can have a look at {set,clear}_current_oom_origin()
> which will automatically select the current process as an oom victim and
> kill it.
But we can not call the function on behalf of the current process
which maybe don't want
to be killed for memory reason. It is proper to tell it ENOMEM and let
it make further decision.
> --
> Michal Hocko
> SUSE Labs
