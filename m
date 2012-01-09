Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id CF9916B005C
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 02:26:04 -0500 (EST)
Message-ID: <4F0A9685.6060103@tao.ma>
Date: Mon, 09 Jan 2012 15:25:57 +0800
From: Tao Ma <tm@tao.ma>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do not drain pagevecs for mlock
References: <1325226961-4271-1-git-send-email-tm@tao.ma> <CAHGf_=qOGy3MQgiFyfeG82+gbDXTBT5KQjgR7JqMfQ7e7RSGpA@mail.gmail.com> <4EFD7AE3.8020403@tao.ma> <CAHGf_=pODc6fLGJAEZWzQtUd6fj6v=fV9n6UTwysqRR1SwY++A@mail.gmail.com> <4EFD8832.6010905@tao.ma> <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com>
In-Reply-To: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

Hi KOSAKI,
On 12/30/2011 06:07 PM, KOSAKI Motohiro wrote:
>>> Because your test program is too artificial. 20sec/100000times =
>>> 200usec. And your
>>> program repeat mlock and munlock the exact same address. so, yes, if
>>> lru_add_drain_all() is removed, it become near no-op. but it's
>>> worthless comparision.
>>> none of any practical program does such strange mlock usage.
>> yes, I should say it is artificial. But mlock did cause the problem in
>> our product system and perf shows that the mlock uses the system time
>> much more than others. That's the reason we created this program to test
>> whether mlock really sucks. And we compared the result with
>> rhel5(2.6.18) which runs much much faster.
>>
>> And from the commit log you described, we can remove lru_add_drain_all
>> safely here, so why add it? At least removing it makes mlock much faster
>> compared to the vanilla kernel.
> 
> If we remove it, we lose to a test way of mlock. "Memlocked" field of
> /proc/meminfo
> show inaccurate number very easily. So, if 200usec is no avoidable,
> I'll ack you.
> But I'm not convinced yet.
As you don't think removing lru_add_drain_all is appropriate, I have
created another patch set to resolve it. I add a new per cpu counter to
record the counter of all the pages in the pagevecs. So if the counter
is 0, don't drain the corresponding cpu. Does it make sense to you?

Thanks
Tao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
