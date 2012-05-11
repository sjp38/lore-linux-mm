Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 282948D0047
	for <linux-mm@kvack.org>; Fri, 11 May 2012 15:19:27 -0400 (EDT)
Received: by bkvi18 with SMTP id i18so2857514bkv.27
        for <linux-mm@kvack.org>; Fri, 11 May 2012 12:19:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA9BE10.1030007@kernel.org>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
 <4FA8CF5E.1070202@kernel.org> <CANfBPZ-d-0FqY8Gruv+KDNoL3+FoQ68JEnxya5PydhY80x8yhA@mail.gmail.com>
 <4FA9BE10.1030007@kernel.org>
From: "S, Venkatraman" <svenkatr@ti.com>
Date: Sat, 12 May 2012 00:48:57 +0530
Message-ID: <CANfBPZ9jHfX6tyrOx=9E+L+Z0JzXMqjMYK++Q53C4TJFSujoGg@mail.gmail.com>
Subject: Re: [PATCHv2 00/16] [FS, MM, block, MMC]: eMMC High Priority
 Interrupt Feature
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Wed, May 9, 2012 at 6:15 AM, Minchan Kim <minchan@kernel.org> wrote:
> On 05/09/2012 01:31 AM, S, Venkatraman wrote:
>
>> On Tue, May 8, 2012 at 1:16 PM, Minchan Kim <minchan@kernel.org> wrote:
>>> On 05/03/2012 11:22 PM, Venkatraman S wrote:
>>>
>>>> Standard eMMC (Embedded MultiMedia Card) specification expects to exec=
ute
>>>> one request at a time. If some requests are more important than others=
, they
>>>> can't be aborted while the flash procedure is in progress.
>>>>
>>>> New versions of the eMMC standard (4.41 and above) specfies a feature
>>>> called High Priority Interrupt (HPI). This enables an ongoing transact=
ion
>>>> to be aborted using a special command (HPI command) so that the card i=
s ready
>>>> to receive new commands immediately. Then the new request can be submi=
tted
>>>> to the card, and optionally the interrupted command can be resumed aga=
in.
>>>>
>>>> Some restrictions exist on when and how the command can be used. For e=
xample,
>>>> only write and write-like commands (ERASE) can be preempted, and the u=
rgent
>>>> request must be a read.
>>>>
>>>> In order to support this in software,
>>>> a) At the top level, some policy decisions have to be made on what is
>>>> worth preempting for.
>>>> =A0 =A0 =A0 This implementation uses the demand paging requests and sw=
ap
>>>> read requests as potential reads worth preempting an ongoing long writ=
e.
>>>> =A0 =A0 =A0 This is expected to provide improved responsiveness for sm=
arphones
>>>> with multitasking capabilities - example would be launch a email appli=
cation
>>>> while a video capture session (which causes long writes) is ongoing.
>>>
>>>
>>> Do you have a number to prove it's really big effective?
>>
>> What type of benchmarks would be appropriate to post ?
>> As you know, the response time of a card would vary depending on
>> whether the flash device
>> has enough empty blocks to write into and doesn't have to resort to GC d=
uring
>> write requests.
>> Macro benchmarks like iozone etc would be inappropriate here, as they wo=
n't show
>> the latency effects of individual write requests hung up doing page
>> reclaim, which happens
>> once in a while.
>
>
> We don't have such special benchmark so you need time to think how to pro=
ve it.
> IMHO, you can use run-many-x-apps.sh which checks elapsed time to activat=
e programs
> by posting by Wu long time ago.
>
> http://www.spinics.net/lists/linux-mm/msg09653.html
>
> Of course, your eMMC is used above 80~90% for triggering GC stress and
> your memory should be used up by dirty pages to happen reclaim.
>
>
>>>
>>> What I have a concern is when we got low memory situation.
>>> Then, writing speed for page reclaim is important for response.
>>> If we allow read preempt write and write is delay, it means read path t=
akes longer time to
>>> get a empty buffer pages in reclaim. In such case, it couldn't be good.
>>>
>>
>> I agree. But when writes are delayed anyway as it exceeds
>> hpi_time_threshold (the window
>> available for invoking HPI), it means that the device is in GC mode
>> and either read or write
>> could be equally delayed. =A0Note that even in case of interrupting a
>> write, a single block write
>> (which usually is too short to be interrupted, as designed) is
>> sufficient for doing a page reclaim,
>> and further write requests (including multiblock) would not be subject
>> to HPI, as they will
>> complete within the average time.
>
>
> My point is that it would be better for read to not preempt write-for-pag=
e_reclaim.
> And we can identify it by PG_reclaim. You can get the idea.
>
> Anyway, HPI is only feature of a device of many storages and you are requ=
iring modification
> of generic layers although it's not big. So for getting justification and=
 attracting many
> core guys(MM,FS,BLOCK), you should provide data at least.
>
Hi Kim,
 Apologies for a delayed response. I am studying your suggestions and
will get back with
some changes and also some profiling data.
Regards,
Venkat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
