Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 44D276B00E7
	for <linux-mm@kvack.org>; Tue,  8 May 2012 12:31:30 -0400 (EDT)
Received: by bkcji2 with SMTP id ji2so7422406bkc.33
        for <linux-mm@kvack.org>; Tue, 08 May 2012 09:31:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA8CF5E.1070202@kernel.org>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com> <4FA8CF5E.1070202@kernel.org>
From: "S, Venkatraman" <svenkatr@ti.com>
Date: Tue, 8 May 2012 22:01:06 +0530
Message-ID: <CANfBPZ-d-0FqY8Gruv+KDNoL3+FoQ68JEnxya5PydhY80x8yhA@mail.gmail.com>
Subject: Re: [PATCHv2 00/16] [FS, MM, block, MMC]: eMMC High Priority
 Interrupt Feature
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Tue, May 8, 2012 at 1:16 PM, Minchan Kim <minchan@kernel.org> wrote:
> On 05/03/2012 11:22 PM, Venkatraman S wrote:
>
>> Standard eMMC (Embedded MultiMedia Card) specification expects to execut=
e
>> one request at a time. If some requests are more important than others, =
they
>> can't be aborted while the flash procedure is in progress.
>>
>> New versions of the eMMC standard (4.41 and above) specfies a feature
>> called High Priority Interrupt (HPI). This enables an ongoing transactio=
n
>> to be aborted using a special command (HPI command) so that the card is =
ready
>> to receive new commands immediately. Then the new request can be submitt=
ed
>> to the card, and optionally the interrupted command can be resumed again=
.
>>
>> Some restrictions exist on when and how the command can be used. For exa=
mple,
>> only write and write-like commands (ERASE) can be preempted, and the urg=
ent
>> request must be a read.
>>
>> In order to support this in software,
>> a) At the top level, some policy decisions have to be made on what is
>> worth preempting for.
>> =A0 =A0 =A0 This implementation uses the demand paging requests and swap
>> read requests as potential reads worth preempting an ongoing long write.
>> =A0 =A0 =A0 This is expected to provide improved responsiveness for smar=
phones
>> with multitasking capabilities - example would be launch a email applica=
tion
>> while a video capture session (which causes long writes) is ongoing.
>
>
> Do you have a number to prove it's really big effective?

What type of benchmarks would be appropriate to post ?
As you know, the response time of a card would vary depending on
whether the flash device
has enough empty blocks to write into and doesn't have to resort to GC duri=
ng
write requests.
Macro benchmarks like iozone etc would be inappropriate here, as they won't=
 show
the latency effects of individual write requests hung up doing page
reclaim, which happens
once in a while.

>
> What I have a concern is when we got low memory situation.
> Then, writing speed for page reclaim is important for response.
> If we allow read preempt write and write is delay, it means read path tak=
es longer time to
> get a empty buffer pages in reclaim. In such case, it couldn't be good.
>

I agree. But when writes are delayed anyway as it exceeds
hpi_time_threshold (the window
available for invoking HPI), it means that the device is in GC mode
and either read or write
could be equally delayed.  Note that even in case of interrupting a
write, a single block write
(which usually is too short to be interrupted, as designed) is
sufficient for doing a page reclaim,
and further write requests (including multiblock) would not be subject
to HPI, as they will
complete within the average time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
