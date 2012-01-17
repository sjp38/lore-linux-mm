Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 00C986B00D7
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 11:36:10 -0500 (EST)
Message-ID: <4F15A34F.40808@redhat.com>
Date: Tue, 17 Jan 2012 11:35:27 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/3] /dev/low_mem_notify
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326788038-29141-2-git-send-email-minchan@kernel.org> <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
In-Reply-To: <CAOJsxLHGYmVNk7D9NyhRuqQDwquDuA7LtUtp-1huSn5F-GvtAg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On 01/17/2012 04:27 AM, Pekka Enberg wrote:
> On Tue, Jan 17, 2012 at 10:13 AM, Minchan Kim<minchan@kernel.org>  wrote:
>> +static unsigned int low_mem_notify_poll(struct file *file, poll_table *wait)
>> +{
>> +        unsigned int ret = 0;
>> +
>> +        poll_wait(file,&low_mem_wait, wait);
>> +
>> +        if (atomic_read(&nr_low_mem) != 0) {
>> +                ret = POLLIN;
>> +                atomic_set(&nr_low_mem, 0);
>> +        }
>> +
>> +        return ret;
>> +}
>
> Doesn't this mean that only one application will receive the notification?

One at a time, which could be a good thing since the last
thing we want to do when the system is under memory
pressure is create a thundering herd.

OTOH, we do need to ensure that programs take turns getting
the memory pressure notification.  I do not know whether
poll_wait automatically takes care of that...

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
