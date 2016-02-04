Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id CC9124403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 06:18:35 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id u9so39470801ykd.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 03:18:35 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id u205si3442603ywb.22.2016.02.04.03.18.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 03:18:34 -0800 (PST)
Received: by mail-yk0-x22d.google.com with SMTP id u9so39470635ykd.1
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 03:18:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160203161910.GA10440@cmpxchg.org>
References: <001a114b360c7fdb9b052adb91d6@google.com>
	<20160203161910.GA10440@cmpxchg.org>
Date: Thu, 4 Feb 2016 12:18:34 +0100
Message-ID: <CA+_MTtwE5NYV2SURj3j1X-RYDL=a0CHZ_UnEi9Giofy9i-JtDA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmpressure: make vmpressure_window a tunable.
From: Martijn Coenen <maco@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Anton Vorontsov <anton@enomsg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>

On Wed, Feb 3, 2016 at 5:19 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>
> If the machine is just cleaning up use-once cache, frequent events
> make no sense. And if the machine is struggling, the notifications
> better be in time.
>
> That's hardly a tunable. It's a factor that needs constant dynamic
> adjustment depending on VM state. The same state this mechanism is
> supposed to report. If we can't get this right, how will userspace?

I tend to agree for the "machine is struggling" case; notifications
had better be in time so userspace can take the right action. But one
prime use for the "low" notification level is maintaining cache
levels, and in that scenario I can imagine the rate at which you want
to receive notifications can be very application-dependent.

For a bit more context, we'd like to use these events for implementing
a user-space low memory killer in Android (and get rid of the one in
staging). What we've found so far is that the "medium" level doesn't
trigger as often as we'd like: by the time we get it the page cache
may have been drained to such low levels that the device will have to
fetch pretty much everything from flash on the next app launch. I
think that's just the way the medium level was defined. The "low"
level on the other hand fires events almost constantly, and we spend a
lot of time waking up, looking at memory state, and then doing
nothing. My first idea was to make the window size dependent on
machine size; but my worry is that this will be somewhat specific to
our use of these pressure events. Maybe on Android devices it's okay
to generate events for every say 1% of main memory being scanned for
reclaim, but how do we know this is a decent value for other uses?

My other concern with changing the window size directly is that there
may be existing users of the API which would suddenly get different
behavior.

One other way to maintain the cache levels may be to not actually look
at vm pressure events, but to just look at the state of the system for
every X bytes allocated.

>
>
> A better approach here would be to 1) find a minimum window size that
> makes us confident that there are no false positives - this is likely
> to be based on machine size, maybe the low watermark? - and 2) limit
> reporting of lower levels, so you're not flooded with ALLGOOD! events.
>
> VMPRESSURE_CRITICAL: report every vmpressure_win
> VMPRESSURE_MEDIUM: report every vmpressure_win*2
> VMPRESSURE_LOW: report every vmpressure_win*4
>
> Pick your favorite scaling factor here.

I like this idea; I'm happy to come up with a window size and scaling
factors that we think works well, and get your feedback on that. My
only concern again would be that what works well for us may not work
well for others.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
