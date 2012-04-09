Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id E7B566B0044
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 08:37:16 -0400 (EDT)
Received: by iajr24 with SMTP id r24so7911519iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 05:37:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120409122950.GA21833@lizard>
References: <20120408233550.GA3791@panacea>
	<20120408233802.GA4839@panacea>
	<1333960831.3943.4.camel@jaguar>
	<20120409122950.GA21833@lizard>
Date: Mon, 9 Apr 2012 15:37:16 +0300
Message-ID: <CAOJsxLEZ6ZHBTKnCBO0bpC0ci6E2F4LZYiQkrExUxWR2dQjqGw@mail.gmail.com>
Subject: Re: [PATCH 1/3] vmevent: Should not grab mutex in the atomic context
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org

> On Mon, Apr 09, 2012 at 11:40:31AM +0300, Pekka Enberg wrote:
>> On Mon, 2012-04-09 at 03:38 +0400, Anton Vorontsov wrote:
>> > vmevent grabs a mutex in the atomic context, and so this pops up:
>> >
>> > BUG: sleeping function called from invalid context at kernel/mutex.c:271
>> > in_atomic(): 1, irqs_disabled(): 0, pid: 0, name: swapper/0
> [...]
>> > This patch fixes the issue by removing the mutex and making the logic
>> > lock-free.
>> >
>> > Signed-off-by: Anton Vorontsov <anton.vorontsov@linaro.org>
>>
>> What guarantees that there's only one thread writing to struct
>> vmevent_attr::value in vmevent_sample() now that the mutex is gone?

On Mon, Apr 9, 2012 at 3:29 PM, Anton Vorontsov
<anton.vorontsov@linaro.org> wrote:
> Well, it is called from the timer function, which has the same guaranties
> as an interrupt handler: it can have only one execution thread (unlike
> bare softirq handler), so we don't need to worry about racing w/
> ourselves?
>
> If you're concerned about several instances of timers accessing the
> same vmevent_watch, I don't really see how it is possible, as we
> allocate vmevent_watch together w/ the timer instance in vmevent_fd(),
> so there is always one timer per vmevent_watch.

Makes sense. A big fat comment on top of vmevent_sample() explaining
all this would be helpful... ;-)

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
