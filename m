Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C10BD6B0022
	for <linux-mm@kvack.org>; Tue,  3 May 2011 13:01:34 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p43H1T6h026051
	for <linux-mm@kvack.org>; Tue, 3 May 2011 10:01:30 -0700
Received: from yih10 (yih10.prod.google.com [10.243.66.202])
	by wpaz21.hot.corp.google.com with ESMTP id p43H1M1p007291
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 3 May 2011 10:01:28 -0700
Received: by yih10 with SMTP id 10so148535yih.11
        for <linux-mm@kvack.org>; Tue, 03 May 2011 10:01:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110503082550.GD18927@tiehlicka.suse.cz>
References: <20110425182849.ab708f12.kamezawa.hiroyu@jp.fujitsu.com>
	<20110429133313.GB306@tiehlicka.suse.cz>
	<20110501150410.75D2.A69D9226@jp.fujitsu.com>
	<20110503064945.GA18927@tiehlicka.suse.cz>
	<BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
	<20110503082550.GD18927@tiehlicka.suse.cz>
Date: Tue, 3 May 2011 10:01:27 -0700
Message-ID: <BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Tue, May 3, 2011 at 1:25 AM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 03-05-11 16:45:23, KOSAKI Motohiro wrote:
>> 2011/5/3 Michal Hocko <mhocko@suse.cz>:
>> > On Sun 01-05-11 15:06:02, KOSAKI Motohiro wrote:
>> >> > On Mon 25-04-11 18:28:49, KAMEZAWA Hiroyuki wrote:
>> >> > > There are two watermarks added per-memcg including "high_wmark" and "low_wmark".
>> >> > > The per-memcg kswapd is invoked when the memcg's memory usage(usage_in_bytes)
>> >> > > is higher than the low_wmark. Then the kswapd thread starts to reclaim pages
>> >> > > until the usage is lower than the high_wmark.
>> >> >
>> >> > I have mentioned this during Ying's patchsets already, but do we really
>> >> > want to have this confusing naming? High and low watermarks have
>> >> > opposite semantic for zones.
>> >>
>> >> Can you please clarify this? I feel it is not opposite semantics.
>> >
>> > In the global reclaim low watermark represents the point when we _start_
>> > background reclaim while high watermark is the _stopper_. Watermarks are
>> > based on the free memory while this proposal makes it based on the used
>> > memory.
>> > I understand that the result is same in the end but it is really
>> > confusing because you have to switch your mindset from free to used and
>> > from under the limit to above the limit.
>>
>> Ah, right. So, do you have an alternative idea?
>
> Why cannot we just keep the global reclaim semantic and make it free
> memory (hard_limit - usage_in_bytes) based with low limit as the trigger
> for reclaiming?

Hmm, that was my initial implementation. But then I got comment to switch to
the current scheme which is based on the usage. The initial comment was that
using the "free" is confusing... :)

The current scheme is closer to the global bg reclaim which the low is
triggering reclaim
and high is stopping reclaim. And we can only use the "usage" to keep
the same API.

--Ying

>
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
