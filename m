Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 796FB6B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 13:20:54 -0400 (EDT)
Received: by vwm42 with SMTP id 42so3582225vwm.14
        for <linux-mm@kvack.org>; Fri, 19 Aug 2011 10:20:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110819142433.GA15401@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
	<20110818094824.GA25752@localhost>
	<1313669702.6607.24.camel@sauron>
	<20110818131343.GA17473@localhost>
	<CAFPAmTShNRykOEbUfRan_2uAAbBoRHE0RhOh4DrbWKq7a4-Z9Q@mail.gmail.com>
	<20110819023406.GA12732@localhost>
	<CAFPAmTSzYg5n150_ykv-Vvc4QVbz14Oxn_Mm+EqxzbUL3c39tg@mail.gmail.com>
	<20110819052839.GB28266@localhost>
	<20110819060803.GA7887@localhost>
	<CAFPAmTQU_rHwFi8KRdTU6BjMFhvq0HKNfufQ762i1KQEHVPk8g@mail.gmail.com>
	<20110819142433.GA15401@localhost>
Date: Fri, 19 Aug 2011 22:50:52 +0530
Message-ID: <CAFPAmTQ2_JdwoLPFWQJze2Zd0QNHwMLWEmktGTQY_jHBAcixKg@mail.gmail.com>
Subject: Re: [PATCH] writeback: Per-block device bdi->dirty_writeback_interval
 and bdi->dirty_expire_interval.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

Hi Wu,

You're right, the BDI threads should be woken up reliably by the
balance_dirty_pages() and balance_dirty_pages()
needs to be called from all code that is responsible for dirtying the pages=
.
Sorry, I was not too aware of the balance_dirty_pages() functionality
and the way it was being called in entirety or I would
have spotted this.

Thanks for adding the dirty_background_time into your
over_bground_thresh() formula.

Now that you seem to have included the time into the threshold, I can
relate to your patch better
as a solution for the problems I earlier mentioned.

Thanks again,
Kautuk.


On Fri, Aug 19, 2011 at 7:54 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> Hi Kautuk,
>
> On Fri, Aug 19, 2011 at 03:00:30PM +0800, Kautuk Consul wrote:
>> Hi Wu,
>>
>> Yes. I think I do understand your approach.
>>
>> Your aim is to always retain the per BDI timeout value.
>>
>> You want to check for threshholds by mathematically adjusting the
>> background time too
>> into your over_bground_thresh() formula so that your understanding
>> holds true always and also
>> affects the page dirtying scenario I mentioned.
>> This definitely helps and refines this scenario in terms of flushing
>> out of the dirty pages.
>
> Thanks.
>
>> Doubts:
>> i) =A0 Your entire implementation seems to be dependent on someone
>> calling balance_dirty_pages()
>> =A0 =A0 =A0directly or indirectly. This function will call the
>> bdi_start_background_writeback() which wakes
>> =A0 =A0 =A0up the flusher thread.
>> =A0 =A0 =A0What about those page dirtying code paths which might not cal=
l
>> balance_dirty_pages ?
>> =A0 =A0 =A0Those paths then depend on the BDI thread periodically writin=
g it
>> to disk and then we are again
>> =A0 =A0 =A0dependent on the writeback interval.
>> =A0 =A0 =A0Can we assume that the kernel will reliably call
>> balance_dirty_pages() whenever the pages
>> =A0 =A0 =A0are dirtied ? If that was true, then we would not need bdi
>> periodic writeback threads ever.
>
> Yes. The kernel need a way to limit the total number of dirty pages at
> any given time and to keep them under dirty_ratio/dirty_bytes.
>
> balance_dirty_pages() is such a central place to throttle the dirty
> pages. Whatever code path generating dirty pages are required to call
> into balance_dirty_pages_ratelimited_nr() which will in turn call
> balance_dirty_pages().
>
> So, the values specified by dirty_ratio/dirty_bytes will be executed
> effectively by balance_dirty_pages(). In contrast, the values
> specified by dirty_expire_centisecs is merely a parameter used by
> wb_writeback() to select the eligible inodes to do writeout. The 30s
> dirty expire time is never a guarantee that all inodes/pages dirtied
> before 30s will be timely written to disk. It's better interpreted in
> the opposite way: when under the dirty_background_ratio threshold and
> hence background writeout does not kick in, dirty inodes younger than
> 30s won't be written to disk by the flusher.
>
>> ii) =A0Even after your rigorous checking, the bdi_writeback_thread()
>> will still do a schedule_timeout()
>> =A0 =A0 =A0with the global value. Will your current solution then handle
>> Artem's disk removal scenario ?
>> =A0 =A0 =A0Else, you start using your value in the schedule_timeout() ca=
ll
>> in the bdi_writeback_thread()
>> =A0 =A0 =A0function, which brings us back to the interval phenomenon I w=
as
>> talking about.
>
> wb_writeback() will keep running as long as over_bground_thresh().
>
> The flusher will keep writing as long as there are more works, since
> there is a
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!list_empty(&bdi->work_list))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> before the schedule_timeout() call.
>
> And the flusher thread will always be woke up timely from
> balance_dirty_pages().
>
> So schedule_timeout() won't block in the way at all.
>
>> Does this patch really help the user control exact time when the write
>> BIO is transferred from the
>> MM to the Block layer assuming balance_dirty_pages() is not called ?
>
> It would be a serious bug if balance_dirty_pages() is somehow not
> called. But note that balance_dirty_pages() is designed to be called
> on every N pages to reduce overheads.
>
> Thanks,
> Fengguang
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
