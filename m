Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id A4F7D6B026F
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 23:48:12 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id t184so6984513vka.13
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 20:48:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q13sor4210648uae.77.2017.11.20.20.48.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 20:48:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171120083548.stupram6kpi5iu7i@dhcp22.suse.cz>
References: <20171101053244.5218-1-slandden@gmail.com> <20171103063544.13383-1-slandden@gmail.com>
 <20171103090915.uuaqo56phdbt6gnf@dhcp22.suse.cz> <CA+49okqZ8CME0EN1xS_cCTc5Q-fGRreg0makhzNNuRpGs3mjfw@mail.gmail.com>
 <20171120083548.stupram6kpi5iu7i@dhcp22.suse.cz>
From: Shawn Landden <slandden@gmail.com>
Date: Mon, 20 Nov 2017 20:48:10 -0800
Message-ID: <CA+49okomOyRy1Av_cAv38xJuX+TstVe6jWWuitmr3XCBx8mU_g@mail.gmail.com>
Subject: Re: [RFC v2] prctl: prctl(PR_SET_IDLE, PR_IDLE_MODE_KILLME), for
 stateless idle loops
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Mon, Nov 20, 2017 at 12:35 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 17-11-17 20:45:03, Shawn Landden wrote:
>> On Fri, Nov 3, 2017 at 2:09 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>
>> > On Thu 02-11-17 23:35:44, Shawn Landden wrote:
>> > > It is common for services to be stateless around their main event loop.
>> > > If a process sets PR_SET_IDLE to PR_IDLE_MODE_KILLME then it
>> > > signals to the kernel that epoll_wait() and friends may not complete,
>> > > and the kernel may send SIGKILL if resources get tight.
>> > >
>> > > See my systemd patch: https://github.com/shawnl/systemd/tree/prctl
>> > >
>> > > Android uses this memory model for all programs, and having it in the
>> > > kernel will enable integration with the page cache (not in this
>> > > series).
>> > >
>> > > 16 bytes per process is kinda spendy, but I want to keep
>> > > lru behavior, which mem_score_adj does not allow. When a supervisor,
>> > > like Android's user input is keeping track this can be done in
>> > user-space.
>> > > It could be pulled out of task_struct if an cross-indexing additional
>> > > red-black tree is added to support pid-based lookup.
>> >
>> > This is still an abuse and the patch is wrong. We really do have an API
>> > to use I fail to see why you do not use it.
>> >
>> When I looked at wait_queue_head_t it was 20 byes.
>
> I do not understand. What I meant to say is that we do have a proper
> user api to hint OOM killer decisions.
This is a FIFO queue, rather than a heuristic, which is all you get
with the current API.
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
