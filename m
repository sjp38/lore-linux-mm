Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A7FE4900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 05:16:24 -0400 (EDT)
Date: Mon, 18 Apr 2011 14:46:09 +0530
From: Raghavendra D Prabhu <rprabhu@wnohang.net>
Subject: Re: [PATCH 1/1] Add check for dirty_writeback_interval in
 bdi_wakeup_thread_delayed
Message-ID: <20110418091609.GC5143@Xye>
References: <20110417162308.GA1208@Xye>
 <1303111152.2815.29.camel@localhost>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ylS2wUBXLOxYXZFQ"
Content-Disposition: inline
In-Reply-To: <1303111152.2815.29.camel@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
Cc: linux-mm@kvack.org, Jens Axboe <jaxboe@fusionio.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org


--ylS2wUBXLOxYXZFQ
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

* On Mon, Apr 18, 2011 at 10:19:12AM +0300, Artem Bityutskiy <Artem.Bityutskiy@nokia.com> wrote:
>On Sun, 2011-04-17 at 21:53 +0530, Raghavendra D Prabhu wrote:
>> In the function bdi_wakeup_thread_delayed, no checks are performed on
>> dirty_writeback_interval unlike other places and timeout is being set to
>> zero as result, thus defeating the purpose. So, I have changed it to be
>> passed default value of interval which is 500 centiseconds, when it is
>> set to zero.
>> I have also verified this and tested it.

>> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>
>If  dirty_writeback_interval then the periodic write-back has to be
>disabled. Which means we should rather do something like this:
>
>diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>index 0d9a036..f38722c 100644
>--- a/mm/backing-dev.c
>+++ b/mm/backing-dev.c
>@@ -334,10 +334,12 @@ static void wakeup_timer_fn(unsigned long data)
>  */
> void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
> {
>-       unsigned long timeout;
>+       if (dirty_writeback_interval) {
>+               unsigned long timeout;
>
>-       timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
>-       mod_timer(&bdi->wb.wakeup_timer, jiffies + timeout);
>+               timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
>+               mod_timer(&bdi->wb.wakeup_timer, jiffies + timeout);
>+       }
> }
>
>I do not see why you use 500 centisecs instead - I think this is wrong.
>
>> ---
>>   mm/backing-dev.c |    5 ++++-
>>   1 files changed, 4 insertions(+), 1 deletions(-)

>> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>> index befc875..d06533c 100644
>> --- a/mm/backing-dev.c
>> +++ b/mm/backing-dev.c
>> @@ -336,7 +336,10 @@ void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
>>   {
>>   	unsigned long timeout;

>> -	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
>> +	if (dirty_writeback_interval)
>> +		timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
>> +	else
>> +		timeout = msecs_to_jiffies(5000);
>>   	mod_timer(&bdi->wb.wakeup_timer, jiffies + timeout);
>>   }
Hi,

I have set it to 500 centisecs as that is the default value of
dirty_writeback_interval. I used this logic for following reason: the
purpose for which dirty_writeback_interval is set to 0 is to disable
periodic writeback
(http://tomoyo.sourceforge.jp/cgi-bin/lxr/source/fs/fs-writeback.c#L818)
, whereas here (in bdi_wakeup_thread_delayed) it is being used for a
different purpose -- to delay the bdi wakeup in order to reduce context
switches for  dirty inode writeback.
Regarding the change you made: in
that case won't it end up disabling the timer altogether ? which
shouldn't happen given the original purpose of defining
dirty_writeback_interval to zero.

--ylS2wUBXLOxYXZFQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNrAFZAAoJEKYW3KHXK+l3tLgH/RPGsfKBlNVgnoIhVJe+0jl1
vTRHw7ImgHPYP6McG8W1CZnIAMeUUQArMjJI9qEgjcAb+DQO7R6OAYz73MguSzHc
FW8l4kAAJP7iWT0lBr/SFEygBDvE9VGdeZPu7Xykmz2pKW+iCEuMLkmLKjWOuAyO
FUoYMToBdc+zqZV1WMS5ms1gQq6QZyTiewQZb1pPi53D/ZqRbuyL7pQ1AUUdVeKK
yLDLQo4+vNYEEwITxf0nR3rxZYhHWVx0s1DIV2atjYBI2dDjtaUfdmdAHnG3EJ4N
uVNHqCT1A/bpsgaycT7L8lBni4NxBL7kE0UBcNrXzG6lqWfu9Lp5ak7h7Ar93Qo=
=x2dh
-----END PGP SIGNATURE-----

--ylS2wUBXLOxYXZFQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
