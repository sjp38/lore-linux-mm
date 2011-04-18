Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 73BC6900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 03:09:01 -0400 (EDT)
Date: Mon, 18 Apr 2011 12:38:40 +0530
From: Raghavendra D Prabhu <rprabhu@wnohang.net>
Subject: Re: [TOME] Re: [PATCH 1/1] Add check for dirty_writeback_interval in
 bdi_wakeup_thread_delayed
Message-ID: <20110418070840.GB5143@Xye>
References: <20110417162308.GA1208@Xye>
 <20110418000204.GQ21395@dastard>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zCKi3GIZzVBPywwA"
Content-Disposition: inline
In-Reply-To: <20110418000204.GQ21395@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, Artem Bityutskiy <Artem.Bityutskiy@nokia.com>, Jens Axboe <jaxboe@fusionio.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org


--zCKi3GIZzVBPywwA
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline

* On Mon, Apr 18, 2011 at 10:02:04AM +1000, Dave Chinner <david@fromorbit.com> wrote:
>On Sun, Apr 17, 2011 at 09:53:08PM +0530, Raghavendra D Prabhu wrote:
>> In the function bdi_wakeup_thread_delayed, no checks are performed on
>> dirty_writeback_interval unlike other places and timeout is being set to
>> zero as result, thus defeating the purpose. So, I have changed it to be
>> passed default value of interval which is 500 centiseconds, when it is
>> set to zero.
>> I have also verified this and tested it.

>> Signed-off-by: Raghavendra D Prabhu <rprabhu@wnohang.net>
>> ---
>>  mm/backing-dev.c |    5 ++++-
>>  1 files changed, 4 insertions(+), 1 deletions(-)

>> diff --git a/mm/backing-dev.c b/mm/backing-dev.c
>> index befc875..d06533c 100644
>> --- a/mm/backing-dev.c
>> +++ b/mm/backing-dev.c
>> @@ -336,7 +336,10 @@ void bdi_wakeup_thread_delayed(struct backing_dev_info *bdi)
>>  {
>>  	unsigned long timeout;
>> -	timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
>> +	if (dirty_writeback_interval)
>> +		timeout = msecs_to_jiffies(dirty_writeback_interval * 10);
>> +	else
>> +		timeout = msecs_to_jiffies(5000);
>>  	mod_timer(&bdi->wb.wakeup_timer, jiffies + timeout);
>>  }
>
>Isn't the problem that the sysctl handler does not have a min/max
>valid value set? I.e. to prevent invalid values from being set in
>the first place?
>
>Cheers,
>
>Dave.
0 is a valid value for dirty_writeback_interval which according to the
definition/documentation is disabled when set to 0. In other places, a constraint
check is done on that value except here.

--zCKi3GIZzVBPywwA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNq+N4AAoJEKYW3KHXK+l3APQIAJ/rUNH9Xj3aqEoQETElAV/D
xb/Uj7klbjAlRXFPHh+1gn09NdUorsBLn+pxqwS1VAkq1Od/SWyN3ElNxS0baU17
joa8dhU4eLiTJmojowiFsx8nl8+CU4F4wuZHdkaGFRSMrEuLlxapSH2ehYdfNJnc
oHgBD1lRFRuD4uwzsRqwngED4v0Oz0oUO8z4kP4Pjmix8rzgVYxKyioU/cJfFsf1
QSWZU/mqMrjs8mb7M5yUWF8jVrEuu+0LuEJ1F70vr6K8w/9eQvE9AnFlgRfZiqus
kNkC42pVB/IoltrVvSmxzrxyNmliCzbGyWb1C+P1x40pSrGLkDRy4sMl0L+wS1I=
=mPbO
-----END PGP SIGNATURE-----

--zCKi3GIZzVBPywwA--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
