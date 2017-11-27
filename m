Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 48BD56B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 04:08:52 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id t1so17091665ite.5
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 01:08:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w143sor6725158ita.54.2017.11.27.01.08.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 01:08:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171127090414.ayp4s5bmizhetmis@dhcp22.suse.cz>
References: <CALOAHbAgh0egRJk7ME_YBzon9ED9jL94vi4aw19bbpZVuUA+aQ@mail.gmail.com>
 <201711261938.BCD34864.QLVFOSJFHOtOFM@I-love.SAKURA.ne.jp>
 <CALOAHbCVoy=5U0_7wg9nZR+sa8buG41BAE4KDnr2Fb4tYqhaXw@mail.gmail.com>
 <20171127082112.b7elnzy24qiqze46@dhcp22.suse.cz> <CALOAHbDZ_rxHYyb8K01Ecd7FBRXO4Bp5_BsPYXAvAOYXMw34Rw@mail.gmail.com>
 <CALOAHbCH1JG=BmpgOwq+7W3wXuHqhXkisj+p-rPXeivTdXa7-w@mail.gmail.com>
 <20171127083707.wsyw5mnhi6juiknh@dhcp22.suse.cz> <CALOAHbD6txwh3dUdv1bSju2PMHyUE1kW4Qt7gyAxpwToie54Rw@mail.gmail.com>
 <20171127085220.kf6gyksfy276mkk6@dhcp22.suse.cz> <CALOAHbD+ab=1=9w=1ikGYhft-s3BU5Ro=ugCDS2GaJ6b90JQgA@mail.gmail.com>
 <20171127090414.ayp4s5bmizhetmis@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 27 Nov 2017 17:08:50 +0800
Message-ID: <CALOAHbDVu=MSJs2sF=fjQgFjsytbpKyD1RuyX4v9F9o1Gm9LKg@mail.gmail.com>
Subject: Re: [PATCH] mm: print a warning once the vm dirtiness settings is illogical
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Linux MM <linux-mm@kvack.org>, fcicq@fcicq.net

2017-11-27 17:04 GMT+08:00 Michal Hocko <mhocko@suse.com>:
> On Mon 27-11-17 16:54:39, Yafang Shao wrote:
>> 2017-11-27 16:52 GMT+08:00 Michal Hocko <mhocko@suse.com>:
>> > On Mon 27-11-17 16:49:34, Yafang Shao wrote:
>> >> 2017-11-27 16:37 GMT+08:00 Michal Hocko <mhocko@suse.com>:
>> >> > On Mon 27-11-17 16:32:42, Yafang Shao wrote:
>> >> >> 2017-11-27 16:29 GMT+08:00 Yafang Shao <laoar.shao@gmail.com>:
>> > [...]
>> >> >> > It will help us to find the error if we don't change these values like this.
>> >> >> >
>> >> >>
>> >> >> And actually it help us find another issue that when availble_memroy
>> >> >> is too small, the thresh and bg_thresh will be 0, that's absolutely
>> >> >> wrong.
>> >> >
>> >> > Why is it wrong?
>> >> > --
>> >>
>> >> For example, the writeback threads will be wakeup on every write.
>> >> I don't think it is meaningful to wakeup the writeback thread when the
>> >> dirty pages is very low.
>> >
>> > Well, this is a corner situation when we are out of memory basically.
>> > Doing a wake up on the flusher is the least of your problem. So _why_
>> > exactly is this is problem?
>> > --
>>
>> Are you _sure_ this is the least of the problem on this corner situation ?
>
> I am not _sure_ and that is why I'm _asking_ _you_ and you seem to come
> up with reasons which don't make me really convinced.
>
> If we wake up flusher which have nothing to do they will simply back
> off. That is what have to do anyway because dirty data can be truncated
> at any time, right?
>

Under this condition it is better not to wakeup the bdi writeback.
That's why I return the min value 100 to avoid doing this.
Maybe 100 is not enough. It should be geater IMHO.

>> Why wakeup the bdi writeback ? why not just kill the program and flush
>> the date into the Disk when we do oom ?
>
> I really do not see how this is related to the discussion here. OOM
> killer doesn't flush anything. It kills a task and that is it. Moreover
> we do not flush any data from direct context at all. We simply rely on
> flushers to do the work.
> --
That's my fault.
Just killing the program is enough.

Thanks
Yafang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
