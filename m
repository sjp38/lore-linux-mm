Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 6CC366B0071
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 23:45:43 -0400 (EDT)
Received: by qabg27 with SMTP id g27so591355qab.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 20:45:42 -0700 (PDT)
Message-ID: <4FD17564.9060209@gmail.com>
Date: Thu, 07 Jun 2012 23:45:40 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Some vmevent fixes...
References: <CAOJsxLHQcDZSHJZg+zbptqmT9YY0VTkPd+gG_zgMzs+HaV_cyA@mail.gmail.com> <CAHGf_=q1nbu=3cnfJ4qXwmngMPB-539kg-DFN2FJGig8+dRaNw@mail.gmail.com> <CAOJsxLFAavdDbiLnYRwe+QiuEHSD62+Sz6LJTk+c3J9gnLVQ_w@mail.gmail.com> <CAHGf_=pSLfAue6AR5gi5RQ7xvgTxpZckA=Ja1fO1AkoO1o_DeA@mail.gmail.com> <CAOJsxLG1+zhOKgi2Rg1eSoXSCU8QGvHVED_EefOOLP-6JbMDkg@mail.gmail.com> <20120601122118.GA6128@lizard> <alpine.LFD.2.02.1206032125320.1943@tux.localdomain> <4FCC7592.9030403@kernel.org> <20120604113811.GA4291@lizard> <4FCD14F1.1030105@gmail.com> <20120604223951.GA20591@lizard>
In-Reply-To: <20120604223951.GA20591@lizard>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <cbouatmailru@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(6/4/12 6:39 PM), Anton Vorontsov wrote:
> On Mon, Jun 04, 2012 at 04:05:05PM -0400, KOSAKI Motohiro wrote:
> [...]
>>> Yes, nobody throws Android lowmemory killer away. And recently I fixed
>>> a bunch of issues in its tasks traversing and killing code. Now it's
>>> just time to "fix" statistics gathering and interpretation issues,
>>> and I see vmevent as a good way to do just that, and then we
>>> can either turn Android lowmemory killer driver to use the vmevent
>>> in-kernel API (so it will become just a "glue" between notifications
>>> and killing functions), or use userland daemon.
>>
>> Huh? No? android lowmem killer is a "killer". it doesn't make any notification,
>> it only kill memory hogging process. I don't think we can merge them.
>
> KOSAKI, you don't read what I write. I didn't ever say that low memory
> killer makes any notifications, that's not what I was saying. I said
> that once we'll have a good "low memory" notification mechanism (e.g.
> vmevent), Android low memory killer would just use this mechanism. Be
> it userland notifications or in-kernel, doesn't matter much.

I don't disagree this. But this was not my point. I have to note why
current android killer is NOT notification.

In fact, notification is a mere notification. There is no guarantee to
success to kill. There are various reason to fail to kill. e.g. 1) Any
shrinking activity need more memory. (that's the reason why now we only
have memcg oom notification) 2) userland memory returning activity is not
atomic nor fast. kernel might find another memory shortage before finishing
memory returning. 3) system thrashing may bring userland process stucking
4) ... and userland bugs.

So, big design choice here. 1) vmevent is a just notification. it can't guarantee
to prevent oom. or 2) to implement some trick (e.g. reserved memory for vmevent
processes, kernel activity blocking until finish memory returing, etc)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
